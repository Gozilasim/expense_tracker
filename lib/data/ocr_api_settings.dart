import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const ocrBackendApiUrlPreferenceKey = 'ocr_backend_api_url';

Uri? parseStoredOcrApiUrl(String? input) {
  final trimmed = input?.trim() ?? '';
  if (trimmed.isEmpty) return null;

  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
    return null;
  }

  if (uri.scheme != 'http' && uri.scheme != 'https') {
    return null;
  }

  return uri;
}

class OcrApiUrlStore {
  OcrApiUrlStore(this._preferences);

  final SharedPreferences _preferences;

  String? load() => _preferences.getString(ocrBackendApiUrlPreferenceKey);

  Future<void> save(String url) {
    return _preferences.setString(ocrBackendApiUrlPreferenceKey, url.trim());
  }

  Future<void> clear() {
    return _preferences.remove(ocrBackendApiUrlPreferenceKey);
  }
}

class OcrApiUrlController extends StateNotifier<AsyncValue<String?>> {
  OcrApiUrlController({
    Future<SharedPreferences> Function()? preferencesFactory,
  })  : _preferencesFactory =
            preferencesFactory ?? SharedPreferences.getInstance,
        super(const AsyncValue.loading()) {
    load();
  }

  final Future<SharedPreferences> Function() _preferencesFactory;

  Future<String?> load() async {
    state = const AsyncValue.loading();

    try {
      final preferences = await _preferencesFactory();
      final value = OcrApiUrlStore(preferences).load();
      state = AsyncValue.data(value);
      return value;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Future<void> save(String url) async {
    final trimmed = url.trim();

    try {
      final preferences = await _preferencesFactory();
      final store = OcrApiUrlStore(preferences);

      if (trimmed.isEmpty) {
        await store.clear();
        state = const AsyncValue.data(null);
        return;
      }

      await store.save(trimmed);
      state = AsyncValue.data(trimmed);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final ocrApiUrlControllerProvider =
    StateNotifierProvider<OcrApiUrlController, AsyncValue<String?>>(
  (ref) => OcrApiUrlController(),
);
