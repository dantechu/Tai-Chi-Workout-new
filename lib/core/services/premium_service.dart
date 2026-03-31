/// Singleton service that manages premium status
/// This is the ONLY place where premium status is determined
class PremiumService {
  static final PremiumService _instance = PremiumService._internal();

  factory PremiumService() {
    return _instance;
  }

  PremiumService._internal();

  /// The single source of truth for premium status
  bool _isPremium = false;

  /// Get premium status
  bool get isPremium => _isPremium;

  /// Update premium status - ONLY called by PremiumBloc
  void updatePremiumStatus(bool isPremium) {
    _isPremium = isPremium;
  }

  /// Reset to non-premium (for testing/logout)
  void reset() {
    _isPremium = false;
  }
}
