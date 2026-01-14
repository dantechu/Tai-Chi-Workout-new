import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../core/error/failures.dart';

enum AppThemeMode { light, dark, system }

abstract class SettingsRepository {
  Future<Either<Failure, AppThemeMode>> getThemeMode();
  Future<Either<Failure, bool>> setThemeMode(AppThemeMode mode);
  Future<Either<Failure, Locale>> getLocale();
  Future<Either<Failure, bool>> setLocale(Locale locale);
  Future<Either<Failure, bool>> getOnboardingComplete();
  Future<Either<Failure, bool>> setOnboardingComplete(bool complete);
  Future<Either<Failure, double>> getMusicVolume();
  Future<Either<Failure, bool>> setMusicVolume(double volume);
  Future<Either<Failure, bool>> getVoiceGuidanceEnabled();
  Future<Either<Failure, bool>> setVoiceGuidanceEnabled(bool enabled);
  Future<Either<Failure, int>> getBreathingDuration();
  Future<Either<Failure, bool>> setBreathingDuration(int minutes);
  Future<Either<Failure, bool>> getNotificationsEnabled();
  Future<Either<Failure, bool>> setNotificationsEnabled(bool enabled);
  Stream<AppThemeMode> get themeModeStream;
  Stream<Locale> get localeStream;
}