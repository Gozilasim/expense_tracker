import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ocr_api_settings.dart';
import '../data/receipt_ocr.dart';
import '../l10n/app_l10n.dart';

class BackendSettingsScreen extends ConsumerStatefulWidget {
  const BackendSettingsScreen({super.key});

  @override
  ConsumerState<BackendSettingsScreen> createState() =>
      _BackendSettingsScreenState();
}

class _BackendSettingsScreenState extends ConsumerState<BackendSettingsScreen> {
  final _apiUrlController = TextEditingController();
  String? _lastLoadedApiUrl;
  bool _isSavingApiUrl = false;
  bool _isTestingApiUrl = false;

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveApiUrl() async {
    final trimmed = _apiUrlController.text.trim();
    if (trimmed.isNotEmpty && parseStoredOcrApiUrl(trimmed) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.invalidApiUrl),
        ),
      );
      return;
    }

    setState(() {
      _isSavingApiUrl = true;
    });

    try {
      await ref.read(ocrApiUrlControllerProvider.notifier).save(trimmed);
      if (!mounted) return;

      final message = trimmed.isEmpty
          ? context.l10n.apiUrlCleared
          : context.l10n.apiUrlSaved;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.failedToSaveApiUrl('$error'))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingApiUrl = false;
        });
      }
    }
  }

  Future<void> _testApiUrl() async {
    final apiUrl = parseStoredOcrApiUrl(_apiUrlController.text);
    if (apiUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.invalidApiUrl)),
      );
      return;
    }

    setState(() {
      _isTestingApiUrl = true;
    });

    try {
      final result = await ref
          .read(receiptOcrApiClientProvider)
          .testConnection(apiUrl: apiUrl);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_localizedConnectionMessage(result)),
          backgroundColor: result.reachable ? Colors.green[700] : null,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTestingApiUrl = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ocrApiUrlAsync = ref.watch(ocrApiUrlControllerProvider);
    final loadedApiUrl = ocrApiUrlAsync.valueOrNull;
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    if (loadedApiUrl != _lastLoadedApiUrl) {
      _lastLoadedApiUrl = loadedApiUrl;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _apiUrlController.value = TextEditingValue(
          text: loadedApiUrl ?? '',
          selection: TextSelection.collapsed(
            offset: (loadedApiUrl ?? '').length,
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.linkBackend),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              l10n.receiptOcrBackend,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.backendDescription,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _apiUrlController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: l10n.ocrBackendApiUrl,
                hintText: 'https://api.example.com/ocr/import',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.backendUrlHelp,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            if (ocrApiUrlAsync.hasError) ...[
              const SizedBox(height: 8),
              Text(
                l10n.failedToLoadApiUrl('${ocrApiUrlAsync.error}'),
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: _isSavingApiUrl ? null : _saveApiUrl,
                  icon: const Icon(Icons.save),
                  label: Text(_isSavingApiUrl ? l10n.saving : l10n.saveApiUrl),
                ),
                OutlinedButton.icon(
                  onPressed: _isTestingApiUrl ? null : _testApiUrl,
                  icon: const Icon(Icons.wifi_tethering),
                  label: Text(
                    _isTestingApiUrl ? l10n.testing : l10n.testConnection,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _localizedConnectionMessage(OcrConnectionTestResult result) {
    final l10n = context.l10n;
    final message = result.message;

    if (message == 'Server reached, but this OCR API path was not found.') {
      return l10n.serverPathNotFound;
    }
    if (message.startsWith('Server reached, but it returned ')) {
      final statusCode = message.replaceAll(RegExp(r'[^0-9]'), '');
      return l10n.serverReturnedStatus(statusCode);
    }
    if (message == 'OCR server is reachable.') {
      return l10n.ocrServerReachable;
    }
    if (message == 'Connection timed out. Check the API URL and network.') {
      return l10n.connectionTimedOut;
    }
    if (message.startsWith('Connection test failed: ')) {
      return l10n.connectionTestFailed(
        message.substring('Connection test failed: '.length),
      );
    }
    if (message ==
        'Cannot resolve the OCR API host. Check the URL domain or IP address.') {
      return l10n.cannotResolveOcrHost;
    }
    if (message ==
        'OCR backend refused the connection. Check that the server is running on this port.') {
      return l10n.ocrConnectionRefused;
    }
    if (message ==
        'OCR backend is unreachable. Check that the phone and server are on the same network.') {
      return l10n.ocrBackendUnreachable;
    }
    if (message ==
        'Cannot connect to the OCR backend. Check the API URL, Wi-Fi, and server firewall.') {
      return l10n.cannotConnectOcrBackend;
    }
    if (message ==
        'HTTP traffic was blocked. Use HTTPS or allow cleartext traffic for local testing.') {
      return l10n.httpTrafficBlocked;
    }
    if (message ==
        'Cannot connect to the OCR backend. Check the API URL and network.') {
      return l10n.cannotConnectOcrNetwork;
    }
    return message;
  }
}
