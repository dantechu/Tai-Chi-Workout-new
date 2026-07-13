import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'core/services/analytics_service.dart';
import 'core/services/revenuecat_service.dart';

// Data sources
import 'data/datasources/bookmark_local_datasource.dart';
import 'data/datasources/course_local_datasource.dart';
import 'data/datasources/course_remote_datasource.dart';
import 'data/datasources/download_local_datasource.dart';
import 'data/datasources/lesson_completion_local_datasource.dart';
import 'data/datasources/onboarding_local_datasource.dart';
import 'data/datasources/premium_local_datasource.dart';
import 'data/datasources/video_local_datasource.dart';
import 'data/datasources/video_remote_datasource.dart';

// Repositories
import 'data/repositories/bookmark_repository_impl.dart';
import 'data/repositories/course_repository_impl.dart';
import 'data/repositories/download_repository_impl.dart';
import 'data/repositories/premium_repository_impl.dart';
import 'data/repositories/video_repository_impl.dart';
import 'domain/repositories/bookmark_repository.dart';
import 'domain/repositories/course_repository.dart';
import 'domain/repositories/download_repository.dart';
import 'domain/repositories/premium_repository.dart';
import 'domain/repositories/video_repository.dart';

// Use cases
import 'domain/usecases/download_usecases.dart';
import 'domain/usecases/get_active_courses.dart';
import 'domain/usecases/get_selected_course.dart';
import 'domain/usecases/get_videos.dart';
import 'domain/usecases/premium_usecases.dart';
import 'domain/usecases/select_course.dart';

// BLoCs
import 'presentation/bloc/bookmark/bookmark_bloc.dart';
import 'presentation/bloc/lesson_completion/lesson_completion_bloc.dart';
import 'presentation/bloc/statistics/statistics_bloc.dart';
import 'presentation/bloc/video/video_bloc.dart';
import 'presentation/bloc/premium/premium_bloc.dart';
import 'presentation/bloc/theme/theme_bloc.dart';
import 'presentation/bloc/locale/locale_bloc.dart';
import 'presentation/courses/bloc/courses_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Open Hive boxes
  await Hive.openBox('settings_box');
  await Hive.openBox('premium_box');
  await Hive.openBox('downloads_box');
  await Hive.openBox('courses_box');
  await Hive.openBox<bool>('onboarding_prefs');
  await Hive.openBox<Map>('bookmarks_cache');
  await Hive.openBox<Map>('lesson_completions_cache');

  // Initialize RevenueCat service
  final revenueCatService = RevenueCatService();
  await revenueCatService.initialize();


  //! Features - Video
  // Bloc
  sl.registerFactory(
    () => VideoBloc(
      getVideos: sl(),
      getVideosByCategory: sl(),
      searchVideos: sl(),
      searchVideosAcrossAllCourses: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetVideos(sl()));
  sl.registerLazySingleton(() => GetVideosByCategory(sl()));
  sl.registerLazySingleton(() => SearchVideos(sl()));
  sl.registerLazySingleton(() => SearchVideosAcrossAllCourses(sl()));
  sl.registerLazySingleton(() => GetVideo(sl()));

  //! Features - Courses
  // Bloc
  sl.registerFactory(
    () => CoursesBloc(
      getActiveCourses: sl(),
      getSelectedCourse: sl(),
      selectCourse: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetActiveCourses(sl()));
  sl.registerLazySingleton(() => GetSelectedCourse(sl()));
  sl.registerLazySingleton(() => SelectCourse(sl()));

  //! Features - Premium
  // Bloc
  sl.registerFactory(
    () => PremiumBloc(
      purchasePremium: sl(),
      restorePurchases: sl(),
      getPremiumStatus: sl(),
      validatePremiumStatus: sl(),
      getProductDetails: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => PurchasePremium(sl()));
  sl.registerLazySingleton(() => RestorePurchases(sl()));
  sl.registerLazySingleton(() => GetPremiumStatus(sl()));
  sl.registerLazySingleton(() => ValidatePremiumStatus(sl()));
  sl.registerLazySingleton(() => GetProductDetails(sl()));

  //! Features - Theme & Locale
  // Blocs
  sl.registerFactory(() => ThemeBloc(sl()));
  sl.registerFactory(() => LocaleBloc(sl(), sl()));

  //! Features - Download
  // Use cases
  sl.registerLazySingleton(() => DownloadVideo(sl()));
  sl.registerLazySingleton(() => IsVideoDownloaded(sl()));
  sl.registerLazySingleton(() => GetLocalVideoPath(sl()));
  sl.registerLazySingleton(() => GetAllDownloads(sl()));
  sl.registerLazySingleton(() => GetCompletedDownloads(sl()));
  sl.registerLazySingleton(() => GetActiveDownloads(sl()));
  sl.registerLazySingleton(() => GetDownloadByVideoId(sl()));
  sl.registerLazySingleton(() => PauseDownload(sl()));
  sl.registerLazySingleton(() => ResumeDownload(sl()));
  sl.registerLazySingleton(() => CancelDownload(sl()));
  sl.registerLazySingleton(() => DeleteDownload(sl()));

  //! Features - Bookmark
  // Bloc
  sl.registerFactory(
    () => BookmarkBloc(
      bookmarkRepository: sl(),
    ),
  );

  //! Features - Lesson Completion
  // Bloc
  sl.registerFactory(
    () => LessonCompletionBloc(
      localDataSource: sl(),
    ),
  );

  //! Features - Statistics
  // Bloc
  sl.registerFactory(
    () => StatisticsBloc(
      completionDataSource: sl(),
      courseRepository: sl(),
    ),
  );

  //! Repository
  sl.registerLazySingleton<VideoRepository>(
    () => VideoRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
      courseRepository: sl(),
    ),
  );

  sl.registerLazySingleton<PremiumRepository>(
    () => PremiumRepositoryImpl(
      localDataSource: sl(),
      revenueCatService: sl(),
    ),
  );

  sl.registerLazySingleton<DownloadRepository>(
    () => DownloadRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<BookmarkRepository>(
    () => BookmarkRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<CourseRepository>(
    () => CourseRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  //! Data sources
  sl.registerLazySingleton<VideoRemoteDataSource>(
    () => VideoRemoteDataSourceImpl(sl(), sl()),
  );

  sl.registerLazySingleton<VideoLocalDataSource>(
    () => VideoLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<PremiumLocalDataSource>(
    () => PremiumLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<DownloadLocalDataSource>(
    () => DownloadLocalDataSourceImpl(
      downloadBox: Hive.box('downloads_box'),
    ),
  );

  sl.registerLazySingleton<CourseRemoteDataSource>(
    () => CourseRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<CourseLocalDataSource>(
    () => CourseLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<BookmarkLocalDataSource>(
    () => BookmarkLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<LessonCompletionLocalDataSource>(
    () => LessonCompletionLocalDataSourceImpl(),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton(() => DioClient().dio);

  // Analytics
  sl.registerLazySingleton(() => AnalyticsService(sl()));

  //! External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAnalytics.instance);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton<RevenueCatService>(() => revenueCatService);

  // SharedPreferences - needs to be initialized asynchronously
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
}

void dispose() {
  // Dispose of repositories that need cleanup
  try {
    final premiumRepo = sl<PremiumRepository>();
    if (premiumRepo is PremiumRepositoryImpl) {
      premiumRepo.dispose();
    }
  } catch (e) {
    debugPrint('Error disposing premium repository: $e');
  }

  // Reset all registered services
  sl.reset();
}