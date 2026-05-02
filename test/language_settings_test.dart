import 'package:expense_tracker/data/language_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LanguagePreferenceStore', () {
    test('returns null when no language was saved', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final store = LanguagePreferenceStore(preferences);

      expect(store.load(), isNull);
    });

    test('saves and loads supported languages', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final store = LanguagePreferenceStore(preferences);

      await store.save(AppLanguage.chinese);
      expect(store.load(), AppLanguage.chinese);

      await store.save(AppLanguage.malay);
      expect(store.load(), AppLanguage.malay);

      await store.save(AppLanguage.english);
      expect(store.load(), AppLanguage.english);
    });

    test('ignores invalid saved language codes', () async {
      SharedPreferences.setMockInitialValues({
        appLanguageCodePreferenceKey: 'fr',
      });
      final preferences = await SharedPreferences.getInstance();
      final store = LanguagePreferenceStore(preferences);

      expect(store.load(), isNull);
    });

    test('clears language to return to system default', () async {
      SharedPreferences.setMockInitialValues({
        appLanguageCodePreferenceKey: 'zh',
      });
      final preferences = await SharedPreferences.getInstance();
      final store = LanguagePreferenceStore(preferences);

      await store.save(null);

      expect(store.load(), isNull);
    });
  });
}
