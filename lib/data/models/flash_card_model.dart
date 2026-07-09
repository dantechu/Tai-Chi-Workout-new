import '../../domain/entities/flash_card.dart';

/// Data model for FlashCard with Firestore serialization
class FlashCardModel extends FlashCard {
  const FlashCardModel({
    required super.id,
    required super.frontText,
    required super.backText,
    super.frontTextDe,
    super.frontTextEs,
    super.frontTextFr,
    super.frontTextJa,
    super.frontTextKo,
    super.frontTextZh,
    super.backTextDe,
    super.backTextEs,
    super.backTextFr,
    super.backTextJa,
    super.backTextKo,
    super.backTextZh,
  });

  /// Create from Map (Firestore compatible)
  factory FlashCardModel.fromMap(Map<String, dynamic> map) {
    return FlashCardModel(
      id: map['id'] as String? ?? '',
      frontText: map['frontText'] as String? ?? '',
      backText: map['backText'] as String? ?? '',
      frontTextDe: map['frontText_de'] as String?,
      frontTextEs: map['frontText_es'] as String?,
      frontTextFr: map['frontText_fr'] as String?,
      frontTextJa: map['frontText_ja'] as String?,
      frontTextKo: map['frontText_ko'] as String?,
      frontTextZh: map['frontText_zh'] as String?,
      backTextDe: map['backText_de'] as String?,
      backTextEs: map['backText_es'] as String?,
      backTextFr: map['backText_fr'] as String?,
      backTextJa: map['backText_ja'] as String?,
      backTextKo: map['backText_ko'] as String?,
      backTextZh: map['backText_zh'] as String?,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'frontText': frontText,
      'backText': backText,
      if (frontTextDe != null) 'frontText_de': frontTextDe,
      if (frontTextEs != null) 'frontText_es': frontTextEs,
      if (frontTextFr != null) 'frontText_fr': frontTextFr,
      if (frontTextJa != null) 'frontText_ja': frontTextJa,
      if (frontTextKo != null) 'frontText_ko': frontTextKo,
      if (frontTextZh != null) 'frontText_zh': frontTextZh,
      if (backTextDe != null) 'backText_de': backTextDe,
      if (backTextEs != null) 'backText_es': backTextEs,
      if (backTextFr != null) 'backText_fr': backTextFr,
      if (backTextJa != null) 'backText_ja': backTextJa,
      if (backTextKo != null) 'backText_ko': backTextKo,
      if (backTextZh != null) 'backText_zh': backTextZh,
    };
  }

  /// Convert to domain entity
  FlashCard toEntity() {
    return FlashCard(
      id: id,
      frontText: frontText,
      backText: backText,
      frontTextDe: frontTextDe,
      frontTextEs: frontTextEs,
      frontTextFr: frontTextFr,
      frontTextJa: frontTextJa,
      frontTextKo: frontTextKo,
      frontTextZh: frontTextZh,
      backTextDe: backTextDe,
      backTextEs: backTextEs,
      backTextFr: backTextFr,
      backTextJa: backTextJa,
      backTextKo: backTextKo,
      backTextZh: backTextZh,
    );
  }

  /// Create from domain entity
  factory FlashCardModel.fromEntity(FlashCard entity) {
    return FlashCardModel(
      id: entity.id,
      frontText: entity.frontText,
      backText: entity.backText,
      frontTextDe: entity.frontTextDe,
      frontTextEs: entity.frontTextEs,
      frontTextFr: entity.frontTextFr,
      frontTextJa: entity.frontTextJa,
      frontTextKo: entity.frontTextKo,
      frontTextZh: entity.frontTextZh,
      backTextDe: entity.backTextDe,
      backTextEs: entity.backTextEs,
      backTextFr: entity.backTextFr,
      backTextJa: entity.backTextJa,
      backTextKo: entity.backTextKo,
      backTextZh: entity.backTextZh,
    );
  }
}
