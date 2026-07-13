import '../../domain/entities/quiz_question.dart';

/// Data model for QuizOption with Firestore serialization
class QuizOptionModel extends QuizOption {
  const QuizOptionModel({
    required super.id,
    required super.text,
    super.textDe,
    super.textEs,
    super.textFr,
    super.textJa,
    super.textKo,
    super.textZh,
  });

  /// Create from Map (Firestore compatible)
  factory QuizOptionModel.fromMap(Map<String, dynamic> map) {
    return QuizOptionModel(
      id: map['id'] as String? ?? '',
      text: map['text'] as String? ?? '',
      textDe: map['text_de'] as String?,
      textEs: map['text_es'] as String?,
      textFr: map['text_fr'] as String?,
      textJa: map['text_ja'] as String?,
      textKo: map['text_ko'] as String?,
      textZh: map['text_zh'] as String?,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      if (textDe != null) 'text_de': textDe,
      if (textEs != null) 'text_es': textEs,
      if (textFr != null) 'text_fr': textFr,
      if (textJa != null) 'text_ja': textJa,
      if (textKo != null) 'text_ko': textKo,
      if (textZh != null) 'text_zh': textZh,
    };
  }

  /// Convert to domain entity
  QuizOption toEntity() {
    return QuizOption(
      id: id,
      text: text,
      textDe: textDe,
      textEs: textEs,
      textFr: textFr,
      textJa: textJa,
      textKo: textKo,
      textZh: textZh,
    );
  }

  /// Create from domain entity
  factory QuizOptionModel.fromEntity(QuizOption entity) {
    return QuizOptionModel(
      id: entity.id,
      text: entity.text,
      textDe: entity.textDe,
      textEs: entity.textEs,
      textFr: entity.textFr,
      textJa: entity.textJa,
      textKo: entity.textKo,
      textZh: entity.textZh,
    );
  }
}

/// Data model for QuizQuestion with Firestore serialization
class QuizQuestionModel extends QuizQuestion {
  const QuizQuestionModel({
    required super.id,
    required super.questionText,
    required List<QuizOptionModel> options,
    required super.correctOptionIndex,
    super.questionTextDe,
    super.questionTextEs,
    super.questionTextFr,
    super.questionTextJa,
    super.questionTextKo,
    super.questionTextZh,
  }) : super(options: options);

  /// Get options as QuizOptionModel list
  List<QuizOptionModel> get optionModels =>
      options.map((o) => o is QuizOptionModel ? o : QuizOptionModel.fromEntity(o)).toList();

  /// Create from Map (Firestore compatible)
  /// Note: When reading from Hive cache, nested maps are Map<dynamic, dynamic>
  /// so we need to convert them to Map<String, dynamic>
  factory QuizQuestionModel.fromMap(Map<String, dynamic> map) {
    final optionsList = (map['options'] as List<dynamic>?)
            ?.map((o) => QuizOptionModel.fromMap(
                Map<String, dynamic>.from(o as Map)))
            .toList() ??
        [];

    return QuizQuestionModel(
      id: map['id'] as String? ?? '',
      questionText: map['questionText'] as String? ?? '',
      options: optionsList,
      correctOptionIndex: map['correctOptionIndex'] as int? ?? 0,
      questionTextDe: map['questionText_de'] as String?,
      questionTextEs: map['questionText_es'] as String?,
      questionTextFr: map['questionText_fr'] as String?,
      questionTextJa: map['questionText_ja'] as String?,
      questionTextKo: map['questionText_ko'] as String?,
      questionTextZh: map['questionText_zh'] as String?,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'options': optionModels.map((o) => o.toMap()).toList(),
      'correctOptionIndex': correctOptionIndex,
      if (questionTextDe != null) 'questionText_de': questionTextDe,
      if (questionTextEs != null) 'questionText_es': questionTextEs,
      if (questionTextFr != null) 'questionText_fr': questionTextFr,
      if (questionTextJa != null) 'questionText_ja': questionTextJa,
      if (questionTextKo != null) 'questionText_ko': questionTextKo,
      if (questionTextZh != null) 'questionText_zh': questionTextZh,
    };
  }

  /// Convert to domain entity
  QuizQuestion toEntity() {
    return QuizQuestion(
      id: id,
      questionText: questionText,
      options: optionModels.map((o) => o.toEntity()).toList(),
      correctOptionIndex: correctOptionIndex,
      questionTextDe: questionTextDe,
      questionTextEs: questionTextEs,
      questionTextFr: questionTextFr,
      questionTextJa: questionTextJa,
      questionTextKo: questionTextKo,
      questionTextZh: questionTextZh,
    );
  }

  /// Create from domain entity
  factory QuizQuestionModel.fromEntity(QuizQuestion entity) {
    return QuizQuestionModel(
      id: entity.id,
      questionText: entity.questionText,
      options: entity.options.map((o) => QuizOptionModel.fromEntity(o)).toList(),
      correctOptionIndex: entity.correctOptionIndex,
      questionTextDe: entity.questionTextDe,
      questionTextEs: entity.questionTextEs,
      questionTextFr: entity.questionTextFr,
      questionTextJa: entity.questionTextJa,
      questionTextKo: entity.questionTextKo,
      questionTextZh: entity.questionTextZh,
    );
  }
}
