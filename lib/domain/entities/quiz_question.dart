import 'package:equatable/equatable.dart';

/// Represents an option/answer choice for a quiz question
class QuizOption extends Equatable {
  final String id;
  final String text;

  // Multi-language support
  final String? textDe;
  final String? textEs;
  final String? textFr;
  final String? textJa;
  final String? textKo;
  final String? textZh;

  const QuizOption({
    required this.id,
    required this.text,
    this.textDe,
    this.textEs,
    this.textFr,
    this.textJa,
    this.textKo,
    this.textZh,
  });

  /// Get localized text based on language code
  String getLocalizedText(String languageCode) {
    switch (languageCode) {
      case 'de':
        return textDe ?? text;
      case 'es':
        return textEs ?? text;
      case 'fr':
        return textFr ?? text;
      case 'ja':
        return textJa ?? text;
      case 'ko':
        return textKo ?? text;
      case 'zh':
        return textZh ?? text;
      default:
        return text;
    }
  }

  QuizOption copyWith({
    String? id,
    String? text,
    String? textDe,
    String? textEs,
    String? textFr,
    String? textJa,
    String? textKo,
    String? textZh,
  }) {
    return QuizOption(
      id: id ?? this.id,
      text: text ?? this.text,
      textDe: textDe ?? this.textDe,
      textEs: textEs ?? this.textEs,
      textFr: textFr ?? this.textFr,
      textJa: textJa ?? this.textJa,
      textKo: textKo ?? this.textKo,
      textZh: textZh ?? this.textZh,
    );
  }

  @override
  List<Object?> get props => [
        id,
        text,
        textDe,
        textEs,
        textFr,
        textJa,
        textKo,
        textZh,
      ];

  @override
  String toString() => 'QuizOption(id: $id, text: $text)';
}

/// Represents a single question in a quiz lesson
class QuizQuestion extends Equatable {
  final String id;
  final String questionText;
  final List<QuizOption> options;
  final int correctOptionIndex;

  // Multi-language support
  final String? questionTextDe;
  final String? questionTextEs;
  final String? questionTextFr;
  final String? questionTextJa;
  final String? questionTextKo;
  final String? questionTextZh;

  const QuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.questionTextDe,
    this.questionTextEs,
    this.questionTextFr,
    this.questionTextJa,
    this.questionTextKo,
    this.questionTextZh,
  });

  /// Get localized question text based on language code
  String getLocalizedQuestionText(String languageCode) {
    switch (languageCode) {
      case 'de':
        return questionTextDe ?? questionText;
      case 'es':
        return questionTextEs ?? questionText;
      case 'fr':
        return questionTextFr ?? questionText;
      case 'ja':
        return questionTextJa ?? questionText;
      case 'ko':
        return questionTextKo ?? questionText;
      case 'zh':
        return questionTextZh ?? questionText;
      default:
        return questionText;
    }
  }

  /// Get the correct option
  QuizOption get correctOption => options[correctOptionIndex];

  /// Check if a selected index is the correct answer
  bool isCorrectAnswer(int selectedIndex) => selectedIndex == correctOptionIndex;

  /// Get the number of options
  int get optionCount => options.length;

  QuizQuestion copyWith({
    String? id,
    String? questionText,
    List<QuizOption>? options,
    int? correctOptionIndex,
    String? questionTextDe,
    String? questionTextEs,
    String? questionTextFr,
    String? questionTextJa,
    String? questionTextKo,
    String? questionTextZh,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      questionTextDe: questionTextDe ?? this.questionTextDe,
      questionTextEs: questionTextEs ?? this.questionTextEs,
      questionTextFr: questionTextFr ?? this.questionTextFr,
      questionTextJa: questionTextJa ?? this.questionTextJa,
      questionTextKo: questionTextKo ?? this.questionTextKo,
      questionTextZh: questionTextZh ?? this.questionTextZh,
    );
  }

  @override
  List<Object?> get props => [
        id,
        questionText,
        options,
        correctOptionIndex,
        questionTextDe,
        questionTextEs,
        questionTextFr,
        questionTextJa,
        questionTextKo,
        questionTextZh,
      ];

  @override
  String toString() =>
      'QuizQuestion(id: $id, questionText: $questionText, options: ${options.length}, correctIndex: $correctOptionIndex)';
}
