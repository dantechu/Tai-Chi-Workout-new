import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/premium_status.dart';
import '../repositories/premium_repository.dart';

class PurchasePremium {
  final PremiumRepository repository;

  PurchasePremium(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.purchasePremium();
  }
}

class RestorePurchases {
  final PremiumRepository repository;

  RestorePurchases(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.restorePurchases();
  }
}

class GetPremiumStatus {
  final PremiumRepository repository;

  GetPremiumStatus(this.repository);

  Future<Either<Failure, PremiumStatus>> call() async {
    return await repository.getPremiumStatus();
  }
}

class ValidatePremiumStatus {
  final PremiumRepository repository;

  ValidatePremiumStatus(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.validatePremiumStatus();
  }
}

class GetProductDetails {
  final PremiumRepository repository;

  GetProductDetails(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String productId) async {
    return await repository.getProductDetails(productId);
  }
}