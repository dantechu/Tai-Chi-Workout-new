import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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
  void Function()? _removeListener;

  // Cache expiration time (24 hours)
  static const Duration _cacheValidDuration = Duration(hours: 24);

  PremiumRepositoryImpl({
    required this.localDataSource,
    required this.revenueCatService,
  }) : _premiumStatusController = StreamController<PremiumStatus>.broadcast() {
    _initializeCustomerInfoListener();
  }

  void _initializeCustomerInfoListener() {
    // Listen to customer info updates from RevenueCat for real-time sync
    _removeListener = revenueCatService.addCustomerInfoUpdateListener(
      (customerInfo) async {
        await _handleCustomerInfoUpdate(customerInfo);
      },
    );
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
      // Silently handle caching errors to avoid disrupting the update flow
      // In production, consider using a proper logging service
      debugPrint('Error caching premium status: $e');
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

    // Get the actual transaction identifier from the entitlement
    // Use the entitlement identifier as the primary transaction reference
    // This is verified by RevenueCat and tied to the actual purchase
    String? transactionId;
    String? originalTransactionId;

    if (isEntitlementActive && entitlement != null) {
      // Use the entitlement's identifier (e.g., "premium") as verification
      // Combined with the user's app ID for uniqueness
      transactionId = '${entitlement.identifier}_${customerInfo.originalAppUserId}';
      // Store the original purchase date as additional verification
      originalTransactionId = entitlement.originalPurchaseDate;
    }

    return PremiumStatus(
      isPremium: isEntitlementActive,
      purchaseDate: parsePurchaseDate(entitlement?.latestPurchaseDate),
      productId: entitlement?.productIdentifier,
      transactionId: transactionId,
      expirationDate: parsePurchaseDate(entitlement?.expirationDate),
      originalTransactionId: originalTransactionId,
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

      // Try to get the configured offering first, fallback to current
      Offering? offering = offerings.getOffering(AppConstants.revenuecatOfferingId);
      offering ??= offerings.current;

      if (offering == null || offering.availablePackages.isEmpty) {
        return Left(PurchaseFailure('No offerings available. Please contact support.'));
      }

      // Get the lifetime package (preferred for one-time purchases)
      // If not available, try annual, then monthly, then fall back to first available
      Package? package = offering.lifetime ??
                         offering.annual ??
                         offering.monthly ??
                         (offering.availablePackages.isNotEmpty ? offering.availablePackages.first : null);

      if (package == null) {
        return Left(PurchaseFailure('No purchase packages available. Please contact support.'));
      }

      // Make the purchase
      final customerInfo = await revenueCatService.purchasePackage(package);

      // Update local status
      await _handleCustomerInfoUpdate(customerInfo);

      // Check if entitlement is now active
      final isActive = customerInfo.entitlements.all[AppConstants.revenuecatEntitlementId]?.isActive ?? false;

      return Right(isActive);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      // Handle all known error codes
      switch (errorCode) {
        case PurchasesErrorCode.purchaseCancelledError:
          return Left(PurchaseFailure('Purchase was cancelled'));

        case PurchasesErrorCode.productAlreadyPurchasedError:
          // Already purchased, trigger restore
          await restorePurchases();
          return const Right(true);

        case PurchasesErrorCode.networkError:
          return Left(PurchaseFailure('Network error. Please check your connection.'));

        case PurchasesErrorCode.storeProblemError:
          return Left(PurchaseFailure('Store error. Please try again later.'));

        case PurchasesErrorCode.purchaseNotAllowedError:
          return Left(PurchaseFailure('Purchases are not allowed on this device.'));

        case PurchasesErrorCode.receiptAlreadyInUseError:
          return Left(PurchaseFailure('This purchase is already in use on another account.'));

        case PurchasesErrorCode.paymentPendingError:
          return Left(PurchaseFailure('Payment is pending. Please check back later.'));

        case PurchasesErrorCode.productNotAvailableForPurchaseError:
          return Left(PurchaseFailure('This product is not available for purchase.'));

        case PurchasesErrorCode.purchaseInvalidError:
          return Left(PurchaseFailure('Purchase is invalid. Please try again.'));

        default:
          return Left(PurchaseFailure('Purchase failed: ${e.message ?? e.code}'));
      }
    } on TimeoutException {
      return Left(PurchaseFailure('Purchase timed out. Please check your connection and try again.'));
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
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      switch (errorCode) {
        case PurchasesErrorCode.networkError:
          return Left(PurchaseFailure('Network error. Please check your connection.'));
        case PurchasesErrorCode.storeProblemError:
          return Left(PurchaseFailure('Store error. Please try again later.'));
        default:
          return Left(PurchaseFailure('Restore failed: ${e.message ?? e.code}'));
      }
    } on TimeoutException {
      return Left(PurchaseFailure('Restore timed out. Please check your connection and try again.'));
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

      // Cache the status with timestamp
      final premiumStatusModel = PremiumStatusModel.fromEntity(premiumStatus);
      await localDataSource.cachePremiumStatus(premiumStatusModel);
      await localDataSource.updateLastPremiumCheck();

      if (premiumStatus.isValidPremium && premiumStatus.transactionId != null) {
        await localDataSource.setSecurePremiumToken(premiumStatus.transactionId!);
      } else {
        // Clear token if not premium
        await localDataSource.clearSecurePremiumToken();
      }

      return Right(premiumStatus);
    } catch (e) {
      // If network fails, fallback to cache with validation
      try {
        final cachedStatus = await localDataSource.getCachedPremiumStatus();
        final lastCheck = await localDataSource.getLastPremiumCheck();

        if (cachedStatus != null) {
          // Validate cache is not expired
          final isCacheValid = lastCheck != null &&
              DateTime.now().difference(lastCheck) < _cacheValidDuration;

          if (isCacheValid) {
            // Use cached status if it's recent enough
            return Right(cachedStatus.toEntity());
          } else {
            // Cache is too old, check if premium has expired
            final cachedEntity = cachedStatus.toEntity();
            if (cachedEntity.isPremium && cachedEntity.isExpired) {
              // Premium has expired, clear cache and return free status
              await localDataSource.clearPremiumCache();
              await localDataSource.clearSecurePremiumToken();
              final freeStatus = PremiumStatus.free();
              final freeStatusModel = PremiumStatusModel.fromEntity(freeStatus);
              await localDataSource.cachePremiumStatus(freeStatusModel);
              return Right(freeStatus);
            }

            // Cache is old but premium might still be valid, return cached with warning
            return Right(cachedEntity);
          }
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

      // Try to get the configured offering first, fallback to current
      Offering? offering = offerings.getOffering(AppConstants.revenuecatOfferingId);
      offering ??= offerings.current;

      if (offering == null || offering.availablePackages.isEmpty) {
        return Left(PurchaseFailure('No products available'));
      }

      // Get the lifetime package (preferred for one-time purchases)
      // If not available, try annual, then monthly, then fall back to first available
      Package? package = offering.lifetime ??
                         offering.annual ??
                         offering.monthly ??
                         (offering.availablePackages.isNotEmpty ? offering.availablePackages.first : null);

      if (package == null) {
        return Left(PurchaseFailure('No purchase packages available'));
      }

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
    } on TimeoutException {
      return Left(PurchaseFailure('Request timed out. Please check your connection.'));
    } catch (e) {
      return Left(PurchaseFailure('Failed to get product details: $e'));
    }
  }

  @override
  Stream<PremiumStatus> get premiumStatusStream => _premiumStatusController.stream;

  @override
  Future<Either<Failure, String>> loginUser(String appUserId) async {
    try {
      // IMPORTANT: This should be called when a user authenticates in your app
      // to enable cross-device purchase syncing. For example:
      // - After Firebase Auth sign-in
      // - After email/password login
      // - When user creates an account
      // Pass your user's unique ID (e.g., Firebase UID, database user ID)
      final customerInfo = await revenueCatService.logIn(appUserId);

      // Update local status after login
      await _handleCustomerInfoUpdate(customerInfo);

      return Right(customerInfo.originalAppUserId);
    } on PlatformException catch (e) {
      return Left(PurchaseFailure('Login failed: ${e.message ?? e.code}'));
    } on TimeoutException {
      return Left(PurchaseFailure('Login timed out. Please check your connection.'));
    } catch (e) {
      return Left(PurchaseFailure('Login failed: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> logoutUser() async {
    try {
      final customerInfo = await revenueCatService.logOut();

      // Clear local status after logout
      await localDataSource.clearPremiumCache();
      await localDataSource.clearSecurePremiumToken();

      return Right(customerInfo.originalAppUserId);
    } on PlatformException catch (e) {
      return Left(PurchaseFailure('Logout failed: ${e.message ?? e.code}'));
    } on TimeoutException {
      return Left(PurchaseFailure('Logout timed out. Please check your connection.'));
    } catch (e) {
      return Left(PurchaseFailure('Logout failed: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAnonymous() async {
    try {
      final isAnon = await revenueCatService.isAnonymous();
      return Right(isAnon);
    } catch (e) {
      return Left(PurchaseFailure('Failed to check anonymous status: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getCurrentUserId() async {
    try {
      final userId = await revenueCatService.getAppUserId();
      return Right(userId);
    } catch (e) {
      return Left(PurchaseFailure('Failed to get user ID: $e'));
    }
  }

  void dispose() {
    // Remove customer info listener if it exists
    _removeListener?.call();
    _premiumStatusController.close();
  }
}
