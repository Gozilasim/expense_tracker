import 'package:flutter/material.dart';
import 'backend_settings_screen.dart';
import 'category_manager_screen.dart';
import 'data_settings_screen.dart';
import 'language_settings_screen.dart';
import '../l10n/app_l10n.dart';
import 'owner_about_screen.dart';
import 'theme_settings_screen.dart';

class SettingsHubScreen extends StatelessWidget {
  const SettingsHubScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SettingsEntry(
              icon: Icons.language,
              title: l10n.language,
              onTap: () => _open(context, const LanguageSettingsScreen()),
            ),
            const SizedBox(height: 10),
            _SettingsEntry(
              icon: Icons.contrast,
              title: l10n.theme,
              onTap: () => _open(context, const ThemeSettingsScreen()),
            ),
            const SizedBox(height: 10),
            _SettingsEntry(
              icon: Icons.link,
              title: l10n.linkBackend,
              onTap: () => _open(context, const BackendSettingsScreen()),
            ),
            const SizedBox(height: 10),
            _SettingsEntry(
              icon: Icons.category,
              title: l10n.categories,
              onTap: () => _open(context, const CategoryManagerScreen()),
            ),
            const SizedBox(height: 10),
            _SettingsEntry(
              icon: Icons.storage,
              title: l10n.data,
              onTap: () => _open(context, const DataSettingsScreen()),
            ),
            const SizedBox(height: 10),
            _SettingsEntry(
              icon: Icons.info_outline,
              title: l10n.about,
              onTap: () => _open(context, const OwnerAboutScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsEntry extends StatelessWidget {
  const _SettingsEntry({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        minVerticalPadding: 18,
        leading: Icon(
          icon,
          color: colorScheme.primary,
          size: 28,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
