import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/premium_usecases.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/premium_service.dart';
import 'premium_event.dart';
import 'premium_state.dart';

class PremiumBloc extends Bloc<PremiumEvent, PremiumState> {
  final PurchasePremium purchasePremium;
  final RestorePurchases restorePurchases;
  final GetPremiumStatus getPremiumStatus;
  final ValidatePremiumStatus validatePremiumStatus;
  final GetProductDetails getProductDetails;
  final PremiumService _premiumService = PremiumService();

  PremiumBloc({
    required this.purchasePremium,
    required this.restorePurchases,
    required this.getPremiumStatus,
    required this.validatePremiumStatus,
    required this.getProductDetails,
  }) : super(const PremiumInitial()) {
    on<CheckPremiumStatus>(_onCheckPremiumStatus);
    on<PurchasePremiumRequested>(_onPurchasePremium);
    on<RestorePremiumRequested>(_onRestorePremium);
    on<ValidatePremiumRequested>(_onValidatePremium);
    on<PremiumStatusUpdated>(_onPremiumStatusUpdated);
  }

  Future<void> _onCheckPremiumStatus(
    CheckPremiumStatus event,
    Emitter<PremiumState> emit,
  ) async {
    emit(const PremiumLoading());

    final result = await getPremiumStatus();
    final isActive = result.fold(
      (failure) {
        emit(PremiumError(failure.message));
        return false;
      },
      (status) {
        if (status.isValidPremium) {
          _premiumService.updatePremiumStatus(true);
          emit(PremiumActive(status));
          return true;
        }
        _premiumService.updatePremiumStatus(false);
        return false;
      },
    );

    // Fetch product details for inactive users
    if (!isActive) {
      final productResult = await getProductDetails(AppConstants.premiumProductId);
      productResult.fold(
        (failure) => emit(const PremiumInactive()),
        (productDetails) {
          final price = productDetails['price'] as String? ?? AppConstants.premiumPrice;
          final title = productDetails['title'] as String?;
          emit(PremiumInactive(productPrice: price, productTitle: title));
        },
      );
    }
  }

  Future<void> _onPurchasePremium(
    PurchasePremiumRequested event,
    Emitter<PremiumState> emit,
  ) async {
    emit(const PremiumPurchasing());

    final result = await purchasePremium();
    result.fold(
      (failure) => emit(PremiumError(failure.message)),
      (success) async {
        if (success) {
          // Get updated status
          final statusResult = await getPremiumStatus();
          statusResult.fold(
            (failure) => emit(PremiumError(failure.message)),
            (status) {
              // Emit final state based on validity
              if (status.isValidPremium) {
                _premiumService.updatePremiumStatus(true);
                emit(PremiumActive(status));
              } else {
                _premiumService.updatePremiumStatus(false);
                emit(const PremiumInactive());
              }
            },
          );
        } else {
          emit(const PremiumError('Purchase failed'));
        }
      },
    );
  }

  Future<void> _onRestorePremium(
    RestorePremiumRequested event,
    Emitter<PremiumState> emit,
  ) async {
    emit(const PremiumRestoring());

    final result = await restorePurchases();
    result.fold(
      (failure) => emit(PremiumError(failure.message)),
      (restored) async {
        if (restored) {
          // Get updated status
          final statusResult = await getPremiumStatus();
          statusResult.fold(
            (failure) => emit(PremiumError(failure.message)),
            (status) {
              // Emit final state based on validity
              if (status.isValidPremium) {
                _premiumService.updatePremiumStatus(true);
                emit(PremiumActive(status));
              } else {
                _premiumService.updatePremiumStatus(false);
                emit(const PremiumInactive());
              }
            },
          );
        } else {
          emit(const PremiumError('No purchases found to restore'));
        }
      },
    );
  }

  Future<void> _onValidatePremium(
    ValidatePremiumRequested event,
    Emitter<PremiumState> emit,
  ) async {
    final result = await validatePremiumStatus();
    result.fold(
      (failure) => emit(PremiumError(failure.message)),
      (isValid) async {
        if (isValid) {
          final statusResult = await getPremiumStatus();
          statusResult.fold(
            (failure) => emit(PremiumValidationComplete(false)),
            (status) => emit(PremiumValidationComplete(true, status)),
          );
        } else {
          emit(const PremiumValidationComplete(false));
        }
      },
    );
  }

  Future<void> _onPremiumStatusUpdated(
    PremiumStatusUpdated event,
    Emitter<PremiumState> emit,
  ) async {
    // Refresh the current status
    add(const CheckPremiumStatus());
  }

  bool get isPremium {
    return state is PremiumActive;
  }

  bool get isProcessing {
    return state is PremiumPurchasing || 
           state is PremiumRestoring || 
           state is PremiumLoading;
  }
}