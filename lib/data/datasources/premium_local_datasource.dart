import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import '../../core/error/exceptions.dart';
import '../models/premium_status_model.dart';

abstract class PremiumLocalDataSource {
  Future<PremiumStatusModel?> getCachedPremiumStatus();
  Future<void> cachePremiumStatus(PremiumStatusModel status);
  Future<void> clearPremiumCache();
  Future<String?> getSecurePremiumToken();
  Future<void> setSecurePremiumToken(String token);
  Future<void> clearSecurePremiumToken();
  Future<DateTime?> getLastPremiumCheck();
  Future<void> updateLastPremiumCheck();
  Future<bool> isPremiumCached();
}

class PremiumLocalDataSourceImpl implements PremiumLocalDataSource {
  static const String premiumBoxName = 'premium_cache';
  static const String premiumTokenKey = 'premium_token';
  static const String premiumDataKey = 'premium_status';
  
  final FlutterSecureStorage secureStorage;

  PremiumLocalDataSourceImpl(this.secureStorage);

  @override
  Future<PremiumStatusModel?> getCachedPremiumStatus() async {
    try {
      final box = await Hive.openBox<Map>(premiumBoxName);
      final statusMap = box.get(premiumDataKey);
      
      if (statusMap != null && statusMap is Map<String, dynamic>) {
        return PremiumStatusModel.fromJson(statusMap);
      }
      
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached premium status: $e');
    }
  }

  @override
  Future<void> cachePremiumStatus(PremiumStatusModel status) async {
    try {
      final box = await Hive.openBox<Map>(premiumBoxName);
      await box.put(premiumDataKey, status.toJson());
    } catch (e) {
      throw CacheException('Failed to cache premium status: $e');
    }
  }

  @override
  Future<void> clearPremiumCache() async {
    try {
      final box = await Hive.openBox<Map>(premiumBoxName);
      await box.clear();
    } catch (e) {
      throw CacheException('Failed to clear premium cache: $e');
    }
  }

  @override
  Future<String?> getSecurePremiumToken() async {
    try {
      return await secureStorage.read(key: premiumTokenKey);
    } catch (e) {
      throw CacheException('Failed to get secure premium token: $e');
    }
  }

  @override
  Future<void> setSecurePremiumToken(String token) async {
    try {
      await secureStorage.write(key: premiumTokenKey, value: token);
    } catch (e) {
      throw CacheException('Failed to set secure premium token: $e');
    }
  }

  @override
  Future<void> clearSecurePremiumToken() async {
    try {
      await secureStorage.delete(key: premiumTokenKey);
    } catch (e) {
      throw CacheException('Failed to clear secure premium token: $e');
    }
  }

  @override
  Future<DateTime?> getLastPremiumCheck() async {
    try {
      final box = await Hive.openBox<String>('premium_metadata');
      final timestamp = box.get('last_check');
      return timestamp != null ? DateTime.parse(timestamp) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateLastPremiumCheck() async {
    try {
      final box = await Hive.openBox<String>('premium_metadata');
      await box.put('last_check', DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException('Failed to update last premium check: $e');
    }
  }

  @override
  Future<bool> isPremiumCached() async {
    try {
      final box = await Hive.openBox<Map>(premiumBoxName);
      return box.containsKey(premiumDataKey);
    } catch (e) {
      return false;
    }
  }
}