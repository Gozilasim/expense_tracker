import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/language_settings.dart';
import '../l10n/app_l10n.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  Future<void> _selectLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLanguage? language,
  ) async {
    await ref.read(languageControllerProvider.notifier).save(language);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage = ref.watch(languageControllerProvider).valueOrNull;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            RadioListTile<AppLanguage?>(
              value: null,
              groupValue: selectedLanguage,
              title: Text(l10n.systemDefault),
              subtitle: Text(l10n.systemDefaultSubtitle),
              secondary: const Icon(Icons.phone_android),
              onChanged: (value) => _selectLanguage(context, ref, value),
            ),
            const Divider(height: 1),
            RadioListTile<AppLanguage?>(
              value: AppLanguage.chinese,
              groupValue: selectedLanguage,
              title: Text(l10n.chineseLanguage),
              secondary: const Icon(Icons.translate),
              onChanged: (value) => _selectLanguage(context, ref, value),
            ),
            RadioListTile<AppLanguage?>(
              value: AppLanguage.malay,
              groupValue: selectedLanguage,
              title: Text(l10n.malayLanguage),
              secondary: const Icon(Icons.translate),
              onChanged: (value) => _selectLanguage(context, ref, value),
            ),
            RadioListTile<AppLanguage?>(
              value: AppLanguage.english,
              groupValue: selectedLanguage,
              title: Text(l10n.englishLanguage),
              secondary: const Icon(Icons.translate),
              onChanged: (value) => _selectLanguage(context, ref, value),
            ),
          ],
        ),
      ),
    );
  }
}
