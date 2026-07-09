import 'package:equatable/equatable.dart';

/// Represents a single flashcard in a flashcard lesson/deck
class FlashCard extends Equatable {
  final String id;
  final String frontText;
  final String backText;

  // Multi-language support for front text
  final String? frontTextDe;
  final String? frontTextEs;
  final String? frontTextFr;
  final String? frontTextJa;
  final String? frontTextKo;
  final String? frontTextZh;

  // Multi-language support for back text
  final String? backTextDe;
  final String? backTextEs;
  final String? backTextFr;
  final String? backTextJa;
  final String? backTextKo;
  final String? backTextZh;

  const FlashCard({
    required this.id,
    required this.frontText,
    required this.backText,
    this.frontTextDe,
    this.frontTextEs,
    this.frontTextFr,
    this.frontTextJa,
    this.frontTextKo,
    this.frontTextZh,
    this.backTextDe,
    this.backTextEs,
    this.backTextFr,
    this.backTextJa,
    this.backTextKo,
    this.backTextZh,
  });

  /// Get localized front text based on language code
  String getLocalizedFrontText(String languageCode) {
    switch (languageCode) {
      case 'de':
        return frontTextDe ?? frontText;
      case 'es':
        return frontTextEs ?? frontText;
      case 'fr':
        return frontTextFr ?? frontText;
      case 'ja':
        return frontTextJa ?? frontText;
      case 'ko':
        return frontTextKo ?? frontText;
      case 'zh':
        return frontTextZh ?? frontText;
      default:
        return frontText;
    }
  }

  /// Get localized back text based on language code
  String getLocalizedBackText(String languageCode) {
    switch (languageCode) {
      case 'de':
        return backTextDe ?? backText;
      case 'es':
        return backTextEs ?? backText;
      case 'fr':
        return backTextFr ?? backText;
      case 'ja':
        return backTextJa ?? backText;
      case 'ko':
        return backTextKo ?? backText;
      case 'zh':
        return backTextZh ?? backText;
      default:
        return backText;
    }
  }

  FlashCard copyWith({
    String? id,
    String? frontText,
    String? backText,
    String? frontTextDe,
    String? frontTextEs,
    String? frontTextFr,
    String? frontTextJa,
    String? frontTextKo,
    String? frontTextZh,
    String? backTextDe,
    String? backTextEs,
    String? backTextFr,
    String? backTextJa,
    String? backTextKo,
    String? backTextZh,
  }) {
    return FlashCard(
      id: id ?? this.id,
      frontText: frontText ?? this.frontText,
      backText: backText ?? this.backText,
      frontTextDe: frontTextDe ?? this.frontTextDe,
      frontTextEs: frontTextEs ?? this.frontTextEs,
      frontTextFr: frontTextFr ?? this.frontTextFr,
      frontTextJa: frontTextJa ?? this.frontTextJa,
      frontTextKo: frontTextKo ?? this.frontTextKo,
      frontTextZh: frontTextZh ?? this.frontTextZh,
      backTextDe: backTextDe ?? this.backTextDe,
      backTextEs: backTextEs ?? this.backTextEs,
      backTextFr: backTextFr ?? this.backTextFr,
      backTextJa: backTextJa ?? this.backTextJa,
      backTextKo: backTextKo ?? this.backTextKo,
      backTextZh: backTextZh ?? this.backTextZh,
    );
  }

  @override
  List<Object?> get props => [
        id,
        frontText,
        backText,
        frontTextDe,
        frontTextEs,
        frontTextFr,
        frontTextJa,
        frontTextKo,
        frontTextZh,
        backTextDe,
        backTextEs,
        backTextFr,
        backTextJa,
        backTextKo,
        backTextZh,
      ];

  @override
  String toString() => 'FlashCard(id: $id, front: $frontText, back: $backText)';
}
