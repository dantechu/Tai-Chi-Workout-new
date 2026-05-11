import 'dart:async';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;
  static const Duration _defaultTimeout = Duration(seconds: 30);

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Set log level based on environment (default to info for production)
    final logLevelEnv = dotenv.env['REVENUECAT_LOG_LEVEL'] ?? 'info';
    final logLevel = _getLogLevel(logLevelEnv);
    await Purchases.setLogLevel(logLevel);

    late PurchasesConfiguration configuration;

    if (Platform.isAndroid) {
      final androidKey = dotenv.env['REVENUECAT_ANDROID_API_KEY'];
      if (androidKey == null || androidKey.isEmpty) {
        throw Exception('REVENUECAT_ANDROID_API_KEY not found in .env');
      }
      configuration = PurchasesConfiguration(androidKey);
    } else if (Platform.isIOS) {
      final iosKey = dotenv.env['REVENUECAT_IOS_API_KEY'];
      if (iosKey == null || iosKey.isEmpty) {
        throw Exception('REVENUECAT_IOS_API_KEY not found in .env');
      }
      configuration = PurchasesConfiguration(iosKey);
    } else {
      throw Exception('Unsupported platform for RevenueCat');
    }

    await Purchases.configure(configuration);
    _isInitialized = true;
  }

  LogLevel _getLogLevel(String level) {
    switch (level.toLowerCase()) {
      case 'verbose':
        return LogLevel.verbose;
      case 'debug':
        return LogLevel.debug;
      case 'warn':
      case 'warning':
        return LogLevel.warn;
      case 'error':
        return LogLevel.error;
      case 'info':
      default:
        return LogLevel.info;
    }
  }

  /// Login user with custom app user ID for cross-device syncing
  ///
  /// IMPORTANT: Call this method when a user logs into your app to enable:
  /// - Cross-device purchase syncing
  /// - Purchase restoration across devices
  /// - Multiple device access with the same account
  ///
  /// Example usage:
  /// ```dart
  /// // When user signs in with Firebase Auth, email, etc.
  /// await revenueCatService.logIn(user.uid);
  /// ```
  ///
  /// Without calling this, purchases are tied to the device and won't sync.
  Future<CustomerInfo> logIn(String appUserId) async {
    final result = await Purchases.logIn(appUserId).timeout(_defaultTimeout);
    return result.customerInfo;
  }

  /// Logout current user
  ///
  /// Call this when a user logs out of your app to:
  /// - Clear the current user's purchase data from the device
  /// - Allow another user to log in on the same device
  /// - Reset to anonymous user state
  Future<CustomerInfo> logOut() async {
    return await Purchases.logOut().timeout(_defaultTimeout);
  }

  /// Check if user is anonymous
  Future<bool> isAnonymous() async {
    return await Purchases.isAnonymous;
  }

  /// Get the current customer info
  Future<CustomerInfo> getCustomerInfo() async {
    return await Purchases.getCustomerInfo().timeout(_defaultTimeout);
  }

  /// Get available offerings from RevenueCat
  Future<Offerings> getOfferings() async {
    return await Purchases.getOfferings().timeout(_defaultTimeout);
  }

  /// Purchase a package
  Future<CustomerInfo> purchasePackage(Package package) async {
    final purchaseParams = PurchaseParams.package(package);
    // Purchase operations can take longer, use extended timeout
    final purchaseResult = await Purchases.purchase(purchaseParams)
        .timeout(const Duration(seconds: 60));
    return purchaseResult.customerInfo;
  }

  /// Restore previous purchases
  Future<CustomerInfo> restorePurchases() async {
    return await Purchases.restorePurchases()
        .timeout(const Duration(seconds: 60));
  }

  /// Listen to customer info updates for real-time premium status changes
  /// Returns a function to remove the listener
  void Function() addCustomerInfoUpdateListener(
    void Function(CustomerInfo) callback,
  ) {
    Purchases.addCustomerInfoUpdateListener(callback);

    // Return a function to remove this specific listener
    return () {
      Purchases.removeCustomerInfoUpdateListener(callback);
    };
  }

  /// Get current app user ID
  Future<String> getAppUserId() async {
    return await Purchases.appUserID;
  }

  void dispose() {
    // RevenueCat handles cleanup internally
  }
}
