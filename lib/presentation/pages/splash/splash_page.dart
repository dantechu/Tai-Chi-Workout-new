import 'package:flutter/material.dart';

import '../../../injection_container.dart' as di;
import '../../../data/datasources/onboarding_local_datasource.dart';
import '../../bloc/video/video_bloc.dart';
import '../../bloc/video/video_event.dart';
import '../../bloc/premium/premium_bloc.dart';
import '../../bloc/premium/premium_event.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _scaleController.forward();
    });
  }

  Future<void> _startInitialization() async {
    try {
      // Initialize app data
      await _initializeAppData();

      // Check if first time user
      final onboardingDataSource = di.sl<OnboardingLocalDataSource>();
      final isFirstTime = await onboardingDataSource.isFirstTime();

      // Wait for minimum splash duration
      await Future.delayed(const Duration(seconds: 3));

      // Navigate to appropriate screen
      if (mounted) {
        if (isFirstTime) {
          Navigator.of(context).pushReplacementNamed('/onboarding');
        } else {
          Navigator.of(context).pushReplacementNamed('/main');
        }
      }
    } catch (e) {
      // Handle initialization error
      if (mounted) {
        _showErrorDialog();
      }
    }
  }

  Future<void> _initializeAppData() async {
    // Initialize video bloc and load videos
    final videoBloc = di.sl<VideoBloc>();
    videoBloc.add(const LoadVideos());
    
    // Initialize premium bloc and check premium status
    final premiumBloc = di.sl<PremiumBloc>();
    premiumBloc.add(const CheckPremiumStatus());
    
    // Simulate other initialization tasks
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Initialization Error'),
          content: const Text(
            'Failed to initialize the app. Please check your internet connection and try again.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startInitialization();
              },
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo with Animation
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.self_improvement,
                        size: 60,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // App Title
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Tai Chi Workout',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Subtitle
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Master the Art of Tai Chi',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                ),
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Loading Indicator
            FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                  strokeWidth: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}