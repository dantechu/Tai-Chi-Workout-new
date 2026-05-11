import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/premium_status.dart';

part 'premium_status_model.g.dart';

@JsonSerializable()
class PremiumStatusModel extends PremiumStatus {
  const PremiumStatusModel({
    required super.isPremium,
    super.purchaseDate,
    super.productId,
    super.transactionId,
    super.receipt,
    super.expirationDate,
    super.originalTransactionId,
    super.isActive = true,
    super.entitlementId,
    super.activeEntitlements,
    super.isFromRevenueCat = true,
  });

  factory PremiumStatusModel.fromJson(Map<String, dynamic> json) => 
      _$PremiumStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$PremiumStatusModelToJson(this);

  factory PremiumStatusModel.fromEntity(PremiumStatus entity) {
    return PremiumStatusModel(
      isPremium: entity.isPremium,
      purchaseDate: entity.purchaseDate,
      productId: entity.productId,
      transactionId: entity.transactionId,
      receipt: entity.receipt,
      expirationDate: entity.expirationDate,
      originalTransactionId: entity.originalTransactionId,
      isActive: entity.isActive,
      entitlementId: entity.entitlementId,
      activeEntitlements: entity.activeEntitlements,
      isFromRevenueCat: entity.isFromRevenueCat,
    );
  }

  PremiumStatus toEntity() {
    return PremiumStatus(
      isPremium: isPremium,
      purchaseDate: purchaseDate,
      productId: productId,
      transactionId: transactionId,
      receipt: receipt,
      expirationDate: expirationDate,
      originalTransactionId: originalTransactionId,
      isActive: isActive,
      entitlementId: entitlementId,
      activeEntitlements: activeEntitlements,
      isFromRevenueCat: isFromRevenueCat,
    );
  }

  @override
  PremiumStatusModel copyWith({
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
    return PremiumStatusModel(
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
}