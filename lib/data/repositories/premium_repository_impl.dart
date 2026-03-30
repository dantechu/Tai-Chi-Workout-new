import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/premium_status.dart';
import '../../domain/repositories/premium_repository.dart';
import '../datasources/premium_local_datasource.dart';
import '../models/premium_status_model.dart';

class PremiumRepositoryImpl implements PremiumRepository {
  final PremiumLocalDataSource localDataSource;
  final InAppPurchase inAppPurchase;
  final StreamController<PremiumStatus> _premiumStatusController;

  PremiumRepositoryImpl({
    required this.localDataSource,
    required this.inAppPurchase,
  }) : _premiumStatusController = StreamController<PremiumStatus>.broadcast() {
    _initializePurchaseListener();
  }

  void _initializePurchaseListener() {
    inAppPurchase.purchaseStream.listen((List<PurchaseDetails> purchaseDetailsList) {
      _handlePurchaseUpdates(purchaseDetailsList);
    });
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.productID == AppConstants.premiumProductId) {
        if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {

          final premiumStatus = PremiumStatusModel.fromEntity(
            PremiumStatus.premium(
              purchaseDate: DateTime.now(),
              productId: purchaseDetails.productID,
              transactionId: purchaseDetails.purchaseID ?? '',
            ),
          );

          try {
            await localDataSource.cachePremiumStatus(premiumStatus);
            if (purchaseDetails.purchaseID != null) {
              await localDataSource.setSecurePremiumToken(purchaseDetails.purchaseID!);
            }

            _premiumStatusController.add(premiumStatus.toEntity());
          } catch (e) {
            // Log error but still complete the purchase
            print('Error caching premium status: $e');
          }

          if (purchaseDetails.pendingCompletePurchase) {
            try {
              await inAppPurchase.completePurchase(purchaseDetails);
            } catch (e) {
              print('Error completing purchase: $e');
            }
          }
        } else if (purchaseDetails.status == PurchaseStatus.error) {
          _premiumStatusController.add(PremiumStatus.free());
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          // User canceled the purchase, no action needed
          print('Purchase canceled by user');
        } else if (purchaseDetails.status == PurchaseStatus.pending) {
          // Purchase is pending, waiting for user action
          print('Purchase is pending');
        }
      }

      // Always complete pending purchases to avoid issues
      if (purchaseDetails.pendingCompletePurchase) {
        try {
          await inAppPurchase.completePurchase(purchaseDetails);
        } catch (e) {
          print('Error completing pending purchase: $e');
        }
      }
    }
  }

  @override
  Future<Either<Failure, bool>> purchasePremium() async {
    try {
      final bool isAvailable = await inAppPurchase.isAvailable();
      if (!isAvailable) {
        return Left(PurchaseFailure('App Store is not available. Please check your internet connection and try again.'));
      }

       Set<String> productIds = {AppConstants.premiumProductId};
      final ProductDetailsResponse productDetailResponse =
          await inAppPurchase.queryProductDetails(productIds);

      if (productDetailResponse.error != null) {
        return Left(PurchaseFailure('Failed to load products: ${productDetailResponse.error!.message}'));
      }

      if (productDetailResponse.productDetails.isEmpty) {
        return Left(PurchaseFailure('Premium product not found in the store. Please contact support.'));
      }

      final ProductDetails productDetails = productDetailResponse.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

      final bool purchaseInitiated = await inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      if (!purchaseInitiated) {
        return Left(PurchaseFailure('Failed to initiate purchase. Please try again.'));
      }

      // The actual purchase completion is handled in _handlePurchaseUpdates
      return const Right(true);
    } on PlatformException catch (e) {
      return Left(PurchaseFailure('Purchase error: ${e.message ?? e.code}'));
    } catch (e) {
      return Left(PurchaseFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> restorePurchases() async {
    try {
      // Check if a secure token already exists
      final existingToken = await localDataSource.getSecurePremiumToken();
      if (existingToken != null) {
        // Already have premium, no need to restore
        return const Right(true);
      }

      // Trigger restore purchases which will invoke the purchase stream
      await inAppPurchase.restorePurchases();

      // Wait a moment for the purchase stream to process
      await Future.delayed(const Duration(seconds: 2));

      // Check if the restore was successful by checking the secure token again
      final restoredToken = await localDataSource.getSecurePremiumToken();
      if (restoredToken != null) {
        return const Right(true);
      }

      // No purchases found to restore
      return const Right(false);
    } catch (e) {
      return Left(PurchaseFailure('Restore failed: $e'));
    }
  }

  @override
  Future<Either<Failure, PremiumStatus>> getPremiumStatus() async {
    try {
      // Check secure storage first
      final secureToken = await localDataSource.getSecurePremiumToken();
      if (secureToken != null) {
        // Check if we have cached status with this token
        final cachedStatus = await localDataSource.getCachedPremiumStatus();

        // If cached status exists and matches the token, use it
        if (cachedStatus != null &&
            cachedStatus.toEntity().transactionId == secureToken &&
            cachedStatus.toEntity().isValidPremium) {
          return Right(cachedStatus.toEntity());
        }

        // Token exists but cache is missing or mismatched - create and cache new status
        final premiumStatus = PremiumStatus.premium(
          purchaseDate: cachedStatus?.toEntity().purchaseDate ?? DateTime.now(),
          productId: AppConstants.premiumProductId,
          transactionId: secureToken,
        );

        // Cache the status to keep everything in sync
        final premiumStatusModel = PremiumStatusModel.fromEntity(premiumStatus);
        await localDataSource.cachePremiumStatus(premiumStatusModel);

        return Right(premiumStatus);
      }

      // No secure token, check cached status
      final cachedStatus = await localDataSource.getCachedPremiumStatus();
      if (cachedStatus != null) {
        final status = cachedStatus.toEntity();
        // If cached status shows premium but no secure token, it's invalid
        if (status.isPremium) {
          // Clear invalid premium status
          await localDataSource.clearPremiumCache();
          final freeStatus = PremiumStatus.free();
          final freeStatusModel = PremiumStatusModel.fromEntity(freeStatus);
          await localDataSource.cachePremiumStatus(freeStatusModel);
          return Right(freeStatus);
        }
        return Right(status);
      }

      // Default to free
      final freeStatus = PremiumStatus.free();
      final freeStatusModel = PremiumStatusModel.fromEntity(freeStatus);
      await localDataSource.cachePremiumStatus(freeStatusModel);

      return Right(freeStatus);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get premium status: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> validatePremiumStatus() async {
    try {
      // For now, just check local storage
      final secureToken = await localDataSource.getSecurePremiumToken();
      final isValidPremium = secureToken != null;
      
      if (!isValidPremium) {
        // Clear premium status
        await localDataSource.clearPremiumCache();
        await localDataSource.clearSecurePremiumToken();
      }

      return Right(isValidPremium);
    } catch (e) {
      return Left(PurchaseFailure('Validation failed: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> cachePremiumStatus(PremiumStatus status) async {
    try {
      final statusModel = PremiumStatusModel.fromEntity(status);
      await localDataSource.cachePremiumStatus(statusModel);
      return Right(true);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to cache premium status: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAvailableProducts() async {
    try {
       Set<String> productIds = {AppConstants.premiumProductId};
      final ProductDetailsResponse response = await inAppPurchase.queryProductDetails(productIds);

      if (response.error != null) {
        return Left(PurchaseFailure(response.error!.message));
      }

      final availableProductIds = response.productDetails.map((product) => product.id).toList();
      return Right(availableProductIds);
    } catch (e) {
      return Left(PurchaseFailure('Failed to get available products: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProductDetails(String productId) async {
    try {
      final Set<String> productIds = {productId};
      final ProductDetailsResponse response = await inAppPurchase.queryProductDetails(productIds);

      if (response.error != null) {
        return Left(PurchaseFailure(response.error!.message));
      }

      if (response.productDetails.isEmpty) {
        return Left(PurchaseFailure('Product not found'));
      }

      final ProductDetails product = response.productDetails.first;
      final productInfo = {
        'id': product.id,
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'currencyCode': product.currencyCode,
        'currencySymbol': product.currencySymbol,
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