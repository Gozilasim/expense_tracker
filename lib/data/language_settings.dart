import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const appLanguageCodePreferenceKey = 'app_language_code';

enum AppLanguage {
  chinese('zh', Locale('zh')),
  malay('ms', Locale('ms')),
  english('en', Locale('en'));

  const AppLanguage(this.code, this.locale);

  final String code;
  final Locale locale;

  static AppLanguage? fromCode(String? code) {
    for (final language in AppLanguage.values) {
      if (language.code == code) {
        return language;
      }
    }
    return null;
  }
}

class LanguagePreferenceStore {
  LanguagePreferenceStore(this._preferences);

  final SharedPreferences _preferences;

  AppLanguage? load() {
    return AppLanguage.fromCode(_preferences.getString(
      appLanguageCodePreferenceKey,
    ));
  }

  Future<void> save(AppLanguage? language) {
    if (language == null) {
      return _preferences.remove(appLanguageCodePreferenceKey);
    }
    return _preferences.setString(appLanguageCodePreferenceKey, language.code);
  }
}

class LanguageController extends StateNotifier<AsyncValue<AppLanguage?>> {
  LanguageController({
    Future<SharedPreferences> Function()? preferencesFactory,
  })  : _preferencesFactory =
            preferencesFactory ?? SharedPreferences.getInstance,
        super(const AsyncValue.loading()) {
    load();
  }

  final Future<SharedPreferences> Function() _preferencesFactory;

  Future<AppLanguage?> load() async {
    state = const AsyncValue.loading();

    try {
      final preferences = await _preferencesFactory();
      final language = LanguagePreferenceStore(preferences).load();
      state = AsyncValue.data(language);
      return language;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Future<void> save(AppLanguage? language) async {
    try {
      final preferences = await _preferencesFactory();
      await LanguagePreferenceStore(preferences).save(language);
      state = AsyncValue.data(language);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final languageControllerProvider =
    StateNotifierProvider<LanguageController, AsyncValue<AppLanguage?>>(
  (ref) => LanguageController(),
);
