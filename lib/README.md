# `lib` Directory Guide

`lib` contains the core application source code. It is mainly split into the entry point, data layer, and UI layer.

## Structure

```text
lib/
|- main.dart
|- data/
|  |- local/
|  |- providers.dart
|  |- providers.g.dart
|- ui/
```

## Responsibilities

- `main.dart`
  - Application entry point
  - Initializes `ProviderScope`
  - Configures the `MaterialApp` theme and home screen

- `data/`
  - Database schema
  - Local SQLite connection
  - Riverpod providers
  - Expense and category query logic

- `ui/`
  - Screens
  - Reusable UI components
  - User interaction logic

## Maintenance Notes

- Prefer splitting new features by data layer and UI layer instead of scattering database operations across screens.
- Do not edit generated files such as `*.g.dart`; regenerate them with `build_runner`.
- If the project grows further, consider splitting `ui/` into `screens/` and `widgets/`.
