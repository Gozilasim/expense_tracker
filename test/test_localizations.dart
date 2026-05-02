import 'package:expense_tracker/data/language_settings.dart';
import 'package:expense_tracker/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget localizedTestApp({
  required Widget home,
  Locale locale = const Locale('en'),
  ThemeData? theme,
  ThemeData? darkTheme,
  ThemeMode? themeMode,
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: theme,
    darkTheme: darkTheme,
    themeMode: themeMode,
    home: home,
  );
}

class LocalizedProviderTestApp extends ConsumerWidget {
  const LocalizedProviderTestApp({
    super.key,
    required this.home,
    this.fallbackLocale = const Locale('en'),
  });

  final Widget home;
  final Locale fallbackLocale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageControllerProvider).valueOrNull;

    return MaterialApp(
      locale: language?.locale ?? fallbackLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    );
  }
}
