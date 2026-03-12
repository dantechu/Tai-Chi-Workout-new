import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injection_container.dart' as di;
import '../../../data/datasources/onboarding_local_datasource.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_event.dart';
import '../../courses/bloc/courses_state.dart';
import '../../courses/widgets/course_card.dart';
//todo: start by implementing bookmarks system. 
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _floatingController;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatingController.dispose();
    _rotationController.dispose();
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
              _WelcomeScreen(
                onNext: _nextPage,
                onSkip: _completeOnboarding,
                floatingController: _floatingController,
                rotationController: _rotationController,
              ),
              _PracticeScreen(
                onNext: _nextPage,
                onSkip: _completeOnboarding,
                floatingController: _floatingController,
                rotationController: _rotationController,
              ),
              _BreathingScreen(
                onNext: _nextPage,
                onSkip: _completeOnboarding,
                floatingController: _floatingController,
                rotationController: _rotationController,
              ),
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
  final AnimationController floatingController;
  final AnimationController rotationController;

  const _WelcomeScreen({
    required this.onNext,
    required this.onSkip,
    required this.floatingController,
    required this.rotationController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Animated Background
        Positioned.fill(
          child: CustomPaint(
            painter: FloatingShapesPainter(
              animation: floatingController,
              color: theme.colorScheme.primary,
            ),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                theme.colorScheme.surface.withValues(alpha: 0.9),
                theme.colorScheme.surface,
              ],
            ),
          ),
        ),

        SafeArea(
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

                // Animated Icon
                AnimatedBuilder(
                  animation: floatingController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 10 * math.sin(floatingController.value * 2 * math.pi)),
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.self_improvement_outlined,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
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
      ],
    );
  }
}

class _PracticeScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final AnimationController floatingController;
  final AnimationController rotationController;

  const _PracticeScreen({
    required this.onNext,
    required this.onSkip,
    required this.floatingController,
    required this.rotationController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Animated Background
        Positioned.fill(
          child: CustomPaint(
            painter: MusicWavesPainter(
              animation: floatingController,
              color: theme.colorScheme.primary,
            ),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                theme.colorScheme.surface.withValues(alpha: 0.9),
                theme.colorScheme.surface,
              ],
            ),
          ),
        ),

        SafeArea(
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

                // Animated Icon with Rotation
                AnimatedBuilder(
                  animation: floatingController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 10 * math.sin(floatingController.value * 2 * math.pi)),
                      child: Transform.rotate(
                        angle: floatingController.value * 0.1,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.music_note_outlined,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
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
      ],
    );
  }
}

class _BreathingScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final AnimationController floatingController;
  final AnimationController rotationController;

  const _BreathingScreen({
    required this.onNext,
    required this.onSkip,
    required this.floatingController,
    required this.rotationController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Animated Background
        Positioned.fill(
          child: CustomPaint(
            painter: BreathingCirclesPainter(
              animation: floatingController,
              color: theme.colorScheme.primary,
            ),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                theme.colorScheme.surface.withValues(alpha: 0.9),
                theme.colorScheme.surface,
              ],
            ),
          ),
        ),

        SafeArea(
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

                // Pulsing Icon Animation
                AnimatedBuilder(
                  animation: floatingController,
                  builder: (context, child) {
                    final scale = 1.0 + (0.1 * math.sin(floatingController.value * 2 * math.pi));
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.air_outlined,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
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
      ],
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

// Custom Painters for Animated Backgrounds

class FloatingShapesPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  FloatingShapesPainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final animValue = animation.value;

    // Floating Circle 1
    final circle1 = Offset(
      size.width * 0.2,
      size.height * 0.3 + (50 * math.sin(animValue * 2 * math.pi)),
    );
    canvas.drawCircle(circle1, 60, paint);

    // Floating Circle 2
    final circle2 = Offset(
      size.width * 0.8,
      size.height * 0.6 + (40 * math.sin(animValue * 2 * math.pi + math.pi / 2)),
    );
    canvas.drawCircle(circle2, 80, paint);

    // Floating Circle 3
    final circle3 = Offset(
      size.width * 0.6,
      size.height * 0.15 + (30 * math.sin(animValue * 2 * math.pi + math.pi)),
    );
    canvas.drawCircle(circle3, 50, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MusicWavesPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  MusicWavesPainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final animValue = animation.value;
    final path = Path();

    // Draw multiple sine waves
    for (var i = 0; i < 3; i++) {
      path.reset();
      final yOffset = size.height * (0.3 + i * 0.2);
      path.moveTo(0, yOffset);

      for (var x = 0; x < size.width; x += 5) {
        final y = yOffset +
          30 * math.sin((x / 40) + (animValue * 2 * math.pi) + (i * math.pi / 3));
        path.lineTo(x.toDouble(), y);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BreathingCirclesPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  BreathingCirclesPainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final animValue = animation.value;
    final center = Offset(size.width / 2, size.height / 2);

    // Draw expanding circles
    for (var i = 0; i < 4; i++) {
      final progress = (animValue + i * 0.25) % 1.0;
      final radius = progress * size.width * 0.5;
      final alpha = (1.0 - progress) * 0.15;

      final paint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
