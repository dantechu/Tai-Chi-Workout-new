import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_constants.dart';

/// Service to manage rewarded video ads for unlocking premium content.
///
/// Features:
/// - Preloads rewarded ads for instant playback
/// - Auto-reloads after each ad is shown
/// - Handles ad completion and rewards
class RewardedAdService {
  static final RewardedAdService _instance = RewardedAdService._internal();
  factory RewardedAdService() => _instance;
  RewardedAdService._internal();

  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  /// Whether a rewarded ad is ready to show
  bool get isAdReady => _rewardedAd != null;

  /// Initialize and preload the first ad
  void initialize() {
    _loadAd();
  }

  void _loadAd() {
    if (_isLoading || _rewardedAd != null) return;

    _isLoading = true;
    debugPrint('RewardedAdService: Loading ad...');

    RewardedAd.load(
      adUnitId: AdConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
          debugPrint('RewardedAdService: Ad loaded successfully');
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          debugPrint('RewardedAdService: Failed to load ad: ${error.message}');
          // Retry after delay
          Future.delayed(const Duration(seconds: 30), _loadAd);
        },
      ),
    );
  }

  /// Show rewarded ad and handle completion.
  ///
  /// [onRewarded] - Called when user earns the reward (watched full ad)
  /// [onAdDismissed] - Called when ad is dismissed (regardless of reward)
  /// [onAdFailedToShow] - Called if ad fails to show
  ///
  /// Returns true if ad started showing, false if no ad available
  bool showAd({
    required VoidCallback onRewarded,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailedToShow,
  }) {
    if (_rewardedAd == null) {
      debugPrint('RewardedAdService: No ad ready to show');
      onAdFailedToShow?.call();
      _loadAd(); // Try to load for next time
      return false;
    }

    bool wasRewarded = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('RewardedAdService: Ad showed full screen');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('RewardedAdService: Ad dismissed, wasRewarded: $wasRewarded');
        ad.dispose();
        _rewardedAd = null;
        _loadAd(); // Preload next ad

        if (wasRewarded) {
          onRewarded();
        }
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('RewardedAdService: Ad failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        _loadAd();
        onAdFailedToShow?.call();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('RewardedAdService: User earned reward: ${reward.amount} ${reward.type}');
        wasRewarded = true;
      },
    );

    return true;
  }

  /// Dispose the service
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
