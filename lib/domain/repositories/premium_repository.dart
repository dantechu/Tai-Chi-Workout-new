import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/premium_status.dart';

abstract class PremiumRepository {
  Future<Either<Failure, bool>> purchasePremium();
  Future<Either<Failure, bool>> restorePurchases();
  Future<Either<Failure, PremiumStatus>> getPremiumStatus();
  Future<Either<Failure, bool>> validatePremiumStatus();
  Future<Either<Failure, bool>> cachePremiumStatus(PremiumStatus status);
  Future<Either<Failure, List<String>>> getAvailableProducts();
  Future<Either<Failure, Map<String, dynamic>>> getProductDetails(String productId);
  Stream<PremiumStatus> get premiumStatusStream;
}