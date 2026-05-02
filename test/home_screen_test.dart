import 'package:drift/native.dart';
import 'package:expense_tracker/data/local/database.dart';
import 'package:expense_tracker/data/language_settings.dart';
import 'package:expense_tracker/data/ocr_api_settings.dart';
import 'package:expense_tracker/data/providers.dart';
import 'package:expense_tracker/data/theme_settings.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/ui/category_pie_chart.dart';
import 'package:expense_tracker/ui/category_manager_screen.dart';
import 'package:expense_tracker/ui/home_screen.dart';
import 'package:expense_tracker/ui/language_settings_screen.dart';
import 'package:expense_tracker/ui/owner_about_screen.dart';
import 'package:expense_tracker/ui/settings_hub_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> closeDatabaseWidget(
    WidgetTester tester,
    AppDatabase database,
  ) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.idle();
    await tester.pump();
    await database.close();
  }

  Future<void> pumpRoute(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.idle();
    await tester.pump();
  }

  Widget buildHomeScreen(AppDatabase database) {
    SharedPreferences.setMockInitialValues({
      ocrBackendApiUrlPreferenceKey: 'https://api.example.com/ocr/import',
    });

    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: localizedTestApp(home: const HomeScreen()),
    );
  }

  Widget buildDarkHomeScreen(AppDatabase database) {
    SharedPreferences.setMockInitialValues({
      ocrBackendApiUrlPreferenceKey: 'https://api.example.com/ocr/import',
      appThemeModePreferenceKey: AppThemeMode.dark.code,
    });

    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: localizedTestApp(
        theme: buildAppTheme(Brightness.light),
        darkTheme: buildAppTheme(Brightness.dark),
        themeMode: ThemeMode.dark,
        home: const HomeScreen(),
      ),
    );
  }

  testWidgets('delete expense confirmation returns false when cancelled',
      (tester) async {
    bool? result;

    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await confirmDeleteExpense(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await pumpRoute(tester);

    expect(find.text('Delete Expense?'), findsOneWidget);
    expect(
      find.text('Are you sure you want to delete this expense?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await pumpRoute(tester);

    expect(result, isFalse);
    expect(find.text('Delete Expense?'), findsNothing);
  });

  testWidgets('delete expense confirmation returns true when confirmed',
      (tester) async {
    bool? result;

    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await confirmDeleteExpense(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await pumpRoute(tester);

    await tester.tap(find.text('Delete'));
    await pumpRoute(tester);

    expect(result, isTrue);
    expect(find.text('Delete Expense?'), findsNothing);
  });

  Widget buildSettingsHub(AppDatabase database) {
    SharedPreferences.setMockInitialValues({
      ocrBackendApiUrlPreferenceKey: 'https://api.example.com/ocr/import',
    });

    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: localizedTestApp(home: const SettingsHubScreen()),
    );
  }

  testWidgets('home app bar menu only shows settings action', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(buildHomeScreen(database));
    await tester.pump();

    expect(find.byIcon(Icons.more_vert), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await pumpRoute(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('About'), findsNothing);

    await closeDatabaseWidget(tester, database);
  });

  testWidgets('home app bar settings action opens settings hub',
      (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(buildHomeScreen(database));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_vert));
    await pumpRoute(tester);
    await tester.tap(find.text('Settings'));
    await pumpRoute(tester);

    expect(find.text('Link Backend'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Data'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Choose app display language.'), findsNothing);
    expect(find.text('Connect the OCR receipt scanning API.'), findsNothing);

    await closeDatabaseWidget(tester, database);
  });

  testWidgets('settings hub opens theme settings screen', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(buildSettingsHub(database));
    await tester.pump();

    await tester.tap(find.text('Theme'));
    await pumpRoute(tester);

    expect(find.text('System mode'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    await closeDatabaseWidget(tester, database);
  });

  testWidgets('selecting dark theme saves preference', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(buildSettingsHub(database));
    await tester.pump();

    await tester.tap(find.text('Theme'));
    await pumpRoute(tester);
    await tester.tap(find.text('Dark'));
    await pumpRoute(tester);

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString(appThemeModePreferenceKey),
      AppThemeMode.dark.code,
    );

    await closeDatabaseWidget(tester, database);
  });

  testWidgets('saved dark theme drives MaterialApp theme mode', (tester) async {
    SharedPreferences.setMockInitialValues({
      appThemeModePreferenceKey: AppThemeMode.dark.code,
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: _ThemeModeProbeApp(),
      ),
    );
    await tester.pump();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
  });

  testWidgets('dark home screen avoids light-only filter and category surfaces',
      (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final categoryId = await database.into(database.categories).insert(
          CategoriesCompanion.insert(
            name: 'Snack',
            color: 0xFF9E9E9E,
          ),
        );
    await database.into(database.expenses).insert(
          ExpensesCompanion.insert(
            amount: 16.5,
            date: DateTime.now(),
            categoryId: categoryId,
          ),
        );

    await tester.pumpWidget(buildDarkHomeScreen(database));
    await tester.pump();

    final context = tester.element(find.byType(HomeScreen));
    final colorScheme = Theme.of(context).colorScheme;
    final filterBar =
        tester.widget<Container>(find.byKey(const Key('home-filter-bar')));
    final categoryChip = tester.widget<Container>(
      find.byKey(Key('home-category-chip-$categoryId')),
    );
    final categoryDecoration = categoryChip.decoration! as BoxDecoration;

    expect(filterBar.color, colorScheme.surfaceVariant);
    expect(categoryDecoration.color, isNot(Colors.white));

    await closeDatabaseWidget(tester, database);
  });

  testWidgets('dark pie chart center amount uses theme text color',
      (tester) async {
    const category = Category(
      id: 1,
      name: 'Snack',
      icon: null,
      color: 0xFF9E9E9E,
    );

    await tester.pumpWidget(
      localizedTestApp(
        theme: buildAppTheme(Brightness.light),
        darkTheme: buildAppTheme(Brightness.dark),
        themeMode: ThemeMode.dark,
        home: CategoryPieChart(
          totalDays: 1,
          expenses: [
            ExpenseWithCategory(
              expense: Expense(
                id: 1,
                amount: 16.5,
                date: DateTime.now(),
                note: null,
                categoryId: category.id,
              ),
              category: category,
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    final context = tester.element(find.byType(CategoryPieChart));
    final amountText = tester.widget<Text>(
      find.byKey(const Key('category-pie-center-amount')),
    );

    expect(amountText.style?.color, Theme.of(context).colorScheme.onSurface);
    expect(amountText.style?.color, isNot(Colors.black87));
  });

  testWidgets('settings hub opens backend settings screen', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(buildSettingsHub(database));
    await tester.pump();

    await tester.tap(find.text('Link Backend'));
    await pumpRoute(tester);

    expect(find.text('Receipt OCR Backend'), findsOneWidget);
    expect(find.text('Save API URL'), findsOneWidget);
    expect(find.text('Test Connection'), findsOneWidget);

    await closeDatabaseWidget(tester, database);
  });

  testWidgets('settings hub opens categories screen', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(buildSettingsHub(database));
    await tester.pump();

    await tester.tap(find.text('Categories'));
    await pumpRoute(tester);

    expect(find.byType(CategoryManagerScreen), findsOneWidget);

    await closeDatabaseWidget(tester, database);
  });

  testWidgets('settings hub opens data screen', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(buildSettingsHub(database));
    await tester.pump();

    await tester.tap(find.text('Data'));
    await pumpRoute(tester);

    expect(find.text('Backup Data'), findsOneWidget);
    expect(find.text('Restore Data'), findsOneWidget);

    await closeDatabaseWidget(tester, database);
  });

  testWidgets('settings hub opens about screen', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(buildSettingsHub(database));
    await tester.pump();

    await tester.tap(find.text('About'));
    await pumpRoute(tester);

    expect(find.text('Owner'), findsOneWidget);
    expect(find.text(ownerGithubUsername), findsOneWidget);
    expect(find.text(ownerGithubUrl), findsOneWidget);
    expect(
      find.text('If you feel satisfied, please treat the developer a coffee.'),
      findsOneWidget,
    );

    await closeDatabaseWidget(tester, database);
  });

  testWidgets('owner screen shows and enlarges DuitNow QR', (tester) async {
    await tester.pumpWidget(
      localizedTestApp(home: const OwnerAboutScreen()),
    );

    expect(find.text(ownerGithubUsername), findsOneWidget);
    expect(find.text(ownerGithubUrl), findsOneWidget);
    expect(
      find.text('If you feel satisfied, please treat the developer a coffee.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('owner-duitnow-qr-preview-image')),
        findsOneWidget);

    await tester.tap(find.byKey(const Key('owner-duitnow-qr-preview')));
    await pumpRoute(tester);

    expect(find.text('DuitNow QR'), findsOneWidget);
    expect(
      find.byKey(const Key('owner-duitnow-qr-dialog-image')),
      findsOneWidget,
    );
  });

  testWidgets('language settings shows supported language options',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        child: localizedTestApp(home: const LanguageSettingsScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('华文'), findsOneWidget);
    expect(find.text('Bahasa Melayu'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('selecting Malay changes settings text', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: LocalizedProviderTestApp(home: SettingsHubScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Language'));
    await pumpRoute(tester);
    await tester.tap(find.text('Bahasa Melayu'));
    await pumpRoute(tester);

    expect(find.text('Bahasa'), findsOneWidget);
    expect(find.text('Tetapan'), findsOneWidget);
  });

  testWidgets('Chinese locale shows localized home actions', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    SharedPreferences.setMockInitialValues({
      ocrBackendApiUrlPreferenceKey: 'https://api.example.com/ocr/import',
      appLanguageCodePreferenceKey: 'zh',
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
        child: const LocalizedProviderTestApp(home: HomeScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('扫描收据'), findsOneWidget);
    expect(find.text('添加支出'), findsOneWidget);

    await closeDatabaseWidget(tester, database);
  });
}

class _ThemeModeProbeApp extends ConsumerWidget {
  const _ThemeModeProbeApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(themeControllerProvider).valueOrNull ?? AppThemeMode.system;

    return MaterialApp(
      themeMode: themeMode.themeMode,
      home: const SizedBox(),
    );
  }
}
