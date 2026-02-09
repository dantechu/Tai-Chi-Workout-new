import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injection_container.dart' as di;
import '../../../data/datasources/onboarding_local_datasource.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_event.dart';
import '../../courses/bloc/courses_state.dart';
import '../../courses/widgets/course_card.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final datasource = di.sl<OnboardingLocalDataSource>();
    await datasource.setFirstTimeFalse();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _WelcomeScreen(onNext: _nextPage, onSkip: _completeOnboarding),
              _PracticeScreen(onNext: _nextPage, onSkip: _completeOnboarding),
              _BreathingScreen(onNext: _nextPage, onSkip: _completeOnboarding),
              _CourseSelectionScreen(onComplete: _completeOnboarding),
            ],
          ),

          // Page Indicator
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _WelcomeScreen({
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.self_improvement_outlined,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                'Welcome to Tai Chi',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Master the ancient art of Tai Chi with guided lessons, breathing exercises, and peaceful music.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(flex: 2),

              // Next Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onNext,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _PracticeScreen({
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.music_note_outlined,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                'Peaceful Practice',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Enhance your practice with carefully selected meditation music designed to improve focus and tranquility.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(flex: 2),

              // Next Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onNext,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreathingScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _BreathingScreen({
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.air_outlined,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                'Breathing Exercise',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Follow guided breathing sessions to center your mind and prepare for practice. Customizable durations for every level.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(flex: 2),

              // Next Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onNext,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseSelectionScreen extends StatelessWidget {
  final VoidCallback onComplete;

  const _CourseSelectionScreen({
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => di.sl<CoursesBloc>()..add(const LoadCourses()),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: onComplete,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.school_outlined,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Choose Your Course',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Description
                    Text(
                      'Select a learning path to get started. You can change this later in settings.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Courses List
              Expanded(
                child: BlocBuilder<CoursesBloc, CoursesState>(
                  builder: (context, state) {
                    if (state is CoursesLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state is CoursesError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: theme.colorScheme.error.withValues(alpha: 0.7),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Unable to load courses',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.message,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is CoursesLoaded) {
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: state.courses.length,
                        itemBuilder: (context, index) {
                          final course = state.courses[index];
                          final isSelected = state.selectedCourse?.id == course.id;

                          return CourseCard(
                            course: course,
                            isSelected: isSelected,
                            onTap: () {
                              context.read<CoursesBloc>().add(SelectCourseEvent(course.id));
                            },
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),

              // Get Started Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onComplete,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
