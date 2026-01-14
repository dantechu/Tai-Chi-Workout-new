import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class LocaleState extends Equatable {
  final Locale locale;

  const LocaleState({required this.locale});

  factory LocaleState.initial() => const LocaleState(locale: Locale('en'));

  String get languageName {
    final language = AppConstants.supportedLocales.firstWhere(
      (lang) => lang['code'] == locale.languageCode,
      orElse: () => {'name': 'English'},
    );
    return language['name'] as String;
  }

  String get languageFlag {
    final language = AppConstants.supportedLocales.firstWhere(
      (lang) => lang['code'] == locale.languageCode,
      orElse: () => {'flag': '🇺🇸'},
    );
    return language['flag'] as String;
  }

  LocaleState copyWith({Locale? locale}) {
    return LocaleState(locale: locale ?? this.locale);
  }

  @override
  List<Object> get props => [locale];

  @override
  String toString() => 'LocaleState(locale: ${locale.languageCode})';
}