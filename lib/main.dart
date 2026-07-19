import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'core/services/interstitial_ad_service.dart';
import 'core/services/rewarded_ad_service.dart';
import 'core/services/ad_unlock_service.dart';
import 'core/services/offline_service.dart';
import 'core/services/notification_service.dart';
import 'injection_container.dart' as di;
import 'presentation/bloc/locale/locale_bloc.dart';
import 'presentation/bloc/locale/locale_event.dart';

import 'presentation/bloc/locale/locale_state.dart';
import 'presentation/bloc/theme/theme_bloc.dart';
import 'presentation/bloc/theme/theme_event.dart';
import 'presentation/bloc/theme/theme_state.dart';
import 'presentation/bloc/bookmark/bookmark_bloc.dart';
import 'presentation/bloc/bookmark/bookmark_event.dart';
import 'presentation/bloc/lesson_completion/lesson_completion_bloc.dart';
import 'presentation/bloc/lesson_completion/lesson_completion_event.dart';
import 'presentation/bloc/premium/premium_bloc.dart';
import 'presentation/bloc/premium/premium_event.dart';
import 'presentation/courses/bloc/courses_bloc.dart';
import 'presentation/courses/bloc/courses_event.dart';
import 'presentation/pages/splash/splash_page.dart';
import 'presentation/pages/onboarding/onboarding_page.dart';
import 'presentation/pages/navigation/main_navigation_page.dart';
import 'presentation/pages/premium/premium_page.dart';
import 'presentation/pages/premium/premium_unlocked_page.dart';
import 'presentation/courses/pages/courses_page.dart';
import 'presentation/pages/lessons/lesson_router.dart';
import 'domain/entities/section.dart';
import 'domain/entities/video.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Google Mobile Ads
  await MobileAds.instance.initialize();

  // Initialize Interstitial Ad Service (preloads first ad)
  InterstitialAdService().initialize();

  // Initialize Rewarded Ad Service (preloads first ad)
  RewardedAdService().initialize();

  // Initialize Ad Unlock Service (loads unlocked lessons from storage)
  await AdUnlockService().initialize();

  // Initialize Offline Service (monitors connectivity)
  await OfflineService().init();

  // Initialize Notification Service (for reminder notifications)
  await NotificationService().init();

  // Initialize dependency injection
  await di.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ScreenUtilInit MUST be at the very top of the widget tree
  // Platform-specific design sizes for pixel-perfect rendering on flagship devices:
  // - iOS: iPhone 16 Pro Max (440x956) - iOS flagship baseline
  // - Android: Pixel 9 Pro (412x915) - Android flagship baseline
  //
  // ADAPTIVE SCALING STRATEGY:
  // - Phones smaller than design size: Scale DOWN proportionally
  // - Phones at design size: Perfect 1:1 ratio
  // - Tablets/larger devices: Use actual screen size as design size (NO scaling up)
  runApp(
    ScreenUtilInit(
      designSize: Platform.isIOS
          ? const Size(440, 956) // iPhone 16 Pro Max
          : const Size(412, 915), // Pixel 9 Pro
      minTextAdapt: false,
      splitScreenMode: true,
      builder: (context, child) {
        // Get actual screen dimensions in logical pixels (dp)
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // ROBUST TABLET DETECTION using industry-standard 600dp breakpoint
        // Standard breakpoints:
        // - Phones: < 600dp shortest side
        // - Tablets: >= 600dp shortest side
        final shortestSide = min(screenWidth, screenHeight);
        final isTablet = shortestSide >= 600;

        // Re-initialize ScreenUtil with adaptive design size for tablets
        if (isTablet) {
          // For tablets: Use actual screen size as design size
          // This creates a 1:1 ratio (NO scaling for fonts, spacing, icons, etc.)
          ScreenUtil.init(
            context,
            designSize: Size(screenWidth, screenHeight),
            minTextAdapt: false,
            splitScreenMode: true,
          );
        }

        return const TaiChiWorkoutApp();
      },
    ),
  );
}

class TaiChiWorkoutApp extends StatefulWidget {
  const TaiChiWorkoutApp({super.key});

  @override
  State<TaiChiWorkoutApp> createState() => _TaiChiWorkoutAppState();
}

class _TaiChiWorkoutAppState extends State<TaiChiWorkoutApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Clean up dependency injection container and dispose of all services
    di.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle app resume - cancel notifications and refresh status
    if (state == AppLifecycleState.resumed) {
      // Cancel all pending reminder notifications
      NotificationService().cancelAllNotifications();

      // Get the premium bloc and refresh status
      try {
        final premiumBloc = di.sl<PremiumBloc>();
        premiumBloc.add(const CheckPremiumStatus());
      } catch (e) {
        debugPrint('Error refreshing premium status on resume: $e');
      }
    }

    // Handle app pause/detach - schedule reminder notifications
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      try {
        final localeBloc = di.sl<LocaleBloc>();
        final languageCode = localeBloc.state.locale?.languageCode ?? 'en';
        NotificationService().scheduleReminderNotifications(languageCode);
      } catch (e) {
        debugPrint('Error scheduling reminder notifications: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => di.sl<ThemeBloc>()..add(const LoadTheme()),
        ),
        BlocProvider<LocaleBloc>(
          create: (context) => di.sl<LocaleBloc>()..add(const LoadLocale()),
        ),
        BlocProvider<PremiumBloc>(
          create: (context) => di.sl<PremiumBloc>()..add(const CheckPremiumStatus()),
        ),
        BlocProvider<BookmarkBloc>(
          create: (context) => di.sl<BookmarkBloc>()..add(const LoadBookmarks()),
        ),
        BlocProvider<LessonCompletionBloc>(
          create: (context) => di.sl<LessonCompletionBloc>()..add(const LoadCompletions()),
        ),
        BlocProvider<CoursesBloc>(
          create: (context) => di.sl<CoursesBloc>()..add(const LoadCourses()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocaleBloc, LocaleState>(
            builder: (context, localeState) {
              return MaterialApp(
                onGenerateTitle: (context) => AppLocalizations.of(context)?.appName ?? 'Excel Training',
                debugShowCheckedModeBanner: false,

                // Theme configuration
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: _getThemeMode(themeState.themeMode),

                // Localization configuration
                locale: localeState.locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,

                // Routes
                initialRoute: '/',
                onGenerateRoute: (settings) {
                  switch (settings.name) {
                    case '/':
                      return MaterialPageRoute(
                        builder: (context) => const SplashPage(),
                      );
                    case '/onboarding':
                      return MaterialPageRoute(
                        builder: (context) => const OnboardingPage(),
                      );
                    case '/main':
                      return MaterialPageRoute(
                        builder: (context) => const MainNavigationPage(),
                      );
                    case '/video-player':
                    case '/lesson':
                      final args = settings.arguments;
                      Video lesson;
                      List<Section>? sections;
                      if (args is Map<String, dynamic>) {
                        lesson = args['video'] as Video? ?? args['lesson'] as Video;
                        sections = args['sections'] as List<Section>?;
                      } else {
                        lesson = args as Video;
                      }
                      // Use LessonRouter to build the appropriate page based on type
                      return MaterialPageRoute(
                        builder: (context) => LessonRouter.buildLessonPage(
                          lesson,
                          sections: sections,
                        ),
                      );
                    case '/premium':
                      return MaterialPageRoute(
                        builder: (context) => const PremiumPage(),
                      );
                    case '/premium-unlocked':
                      return MaterialPageRoute(
                        builder: (context) => const PremiumUnlockedPage(),
                      );
                    case '/courses':
                      return MaterialPageRoute(
                        builder: (context) => const CoursesPage(),
                      );
                    default:
                      return MaterialPageRoute(
                        builder: (context) => const MainNavigationPage(),
                      );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  ThemeMode _getThemeMode(AppThemeMode appThemeMode) {
    switch (appThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
