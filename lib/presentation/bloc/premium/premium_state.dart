import 'package:equatable/equatable.dart';
import '../../../domain/entities/premium_status.dart';

abstract class PremiumState extends Equatable {
  const PremiumState();

  @override
  List<Object?> get props => [];
}

class PremiumInitial extends PremiumState {
  const PremiumInitial();
}

class PremiumLoading extends PremiumState {
  const PremiumLoading();
}

class PremiumInactive extends PremiumState {
  final String? productPrice;
  final String? productTitle;

  const PremiumInactive({this.productPrice, this.productTitle});

  @override
  List<Object?> get props => [productPrice, productTitle];
}

class PremiumActive extends PremiumState {
  final PremiumStatus status;

  const PremiumActive(this.status);

  @override
  List<Object> get props => [status];
}

class PremiumPurchasing extends PremiumState {
  const PremiumPurchasing();
}

class PremiumRestoring extends PremiumState {
  const PremiumRestoring();
}

class PremiumError extends PremiumState {
  final String message;

  const PremiumError(this.message);

  @override
  List<Object> get props => [message];
}

class PremiumPurchaseSuccess extends PremiumState {
  final PremiumStatus status;

  const PremiumPurchaseSuccess(this.status);

  @override
  List<Object> get props => [status];
}

class PremiumRestoreSuccess extends PremiumState {
  final PremiumStatus status;

  const PremiumRestoreSuccess(this.status);

  @override
  List<Object> get props => [status];
}

class PremiumValidationComplete extends PremiumState {
  final bool isValid;
  final PremiumStatus? status;

  const PremiumValidationComplete(this.isValid, [this.status]);

  @override
  List<Object?> get props => [isValid, status];
}