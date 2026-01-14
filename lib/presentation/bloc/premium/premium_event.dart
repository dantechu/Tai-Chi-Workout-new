import 'package:equatable/equatable.dart';

abstract class PremiumEvent extends Equatable {
  const PremiumEvent();

  @override
  List<Object> get props => [];
}

class CheckPremiumStatus extends PremiumEvent {
  const CheckPremiumStatus();
}

class PurchasePremiumRequested extends PremiumEvent {
  const PurchasePremiumRequested();
}

class RestorePremiumRequested extends PremiumEvent {
  const RestorePremiumRequested();
}

class ValidatePremiumRequested extends PremiumEvent {
  const ValidatePremiumRequested();
}

class PremiumStatusUpdated extends PremiumEvent {
  const PremiumStatusUpdated();
}