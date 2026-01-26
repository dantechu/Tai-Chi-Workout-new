import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';

// Data sources
import 'data/datasources/download_local_datasource.dart';
import 'data/datasources/premium_local_datasource.dart';
import 'data/datasources/video_local_datasource.dart';
import 'data/datasources/video_remote_datasource.dart';

// Repositories
import 'data/repositories/download_repository_impl.dart';
import 'data/repositories/premium_repository_impl.dart';
import 'data/repositories/video_repository_impl.dart';
import 'domain/repositories/download_repository.dart';
import 'domain/repositories/premium_repository.dart';
import 'domain/repositories/video_repository.dart';

// Use cases
import 'domain/usecases/download_usecases.dart';
import 'domain/usecases/get_videos.dart';
import 'domain/usecases/premium_usecases.dart';

// BLoCs
import 'presentation/bloc/video/video_bloc.dart';
import 'presentation/bloc/premium/premium_bloc.dart';
import 'presentation/bloc/theme/theme_bloc.dart';
import 'presentation/bloc/locale/locale_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Open Hive boxes
  await Hive.openBox('settings_box');
  await Hive.openBox('premium_box');
  await Hive.openBox('downloads_box');


  //! Features - Video
  // Bloc
  sl.registerFactory(
    () => VideoBloc(
      getVideos: sl(),
      getVideosByCategory: sl(),
      searchVideos: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetVideos(sl()));
  sl.registerLazySingleton(() => GetVideosByCategory(sl()));
  sl.registerLazySingleton(() => SearchVideos(sl()));
  sl.registerLazySingleton(() => GetVideo(sl()));

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
  sl.registerFactory(() => LocaleBloc(sl()));

  //! Features - Download
  // Use cases
  sl.registerLazySingleton(() => DownloadVideo(sl()));
  sl.registerLazySingleton(() => IsVideoDownloaded(sl()));

  //! Repository
  sl.registerLazySingleton<VideoRepository>(
    () => VideoRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<PremiumRepository>(
    () => PremiumRepositoryImpl(
      localDataSource: sl(),
      inAppPurchase: sl(),
    ),
  );

  sl.registerLazySingleton<DownloadRepository>(
    () => DownloadRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  //! Data sources
  sl.registerLazySingleton<VideoRemoteDataSource>(
    () => VideoRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<VideoLocalDataSource>(
    () => VideoLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<PremiumLocalDataSource>(
    () => PremiumLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<DownloadLocalDataSource>(
    () => DownloadLocalDataSourceImpl(
      dio: sl(),
      downloadBox: Hive.box('downloads_box'),
    ),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton(() => DioClient().dio);

  //! External
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => InAppPurchase.instance);

  // SharedPreferences - needs to be initialized asynchronously
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
}

void dispose() {
  sl.reset();
}