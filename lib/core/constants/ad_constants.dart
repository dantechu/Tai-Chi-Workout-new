import 'dart:io';

class AdConstants {
  // Banner Ads
  static const String androidBannerId = 'ca-app-pub-9740790965972178/2276608078';
  static const String iosBannerId = 'ca-app-pub-9740790965972178/2276608078';

  // Test Ads (for development)
  static const String testAndroidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testIosBannerId = 'ca-app-pub-3940256099942544/2934735716';

  // Interstitial Ads (for future use)
  static const String androidInterstitialId = 'ca-app-pub-9740790965972178/XXXXXXXX';
  static const String iosInterstitialId = 'ca-app-pub-9740790965972178/XXXXXXXX';

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return androidBannerId;
    } else if (Platform.isIOS) {
      return iosBannerId;
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
}