import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/video.dart';
import '../../../domain/entities/section.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/quiz_question.dart';
import '../../../core/utils/localization_helper.dart';
import '../../../core/services/interstitial_ad_service.dart';
import '../../../core/services/next_lesson_service.dart';
import '../../../core/services/premium_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../bloc/lesson_completion/lesson_completion_bloc.dart';
import '../../bloc/lesson_completion/lesson_completion_event.dart';
import '../../bloc/lesson_completion/lesson_completion_state.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_state.dart' show CoursesLoaded, SelectedCourseLoaded, CourseSelected;
import '../../../core/services/certificate_service.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/section_completion_dialog.dart';
import '../../widgets/course_completion_dialog.dart';
import '../lessons/lesson_router.dart';

/// Page for interactive quiz lessons.
///
/// Features:
/// - Question-by-question progression
/// - Multiple choice answers with visual feedback
/// - Score tracking and results display
/// - Support for multilingual content
/// - Next lesson navigation when passed
class QuizPage extends StatefulWidget {
  final Video lesson;
  final List<Section>? sections;

  const QuizPage({
    super.key,
    required this.lesson,
    this.sections,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _quizCompleted = false;
  final List<int?> _userAnswers = [];
  bool _isLastLesson = false;
  bool _autoShowTriggered = false;

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
    _checkIfLastLesson();
  }

  void _checkIfLastLesson() {
    // Get the current course
    Course? currentCourse;
    try {
      final coursesState = context.read<CoursesBloc>().state;
      if (coursesState is CoursesLoaded) {
        currentCourse = coursesState.selectedCourse;
        if (currentCourse == null && widget.lesson.courseId != null) {
          currentCourse = coursesState.courses.where(
            (c) => c.id == widget.lesson.courseId,
          ).firstOrNull;
        }
      } else if (coursesState is SelectedCourseLoaded) {
        currentCourse = coursesState.course;
      } else if (coursesState is CourseSelected) {
        currentCourse = coursesState.course;
      }
    } catch (_) {}

    if (currentCourse != null) {
      final nextLessonResult = NextLessonService.findNextLesson(
        currentLesson: widget.lesson,
        course: currentCourse,
      );
      _isLastLesson = !nextLessonResult.hasNextLesson;
    }
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
      // Mark as complete if passed (70% or more)
      _checkAndMarkComplete();
    }
  }

  void _checkAndMarkComplete() {
    if (passed) {
      context.read<LessonCompletionBloc>().add(
        MarkLessonCompleted(
          widget.lesson.id,
          courseId: widget.lesson.courseId,
          lessonType: 'quiz',
          scorePercentage: scorePercentage.toInt(),
          durationSeconds: widget.lesson.duration.inSeconds,
        ),
      );

      // If this is the last lesson, start countdown to auto-show completion dialog
      if (_isLastLesson) {
        _startAutoShowCountdown();
      }
    }
  }

  void _startAutoShowCountdown() {
    // Wait 3 seconds in the background, then show completion dialog
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || _autoShowTriggered) return;
      _autoShowTriggered = true;
      _showCompletionDialogs();
    });
  }

  void _showCompletionDialogs() async {
    if (!mounted) return;

    // Get the completion state
    final completionState = context.read<LessonCompletionBloc>().state;

    // Get the current course
    Course? currentCourse;
    try {
      final coursesState = context.read<CoursesBloc>().state;
      if (coursesState is CoursesLoaded) {
        currentCourse = coursesState.selectedCourse;
        if (currentCourse == null && widget.lesson.courseId != null) {
          currentCourse = coursesState.courses.where(
            (c) => c.id == widget.lesson.courseId,
          ).firstOrNull;
        }
      } else if (coursesState is SelectedCourseLoaded) {
        currentCourse = coursesState.course;
      } else if (coursesState is CourseSelected) {
        currentCourse = coursesState.course;
      }
    } catch (_) {}

    if (currentCourse == null || !mounted) return;

    final allSections = widget.sections ?? currentCourse.sections;

    // Check for course completion first
    if (completionState is LessonCompletionLoaded) {
      final isCourseComplete = CourseCompletionDialog.isCourseCompleted(
        course: currentCourse,
        completionState: completionState,
        currentLessonId: widget.lesson.id,
      );

      if (isCourseComplete && mounted) {
        await CertificateService().markCourseCompleted(currentCourse.id);
        if (mounted) {
          await CourseCompletionDialog.show(
            context: context,
            course: currentCourse,
          );
        }
        return;
      }
    }

    // Check for section completion
    if (completionState is LessonCompletionLoaded && allSections != null && mounted) {
      for (final section in allSections) {
        final lessonInSection = section.lessons.any((l) => l.id == widget.lesson.id);
        if (lessonInSection) {
          final isSectionComplete = SectionCompletionDialog.isSectionCompleted(
            section: section,
            currentLesson: widget.lesson,
            completionState: completionState,
          );

          if (isSectionComplete && mounted) {
            await SectionCompletionDialog.show(
              context: context,
              completedSection: section,
            );
          }
          break;
        }
      }
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

    final l10n = AppLocalizations.of(context);

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Text(l10n?.noQuestionsForQuiz ?? 'No questions available for this quiz.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      bottomNavigationBar: _quizCompleted && !PremiumService().isPremium
          ? const SafeArea(
              child: BannerAdWidget(),
            )
          : null,
      body: _quizCompleted
          ? _buildResultsView(context, languageCode, l10n)
          : _buildQuizView(context, languageCode, description, l10n),
    );
  }

  Widget _buildQuizView(
    BuildContext context,
    String languageCode,
    String? description,
    AppLocalizations? l10n,
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
                    l10n?.questionXOfY(_currentQuestionIndex + 1, totalQuestions) ?? 'Question ${_currentQuestionIndex + 1} of $totalQuestions',
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
                        child: Text(
                          l10n?.previous ?? 'Previous',
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
                            ? (l10n?.next ?? 'Next')
                            : (l10n?.seeResults ?? 'See Results'),
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

  Widget _buildResultsView(BuildContext context, String languageCode, AppLocalizations? l10n) {
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
              passed ? (l10n?.congratulations ?? 'Congratulations!') : (l10n?.keepPracticing ?? 'Keep Practicing!'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: passed ? Colors.green : Colors.orange,
                  ),
            ),
            const SizedBox(height: 16),

            // Score
            Text(
              l10n?.youScoredPercent(scorePercentage.toInt()) ?? 'You scored ${scorePercentage.toInt()}%',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.xOutOfYCorrect(_correctAnswers, totalQuestions) ?? '$_correctAnswers out of $totalQuestions correct',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.passingScorePercent(passingPercentage) ?? 'Passing score: $passingPercentage%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
            ),
            const SizedBox(height: 48),

            // Action buttons - hide Next Lesson if last lesson (completion dialog shows automatically)
            if (passed) ...[
              if (_isLastLesson) ...[
                // Only show Try Again button for last lesson (completion dialog shows automatically after 3s)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _restartQuiz,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n?.tryAgain ?? 'Try Again',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Next Lesson button (primary) - only show if NOT last lesson
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => _onNextLessonPressed(context),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    label: Text(
                      l10n?.nextLesson ?? 'Next Lesson',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Try Again button (secondary)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _restartQuiz,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n?.tryAgain ?? 'Try Again',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ] else ...[
              // Try Again button (primary) when failed
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
                  child: Text(
                    l10n?.tryAgain ?? 'Try Again',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
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
                child: Text(
                  l10n?.backToLessons ?? 'Back to Lessons',
                  style: const TextStyle(
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

  void _onNextLessonPressed(BuildContext context) async {
    // Get the completion state before navigating
    final completionState = context.read<LessonCompletionBloc>().state;

    // Get the current course from CoursesBloc
    Course? currentCourse;
    try {
      final coursesState = context.read<CoursesBloc>().state;
      if (coursesState is CoursesLoaded) {
        // First try selectedCourse, then find by courseId
        currentCourse = coursesState.selectedCourse;
        if (currentCourse == null && widget.lesson.courseId != null) {
          currentCourse = coursesState.courses.where(
            (c) => c.id == widget.lesson.courseId,
          ).firstOrNull;
        }
      } else if (coursesState is SelectedCourseLoaded) {
        currentCourse = coursesState.course;
      } else if (coursesState is CourseSelected) {
        currentCourse = coursesState.course;
      }
    } catch (_) {
      // CoursesBloc not available
    }

    if (currentCourse == null) {
      // No course available, just go back
      Navigator.pop(context);
      return;
    }

    // Get all sections for navigation
    final allSections = widget.sections ?? currentCourse.sections;

    // Check for COURSE completion first (takes priority over section completion)
    if (completionState is LessonCompletionLoaded) {
      final isCourseComplete = CourseCompletionDialog.isCourseCompleted(
        course: currentCourse,
        completionState: completionState,
        currentLessonId: widget.lesson.id,
      );

      if (isCourseComplete && mounted) {
        // Mark course as completed for certificate purposes
        await CertificateService().markCourseCompleted(currentCourse.id);

        // Show course completion dialog and return (don't show section dialog)
        await CourseCompletionDialog.show(
          context: context,
          course: currentCourse,
        );
        return;
      }
    }

    // Check for section completion before navigating
    if (completionState is LessonCompletionLoaded && allSections != null) {
      // Find the section containing this lesson
      for (final section in allSections) {
        final lessonInSection = section.lessons.any((l) => l.id == widget.lesson.id);
        if (lessonInSection) {
          // Check if all lessons in this section are now completed
          final isSectionComplete = SectionCompletionDialog.isSectionCompleted(
            section: section,
            currentLesson: widget.lesson,
            completionState: completionState,
          );

          if (isSectionComplete && mounted) {
            await SectionCompletionDialog.show(
              context: context,
              completedSection: section,
            );
          }
          break;
        }
      }
    }

    if (!mounted) return;

    // Find next lesson
    final nextLessonResult = NextLessonService.findNextLesson(
      currentLesson: widget.lesson,
      course: currentCourse,
    );

    if (!nextLessonResult.hasNextLesson) {
      // Course complete - go back to home
      Navigator.pop(context);
      return;
    }

    // Show interstitial ad if applicable, then navigate
    InterstitialAdService().showAdIfReady(
      onAdDismissed: () {
        // Use replaceWithLesson so we don't stack lesson pages
        LessonRouter.replaceWithLesson(
          context,
          nextLessonResult.nextLesson!,
          sections: allSections,
        );
      },
    );
  }
}
