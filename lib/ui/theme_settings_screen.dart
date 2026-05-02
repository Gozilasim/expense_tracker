import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/theme_settings.dart';
import '../l10n/app_l10n.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  Future<void> _selectThemeMode(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode mode,
  ) async {
    await ref.read(themeControllerProvider.notifier).save(mode);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedThemeMode =
        ref.watch(themeControllerProvider).valueOrNull ?? AppThemeMode.system;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.theme),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            RadioListTile<AppThemeMode>(
              value: AppThemeMode.system,
              groupValue: selectedThemeMode,
              title: Text(l10n.themeSystemMode),
              secondary: const Icon(Icons.brightness_auto),
              onChanged: (value) {
                if (value != null) {
                  _selectThemeMode(context, ref, value);
                }
              },
            ),
            const Divider(height: 1),
            RadioListTile<AppThemeMode>(
              value: AppThemeMode.light,
              groupValue: selectedThemeMode,
              title: Text(l10n.themeLight),
              secondary: const Icon(Icons.light_mode),
              onChanged: (value) {
                if (value != null) {
                  _selectThemeMode(context, ref, value);
                }
              },
            ),
            RadioListTile<AppThemeMode>(
              value: AppThemeMode.dark,
              groupValue: selectedThemeMode,
              title: Text(l10n.themeDark),
              secondary: const Icon(Icons.dark_mode),
              onChanged: (value) {
                if (value != null) {
                  _selectThemeMode(context, ref, value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
