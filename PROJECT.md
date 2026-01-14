# Tai Chi Workout Flutter App - Complete Project Documentation

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Architecture & State Management](#2-architecture--state-management)
3. [API Integration & Backend Services](#3-api-integration--backend-services)
4. [Video Player Implementation](#4-video-player-implementation)
5. [Music/Voice Player & Breathing Timer](#5-musicvoice-player--breathing-timer)
6. [Premium Features & In-App Purchases](#6-premium-features--in-app-purchases)
7. [Ads Integration](#7-ads-integration)
8. [Theming System](#8-theming-system)
9. [Multi-Language Localization](#9-multi-language-localization)
10. [UI/UX Design & Screens](#10-uiux-design--screens)
11. [Dependencies & Setup](#11-dependencies--setup)
12. [Project Structure](#12-project-structure)

---

## 1. Project Overview

### 1.1 App Information
- **Name:** Tai Chi Workout Training
- **Platform:** Android & iOS (Flutter 3.35.7)
- **Target SDK:** Android 13+ (API 33+), iOS 13+
- **Bundle ID:** `com.amazingelearning.taichi`
- **Business Model:** Freemium (Free with ads + Premium unlock)

### 1.2 App Purpose
A mobile video training platform for learning Tai Chi featuring structured lessons with professional instructor John Saxxon. The app delivers instructional content through video lessons, relaxing music, voice guidance, and breathing exercises.

### 1.3 Core Features
- **22 Video Lessons** organized in 6 categories (Intro, Structure, Flexibility, Fluidity, Power)
- **Advanced Video Player** with speed controls, captions, pause/play
- **Music & Voice Player** for relaxing Tai Chi background audio and guided meditation
- **Breathing Timer** with animated circle and voice guidance
- **Offline Downloads** (Premium feature)
- **Ad-Free Experience** (Premium feature)
- **Multi-Language Support** (7 languages)
- **Light/Dark Theme**
- **Material 3 Design**

### 1.4 Content Categories
1. **About Us** - 1 video
2. **Intro by John Saxxon** - 2 videos (Intro, Course Outline)
3. **Structure** - 3 videos (Parts 1-3)
4. **Flexibility** - 3 videos (Parts 1-3)
5. **Fluidity** - 10 videos (Movements 1-10)
6. **Power** - 3 videos (Parts 1-3)

---

## 2. Architecture & State Management

### 2.1 Clean Architecture Layers

```
lib/
├── core/                      # Core utilities, constants, error handling
│   ├── constants/
│   ├── error/
│   ├── network/
│   ├── theme/
│   └── localization/
├── domain/                    # Business logic layer
│   ├── entities/              # Pure Dart models
│   ├── repositories/          # Abstract repository interfaces
│   └── usecases/              # Business use cases
├── data/                      # Data layer
│   ├── models/                # Data models (JSON serialization)
│   ├── datasources/           # Remote & Local data sources
│   └── repositories/          # Repository implementations
└── presentation/              # UI layer
    ├── bloc/                  # BLoC state management
    ├── pages/                 # Screen widgets
    └── widgets/               # Reusable UI components
```

### 2.2 State Management - Flutter Bloc

**Why Bloc?**
- Predictable state management
- Separation of business logic from UI
- Excellent testing support
- Community standard for clean architecture

**Key Blocs:**

```dart
// Video Management
VideoBloc - Handles video list, filtering, search
VideoPlayerBloc - Controls video playback state
DownloadBloc - Manages offline video downloads

// Premium & Monetization
PremiumBloc - Premium status, purchase flow
AdsBloc - Ad loading and display logic

// Media Players
MusicPlayerBloc - Background music/voice playback
BreathingTimerBloc - Breathing exercise state

// App Settings
ThemeBloc - Light/dark mode switching
LocaleBloc - Language switching
SettingsBloc - App preferences
```

### 2.3 Dependency Injection

Use **get_it** for service locator pattern:

```dart
// injection_container.dart
final sl = GetIt.instance;

void init() {
  // Blocs
  sl.registerFactory(() => VideoBloc(sl()));
  sl.registerFactory(() => PremiumBloc(sl(), sl()));

  // Use Cases
  sl.registerLazySingleton(() => GetVideos(sl()));
  sl.registerLazySingleton(() => PurchasePremium(sl()));

  // Repositories
  sl.registerLazySingleton<VideoRepository>(
    () => VideoRepositoryImpl(sl(), sl()),
  );

  // Data Sources
  sl.registerLazySingleton<VideoRemoteDataSource>(
    () => VideoRemoteDataSourceImpl(sl()),
  );

  // Core
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => SharedPreferences.getInstance());
}
```

---

## 3. API Integration & Backend Services

### 3.1 Video Content API

**Base URL:** `https://www.amazingonlinecourse.com/mobile/taichi/`

**Video URL Pattern:**
```
https://www.amazingonlinecourse.com/mobile/taichi/taichi_{section}_{row}.mp4
```

**Example URLs:**
- `taichi_2_1.mp4` - Intro by John Saxxon
- `taichi_3_1.mp4` - Structure Part 1
- `taichi_5_7.mp4` - Fluidity Movement 7

### 3.2 Data Models

```dart
// Video Entity (domain layer)
class Video {
  final String id;
  final String title;
  final String category;
  final String videoUrl;
  final String? thumbnailUrl;
  final int sectionNumber;
  final int rowNumber;
  final Duration duration;
  final bool isPremium;

  Video({...});
}

// Lesson/Category Entity
class Lesson {
  final String id;
  final String title;
  final String description;
  final List<Video> videos;
  final int order;

  Lesson({...});
}

// Premium Status Model
class PremiumStatus {
  final bool isPremium;
  final DateTime? purchaseDate;
  final String? productId;

  PremiumStatus({...});
}
```

### 3.3 Local Storage

**Use Hive for local database:**

```dart
// Boxes
- videos_box: Cache video metadata
- downloads_box: Store downloaded video paths
- premium_box: Store premium status (encrypted)
- settings_box: App preferences
- favorites_box: User favorite videos
```

**Secure Storage (flutter_secure_storage):**
```dart
// Store sensitive data
- premium_purchase_token
- user_id (if implemented)
```

### 3.4 Video Content Provider

```dart
// lib/data/datasources/video_remote_datasource.dart
abstract class VideoRemoteDataSource {
  Future<List<VideoModel>> getAllVideos();
  Future<VideoModel> getVideo(String id);
}

class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  // Hardcoded content (matching iOS app structure)
  static const List<Map<String, dynamic>> _videoData = [
    {
      'section': 1,
      'title': 'About us',
      'videos': [
        {'row': 1, 'title': 'About us', 'isPremium': false}
      ]
    },
    {
      'section': 2,
      'title': 'Intro by John Saxxon',
      'videos': [
        {'row': 1, 'title': 'Intro by John Saxxon', 'isPremium': false},
        {'row': 2, 'title': 'Course Outline', 'isPremium': false}
      ]
    },
    // ... more sections
  ];

  @override
  Future<List<VideoModel>> getAllVideos() async {
    return _videoData.map((section) {
      // Transform to VideoModel list
    }).toList();
  }
}
```

---

## 4. Video Player Implementation

### 4.1 Video Player Package

**Use:** `video_player` + `chewie` (enhanced controls)

### 4.2 Video Player Features

**Core Playback Controls:**
- Play / Pause / Stop
- Seek forward/backward
- Progress bar with timestamp
- Fullscreen toggle

**Speed Controls:**
- 0.25x (Slow motion)
- 0.5x
- 1.0x (Normal)
- 1.5x
- 2.0x (Fast forward)

**Captions:**
- Show/Hide toggle (if captions available)
- Support for SRT/VTT formats

**Visual Effects:**
- Gentle fade in/out transitions (300ms duration)
- Smooth control overlay animations

### 4.3 Video Player Widget Structure

```dart
// lib/presentation/widgets/video_player_widget.dart
class CustomVideoPlayer extends StatefulWidget {
  final Video video;
  final bool isDownloaded;

  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    final videoSource = widget.isDownloaded
        ? VideoPlayerController.file(File(localPath))
        : VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl));

    _controller = videoSource;

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: false,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Theme.of(context).primaryColor,
        handleColor: Theme.of(context).primaryColor,
      ),
      placeholder: FadeInImage(...),
      allowFullScreen: true,
      allowPlaybackSpeedChanging: true,
      playbackSpeeds: [0.25, 0.5, 1.0, 1.5, 2.0],
      subtitle: widget.video.hasSubtitles
          ? Subtitles([...])
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _controller.value.isInitialized ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: Chewie(controller: _chewieController),
    );
  }
}
```

### 4.4 Video Download Manager

```dart
// lib/data/datasources/video_download_manager.dart
class VideoDownloadManager {
  final Dio dio;
  final HiveInterface hive;

  Future<void> downloadVideo(Video video, {
    Function(double)? onProgress,
  }) async {
    final downloadPath = await _getDownloadPath(video.id);

    await dio.download(
      video.videoUrl,
      downloadPath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          final progress = received / total;
          onProgress?.call(progress);
        }
      },
    );

    // Save to Hive
    final box = await hive.openBox('downloads');
    await box.put(video.id, {
      'path': downloadPath,
      'downloadedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<String> _getDownloadPath(String videoId) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/videos/$videoId.mp4';
  }

  Future<bool> isDownloaded(String videoId) async {
    final box = await hive.openBox('downloads');
    return box.containsKey(videoId);
  }

  Future<String?> getLocalPath(String videoId) async {
    final box = await hive.openBox('downloads');
    final data = box.get(videoId);
    return data?['path'];
  }

  Future<void> deleteDownload(String videoId) async {
    final path = await getLocalPath(videoId);
    if (path != null) {
      await File(path).delete();
      final box = await hive.openBox('downloads');
      await box.delete(videoId);
    }
  }
}
```

---

## 5. Music/Voice Player & Breathing Timer

### 5.1 Music/Voice Player

**Package:** `audioplayers`

**Features:**
- Play relaxing Tai Chi background music
- Play voice guidance tracks
- Background playback support
- Volume control
- Play/Pause/Stop
- Track selection

**Audio Assets:**
```
assets/audio/
├── music/
│   ├── tai_chi_calm.mp3
│   ├── meditation_flow.mp3
│   └── peaceful_chi.mp3
└── voice/
    ├── breathing_guide_en.mp3
    ├── breathing_guide_zh.mp3
    └── meditation_guide.mp3
```

**Music Player Widget:**

```dart
// lib/presentation/widgets/music_player_widget.dart
class MusicPlayerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
      builder: (context, state) {
        return Card(
          child: Column(
            children: [
              Text(
                state.currentTrack?.title ?? 'Select Music',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.skip_previous),
                    onPressed: () => context.read<MusicPlayerBloc>()
                        .add(PreviousTrack()),
                  ),
                  IconButton(
                    icon: Icon(state.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled),
                    iconSize: 64,
                    onPressed: () => context.read<MusicPlayerBloc>()
                        .add(TogglePlayPause()),
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next),
                    onPressed: () => context.read<MusicPlayerBloc>()
                        .add(NextTrack()),
                  ),
                ],
              ),
              Slider(
                value: state.volume,
                onChanged: (value) => context.read<MusicPlayerBloc>()
                    .add(SetVolume(value)),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### 5.2 Breathing Timer

**Features:**
- Animated circle (expanding for inhale, contracting for exhale)
- Adjustable duration (1-10 minutes)
- Soft sound cues for inhale/exhale
- Optional voice guidance ("Inhale… Exhale…")
- Calm color palette with smooth animations
- Haptic feedback on breath transitions

**Breathing Timer Widget:**

```dart
// lib/presentation/widgets/breathing_timer_widget.dart
class BreathingTimerWidget extends StatefulWidget {
  @override
  _BreathingTimerWidgetState createState() => _BreathingTimerWidgetState();
}

class _BreathingTimerWidgetState extends State<BreathingTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 8), // 4s inhale + 4s exhale
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      // Inhale started
      _playSound('inhale');
      if (voiceGuidanceEnabled) {
        _playVoice('inhale');
      }
      HapticFeedback.lightImpact();
    } else if (status == AnimationStatus.reverse) {
      // Exhale started
      _playSound('exhale');
      if (voiceGuidanceEnabled) {
        _playVoice('exhale');
      }
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BreathingTimerBloc, BreathingTimerState>(
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer display
            Text(
              _formatTime(state.remainingTime),
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 40),

            // Animated breathing circle
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Container(
                  width: 300 * _scaleAnimation.value,
                  height: 300 * _scaleAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.3),
                        Theme.of(context).primaryColor.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _animationController.status == AnimationStatus.forward
                          ? context.l10n.inhale
                          : context.l10n.exhale,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 40),

            // Duration selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(context.l10n.duration),
                SizedBox(width: 16),
                DropdownButton<int>(
                  value: state.durationMinutes,
                  items: List.generate(10, (i) => i + 1)
                      .map((min) => DropdownMenuItem(
                            value: min,
                            child: Text('$min min'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    context.read<BreathingTimerBloc>()
                        .add(SetDuration(value!));
                  },
                ),
              ],
            ),

            // Voice guidance toggle
            SwitchListTile(
              title: Text(context.l10n.voiceGuidance),
              value: state.voiceGuidanceEnabled,
              onChanged: (value) {
                context.read<BreathingTimerBloc>()
                    .add(ToggleVoiceGuidance());
              },
            ),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(state.isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(state.isRunning
                      ? context.l10n.pause
                      : context.l10n.start),
                  onPressed: () {
                    if (state.isRunning) {
                      _animationController.stop();
                      context.read<BreathingTimerBloc>().add(PauseTimer());
                    } else {
                      _animationController.repeat(reverse: true);
                      context.read<BreathingTimerBloc>().add(StartTimer());
                    }
                  },
                ),
                SizedBox(width: 16),
                OutlinedButton.icon(
                  icon: Icon(Icons.stop),
                  label: Text(context.l10n.stop),
                  onPressed: () {
                    _animationController.reset();
                    context.read<BreathingTimerBloc>().add(StopTimer());
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _playSound(String type) async {
    await _audioPlayer.play(
      AssetSource('audio/sounds/${type}_sound.mp3'),
      volume: 0.3,
    );
  }

  void _playVoice(String type) async {
    final locale = context.read<LocaleBloc>().state.locale.languageCode;
    await _audioPlayer.play(
      AssetSource('audio/voice/${type}_${locale}.mp3'),
    );
  }

  String _formatTime(Duration duration) {
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
```

**Audio Assets Required:**
```
assets/audio/sounds/
├── inhale_sound.mp3      # Soft bell/chime
└── exhale_sound.mp3      # Gentle bowl/gong

assets/audio/voice/
├── inhale_en.mp3         # "Inhale"
├── exhale_en.mp3         # "Exhale"
├── inhale_zh.mp3         # "吸气"
├── exhale_zh.mp3         # "呼气"
└── ... (other languages)
```

---

## 6. Premium Features & In-App Purchases

### 6.1 Premium Benefits

**Free Users:**
- Stream videos (online only)
- View all video titles
- See banner ads
- Access to 2-3 preview videos

**Premium Users:**
- Offline video downloads
- No advertisements
- Unlock all 22 lessons
- Priority support
- Future premium content access

### 6.2 In-App Purchase Setup

**Package:** `in_app_purchase`

**Product Configuration:**

**Android (Google Play):**
```
Product ID: com.amazingelearning.taichi.premium
Type: One-time purchase (non-consumable)
Price: $9.99 USD (or equivalent)
```

**iOS (App Store):**
```
Product ID: com.amazingelearning.taichi.Premium
Type: Non-consumable
Price: $9.99 USD (or equivalent)
```

### 6.3 Premium Implementation

```dart
// lib/domain/usecases/purchase_premium.dart
class PurchasePremium {
  final PremiumRepository repository;

  Future<Either<Failure, bool>> call() async {
    return await repository.purchasePremium();
  }
}

// lib/data/repositories/premium_repository_impl.dart
class PremiumRepositoryImpl implements PremiumRepository {
  final InAppPurchase _iap = InAppPurchase.instance;
  final FlutterSecureStorage _secureStorage;
  final HiveInterface _hive;

  @override
  Future<Either<Failure, bool>> purchasePremium() async {
    try {
      // Check if purchases are available
      final available = await _iap.isAvailable();
      if (!available) {
        return Left(PurchaseFailure('Store not available'));
      }

      // Get product details
      const productId = 'com.amazingelearning.taichi.premium';
      final response = await _iap.queryProductDetails({productId});

      if (response.productDetails.isEmpty) {
        return Left(PurchaseFailure('Product not found'));
      }

      // Initiate purchase
      final product = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: product);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);

      // Listen to purchase updates
      _iap.purchaseStream.listen((purchases) async {
        for (var purchase in purchases) {
          if (purchase.productID == productId) {
            if (purchase.status == PurchaseStatus.purchased) {
              // Verify purchase
              await _verifyPurchase(purchase);

              // Save premium status
              await _savePremiumStatus(true, purchase.purchaseID);

              // Complete purchase
              await _iap.completePurchase(purchase);

              return Right(true);
            }
          }
        }
      });

      return Right(true);
    } catch (e) {
      return Left(PurchaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> restorePurchases() async {
    try {
      await _iap.restorePurchases();

      final purchases = await _iap.queryPurchaseDetails();
      final premiumPurchase = purchases.pastPurchases
          .where((p) => p.productID.contains('premium'))
          .firstOrNull;

      if (premiumPurchase != null) {
        await _savePremiumStatus(true, premiumPurchase.purchaseID);
        return Right(true);
      }

      return Right(false);
    } catch (e) {
      return Left(PurchaseFailure(e.toString()));
    }
  }

  @override
  Future<bool> isPremium() async {
    // Check secure storage
    final token = await _secureStorage.read(key: 'premium_token');
    if (token != null) return true;

    // Check Hive
    final box = await _hive.openBox('premium');
    return box.get('is_premium', defaultValue: false);
  }

  Future<void> _savePremiumStatus(bool status, String? purchaseId) async {
    // Save to secure storage
    if (purchaseId != null) {
      await _secureStorage.write(
        key: 'premium_token',
        value: purchaseId,
      );
    }

    // Save to Hive
    final box = await _hive.openBox('premium');
    await box.put('is_premium', status);
    await box.put('purchase_date', DateTime.now().toIso8601String());
    if (purchaseId != null) {
      await box.put('purchase_id', purchaseId);
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    // TODO: Implement server-side verification
    // Send purchase.verificationData to backend
    // Backend validates with Google/Apple
  }
}
```

### 6.4 Premium BLoC

```dart
// lib/presentation/bloc/premium/premium_bloc.dart
class PremiumBloc extends Bloc<PremiumEvent, PremiumState> {
  final PurchasePremium purchasePremium;
  final RestorePurchases restorePurchases;
  final CheckPremiumStatus checkPremiumStatus;

  PremiumBloc({
    required this.purchasePremium,
    required this.restorePurchases,
    required this.checkPremiumStatus,
  }) : super(PremiumInitial()) {
    on<CheckPremium>(_onCheckPremium);
    on<PurchasePremiumRequested>(_onPurchase);
    on<RestorePremiumRequested>(_onRestore);
  }

  Future<void> _onCheckPremium(
    CheckPremium event,
    Emitter<PremiumState> emit,
  ) async {
    final result = await checkPremiumStatus();
    result.fold(
      (failure) => emit(PremiumError(failure.message)),
      (isPremium) => emit(isPremium
          ? PremiumActive()
          : PremiumInactive()),
    );
  }

  Future<void> _onPurchase(
    PurchasePremiumRequested event,
    Emitter<PremiumState> emit,
  ) async {
    emit(PremiumPurchasing());
    final result = await purchasePremium();
    result.fold(
      (failure) => emit(PremiumError(failure.message)),
      (success) => emit(PremiumActive()),
    );
  }

  Future<void> _onRestore(
    RestorePremiumRequested event,
    Emitter<PremiumState> emit,
  ) async {
    emit(PremiumRestoring());
    final result = await restorePurchases();
    result.fold(
      (failure) => emit(PremiumError(failure.message)),
      (restored) => emit(restored
          ? PremiumActive()
          : PremiumInactive()),
    );
  }
}
```

---

## 7. Ads Integration

### 7.1 Google AdMob Setup

**Package:** `google_mobile_ads`

**Ad Units:**

**Android:**
```yaml
# android/app/src/main/AndroidManifest.xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-9740790965972178~4504042514"/>
```

**iOS:**
```xml
<!-- ios/Runner/Info.plist -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-9740790965972178~4504042514</string>
```

**Ad Unit IDs:**
```dart
// lib/core/constants/ad_constants.dart
class AdConstants {
  // Banner Ads
  static const String androidBannerId =
      'ca-app-pub-9740790965972178/2276608078';
  static const String iosBannerId =
      'ca-app-pub-9740790965972178/2276608078';

  // Interstitial Ads (for future use)
  static const String androidInterstitialId =
      'ca-app-pub-9740790965972178/XXXXXXXX';
  static const String iosInterstitialId =
      'ca-app-pub-9740790965972178/XXXXXXXX';

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return androidBannerId;
    } else if (Platform.isIOS) {
      return iosBannerId;
    }
    throw UnsupportedError('Unsupported platform');
  }
}
```

### 7.2 Banner Ad Widget

```dart
// lib/presentation/widgets/banner_ad_widget.dart
class BannerAdWidget extends StatefulWidget {
  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner ad failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PremiumBloc, PremiumState>(
      builder: (context, state) {
        // Hide ads for premium users
        if (state is PremiumActive) {
          return SizedBox.shrink();
        }

        if (!_isAdLoaded || _bannerAd == null) {
          return SizedBox(height: 50);
        }

        return Container(
          alignment: Alignment.center,
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        );
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
```

### 7.3 Ad Display Strategy

**Where to show ads:**
- Bottom of main video list screen
- Bottom of video detail/player screen (before playback)
- Bottom of about/contact screen

**Where NOT to show ads:**
- During video playback (user experience priority)
- Settings screen
- Premium purchase screen
- Any screen for premium users

---

## 8. Theming System

### 8.1 Material 3 Theme Configuration

```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF2E7D32), // Tai Chi green
      brightness: Brightness.light,
      primary: Color(0xFF2E7D32),
      secondary: Color(0xFF8D6E63), // Earthy brown
      tertiary: Color(0xFF1976D2), // Calm blue
      surface: Colors.white,
      background: Color(0xFFF5F5F5),
      error: Color(0xFFD32F2F),
    ),

    // Typography
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
    ),

    // Card theme
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // App bar theme
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 2,
    ),

    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(120, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    // Bottom navigation
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: Color(0xFF2E7D32).withOpacity(0.2),
      height: 64,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF66BB6A), // Lighter green for dark mode
      brightness: Brightness.dark,
      primary: Color(0xFF66BB6A),
      secondary: Color(0xFFBCAAA4),
      tertiary: Color(0xFF64B5F6),
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      error: Color(0xFFEF5350),
    ),

    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: Colors.white70,
      ),
    ),

    cardTheme: CardTheme(
      elevation: 4,
      color: Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color(0xFF1E1E1E),
    ),
  );
}
```

### 8.2 Theme BLoC

```dart
// lib/presentation/bloc/theme/theme_bloc.dart
enum AppThemeMode { light, dark, system }

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences prefs;

  ThemeBloc({required this.prefs}) : super(ThemeState.initial()) {
    on<ChangeTheme>(_onChangeTheme);
    on<LoadTheme>(_onLoadTheme);
  }

  Future<void> _onChangeTheme(
    ChangeTheme event,
    Emitter<ThemeState> emit,
  ) async {
    await prefs.setString('theme_mode', event.themeMode.name);
    emit(ThemeState(themeMode: event.themeMode));
  }

  Future<void> _onLoadTheme(
    LoadTheme event,
    Emitter<ThemeState> emit,
  ) async {
    final themeName = prefs.getString('theme_mode') ?? 'system';
    final themeMode = AppThemeMode.values.firstWhere(
      (e) => e.name == themeName,
      orElse: () => AppThemeMode.system,
    );
    emit(ThemeState(themeMode: themeMode));
  }
}

class ThemeState {
  final AppThemeMode themeMode;

  ThemeState({required this.themeMode});

  factory ThemeState.initial() => ThemeState(themeMode: AppThemeMode.system);

  ThemeMode get materialThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
```

### 8.3 Theme UI

```dart
// In MaterialApp
BlocBuilder<ThemeBloc, ThemeState>(
  builder: (context, state) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: state.materialThemeMode,
      // ...
    );
  },
)

// Settings screen theme selector
ListTile(
  leading: Icon(Icons.palette_outlined),
  title: Text(context.l10n.theme),
  trailing: SegmentedButton<AppThemeMode>(
    segments: [
      ButtonSegment(
        value: AppThemeMode.light,
        icon: Icon(Icons.light_mode),
        label: Text(context.l10n.light),
      ),
      ButtonSegment(
        value: AppThemeMode.dark,
        icon: Icon(Icons.dark_mode),
        label: Text(context.l10n.dark),
      ),
      ButtonSegment(
        value: AppThemeMode.system,
        icon: Icon(Icons.brightness_auto),
        label: Text(context.l10n.system),
      ),
    ],
    selected: {state.themeMode},
    onSelectionChanged: (Set<AppThemeMode> selected) {
      context.read<ThemeBloc>().add(
        ChangeTheme(selected.first),
      );
    },
  ),
)
```

---

## 9. Multi-Language Localization

### 9.1 Supported Languages

1. **English (en)** - Default
2. **Simplified Chinese (zh)**
3. **Spanish (es)**
4. **Japanese (ja)**
5. **French (fr)**
6. **German (de)**
7. **Korean (ko)**

### 9.2 Localization Setup

**pubspec.yaml:**
```yaml
flutter:
  generate: true

dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any
```

**l10n.yaml:**
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

### 9.3 ARB Files Structure

```
lib/l10n/
├── app_en.arb        # English
├── app_zh.arb        # Simplified Chinese
├── app_es.arb        # Spanish
├── app_ja.arb        # Japanese
├── app_fr.arb        # French
├── app_de.arb        # German
└── app_ko.arb        # Korean
```

**Example: app_en.arb**
```json
{
  "@@locale": "en",

  "appName": "Tai Chi Workout",
  "@appName": {
    "description": "Application name"
  },

  "home": "Home",
  "videos": "Videos",
  "practice": "Practice",
  "settings": "Settings",

  "allLessons": "All Lessons",
  "aboutUs": "About Us",
  "intro": "Introduction",
  "structure": "Structure",
  "flexibility": "Flexibility",
  "fluidity": "Fluidity",
  "power": "Power",

  "play": "Play",
  "pause": "Pause",
  "stop": "Stop",
  "download": "Download",
  "downloaded": "Downloaded",
  "delete": "Delete",

  "premiumTitle": "Unlock Premium",
  "premiumSubtitle": "Get unlimited access",
  "premiumFeature1": "Offline video downloads",
  "premiumFeature2": "No advertisements",
  "premiumFeature3": "Unlock all lessons",
  "premiumPrice": "$9.99",
  "purchase": "Purchase",
  "restore": "Restore Purchases",

  "music": "Music",
  "voiceGuidance": "Voice Guidance",
  "breathingTimer": "Breathing Timer",
  "duration": "Duration",
  "inhale": "Inhale",
  "exhale": "Exhale",

  "theme": "Theme",
  "light": "Light",
  "dark": "Dark",
  "system": "System",

  "language": "Language",
  "english": "English",
  "chinese": "简体中文",
  "spanish": "Español",
  "japanese": "日本語",
  "french": "Français",
  "german": "Deutsch",
  "korean": "한국어",

  "about": "About",
  "privacyPolicy": "Privacy Policy",
  "termsOfService": "Terms of Service",
  "contactUs": "Contact Us",
  "rateApp": "Rate App",

  "video": "{count, plural, =1{1 video} other{{count} videos}}",
  "@video": {
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}
```

**Example: app_zh.arb (Simplified Chinese)**
```json
{
  "@@locale": "zh",

  "appName": "太极拳锻炼",
  "home": "主页",
  "videos": "视频",
  "practice": "练习",
  "settings": "设置",

  "allLessons": "所有课程",
  "aboutUs": "关于我们",
  "intro": "介绍",
  "structure": "结构",
  "flexibility": "灵活性",
  "fluidity": "流畅性",
  "power": "力量",

  "play": "播放",
  "pause": "暂停",
  "stop": "停止",
  "download": "下载",
  "downloaded": "已下载",
  "delete": "删除",

  "premiumTitle": "解锁高级版",
  "premiumSubtitle": "获得无限访问",
  "premiumFeature1": "离线视频下载",
  "premiumFeature2": "无广告",
  "premiumFeature3": "解锁所有课程",
  "premiumPrice": "$9.99",
  "purchase": "购买",
  "restore": "恢复购买",

  "music": "音乐",
  "voiceGuidance": "语音指导",
  "breathingTimer": "呼吸计时器",
  "duration": "持续时间",
  "inhale": "吸气",
  "exhale": "呼气",

  "theme": "主题",
  "light": "浅色",
  "dark": "深色",
  "system": "系统",

  "language": "语言",

  "about": "关于",
  "privacyPolicy": "隐私政策",
  "contactUs": "联系我们"
}
```

### 9.4 Locale BLoC

```dart
// lib/presentation/bloc/locale/locale_bloc.dart
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final SharedPreferences prefs;

  LocaleBloc({required this.prefs}) : super(LocaleState.initial()) {
    on<ChangeLocale>(_onChangeLocale);
    on<LoadLocale>(_onLoadLocale);
  }

  Future<void> _onChangeLocale(
    ChangeLocale event,
    Emitter<LocaleState> emit,
  ) async {
    await prefs.setString('locale', event.locale.languageCode);
    emit(LocaleState(locale: event.locale));
  }

  Future<void> _onLoadLocale(
    LoadLocale event,
    Emitter<LocaleState> emit,
  ) async {
    final languageCode = prefs.getString('locale');
    if (languageCode != null) {
      emit(LocaleState(locale: Locale(languageCode)));
    }
  }
}

class LocaleState {
  final Locale locale;

  LocaleState({required this.locale});

  factory LocaleState.initial() => LocaleState(locale: Locale('en'));
}
```

### 9.5 Usage in MaterialApp

```dart
BlocBuilder<LocaleBloc, LocaleState>(
  builder: (context, state) {
    return MaterialApp(
      locale: state.locale,
      supportedLocales: [
        Locale('en'),
        Locale('zh'),
        Locale('es'),
        Locale('ja'),
        Locale('fr'),
        Locale('de'),
        Locale('ko'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // ...
    );
  },
)
```

### 9.6 Language Selector UI

```dart
// Settings screen
ListTile(
  leading: Icon(Icons.language),
  title: Text(context.l10n.language),
  trailing: DropdownButton<Locale>(
    value: state.locale,
    items: [
      DropdownMenuItem(
        value: Locale('en'),
        child: Row(
          children: [
            Text('🇺🇸'),
            SizedBox(width: 8),
            Text('English'),
          ],
        ),
      ),
      DropdownMenuItem(
        value: Locale('zh'),
        child: Row(
          children: [
            Text('🇨🇳'),
            SizedBox(width: 8),
            Text('简体中文'),
          ],
        ),
      ),
      DropdownMenuItem(
        value: Locale('es'),
        child: Row(
          children: [
            Text('🇪🇸'),
            SizedBox(width: 8),
            Text('Español'),
          ],
        ),
      ),
      DropdownMenuItem(
        value: Locale('ja'),
        child: Row(
          children: [
            Text('🇯🇵'),
            SizedBox(width: 8),
            Text('日本語'),
          ],
        ),
      ),
      DropdownMenuItem(
        value: Locale('fr'),
        child: Row(
          children: [
            Text('🇫🇷'),
            SizedBox(width: 8),
            Text('Français'),
          ],
        ),
      ),
      DropdownMenuItem(
        value: Locale('de'),
        child: Row(
          children: [
            Text('🇩🇪'),
            SizedBox(width: 8),
            Text('Deutsch'),
          ],
        ),
      ),
      DropdownMenuItem(
        value: Locale('ko'),
        child: Row(
          children: [
            Text('🇰🇷'),
            SizedBox(width: 8),
            Text('한국어'),
          ],
        ),
      ),
    ],
    onChanged: (locale) {
      if (locale != null) {
        context.read<LocaleBloc>().add(ChangeLocale(locale));
      }
    },
  ),
)
```

---

## 10. UI/UX Design & Screens

### 10.1 Navigation Structure

**Bottom Navigation Bar (4 tabs):**
1. **Home** - Video lessons list
2. **Practice** - Music player + Breathing timer
3. **Premium** - Upgrade screen (hidden for premium users)
4. **Settings** - App settings

### 10.2 Screen Details

#### 10.2.1 Splash Screen

**Purpose:** App initialization, check premium status

**Design:**
- Tai Chi logo with gradient background
- Calm animation (fade in logo + tagline)
- Progress indicator
- Duration: 2-3 seconds

```dart
// lib/presentation/pages/splash_page.dart
class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([
      MobileAds.instance.initialize(),
      sl<LocaleBloc>().stream.first,
      sl<ThemeBloc>().stream.first,
      sl<PremiumBloc>().stream.first,
    ]);

    await Future.delayed(Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF66BB6A),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  height: 150,
                ),
                SizedBox(height: 24),
                Text(
                  'Tai Chi Workout',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Find Your Inner Peace',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 48),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

#### 10.2.2 Home Screen (Video List)

**Layout:**
- App bar with app name + search icon
- Horizontal scrolling category chips (All, Intro, Structure, etc.)
- Grid/List view of videos
- Each video card shows:
  - Thumbnail (generated or placeholder)
  - Title
  - Duration
  - Download status icon (premium users)
  - Premium badge (if locked)
- Banner ad at bottom (free users)
- Floating action button to scroll to top

**Video Card Design:**
```dart
// lib/presentation/widgets/video_card.dart
class VideoCard extends StatelessWidget {
  final Video video;
  final bool isDownloaded;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (video.isPremium && !isPremium) {
            _showPremiumDialog(context);
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => VideoPlayerPage(video: video),
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: video.thumbnailUrl != null
                      ? Image.network(
                          video.thumbnailUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),

                // Premium badge
                if (video.isPremium && !isPremium)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Download indicator
                if (isPremium)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDownloaded
                            ? Icons.download_done
                            : Icons.download,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                // Duration
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatDuration(video.duration),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Video info
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    video.category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}
```

#### 10.2.3 Video Player Screen

**Layout:**
- Full-screen video player (landscape + portrait)
- Custom controls overlay:
  - Play/Pause button (center)
  - Progress bar with scrubbing
  - Speed selector (0.25x - 2x)
  - Caption toggle (if available)
  - Fullscreen toggle
  - Back button
- Video title and description below player (portrait mode)
- Related videos section
- Banner ad at bottom (free users, only in portrait before playback)

#### 10.2.4 Practice Screen

**Layout - Two Tabs:**

**Tab 1: Music Player**
- Large album art (animated breathing circle or static image)
- Track title
- Playback controls (prev, play/pause, next)
- Volume slider
- Track list below
- Categories: Relaxing Music, Voice Guidance, Meditation

**Tab 2: Breathing Timer**
- Large animated circle (center)
- Current phase text (Inhale/Exhale)
- Countdown timer
- Duration selector dropdown
- Voice guidance toggle
- Start/Pause/Stop buttons
- Instructions card at bottom

```dart
// lib/presentation/pages/practice_page.dart
class PracticePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.practice),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.music_note),
                text: context.l10n.music,
              ),
              Tab(
                icon: Icon(Icons.air),
                text: context.l10n.breathingTimer,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MusicPlayerTab(),
            BreathingTimerTab(),
          ],
        ),
      ),
    );
  }
}
```

#### 10.2.5 Premium Screen

**Design:**
- Hero section with premium badge/icon
- "Unlock Premium Features" headline
- Feature list with icons:
  - Offline Downloads
  - Ad-Free Experience
  - All Lessons Unlocked
  - Priority Support
- Pricing card ($9.99 one-time)
- Large "Purchase Premium" button
- "Restore Purchases" text button
- Terms of service link

```dart
// lib/presentation/pages/premium_page.dart
class PremiumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.premiumTitle),
      ),
      body: BlocConsumer<PremiumBloc, PremiumState>(
        listener: (context, state) {
          if (state is PremiumActive) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Premium activated! 🎉'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is PremiumError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PremiumPurchasing || state is PremiumRestoring) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                // Hero icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber,
                        Colors.orange,
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.workspace_premium,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 24),

                // Title
                Text(
                  context.l10n.premiumTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  context.l10n.premiumSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),

                // Features
                _FeatureItem(
                  icon: Icons.download,
                  title: context.l10n.premiumFeature1,
                ),
                _FeatureItem(
                  icon: Icons.block,
                  title: context.l10n.premiumFeature2,
                ),
                _FeatureItem(
                  icon: Icons.lock_open,
                  title: context.l10n.premiumFeature3,
                ),
                SizedBox(height: 32),

                // Pricing card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'One-Time Purchase',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 8),
                        Text(
                          context.l10n.premiumPrice,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<PremiumBloc>().add(
                              PurchasePremiumRequested(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 56),
                          ),
                          child: Text(
                            context.l10n.purchase,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Restore button
                TextButton(
                  onPressed: () {
                    context.read<PremiumBloc>().add(
                      RestorePremiumRequested(),
                    );
                  },
                  child: Text(context.l10n.restore),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _FeatureItem({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 10.2.6 Settings Screen

**Layout:**
- Section: Appearance
  - Theme selector (Light/Dark/System)
  - Language selector
- Section: Account (if premium)
  - Premium status badge
  - Purchase date
- Section: About
  - About button → About screen
  - Privacy Policy button → Web view
  - Terms of Service button → Web view
  - Contact Us button → Email/phone options
  - Rate App button → App Store link
- Section: App Info
  - Version number
  - Build number

```dart
// lib/presentation/pages/settings_page.dart
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settings),
      ),
      body: ListView(
        children: [
          // Appearance Section
          _SectionHeader(title: 'Appearance'),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return ListTile(
                leading: Icon(Icons.palette_outlined),
                title: Text(context.l10n.theme),
                trailing: SegmentedButton<AppThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: AppThemeMode.light,
                      icon: Icon(Icons.light_mode, size: 16),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.dark,
                      icon: Icon(Icons.dark_mode, size: 16),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.system,
                      icon: Icon(Icons.brightness_auto, size: 16),
                    ),
                  ],
                  selected: {state.themeMode},
                  onSelectionChanged: (Set<AppThemeMode> selected) {
                    context.read<ThemeBloc>().add(
                      ChangeTheme(selected.first),
                    );
                  },
                ),
              );
            },
          ),
          BlocBuilder<LocaleBloc, LocaleState>(
            builder: (context, state) {
              return ListTile(
                leading: Icon(Icons.language),
                title: Text(context.l10n.language),
                subtitle: Text(_getLanguageName(state.locale)),
                onTap: () => _showLanguageDialog(context, state.locale),
              );
            },
          ),
          Divider(),

          // Premium Section
          BlocBuilder<PremiumBloc, PremiumState>(
            builder: (context, state) {
              if (state is PremiumActive) {
                return Column(
                  children: [
                    _SectionHeader(title: 'Premium'),
                    ListTile(
                      leading: Icon(
                        Icons.workspace_premium,
                        color: Colors.amber,
                      ),
                      title: Text('Premium Active'),
                      subtitle: Text('Thank you for your support!'),
                      trailing: Icon(Icons.check_circle, color: Colors.green),
                    ),
                    Divider(),
                  ],
                );
              }
              return SizedBox.shrink();
            },
          ),

          // About Section
          _SectionHeader(title: context.l10n.about),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(context.l10n.about),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/about'),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text(context.l10n.privacyPolicy),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _openUrl(
              'https://www.amazingelearning.com/privacy',
            ),
          ),
          ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text('Terms of Service'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _openUrl(
              'https://www.amazingelearning.com/terms',
            ),
          ),
          ListTile(
            leading: Icon(Icons.contact_support_outlined),
            title: Text(context.l10n.contactUs),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _showContactDialog(context),
          ),
          ListTile(
            leading: Icon(Icons.star_outline),
            title: Text(context.l10n.rateApp),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _rateApp(),
          ),
          Divider(),

          // App Info
          _SectionHeader(title: 'App Info'),
          ListTile(
            leading: Icon(Icons.app_settings_alt),
            title: Text('Version'),
            trailing: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
```

#### 10.2.7 About Screen

**Layout:**
- App logo + name
- Instructor section:
  - Photo of John Saxxon
  - Bio paragraph
- Contact information:
  - Email: support@amazingelearning.com
  - Phone: 1(650)692-2500
  - Website: www.amazingelearning.com
- Social media links (if available)
- Copyright notice

### 10.3 Design Guidelines

**Color Palette:**
- Primary: Tai Chi Green (#2E7D32)
- Secondary: Earthy Brown (#8D6E63)
- Accent: Calm Blue (#1976D2)
- Background Light: #F5F5F5
- Background Dark: #121212
- Surface Dark: #1E1E1E

**Typography:**
- Display: 32sp, Light (300)
- Headline: 24sp, Regular (400)
- Body: 16sp, Regular (400)
- Caption: 12sp, Regular (400)

**Spacing:**
- Small: 8dp
- Medium: 16dp
- Large: 24dp
- Extra Large: 32dp

**Border Radius:**
- Cards: 12dp
- Buttons: 8dp
- Chips: 16dp

**Elevation:**
- Cards: 2dp
- App Bar: 0dp (scrolled: 2dp)
- Bottom Nav: 8dp

**Animations:**
- Fade transitions: 300ms
- Scale animations: 200ms
- Page transitions: 350ms
- Easing: Cubic curves (Material 3 default)

---

## 11. Dependencies & Setup

### 11.1 pubspec.yaml

```yaml
name: taichi_workout
description: A Tai Chi workout and meditation app
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.3
  bloc: ^8.1.2
  equatable: ^2.0.5

  # Dependency Injection
  get_it: ^7.6.4

  # Network
  dio: ^5.3.3
  connectivity_plus: ^5.0.1

  # Video Player
  video_player: ^2.7.2
  chewie: ^1.7.1

  # Audio Player
  audioplayers: ^5.2.0

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  path_provider: ^2.1.1

  # In-App Purchase
  in_app_purchase: ^3.1.11

  # Ads
  google_mobile_ads: ^4.0.0

  # UI
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  lottie: ^2.7.0

  # Utilities
  intl: ^0.18.1
  url_launcher: ^6.2.1
  share_plus: ^7.2.1
  permission_handler: ^11.0.1

  # Functional Programming
  dartz: ^0.10.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

  # Code Generation
  hive_generator: ^2.0.1
  build_runner: ^2.4.6

  # Testing
  bloc_test: ^9.1.4
  mocktail: ^1.0.0

flutter:
  uses-material-design: true
  generate: true

  assets:
    - assets/images/
    - assets/audio/music/
    - assets/audio/voice/
    - assets/audio/sounds/
    - assets/lottie/

  fonts:
    - family: Roboto
      fonts:
        - asset: fonts/Roboto-Light.ttf
          weight: 300
        - asset: fonts/Roboto-Regular.ttf
          weight: 400
        - asset: fonts/Roboto-Medium.ttf
          weight: 500
```

### 11.2 Android Setup

**android/app/build.gradle:**
```gradle
android {
    namespace "com.amazingelearning.taichi"
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.amazingelearning.taichi"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}

dependencies {
    implementation 'com.android.support:multidex:1.0.3'
}
```

**android/app/src/main/AndroidManifest.xml:**
```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
                     android:maxSdkVersion="28" />

    <application
        android:name="${applicationName}"
        android:label="Tai Chi Workout"
        android:icon="@mipmap/ic_launcher">

        <!-- AdMob App ID -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-9740790965972178~4504042514"/>

        <!-- Main Activity -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### 11.3 iOS Setup

**ios/Runner/Info.plist:**
```xml
<dict>
    <key>CFBundleName</key>
    <string>Tai Chi Workout</string>

    <key>CFBundleIdentifier</key>
    <string>com.amazingelearning.taichi</string>

    <!-- AdMob App ID -->
    <key>GADApplicationIdentifier</key>
    <string>ca-app-pub-9740790965972178~4504042514</string>

    <!-- Permissions -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Allow access to save video thumbnails</string>

    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>

    <!-- Supported Orientations -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
```

**Podfile:**
```ruby
platform :ios, '13.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
```

### 11.4 Project Setup Commands

```bash
# Clone/create project
flutter create --org com.amazingelearning taichi_workout
cd taichi_workout

# Add dependencies
flutter pub add flutter_bloc dio hive video_player chewie audioplayers \
  in_app_purchase google_mobile_ads get_it shared_preferences \
  flutter_secure_storage cached_network_image

# Add dev dependencies
flutter pub add -d hive_generator build_runner bloc_test mocktail

# Generate files
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Build for release
flutter build apk --release
flutter build ios --release
```

---

## 12. Project Structure

```
taichi_workout/
├── android/                        # Android native code
├── ios/                            # iOS native code
├── lib/
│   ├── main.dart                   # App entry point
│   ├── injection_container.dart    # Dependency injection setup
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   ├── ad_constants.dart
│   │   │   └── app_constants.dart
│   │   ├── error/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── network/
│   │   │   ├── network_info.dart
│   │   │   └── dio_client.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── app_colors.dart
│   │   └── utils/
│   │       ├── formatters.dart
│   │       └── validators.dart
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── video.dart
│   │   │   ├── lesson.dart
│   │   │   ├── premium_status.dart
│   │   │   └── audio_track.dart
│   │   ├── repositories/
│   │   │   ├── video_repository.dart
│   │   │   ├── premium_repository.dart
│   │   │   ├── download_repository.dart
│   │   │   └── audio_repository.dart
│   │   └── usecases/
│   │       ├── get_videos.dart
│   │       ├── play_video.dart
│   │       ├── download_video.dart
│   │       ├── purchase_premium.dart
│   │       ├── restore_purchases.dart
│   │       ├── check_premium_status.dart
│   │       ├── play_audio.dart
│   │       └── start_breathing_timer.dart
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── video_model.dart
│   │   │   ├── lesson_model.dart
│   │   │   ├── premium_status_model.dart
│   │   │   └── audio_track_model.dart
│   │   ├── datasources/
│   │   │   ├── video_remote_datasource.dart
│   │   │   ├── video_local_datasource.dart
│   │   │   ├── premium_local_datasource.dart
│   │   │   ├── download_manager.dart
│   │   │   └── audio_local_datasource.dart
│   │   └── repositories/
│   │       ├── video_repository_impl.dart
│   │       ├── premium_repository_impl.dart
│   │       ├── download_repository_impl.dart
│   │       └── audio_repository_impl.dart
│   │
│   └── presentation/
│       ├── bloc/
│       │   ├── video/
│       │   │   ├── video_bloc.dart
│       │   │   ├── video_event.dart
│       │   │   └── video_state.dart
│       │   ├── video_player/
│       │   │   ├── video_player_bloc.dart
│       │   │   ├── video_player_event.dart
│       │   │   └── video_player_state.dart
│       │   ├── download/
│       │   │   ├── download_bloc.dart
│       │   │   ├── download_event.dart
│       │   │   └── download_state.dart
│       │   ├── premium/
│       │   │   ├── premium_bloc.dart
│       │   │   ├── premium_event.dart
│       │   │   └── premium_state.dart
│       │   ├── ads/
│       │   │   ├── ads_bloc.dart
│       │   │   ├── ads_event.dart
│       │   │   └── ads_state.dart
│       │   ├── music_player/
│       │   │   ├── music_player_bloc.dart
│       │   │   ├── music_player_event.dart
│       │   │   └── music_player_state.dart
│       │   ├── breathing_timer/
│       │   │   ├── breathing_timer_bloc.dart
│       │   │   ├── breathing_timer_event.dart
│       │   │   └── breathing_timer_state.dart
│       │   ├── theme/
│       │   │   ├── theme_bloc.dart
│       │   │   ├── theme_event.dart
│       │   │   └── theme_state.dart
│       │   └── locale/
│       │       ├── locale_bloc.dart
│       │       ├── locale_event.dart
│       │       └── locale_state.dart
│       ├── pages/
│       │   ├── splash_page.dart
│       │   ├── home_page.dart
│       │   ├── video_player_page.dart
│       │   ├── practice_page.dart
│       │   ├── premium_page.dart
│       │   ├── settings_page.dart
│       │   └── about_page.dart
│       └── widgets/
│           ├── video_card.dart
│           ├── video_player_widget.dart
│           ├── music_player_widget.dart
│           ├── breathing_timer_widget.dart
│           ├── banner_ad_widget.dart
│           ├── premium_badge.dart
│           └── category_chip.dart
│
├── assets/
│   ├── images/
│   │   ├── logo.png
│   │   ├── instructor.jpg
│   │   └── placeholders/
│   ├── audio/
│   │   ├── music/
│   │   │   ├── tai_chi_calm.mp3
│   │   │   ├── meditation_flow.mp3
│   │   │   └── peaceful_chi.mp3
│   │   ├── voice/
│   │   │   ├── breathing_guide_en.mp3
│   │   │   ├── breathing_guide_zh.mp3
│   │   │   └── meditation_guide.mp3
│   │   └── sounds/
│   │       ├── inhale_sound.mp3
│   │       └── exhale_sound.mp3
│   └── lottie/
│       └── breathing_animation.json
│
├── l10n/
│   ├── app_en.arb
│   ├── app_zh.arb
│   ├── app_es.arb
│   ├── app_ja.arb
│   ├── app_fr.arb
│   ├── app_de.arb
│   └── app_ko.arb
│
├── test/
│   ├── domain/
│   ├── data/
│   └── presentation/
│
├── pubspec.yaml
├── l10n.yaml
└── README.md
```

---

## Final Notes

### Implementation Priority

**Phase 1: Core Features (Week 1-2)**
1. Project setup, dependencies, folder structure
2. Video list with categories
3. Basic video player (stream only)
4. Light/dark theme
5. English localization

**Phase 2: Premium & Monetization (Week 3)**
6. AdMob banner integration
7. In-app purchase implementation
8. Premium status management
9. Video download manager

**Phase 3: Enhanced Features (Week 4)**
10. Music/voice player
11. Breathing timer with animations
12. Multi-language support (all 7 languages)
13. Settings screen

**Phase 4: Polish & Testing (Week 5)**
14. UI/UX refinements
15. Error handling improvements
16. Performance optimization
17. Testing (unit, widget, integration)
18. App store assets preparation

### Technical Considerations

**Performance:**
- Use `cached_network_image` for thumbnails
- Implement lazy loading for video lists
- Dispose video players properly
- Use `const` constructors where possible
- Optimize animations (60fps target)

**Security:**
- Use `flutter_secure_storage` for sensitive data
- Implement certificate pinning for API calls
- Validate all in-app purchases server-side
- Don't hardcode API keys in source code

**Accessibility:**
- Add semantic labels to all interactive widgets
- Support screen readers
- Ensure minimum touch target size (48x48dp)
- Test with TalkBack/VoiceOver

**Testing:**
- Unit tests for all use cases and repositories
- Widget tests for custom widgets
- Integration tests for critical flows
- Mock external dependencies

**App Store Optimization:**
- Compelling screenshots showing key features
- Clear app description highlighting benefits
- Keywords: Tai Chi, meditation, workout, wellness
- Positive user reviews strategy

### API Backend Recommendation (Future Enhancement)

Consider building a backend API for:
- Dynamic content management (add/update videos without app updates)
- User accounts and progress tracking
- Analytics and usage metrics
- Push notifications for new content
- Social features (comments, ratings)
- Content recommendations

**Suggested Stack:**
- Backend: Node.js + Express or Python + FastAPI
- Database: PostgreSQL + Redis cache
- Storage: AWS S3 or Google Cloud Storage for videos
- CDN: CloudFront or Cloudflare for video delivery
- Auth: Firebase Auth or JWT tokens

---

**End of Documentation**

This documentation provides a complete blueprint for building a professional Flutter Tai Chi Workout app. Follow the architecture patterns, implement features incrementally, and maintain code quality throughout development. Good luck with your Flutter implementation!
