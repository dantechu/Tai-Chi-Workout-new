/// Provides localized notification content for reminder notifications.
/// This class is used instead of AppLocalizations because notifications
/// are scheduled when the app is in the background (no BuildContext available).
class NotificationContent {
  static const Map<String, Map<String, String>> _content = {
    'en': {
      'title': 'Continue Your Learning Journey!',
      '24hr':
          'You haven\'t practiced today. A quick lesson keeps your skills sharp!',
      '3day':
          'We miss you! Your skills are waiting. Come back and learn something new.',
      '7day':
          'It\'s been a week! Don\'t let your progress slip away. Start a lesson now.',
    },
    'zh': {
      'title': '继续您的学习之旅！',
      '24hr': '您今天还没有练习。快速学习一课，保持技能敏锐！',
      '3day': '我们想念您！您的技能正在等待。回来学习新知识吧。',
      '7day': '已经一周了！不要让您的进步消失。现在开始一课吧。',
    },
    'es': {
      'title': '¡Continúa tu viaje de aprendizaje!',
      '24hr':
          'No has practicado hoy. ¡Una lección rápida mantiene tus habilidades afiladas!',
      '3day':
          '¡Te echamos de menos! Tus habilidades están esperando. Vuelve y aprende algo nuevo.',
      '7day':
          '¡Ha pasado una semana! No dejes que tu progreso se escape. Comienza una lección ahora.',
    },
    'ja': {
      'title': '学習の旅を続けましょう！',
      '24hr': '今日はまだ練習していません。短いレッスンでスキルを磨きましょう！',
      '3day': 'お待ちしています！スキルが待っています。戻って新しいことを学びましょう。',
      '7day': '1週間経ちました！進歩を逃さないでください。今すぐレッスンを始めましょう。',
    },
    'fr': {
      'title': 'Continuez votre parcours d\'apprentissage !',
      '24hr':
          'Vous n\'avez pas pratiqué aujourd\'hui. Une leçon rapide garde vos compétences affûtées !',
      '3day':
          'Vous nous manquez ! Vos compétences vous attendent. Revenez apprendre quelque chose de nouveau.',
      '7day':
          'Cela fait une semaine ! Ne laissez pas vos progrès s\'échapper. Commencez une leçon maintenant.',
    },
    'de': {
      'title': 'Setzen Sie Ihre Lernreise fort!',
      '24hr':
          'Sie haben heute noch nicht geübt. Eine kurze Lektion hält Ihre Fähigkeiten scharf!',
      '3day':
          'Wir vermissen Sie! Ihre Fähigkeiten warten. Kommen Sie zurück und lernen Sie etwas Neues.',
      '7day':
          'Es ist eine Woche her! Lassen Sie Ihren Fortschritt nicht entgleiten. Starten Sie jetzt eine Lektion.',
    },
    'ko': {
      'title': '학습 여정을 계속하세요!',
      '24hr': '오늘 아직 연습하지 않았습니다. 짧은 레슨으로 실력을 유지하세요!',
      '3day': '보고 싶어요! 실력이 기다리고 있습니다. 돌아와서 새로운 것을 배워보세요.',
      '7day': '일주일이 지났습니다! 진전을 잃지 마세요. 지금 레슨을 시작하세요.',
    },
  };

  /// Get the notification title for the given language code.
  /// Falls back to English if the language is not supported.
  static String getTitle(String languageCode) =>
      _content[languageCode]?['title'] ?? _content['en']!['title']!;

  /// Get the 24-hour reminder body for the given language code.
  /// Falls back to English if the language is not supported.
  static String get24HrBody(String languageCode) =>
      _content[languageCode]?['24hr'] ?? _content['en']!['24hr']!;

  /// Get the 3-day reminder body for the given language code.
  /// Falls back to English if the language is not supported.
  static String get3DayBody(String languageCode) =>
      _content[languageCode]?['3day'] ?? _content['en']!['3day']!;

  /// Get the 7-day reminder body for the given language code.
  /// Falls back to English if the language is not supported.
  static String get7DayBody(String languageCode) =>
      _content[languageCode]?['7day'] ?? _content['en']!['7day']!;
}
