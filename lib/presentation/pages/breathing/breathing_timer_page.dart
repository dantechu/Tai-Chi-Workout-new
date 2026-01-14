import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';

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

class BreathingSetupScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.breathingTimer ?? 'Breathing Timer'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(theme, context),
                const SizedBox(height: 40),
                _buildDurationSelector(theme, context),
                const Spacer(),
                _buildStartButton(theme, context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.2),
                theme.colorScheme.primary.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.air,
            size: 48,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          AppLocalizations.of(context)?.breathingExercise ?? 'Breathing Exercise',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            AppLocalizations.of(context)?.findYourCalm ?? 'Find your calm with guided breathing. Select your session duration and let\'s begin.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
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
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            AppLocalizations.of(context)?.selectDuration ?? 'Select Duration',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: durations.map((duration) {
            final isSelected = selectedDuration == duration;
            final minutes = duration ~/ 60;
            
            return GestureDetector(
              onTap: () => onDurationChanged(duration),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$minutes',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected 
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      minutes == 1 ? 'minute' : (AppLocalizations.of(context)?.minutes ?? 'minutes'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected 
                            ? theme.colorScheme.onPrimary.withValues(alpha: 0.9)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onStart,
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_arrow,
              color: theme.colorScheme.onPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)?.startBreathing ?? 'Start Breathing',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
  late Animation<double> _phaseProgressAnimation;
  
  bool _isRunning = false;
  bool _isPaused = false;
  final int _inhaleTime = 4;
  final int _holdTime = 4;
  final int _exhaleTime = 4;
  int _currentPhase = 0; // 0: inhale, 1: hold, 2: exhale
  
  final Color _breathingColor = const Color(0xFF6B73FF); // Single calming blue

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

    _phaseProgressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _breathController,
      curve: Curves.linear,
    ));

    _breathController.addListener(_onBreathAnimationUpdate);
    _progressController.addListener(_onProgressUpdate);
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

  void _onProgressUpdate() {
    // Progress updates are handled by the visual progress circle
    // No need to track remaining time as we're not displaying it during sessions
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
      case 0: // Inhale
        HapticFeedback.lightImpact();
        break;
      case 1: // Hold
        HapticFeedback.mediumImpact();
        break;
      case 2: // Exhale
        HapticFeedback.lightImpact();
        break;
    }
  }

  void _startBreathing() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    
    if (_progressController.value == 0) {
      _progressController.forward();
    } else {
      _progressController.forward();
    }
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
        title: Text(AppLocalizations.of(context)?.wellDone ?? '🎉 Well Done!'),
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
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.breathingSession ?? 'Breathing Session'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (_isRunning) {
              _stopBreathing();
            }
            widget.onBack();
          },
        ),
        actions: [
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _breathingColor.withValues(alpha: 0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildBreathingCircle(theme),
                const SizedBox(height: 40),
                _buildPhaseIndicator(theme),
                const SizedBox(height: 32),
                _buildPhaseDescription(theme),
                const Spacer(),
                _buildControlButtons(theme),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
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
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer circular progress ring
              CustomPaint(
                size: const Size(300, 300),
                painter: CircularProgressPainter(
                  progress: 1.0 - _progressAnimation.value,
                  color: _breathingColor,
                  strokeWidth: 6,
                ),
              ),
              // Main breathing circle
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 220,
                  height: 220,
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
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: _breathingColor.withValues(alpha: 0.7),
                            fontSize: 18,
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
                  width: 260,
                  height: 260,
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
    return Column(
      children: [
        Container(
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
        ),
        const SizedBox(height: 12),
        // Phase progress bar
        AnimatedBuilder(
          animation: _phaseProgressAnimation,
          builder: (context, child) {
            return Container(
              width: 80,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: _breathingColor.withValues(alpha: 0.2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _getPhaseProgress(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: _breathingColor,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  double _getPhaseProgress() {
    final progress = _breathController.value;
    final totalCycleTime = _inhaleTime + _holdTime + _exhaleTime;
    final currentTime = progress * totalCycleTime;
    
    if (_currentPhase == 0) {
      // Inhale phase
      return (currentTime / _inhaleTime).clamp(0.0, 1.0);
    } else if (_currentPhase == 1) {
      // Hold phase
      final holdProgress = (currentTime - _inhaleTime) / _holdTime;
      return holdProgress.clamp(0.0, 1.0);
    } else {
      // Exhale phase
      final exhaleProgress = (currentTime - _inhaleTime - _holdTime) / _exhaleTime;
      return exhaleProgress.clamp(0.0, 1.0);
    }
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
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          height: 1.6,
          fontWeight: FontWeight.w300,
          fontSize: 16,
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
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Progress arc
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
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Progress arc
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
      // Inhale phase: smooth acceleration
      final inhaleProgress = t / inhaleEnd;
      return 0.9 + (0.3 * Curves.easeInOut.transform(inhaleProgress));
    } else if (t <= holdEnd) {
      // Hold phase: maintain size
      return 1.2;
    } else {
      // Exhale phase: smooth deceleration
      final exhaleProgress = (t - holdEnd) / (1.0 - holdEnd);
      return 1.2 - (0.3 * Curves.easeInOut.transform(exhaleProgress));
    }
  }
}