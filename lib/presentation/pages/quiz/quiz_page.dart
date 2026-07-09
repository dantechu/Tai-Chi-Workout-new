import 'package:flutter/material.dart';
import '../../../domain/entities/video.dart';
import '../../../domain/entities/quiz_question.dart';
import '../../../core/utils/localization_helper.dart';
import '../../widgets/banner_ad_widget.dart';

/// Page for interactive quiz lessons.
///
/// Features:
/// - Question-by-question progression
/// - Multiple choice answers with visual feedback
/// - Score tracking and results display
/// - Support for multilingual content
class QuizPage extends StatefulWidget {
  final Video lesson;

  const QuizPage({
    super.key,
    required this.lesson,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _quizCompleted = false;
  final List<int?> _userAnswers = [];

  List<QuizQuestion> get questions => widget.lesson.questions ?? [];
  QuizQuestion? get currentQuestion =>
      questions.isNotEmpty && _currentQuestionIndex < questions.length
          ? questions[_currentQuestionIndex]
          : null;
  int get totalQuestions => questions.length;
  int get passingPercentage => widget.lesson.passingPercentage ?? 70;

  @override
  void initState() {
    super.initState();
    _userAnswers.addAll(List.filled(questions.length, null));
  }

  void _selectOption(int index) {
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _nextQuestion() {
    if (_selectedOptionIndex == null) return;

    // Store the user's answer
    _userAnswers[_currentQuestionIndex] = _selectedOptionIndex;

    if (_currentQuestionIndex < totalQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = _userAnswers[_currentQuestionIndex];
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      // Store current answer before going back
      _userAnswers[_currentQuestionIndex] = _selectedOptionIndex;

      setState(() {
        _currentQuestionIndex--;
        _selectedOptionIndex = _userAnswers[_currentQuestionIndex];
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedOptionIndex = null;
      _quizCompleted = false;
      _userAnswers.clear();
      _userAnswers.addAll(List.filled(questions.length, null));
    });
  }

  int get _correctAnswers {
    int correct = 0;
    for (int i = 0; i < questions.length; i++) {
      if (_userAnswers[i] != null &&
          questions[i].isCorrectAnswer(_userAnswers[i]!)) {
        correct++;
      }
    }
    return correct;
  }

  double get scorePercentage => totalQuestions > 0
      ? (_correctAnswers / totalQuestions) * 100
      : 0;

  bool get passed => scorePercentage >= passingPercentage;

  @override
  Widget build(BuildContext context) {
    final languageCode = LocalizationHelper.getCurrentLanguageCode(context);
    final title = widget.lesson.getLocalizedTitle(languageCode);
    final description = widget.lesson.getLocalizedDescription(languageCode);

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(
          child: Text('No questions available for this quiz.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      bottomNavigationBar: _quizCompleted
          ? const SafeArea(
              child: BannerAdWidget(),
            )
          : null,
      body: _quizCompleted
          ? _buildResultsView(context, languageCode)
          : _buildQuizView(context, languageCode, description),
    );
  }

  Widget _buildQuizView(
    BuildContext context,
    String languageCode,
    String? description,
  ) {
    final question = currentQuestion!;
    final questionText = question.getLocalizedQuestionText(languageCode);

    return SafeArea(
      child: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / totalQuestions,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              Theme.of(context).colorScheme.primary,
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question counter
                  Text(
                    'Question ${_currentQuestionIndex + 1} of $totalQuestions',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Question text
                  Text(
                    questionText,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Options
                  ...List.generate(question.options.length, (index) {
                    final option = question.options[index];
                    return _buildOptionCard(
                      context,
                      index,
                      option.getLocalizedText(languageCode),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Bottom navigation buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Previous button
                if (_currentQuestionIndex > 0) ...[
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _previousQuestion,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Previous',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],

                // Next/Submit button
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _selectedOptionIndex != null ? _nextQuestion : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentQuestionIndex < totalQuestions - 1
                            ? 'Next'
                            : 'See Results',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    int index,
    String text,
  ) {
    final isSelected = _selectedOptionIndex == index;

    Color? backgroundColor;
    Color? borderColor;

    if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
      borderColor = Theme.of(context).colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectOption(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor ??
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Option letter
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D...
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Option text
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),

              // Check icon for selected
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsView(BuildContext context, String languageCode) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Result icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: passed
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
              ),
              child: Icon(
                passed ? Icons.emoji_events : Icons.refresh,
                size: 60,
                color: passed ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 24),

            // Result text
            Text(
              passed ? 'Congratulations!' : 'Keep Practicing!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: passed ? Colors.green : Colors.orange,
                  ),
            ),
            const SizedBox(height: 16),

            // Score
            Text(
              'You scored ${scorePercentage.toInt()}%',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '$_correctAnswers out of $totalQuestions correct',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Passing score: $passingPercentage%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
            ),
            const SizedBox(height: 48),

            // Action buttons
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _restartQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Back to Lessons',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
