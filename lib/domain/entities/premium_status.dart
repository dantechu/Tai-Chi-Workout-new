import 'package:equatable/equatable.dart';

class PremiumStatus extends Equatable {
  final bool isPremium;
  final DateTime? purchaseDate;
  final String? productId;
  final String? transactionId;
  final String? receipt;
  final DateTime? expirationDate;
  final String? originalTransactionId;
  final bool isActive;

  // RevenueCat entitlement fields
  final String? entitlementId;
  final List<String>? activeEntitlements;
  final bool isFromRevenueCat;

  const PremiumStatus({
    required this.isPremium,
    this.purchaseDate,
    this.productId,
    this.transactionId,
    this.receipt,
    this.expirationDate,
    this.originalTransactionId,
    this.isActive = true,
    this.entitlementId,
    this.activeEntitlements,
    this.isFromRevenueCat = true,
  });

  factory PremiumStatus.free() {
    return const PremiumStatus(
      isPremium: false,
      isActive: false,
      isFromRevenueCat: true,
    );
  }

  factory PremiumStatus.premium({
    required DateTime purchaseDate,
    required String productId,
    required String transactionId,
    String? receipt,
    DateTime? expirationDate,
    String? originalTransactionId,
    String? entitlementId,
    List<String>? activeEntitlements,
  }) {
    return PremiumStatus(
      isPremium: true,
      purchaseDate: purchaseDate,
      productId: productId,
      transactionId: transactionId,
      receipt: receipt,
      expirationDate: expirationDate,
      originalTransactionId: originalTransactionId,
      isActive: true,
      entitlementId: entitlementId,
      activeEntitlements: activeEntitlements,
      isFromRevenueCat: true,
    );
  }

  bool get isExpired {
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }

  bool get isValidPremium {
    return isPremium && isActive && !isExpired;
  }

  Duration? get timeUntilExpiration {
    if (expirationDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expirationDate!)) return Duration.zero;
    return expirationDate!.difference(now);
  }

  Duration? get timeSincePurchase {
    if (purchaseDate == null) return null;
    return DateTime.now().difference(purchaseDate!);
  }

  PremiumStatus copyWith({
    bool? isPremium,
    DateTime? purchaseDate,
    String? productId,
    String? transactionId,
    String? receipt,
    DateTime? expirationDate,
    String? originalTransactionId,
    bool? isActive,
    String? entitlementId,
    List<String>? activeEntitlements,
    bool? isFromRevenueCat,
  }) {
    return PremiumStatus(
      isPremium: isPremium ?? this.isPremium,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      productId: productId ?? this.productId,
      transactionId: transactionId ?? this.transactionId,
      receipt: receipt ?? this.receipt,
      expirationDate: expirationDate ?? this.expirationDate,
      originalTransactionId: originalTransactionId ?? this.originalTransactionId,
      isActive: isActive ?? this.isActive,
      entitlementId: entitlementId ?? this.entitlementId,
      activeEntitlements: activeEntitlements ?? this.activeEntitlements,
      isFromRevenueCat: isFromRevenueCat ?? this.isFromRevenueCat,
    );
  }

  @override
  List<Object?> get props => [
        isPremium,
        purchaseDate,
        productId,
        transactionId,
        receipt,
        expirationDate,
        originalTransactionId,
        isActive,
        entitlementId,
        activeEntitlements,
        isFromRevenueCat,
      ];

  @override
  String toString() {
    return 'PremiumStatus(isPremium: $isPremium, isActive: $isActive, productId: $productId)';
  }
}