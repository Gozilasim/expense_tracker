# Expense Tracker

A local expense tracking app built with Flutter. Data is stored in SQLite, state is managed with Riverpod, and charts are rendered with `fl_chart`.

## Features

- Add, edit, and delete expense records
- Filter data by month, year, or a custom date range
- View category totals and spending distribution
- Manage categories: add, edit, and delete
- Backup and restore local data
- Fully local persistence with no remote backend

## Tech Stack

- Flutter
- Riverpod
- Drift + SQLite
- fl_chart
- intl
- share_plus
- file_picker

## Project Structure

```text
expense_tracker/
|- lib/
|  |- data/          Data layer: database, providers, query logic
|  |- ui/            Screens and UI components
|  |- main.dart      Application entry point
|- test/             Test directory
|- android/ios/...   Flutter platform projects
|- pubspec.yaml      Dependencies and project configuration
```

See the following for more details:

- [lib/README.md](lib/README.md)
- [lib/data/README.md](lib/data/README.md)
- [lib/ui/README.md](lib/ui/README.md)
- [test/README.md](test/README.md)

## Current Data Model

### `categories`

- `id`: auto-increment primary key
- `name`: category name
- `icon`: Material Icon code point stored as a string, nullable
- `color`: category color value

### `expenses`

- `id`: auto-increment primary key
- `amount`: expense amount
- `date`: expense timestamp
- `note`: optional note
- `categoryId`: related category id

When the database is created for the first time, a default `General` category is inserted automatically.

## Local Development

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Generate code

This project uses code generation for Drift and Riverpod:

```bash
dart run build_runner build --delete-conflicting-outputs
```

If you want continuous generation during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### 3. Run the app

```bash
flutter run
```

## Key Entry Points

- App entry point: [lib/main.dart](lib/main.dart)
- Home screen and filter logic: [lib/ui/home_screen.dart](lib/ui/home_screen.dart)
- Add/edit expense flow: [lib/ui/add_expense_screen.dart](lib/ui/add_expense_screen.dart)
- Category management and backup/restore: [lib/ui/category_manager_screen.dart](lib/ui/category_manager_screen.dart)
- Database definition: [lib/data/local/database.dart](lib/data/local/database.dart)
- Providers and queries: [lib/data/providers.dart](lib/data/providers.dart)

## Important Notes

- The database file is a local `db.sqlite` stored in the app documents directory, not the repository root.
- `lib/data/providers.g.dart` and `lib/data/local/database.g.dart` are generated files and should not be edited manually.
- `test/widget_test.dart` is still the default Flutter template test and does not match the current app behavior.
- The repository root contains development artifacts such as `build/`, `.dart_tool/`, `db.sqlite`, and `build_log*.txt`; keep them separate from source files when maintaining the project.

## Suggested Next Improvements

- Improve database reload behavior after import/restore so the app does not rely on a restart recommendation
- Define a clearer strategy for deleting categories that are referenced by expenses
- Add tests for filtering, CRUD flows, and backup/restore behavior
