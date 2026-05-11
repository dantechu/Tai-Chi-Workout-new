import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Set log level (use LogLevel.info in production)
    await Purchases.setLogLevel(LogLevel.debug);

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

  /// Get the current customer info
  Future<CustomerInfo> getCustomerInfo() async {
    return await Purchases.getCustomerInfo();
  }

  /// Get available offerings from RevenueCat
  Future<Offerings> getOfferings() async {
    return await Purchases.getOfferings();
  }

  /// Purchase a package
  Future<CustomerInfo> purchasePackage(Package package) async {
    final purchaseParams = PurchaseParams.package(package);
    final purchaseResult = await Purchases.purchase(purchaseParams);
    return purchaseResult.customerInfo;
  }

  /// Restore previous purchases
  Future<CustomerInfo> restorePurchases() async {
    return await Purchases.restorePurchases();
  }

  /// Listen to customer info updates  /// Note: This is a placeholder - actual listener setup should be done via callbacks
  void addCustomerInfoUpdateListener(void Function(CustomerInfo) callback) {
    Purchases.addCustomerInfoUpdateListener(callback);
  }

  void dispose() {
    // RevenueCat handles cleanup internally
  }
}
