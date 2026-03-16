import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/analytics_service.dart';
import 'locale_event.dart';
import 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final SharedPreferences prefs;
  final AnalyticsService analyticsService;
  static const String localeKey = 'locale';

  LocaleBloc(this.prefs, this.analyticsService) : super(LocaleState.initial()) {
    on<LoadLocale>(_onLoadLocale);
    on<ChangeLocale>(_onChangeLocale);
  }

  Future<void> _onLoadLocale(LoadLocale event, Emitter<LocaleState> emit) async {
    try {
      final languageCode = prefs.getString(localeKey);
      if (languageCode != null) {
        // Verify that the language code is supported
        final isSupported = AppConstants.supportedLocales
            .any((lang) => lang['code'] == languageCode);
        
        if (isSupported) {
          emit(LocaleState(locale: Locale(languageCode)));
          return;
        }
      }
      
      // Default to system locale or English
      emit(_getSystemLocaleOrDefault());
    } catch (e) {
      emit(LocaleState.initial());
    }
  }

  Future<void> _onChangeLocale(
    ChangeLocale event,
    Emitter<LocaleState> emit,
  ) async {
    try {
      // Verify that the new locale is supported
      final isSupported = AppConstants.supportedLocales
          .any((lang) => lang['code'] == event.locale.languageCode);

      if (!isSupported) {
        // Don't change to unsupported locale
        return;
      }

      await prefs.setString(localeKey, event.locale.languageCode);
      emit(LocaleState(locale: event.locale));

      // Log language selection event to Firebase Analytics
      await analyticsService.logLanguageSelected(event.locale.languageCode);
    } catch (e) {
      // If saving fails, still emit the new state but log the error
      emit(LocaleState(locale: event.locale));

      // Still try to log the analytics event
      try {
        await analyticsService.logLanguageSelected(event.locale.languageCode);
      } catch (_) {
        // Silently fail analytics logging
      }
    }
  }

  LocaleState _getSystemLocaleOrDefault() {
    try {
      // Try to get system locale
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final isSystemSupported = AppConstants.supportedLocales
          .any((lang) => lang['code'] == systemLocale.languageCode);
      
      if (isSystemSupported) {
        return LocaleState(locale: systemLocale);
      }
    } catch (e) {
      // If system locale detection fails, continue to default
    }
    
    return LocaleState.initial();
  }

  List<Locale> get supportedLocales {
    return AppConstants.supportedLocales
        .map((lang) => Locale(lang['code'] as String))
        .toList();
  }

  bool isLocaleSupported(Locale locale) {
    return AppConstants.supportedLocales
        .any((lang) => lang['code'] == locale.languageCode);
  }
}