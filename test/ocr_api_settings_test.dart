import 'package:expense_tracker/data/ocr_api_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OcrApiUrlStore', () {
    test('loads, saves, and overwrites the stored API URL', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final store = OcrApiUrlStore(preferences);

      expect(store.load(), isNull);

      await store.save('https://api.example.com/ocr/import');
      expect(store.load(), 'https://api.example.com/ocr/import');

      await store.save('https://api.example.com/v2/import');
      expect(store.load(), 'https://api.example.com/v2/import');
    });

    test('clears the stored API URL', () async {
      SharedPreferences.setMockInitialValues({
        ocrBackendApiUrlPreferenceKey: 'https://api.example.com/ocr/import',
      });
      final preferences = await SharedPreferences.getInstance();
      final store = OcrApiUrlStore(preferences);

      await store.clear();

      expect(store.load(), isNull);
    });
  });

  group('parseStoredOcrApiUrl', () {
    test('accepts valid absolute http and https URLs', () {
      expect(
        parseStoredOcrApiUrl('https://api.example.com/ocr/import')?.toString(),
        'https://api.example.com/ocr/import',
      );
      expect(
        parseStoredOcrApiUrl('http://localhost:8000/import')?.toString(),
        'http://localhost:8000/import',
      );
    });

    test('rejects invalid or empty URLs', () {
      expect(parseStoredOcrApiUrl(null), isNull);
      expect(parseStoredOcrApiUrl(''), isNull);
      expect(parseStoredOcrApiUrl('not-a-url'), isNull);
      expect(parseStoredOcrApiUrl('/ocr/import'), isNull);
      expect(parseStoredOcrApiUrl('ftp://api.example.com/import'), isNull);
    });
  });
}
