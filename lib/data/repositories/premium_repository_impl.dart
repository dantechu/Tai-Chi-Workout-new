import 'dart:async';
import 'package:dartz/dartz.dart';
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

          await localDataSource.cachePremiumStatus(premiumStatus);
          if (purchaseDetails.purchaseID != null) {
            await localDataSource.setSecurePremiumToken(purchaseDetails.purchaseID!);
          }

          _premiumStatusController.add(premiumStatus.toEntity());

          if (purchaseDetails.pendingCompletePurchase) {
            await inAppPurchase.completePurchase(purchaseDetails);
          }
        } else if (purchaseDetails.status == PurchaseStatus.error) {
          _premiumStatusController.add(PremiumStatus.free());
        }
      }
    }
  }

  @override
  Future<Either<Failure, bool>> purchasePremium() async {
    try {
      final bool isAvailable = await inAppPurchase.isAvailable();
      if (!isAvailable) {
        return Left(PurchaseFailure('Store not available'));
      }

      const Set<String> productIds = {AppConstants.premiumProductId};
      final ProductDetailsResponse productDetailResponse =
          await inAppPurchase.queryProductDetails(productIds);

      if (productDetailResponse.error != null) {
        return Left(PurchaseFailure(productDetailResponse.error!.message));
      }

      if (productDetailResponse.productDetails.isEmpty) {
        return Left(PurchaseFailure('Product not found'));
      }

      final ProductDetails productDetails = productDetailResponse.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

      await inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      // The actual purchase completion is handled in _handlePurchaseUpdates
      return Right(true);
    } catch (e) {
      return Left(PurchaseFailure('Purchase failed: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> restorePurchases() async {
    try {
      await inAppPurchase.restorePurchases();

      // Get past purchases from the stream
      // Note: In the real implementation, you would listen to purchaseStream
      // and check for past purchases. For now, we'll return false.
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
        // We have a secure token, user is premium
        final premiumStatus = PremiumStatus.premium(
          purchaseDate: DateTime.now(), // We don't store the actual date
          productId: AppConstants.premiumProductId,
          transactionId: secureToken,
        );
        return Right(premiumStatus);
      }

      // Check cached status
      final cachedStatus = await localDataSource.getCachedPremiumStatus();
      if (cachedStatus != null) {
        return Right(cachedStatus.toEntity());
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
      const Set<String> productIds = {AppConstants.premiumProductId};
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