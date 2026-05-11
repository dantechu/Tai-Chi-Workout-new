import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'injection_container.dart' as di;
import 'presentation/bloc/locale/locale_bloc.dart';
import 'presentation/bloc/locale/locale_event.dart';
import 'presentation/bloc/locale/locale_state.dart';
import 'presentation/bloc/theme/theme_bloc.dart';
import 'presentation/bloc/theme/theme_event.dart';
import 'presentation/bloc/theme/theme_state.dart';
import 'presentation/bloc/bookmark/bookmark_bloc.dart';
import 'presentation/bloc/bookmark/bookmark_event.dart';
import 'presentation/bloc/premium/premium_bloc.dart';
import 'presentation/bloc/premium/premium_event.dart';
import 'presentation/pages/splash/splash_page.dart';
import 'presentation/pages/onboarding/onboarding_page.dart';
import 'presentation/pages/navigation/main_navigation_page.dart';
import 'presentation/pages/video_player/video_player_page.dart';
import 'presentation/pages/premium/premium_page.dart';
import 'presentation/pages/premium/premium_unlocked_page.dart';
import 'presentation/courses/pages/courses_page.dart';
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

  // Initialize dependency injection
  await di.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const TaiChiWorkoutApp());
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

    // Refresh premium status when app resumes
    if (state == AppLifecycleState.resumed) {
      // Get the premium bloc and refresh status
      try {
        final premiumBloc = di.sl<PremiumBloc>();
        premiumBloc.add(const CheckPremiumStatus());
      } catch (e) {
        debugPrint('Error refreshing premium status on resume: $e');
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
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocaleBloc, LocaleState>(
            builder: (context, localeState) {
              return MaterialApp(
                onGenerateTitle: (context) => AppLocalizations.of(context)?.appName ?? 'Tai Chi Workout',
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
                      final args = settings.arguments;
                      Video video;
                      List<Section>? sections;
                      if (args is Map<String, dynamic>) {
                        video = args['video'] as Video;
                        sections = args['sections'] as List<Section>?;
                      } else {
                        video = args as Video;
                      }
                      return MaterialPageRoute(
                        builder: (context) => VideoPlayerPage(
                          video: video,
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
