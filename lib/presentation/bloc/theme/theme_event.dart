import 'package:equatable/equatable.dart';

enum AppThemeMode { light, dark, system }

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class LoadTheme extends ThemeEvent {
  const LoadTheme();
}

class ChangeTheme extends ThemeEvent {
  final AppThemeMode themeMode;

  const ChangeTheme(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}