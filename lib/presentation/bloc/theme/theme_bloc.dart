import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences prefs;
  static const String themeKey = 'theme_mode';

  ThemeBloc(this.prefs) : super(ThemeState.initial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ChangeTheme>(_onChangeTheme);
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    try {
      final themeName = prefs.getString(themeKey) ?? 'system';
      final themeMode = AppThemeMode.values.firstWhere(
        (e) => e.name == themeName,
        orElse: () => AppThemeMode.system,
      );
      emit(ThemeState(themeMode: themeMode));
    } catch (e) {
      emit(ThemeState.initial());
    }
  }

  Future<void> _onChangeTheme(ChangeTheme event, Emitter<ThemeState> emit) async {
    try {
      await prefs.setString(themeKey, event.themeMode.name);
      emit(ThemeState(themeMode: event.themeMode));
    } catch (e) {
      // If saving fails, still emit the new state but log the error
      emit(ThemeState(themeMode: event.themeMode));
    }
  }
}