import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const appThemeModePreferenceKey = 'app_theme_mode';

enum AppThemeMode {
  system('system', ThemeMode.system),
  light('light', ThemeMode.light),
  dark('dark', ThemeMode.dark);

  const AppThemeMode(this.code, this.themeMode);

  final String code;
  final ThemeMode themeMode;

  static AppThemeMode fromCode(String? code) {
    for (final mode in AppThemeMode.values) {
      if (mode.code == code) {
        return mode;
      }
    }
    return AppThemeMode.system;
  }
}

class ThemePreferenceStore {
  ThemePreferenceStore(this._preferences);

  final SharedPreferences _preferences;

  AppThemeMode load() {
    return AppThemeMode.fromCode(
      _preferences.getString(appThemeModePreferenceKey),
    );
  }

  Future<void> save(AppThemeMode mode) {
    if (mode == AppThemeMode.system) {
      return _preferences.remove(appThemeModePreferenceKey);
    }
    return _preferences.setString(appThemeModePreferenceKey, mode.code);
  }
}

class ThemeController extends StateNotifier<AsyncValue<AppThemeMode>> {
  ThemeController({
    Future<SharedPreferences> Function()? preferencesFactory,
  })  : _preferencesFactory =
            preferencesFactory ?? SharedPreferences.getInstance,
        super(const AsyncValue.loading()) {
    load();
  }

  final Future<SharedPreferences> Function() _preferencesFactory;

  Future<AppThemeMode> load() async {
    state = const AsyncValue.loading();

    try {
      final preferences = await _preferencesFactory();
      final mode = ThemePreferenceStore(preferences).load();
      state = AsyncValue.data(mode);
      return mode;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return AppThemeMode.system;
    }
  }

  Future<void> save(AppThemeMode mode) async {
    try {
      final preferences = await _preferencesFactory();
      await ThemePreferenceStore(preferences).save(mode);
      state = AsyncValue.data(mode);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final themeControllerProvider =
    StateNotifierProvider<ThemeController, AsyncValue<AppThemeMode>>(
  (ref) => ThemeController(),
);
