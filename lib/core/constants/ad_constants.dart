import 'dart:io';
import 'package:flutter/foundation.dart';

class AdConstants {
  // Production Banner Ads
  static const String androidBannerId = 'ca-app-pub-9740790965972178/7987836878';
  static const String iosBannerId = 'ca-app-pub-9740790965972178/7987836878';

  // Test Ads (for development)
  static const String testAndroidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testIosBannerId = 'ca-app-pub-3940256099942544/2934735716';

  // Production Interstitial Ads (replace XXXXXXXX with actual IDs when ready)
  static const String androidInterstitialId = 'ca-app-pub-9740790965972178/XXXXXXXX';
  static const String iosInterstitialId = 'ca-app-pub-9740790965972178/XXXXXXXX';

  // Test Interstitial Ads (AdMob official test IDs)
  static const String testAndroidInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testIosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  /// Cooldown duration between interstitial ads (in minutes)
  static const int interstitialCooldownMinutes = 5;

  /// Returns the appropriate banner ad unit ID based on platform and build mode
  /// - Debug/Profile mode: Uses test ad IDs
  /// - Release mode: Uses production ad IDs
  static String get bannerAdUnitId {
    // Use test IDs in debug and profile mode, production IDs in release mode
    final bool useTestAds = kDebugMode || kProfileMode;

    if (Platform.isIOS) {
      return useTestAds ? testIosBannerId : iosBannerId;
    } else if (Platform.isAndroid) {
      return useTestAds ? testAndroidBannerId : androidBannerId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Returns the appropriate interstitial ad unit ID based on platform and build mode
  /// - Debug/Profile mode: Uses test ad IDs
  /// - Release mode: Uses production ad IDs
  static String get interstitialAdUnitId {
    final bool useTestAds = kDebugMode || kProfileMode;

    if (Platform.isIOS) {
      return useTestAds ? testIosInterstitialId : iosInterstitialId;
    } else if (Platform.isAndroid) {
      return useTestAds ? testAndroidInterstitialId : androidInterstitialId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get testBannerAdUnitId {
    if (Platform.isAndroid) {
      return testAndroidBannerId;
    } else if (Platform.isIOS) {
      return testIosBannerId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get testInterstitialAdUnitId {
    if (Platform.isAndroid) {
      return testAndroidInterstitialId;
    } else if (Platform.isIOS) {
      return testIosInterstitialId;
    }
    throw UnsupportedError('Unsupported platform');
  }
}