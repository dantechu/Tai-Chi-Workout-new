import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_constants.dart';
import 'premium_service.dart';

/// Singleton service to manage interstitial ads.
///
/// Features:
/// - Auto-preloads interstitial ad
/// - Tracks cooldown between ads (5 minutes)
/// - First ad shows immediately (no cooldown)
/// - Premium users skip all interstitial ads
/// - Provides callback after ad is dismissed for navigation
class InterstitialAdService {
  static final InterstitialAdService _instance = InterstitialAdService._internal();

  factory InterstitialAdService() => _instance;

  InterstitialAdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  DateTime? _lastAdShownTime;
  int _adsShownThisSession = 0;

  /// Whether an ad is ready to be shown
  bool get isAdReady => _isAdLoaded && _interstitialAd != null;

  /// Number of ads shown in current session
  int get adsShownThisSession => _adsShownThisSession;

  /// Initialize and preload the first interstitial ad.
  /// Call this once at app startup.
  void initialize() {
    _loadAd();
  }

  /// Load an interstitial ad.
  void _loadAd() {
    if (_isAdLoading || _isAdLoaded) return;

    _isAdLoading = true;

    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('InterstitialAdService: Ad loaded successfully');
          _interstitialAd = ad;
          _isAdLoaded = true;
          _isAdLoading = false;

          // Set up fullscreen callbacks
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('InterstitialAdService: Ad dismissed');
              ad.dispose();
              _interstitialAd = null;
              _isAdLoaded = false;
              // Preload next ad
              _loadAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('InterstitialAdService: Ad failed to show: $error');
              ad.dispose();
              _interstitialAd = null;
              _isAdLoaded = false;
              // Try loading again
              _loadAd();
            },
            onAdShowedFullScreenContent: (ad) {
              debugPrint('InterstitialAdService: Ad showed');
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAdService: Ad failed to load: $error');
          _isAdLoading = false;
          _isAdLoaded = false;
          // Retry after a delay
          Future.delayed(const Duration(seconds: 30), () {
            _loadAd();
          });
        },
      ),
    );
  }

  /// Check if an ad should be shown based on cooldown logic.
  ///
  /// Rules:
  /// - Premium users: Never show ads
  /// - First ad: Show immediately (no cooldown)
  /// - Subsequent ads: Only show if 5+ minutes since last ad
  bool shouldShowAd() {
    // Premium users don't see ads
    if (PremiumService().isPremium) {
      return false;
    }

    // Ad not loaded
    if (!isAdReady) {
      return false;
    }

    // First ad of the session - show immediately
    if (_adsShownThisSession == 0) {
      return true;
    }

    // Check cooldown
    if (_lastAdShownTime != null) {
      final minutesSinceLastAd = DateTime.now()
          .difference(_lastAdShownTime!)
          .inMinutes;

      return minutesSinceLastAd >= AdConstants.interstitialCooldownMinutes;
    }

    return true;
  }

  /// Show the interstitial ad if conditions are met.
  ///
  /// [onAdDismissed] - Callback invoked after ad is dismissed or if ad shouldn't show.
  ///                   Use this to navigate to the next lesson.
  ///
  /// Returns true if ad was shown, false if skipped.
  bool showAdIfReady({required VoidCallback onAdDismissed}) {
    // Check if we should show the ad
    if (!shouldShowAd()) {
      debugPrint('InterstitialAdService: Skipping ad (conditions not met)');
      // Still call the callback so navigation proceeds
      onAdDismissed();
      return false;
    }

    // Store the callback to call when ad is dismissed
    final ad = _interstitialAd;
    if (ad == null) {
      onAdDismissed();
      return false;
    }

    // Update fullscreen callback to include the onAdDismissed callback
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('InterstitialAdService: Ad dismissed, calling navigation callback');
        ad.dispose();
        _interstitialAd = null;
        _isAdLoaded = false;
        // Preload next ad
        _loadAd();
        // Navigate to next lesson
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('InterstitialAdService: Ad failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
        _isAdLoaded = false;
        _loadAd();
        // Still navigate even if ad fails
        onAdDismissed();
      },
      onAdShowedFullScreenContent: (ad) {
        debugPrint('InterstitialAdService: Ad showed full screen');
        // Update tracking
        _lastAdShownTime = DateTime.now();
        _adsShownThisSession++;
      },
    );

    // Show the ad
    ad.show();
    return true;
  }

  /// Reset session tracking (call when app restarts or user logs out)
  void resetSession() {
    _adsShownThisSession = 0;
    _lastAdShownTime = null;
  }

  /// Dispose of any loaded ad
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
    _isAdLoading = false;
  }
}
