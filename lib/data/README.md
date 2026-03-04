# `lib/data` Directory Guide

This directory is responsible for data access, persistence, and state exposure.

## File Responsibilities

- `providers.dart`
  - Exposes the database provider
  - Exposes category and expense streams
  - Defines the `ExpenseWithCategory` aggregate model

- `providers.g.dart`
  - Riverpod generated file
  - Do not edit manually

- `local/database.dart`
  - Drift table definitions
  - Database instance and migration strategy
  - SQLite file connection logic

- `local/database.g.dart`
  - Drift generated file
  - Do not edit manually

## Current Implementation Highlights

- `expensesProvider` filters by date range at the SQL level instead of loading all records and filtering in Dart.
- Categories and expenses are joined into `ExpenseWithCategory`, so the UI does not need to resolve categories separately.
- A default `General` category is seeded when the database is created for the first time.
- The database enables `PRAGMA foreign_keys = ON` before use.

## Maintenance Notes

- If you change the schema, update both `schemaVersion` and the migration logic.
- When adding new providers, reuse the existing database provider instead of creating another database instance.
- Backup restore currently refreshes providers via `invalidate`, but the UX still recommends restarting the app; this can be improved later.
