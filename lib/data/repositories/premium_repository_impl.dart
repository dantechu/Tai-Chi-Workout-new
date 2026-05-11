import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/services/revenuecat_service.dart';
import '../../domain/entities/premium_status.dart';
import '../../domain/repositories/premium_repository.dart';
import '../datasources/premium_local_datasource.dart';
import '../models/premium_status_model.dart';

class PremiumRepositoryImpl implements PremiumRepository {
  final PremiumLocalDataSource localDataSource;
  final RevenueCatService revenueCatService;
  final StreamController<PremiumStatus> _premiumStatusController;

  PremiumRepositoryImpl({
    required this.localDataSource,
    required this.revenueCatService,
  }) : _premiumStatusController = StreamController<PremiumStatus>.broadcast() {
    _initializeCustomerInfoListener();
  }

  void _initializeCustomerInfoListener() {
    // Listen to customer info updates from RevenueCat
    // Note: The stream listener will be set up when needed
  }

  Future<void> _handleCustomerInfoUpdate(CustomerInfo customerInfo) async {
    final premiumStatus = _createPremiumStatusFromCustomerInfo(customerInfo);

    try {
      // Cache the status
      final premiumStatusModel = PremiumStatusModel.fromEntity(premiumStatus);
      await localDataSource.cachePremiumStatus(premiumStatusModel);

      // Store secure token if premium
      if (premiumStatus.isValidPremium && premiumStatus.transactionId != null) {
        await localDataSource.setSecurePremiumToken(premiumStatus.transactionId!);
      }

      _premiumStatusController.add(premiumStatus);
    } catch (e) {
      print('Error caching premium status: $e');
    }
  }

  PremiumStatus _createPremiumStatusFromCustomerInfo(CustomerInfo customerInfo) {
    final entitlement = customerInfo.entitlements.all[AppConstants.revenuecatEntitlementId];
    final isEntitlementActive = entitlement?.isActive ?? false;

    // Parse date strings to DateTime if they exist
    DateTime? parsePurchaseDate(String? dateString) {
      if (dateString == null) return null;
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return null;
      }
    }

    return PremiumStatus(
      isPremium: isEntitlementActive,
      purchaseDate: parsePurchaseDate(entitlement?.latestPurchaseDate),
      productId: entitlement?.productIdentifier,
      transactionId: customerInfo.originalAppUserId,
      expirationDate: parsePurchaseDate(entitlement?.expirationDate),
      originalTransactionId: entitlement?.originalPurchaseDate,
      isActive: isEntitlementActive,
      entitlementId: AppConstants.revenuecatEntitlementId,
      activeEntitlements: customerInfo.entitlements.active.keys.toList(),
      isFromRevenueCat: true,
    );
  }

  @override
  Future<Either<Failure, bool>> purchasePremium() async {
    try {
      // Get offerings from RevenueCat
      final offerings = await revenueCatService.getOfferings();

      final offering = offerings.current;
      if (offering == null || offering.availablePackages.isEmpty) {
        return Left(PurchaseFailure('No offerings available. Please contact support.'));
      }

      // Get the default package (or specific package based on your setup)
      final package = offering.availablePackages.first;

      // Make the purchase
      final customerInfo = await revenueCatService.purchasePackage(package);

      // Update local status
      await _handleCustomerInfoUpdate(customerInfo);

      // Check if entitlement is now active
      final isActive = customerInfo.entitlements.all[AppConstants.revenuecatEntitlementId]?.isActive ?? false;

      return Right(isActive);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return Left(PurchaseFailure('Purchase was cancelled'));
      } else if (errorCode == PurchasesErrorCode.productAlreadyPurchasedError) {
        // Already purchased, trigger restore
        await restorePurchases();
        return const Right(true);
      } else if (errorCode == PurchasesErrorCode.networkError) {
        return Left(PurchaseFailure('Network error. Please check your connection.'));
      }

      return Left(PurchaseFailure('Purchase failed: ${e.message ?? e.code}'));
    } catch (e) {
      return Left(PurchaseFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> restorePurchases() async {
    try {
      final customerInfo = await revenueCatService.restorePurchases();

      // Update local status
      await _handleCustomerInfoUpdate(customerInfo);

      final entitlement = customerInfo.entitlements.all[AppConstants.revenuecatEntitlementId];
      final hasActivePurchase = entitlement?.isActive ?? false;

      return Right(hasActivePurchase);
    } on PlatformException catch (e) {
      return Left(PurchaseFailure('Restore failed: ${e.message ?? e.code}'));
    } catch (e) {
      return Left(PurchaseFailure('Restore failed: $e'));
    }
  }

  @override
  Future<Either<Failure, PremiumStatus>> getPremiumStatus() async {
    try {
      // Try to get fresh customer info from RevenueCat
      final customerInfo = await revenueCatService.getCustomerInfo();
      final premiumStatus = _createPremiumStatusFromCustomerInfo(customerInfo);

      // Cache the status
      final premiumStatusModel = PremiumStatusModel.fromEntity(premiumStatus);
      await localDataSource.cachePremiumStatus(premiumStatusModel);

      if (premiumStatus.isValidPremium && premiumStatus.transactionId != null) {
        await localDataSource.setSecurePremiumToken(premiumStatus.transactionId!);
      } else {
        // Clear token if not premium
        await localDataSource.clearSecurePremiumToken();
      }

      return Right(premiumStatus);
    } catch (e) {
      // If network fails, fallback to cache
      try {
        final cachedStatus = await localDataSource.getCachedPremiumStatus();
        if (cachedStatus != null) {
          return Right(cachedStatus.toEntity());
        }
      } catch (_) {}

      // Default to free
      final freeStatus = PremiumStatus.free();
      final freeStatusModel = PremiumStatusModel.fromEntity(freeStatus);
      await localDataSource.cachePremiumStatus(freeStatusModel);

      return Right(freeStatus);
    }
  }

  @override
  Future<Either<Failure, bool>> validatePremiumStatus() async {
    try {
      // Fetch latest customer info from RevenueCat
      final customerInfo = await revenueCatService.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[AppConstants.revenuecatEntitlementId];
      final isValidPremium = entitlement?.isActive ?? false;

      if (!isValidPremium) {
        // Clear premium status
        await localDataSource.clearPremiumCache();
        await localDataSource.clearSecurePremiumToken();
      } else {
        // Update cached status
        await _handleCustomerInfoUpdate(customerInfo);
      }

      return Right(isValidPremium);
    } catch (e) {
      // If validation fails, check local cache
      final secureToken = await localDataSource.getSecurePremiumToken();
      final isValidPremium = secureToken != null;
      return Right(isValidPremium);
    }
  }

  @override
  Future<Either<Failure, bool>> cachePremiumStatus(PremiumStatus status) async {
    try {
      final statusModel = PremiumStatusModel.fromEntity(status);
      await localDataSource.cachePremiumStatus(statusModel);
      return const Right(true);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to cache premium status: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAvailableProducts() async {
    try {
      final offerings = await revenueCatService.getOfferings();

      if (offerings.current == null) {
        return Left(PurchaseFailure('No offerings available'));
      }

      final productIds = offerings.current!.availablePackages
          .map((package) => package.storeProduct.identifier)
          .toList();

      return Right(productIds);
    } catch (e) {
      return Left(PurchaseFailure('Failed to get products: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProductDetails(String productId) async {
    try {
      final offerings = await revenueCatService.getOfferings();

      if (offerings.current == null || offerings.current!.availablePackages.isEmpty) {
        return Left(PurchaseFailure('No products available'));
      }

      // Get the first package (or find specific package)
      final package = offerings.current!.availablePackages.first;
      final product = package.storeProduct;

      final productInfo = {
        'id': product.identifier,
        'title': product.title,
        'description': product.description,
        'price': product.priceString,
        'currencyCode': product.currencyCode,
        'currencySymbol': product.currencyCode,  // RevenueCat doesn't provide currency symbol separately
      };

      return Right(productInfo);
    } catch (e) {
      return Left(PurchaseFailure('Failed to get product details: $e'));
    }
  }

  @override
  Stream<PremiumStatus> get premiumStatusStream => _premiumStatusController.stream;

  void dispose() {
    _premiumStatusController.close();
  }
}
