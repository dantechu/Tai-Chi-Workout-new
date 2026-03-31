import '../../../../core/services/premium_service.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/app_localizations.dart';
import '../../bloc/premium/premium_bloc.dart';
import '../../bloc/premium/premium_state.dart';
import '../../widgets/banner_ad_widget.dart';

class BreathingTimerPage extends StatefulWidget {
  const BreathingTimerPage({super.key});

  @override
  State<BreathingTimerPage> createState() => _BreathingTimerPageState();
}

class _BreathingTimerPageState extends State<BreathingTimerPage> {
  bool _showSetup = true;
  int _selectedDuration = 300; // 5 minutes default

  final List<int> _durations = [60, 180, 300, 600, 900]; // 1, 3, 5, 10, 15 minutes

  @override
  Widget build(BuildContext context) {
    if (_showSetup) {
      return BreathingSetupScreen(
        selectedDuration: _selectedDuration,
        durations: _durations,
        onDurationChanged: (duration) {
          setState(() {
            _selectedDuration = duration;
          });
        },
        onStart: () {
          setState(() {
            _showSetup = false;
          });
        },
      );
    } else {
      return BreathingSessionScreen(
        duration: _selectedDuration,
        onComplete: () {
          setState(() {
            _showSetup = true;
          });
        },
        onBack: () {
          setState(() {
            _showSetup = true;
          });
        },
      );
    }
  }
}

class BreathingSetupScreen extends StatefulWidget {
  final int selectedDuration;
  final List<int> durations;
  final ValueChanged<int> onDurationChanged;
  final VoidCallback onStart;

  const BreathingSetupScreen({
    super.key,
    required this.selectedDuration,
    required this.durations,
    required this.onDurationChanged,
    required this.onStart,
  });

  @override
  State<BreathingSetupScreen> createState() => _BreathingSetupScreenState();
}

class _BreathingSetupScreenState extends State<BreathingSetupScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;

  static const Color _accentColor = Color(0xFF6B73FF);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            SizedBox(height: constraints.maxHeight * 0.02),
                            _buildAnimatedIcon(theme),
                            const SizedBox(height: 24),
                            _buildHeader(theme, context),
                            const SizedBox(height: 32),
                            _buildDurationSelector(theme, context),
                          ],
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 24),
                            _buildStartButton(theme, context),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildAnimatedIcon(ThemeData theme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer wave
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _accentColor.withValues(alpha: 0.2 + (_waveController.value * 0.1)),
                  width: 2,
                ),
              ),
            );
          },
        ),
        // Inner wave
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return Container(
              width: 115,
              height: 115,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _accentColor.withValues(alpha: 0.3 + (_waveController.value * 0.15)),
                  width: 2,
                ),
              ),
            );
          },
        ),
        // Main icon with pulse
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1.0 + (_pulseController.value * 0.08);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _accentColor.withValues(alpha: 0.9),
                      _accentColor.withValues(alpha: 0.6),
                      _accentColor.withValues(alpha: 0.3),
                    ],
                    stops: const [0.3, 0.7, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.air_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)?.breathingExercise ?? 'Breathing Exercise',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            AppLocalizations.of(context)?.findYourCalm ?? 'Find your calm',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelector(ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            AppLocalizations.of(context)?.selectDuration ?? 'Select Duration',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: widget.durations.map((duration) {
            final isSelected = widget.selectedDuration == duration;
            final minutes = duration ~/ 60;

            return GestureDetector(
              onTap: () => widget.onDurationChanged(duration),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _accentColor,
                            _accentColor.withValues(alpha: 0.8),
                          ],
                        )
                      : null,
                  color: isSelected ? null : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: _accentColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$minutes',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)?.min ?? 'min',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.9)
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStartButton(ThemeData theme, BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _accentColor,
            _accentColor.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onStart,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_arrow_rounded,
                  size: 24,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)?.startBreathing ?? 'Start Breathing',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BreathingSessionScreen extends StatefulWidget {
  final int duration;
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const BreathingSessionScreen({
    super.key,
    required this.duration,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<BreathingSessionScreen> createState() => _BreathingSessionScreenState();
}

class _BreathingSessionScreenState extends State<BreathingSessionScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _progressController;
  late Animation<double> _breathAnimation;
  late Animation<double> _progressAnimation;

  bool _isRunning = false;
  bool _isPaused = false;
  final int _inhaleTime = 4;
  final int _holdTime = 4;
  final int _exhaleTime = 4;
  int _currentPhase = 0; // 0: inhale, 1: hold, 2: exhale

  final Color _breathingColor = const Color(0xFF6B73FF);

  List<String> get _phaseDescriptions => [
    AppLocalizations.of(context)?.breatheInSlowly ?? 'Breathe in slowly and deeply',
    AppLocalizations.of(context)?.holdYourBreath ?? 'Hold your breath gently',
    AppLocalizations.of(context)?.exhaleSlowly ?? 'Exhale slowly and completely',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _breathController = AnimationController(
      duration: Duration(seconds: _inhaleTime + _holdTime + _exhaleTime),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: Duration(seconds: widget.duration),
      vsync: this,
    );

    _breathAnimation = Tween<double>(
      begin: 0.9,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _breathController,
      curve: _createBreathCurve(),
    ));

    _progressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    ));

    _breathController.addListener(_onBreathAnimationUpdate);
    _progressController.addStatusListener(_onProgressComplete);
  }

  Curve _createBreathCurve() {
    final totalTime = _inhaleTime + _holdTime + _exhaleTime;
    final inhaleEnd = _inhaleTime / totalTime;
    final holdEnd = (_inhaleTime + _holdTime) / totalTime;

    return CustomBreathCurve(
      inhaleEnd: inhaleEnd,
      holdEnd: holdEnd,
    );
  }

  void _onBreathAnimationUpdate() {
    final progress = _breathController.value;
    final totalCycleTime = _inhaleTime + _holdTime + _exhaleTime;
    final currentTime = progress * totalCycleTime;

    int newPhase;
    if (currentTime <= _inhaleTime) {
      newPhase = 0;
    } else if (currentTime <= _inhaleTime + _holdTime) {
      newPhase = 1;
    } else {
      newPhase = 2;
    }

    if (_currentPhase != newPhase) {
      setState(() {
        _currentPhase = newPhase;
      });
      _triggerHapticFeedback();
    }
  }

  void _onProgressComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _stopBreathing();
      _showCompletionDialog();
    }
  }

  String _getPhaseText(BuildContext context) {
    switch (_currentPhase) {
      case 0:
        return AppLocalizations.of(context)?.inhale ?? 'Inhale';
      case 1:
        return AppLocalizations.of(context)?.hold ?? 'Hold';
      case 2:
        return AppLocalizations.of(context)?.exhale ?? 'Exhale';
      default:
        return AppLocalizations.of(context)?.breathe ?? 'Breathe';
    }
  }

  void _triggerHapticFeedback() {
    switch (_currentPhase) {
      case 0:
        HapticFeedback.lightImpact();
        break;
      case 1:
        HapticFeedback.mediumImpact();
        break;
      case 2:
        HapticFeedback.lightImpact();
        break;
    }
  }

  void _startBreathing() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _progressController.forward();
    _startBreathCycle();
  }

  void _pauseBreathing() {
    setState(() {
      _isPaused = true;
    });
    _breathController.stop();
    _progressController.stop();
  }

  void _resumeBreathing() {
    setState(() {
      _isPaused = false;
    });
    _progressController.forward();
    _startBreathCycle();
  }

  void _startBreathCycle() {
    if (_isRunning && !_isPaused) {
      _breathController.reset();
      _breathController.forward().then((_) {
        if (_isRunning && !_isPaused) {
          _startBreathCycle();
        }
      });
    }
  }

  void _stopBreathing() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });
    _breathController.stop();
    _progressController.stop();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.wellDone ?? 'Well Done!'),
        content: Text(AppLocalizations.of(context)?.breathingSessionComplete ?? 'You have completed your breathing session. Take a moment to notice how you feel.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onComplete();
            },
            child: Text(AppLocalizations.of(context)?.close ?? 'Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header with back and end buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  if (_isRunning) {
                    _stopBreathing();
                  }
                  widget.onBack();
                },
              ),
              if (_isRunning || _isPaused)
                TextButton(
                  onPressed: () {
                    _stopBreathing();
                    widget.onBack();
                  },
                  child: Text(
                    AppLocalizations.of(context)?.endSession ?? 'End',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  _buildBreathingCircle(theme),
                                  const SizedBox(height: 24),
                                  _buildPhaseIndicator(theme),
                                  const SizedBox(height: 16),
                                  _buildPhaseDescription(theme),
                                ],
                              ),
                              Column(
                                children: [
                                  _buildControlButtons(theme),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          ),
        BlocBuilder<PremiumBloc, PremiumState>(
            builder: (context, state) {
              // Use singleton service - SINGLE SOURCE OF TRUTH
              final isPremium = PremiumService().isPremium;
              if (isPremium) {
                return const SizedBox.shrink();
              }
              return Container(
                color: theme.colorScheme.surface,
                child: const SafeArea(
                  top: false,
                  child: BannerAdWidget(),
                ),
              );
            },
          ),
        ],
      );
  }

  Widget _buildBreathingCircle(ThemeData theme) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathAnimation, _progressAnimation]),
      builder: (context, child) {
        final scale = _breathAnimation.value;
        final remainingMinutes = (widget.duration * _progressAnimation.value / 60).floor();
        final remainingSeconds = ((widget.duration * _progressAnimation.value) % 60).floor();

        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer circular progress ring
              CustomPaint(
                size: const Size(200, 200),
                painter: CircularProgressPainter(
                  progress: 1.0 - _progressAnimation.value,
                  color: _breathingColor,
                  strokeWidth: 4,
                ),
              ),
              // Main breathing circle
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _breathingColor.withValues(alpha: 0.15),
                    border: Border.all(
                      color: _breathingColor.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getPhaseText(context),
                          style: TextStyle(
                            color: _breathingColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: _breathingColor.withValues(alpha: 0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Subtle outer ring
              Transform.scale(
                scale: scale * 1.1,
                child: Container(
                  width: 175,
                  height: 175,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _breathingColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhaseIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: _breathingColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getTimingText(),
        style: theme.textTheme.titleLarge?.copyWith(
          color: _breathingColor,
          fontWeight: FontWeight.w400,
          letterSpacing: 1,
        ),
      ),
    );
  }

  String _getTimingText() {
    switch (_currentPhase) {
      case 0:
        return '${_inhaleTime}s';
      case 1:
        return '${_holdTime}s';
      case 2:
        return '${_exhaleTime}s';
      default:
        return '';
    }
  }

  Widget _buildPhaseDescription(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Text(
        _phaseDescriptions[_currentPhase],
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          height: 1.6,
          fontWeight: FontWeight.w300,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildControlButtons(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_isRunning && !_isPaused) ...[
          FilledButton.icon(
            onPressed: _startBreathing,
            icon: const Icon(Icons.play_arrow),
            label: Text(AppLocalizations.of(context)?.start ?? 'Start'),
            style: FilledButton.styleFrom(
              backgroundColor: _breathingColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ] else if (_isRunning && !_isPaused) ...[
          OutlinedButton.icon(
            onPressed: _pauseBreathing,
            icon: const Icon(Icons.pause),
            label: Text(AppLocalizations.of(context)?.pause ?? 'Pause'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _breathingColor,
              side: BorderSide(color: _breathingColor, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ] else if (_isPaused) ...[
          FilledButton.icon(
            onPressed: _resumeBreathing,
            icon: const Icon(Icons.play_arrow),
            label: Text(AppLocalizations.of(context)?.resume ?? 'Resume'),
            style: FilledButton.styleFrom(
              backgroundColor: _breathingColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class ProgressCirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  ProgressCirclePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;

    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CustomBreathCurve extends Curve {
  final double inhaleEnd;
  final double holdEnd;

  const CustomBreathCurve({
    required this.inhaleEnd,
    required this.holdEnd,
  });

  @override
  double transformInternal(double t) {
    if (t <= inhaleEnd) {
      final inhaleProgress = t / inhaleEnd;
      return 0.9 + (0.25 * Curves.easeInOut.transform(inhaleProgress));
    } else if (t <= holdEnd) {
      return 1.15;
    } else {
      final exhaleProgress = (t - holdEnd) / (1.0 - holdEnd);
      return 1.15 - (0.25 * Curves.easeInOut.transform(exhaleProgress));
    }
  }
}
