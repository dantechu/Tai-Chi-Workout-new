import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for managing offline/online status and caching for premium users.
///
/// This is a singleton service that:
/// - Monitors network connectivity status
/// - Provides real-time updates when connectivity changes
/// - Can be used throughout the app to check offline status
class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<dynamic>? _subscription;

  bool _isOffline = false;
  bool get isOffline => _isOffline;
  bool get isOnline => !_isOffline;

  final StreamController<bool> _offlineController = StreamController<bool>.broadcast();
  Stream<bool> get offlineStream => _offlineController.stream;

  Future<void> init() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isOffline = !_hasConnection(result);

    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      final wasOffline = _isOffline;
      _isOffline = !_hasConnection(result);

      if (wasOffline != _isOffline) {
        _offlineController.add(_isOffline);
      }
    });
  }

  bool _hasConnection(dynamic result) {
    // Handle both single result and list of results (API varies by version)
    if (result is List) {
      return result.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet
      );
    }
    return result == ConnectivityResult.mobile ||
           result == ConnectivityResult.wifi ||
           result == ConnectivityResult.ethernet;
  }

  void dispose() {
    _subscription?.cancel();
    _offlineController.close();
  }
}
