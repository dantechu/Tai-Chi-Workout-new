// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PremiumStatusModel _$PremiumStatusModelFromJson(Map<String, dynamic> json) =>
    PremiumStatusModel(
      isPremium: json['isPremium'] as bool,
      purchaseDate: json['purchaseDate'] == null
          ? null
          : DateTime.parse(json['purchaseDate'] as String),
      productId: json['productId'] as String?,
      transactionId: json['transactionId'] as String?,
      receipt: json['receipt'] as String?,
      expirationDate: json['expirationDate'] == null
          ? null
          : DateTime.parse(json['expirationDate'] as String),
      originalTransactionId: json['originalTransactionId'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$PremiumStatusModelToJson(PremiumStatusModel instance) =>
    <String, dynamic>{
      'isPremium': instance.isPremium,
      'purchaseDate': instance.purchaseDate?.toIso8601String(),
      'productId': instance.productId,
      'transactionId': instance.transactionId,
      'receipt': instance.receipt,
      'expirationDate': instance.expirationDate?.toIso8601String(),
      'originalTransactionId': instance.originalTransactionId,
      'isActive': instance.isActive,
    };
