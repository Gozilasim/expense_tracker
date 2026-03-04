import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import 'local/database.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase database(Ref ref) {
  return AppDatabase();
}

class ExpenseWithCategory {
  final Expense expense;
  final Category category;
  ExpenseWithCategory({required this.expense, required this.category});
}

@riverpod
Stream<List<ExpenseWithCategory>> expenses(Ref ref, {required DateTimeRange dateRange}) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.expenses).join([
    innerJoin(db.categories, db.categories.id.equalsExp(db.expenses.categoryId))
  ])
      ..where(db.expenses.date.isBetweenValues(dateRange.start, dateRange.end))
      ..orderBy([OrderingTerm.desc(db.expenses.date)]))
      .watch()
      .map((rows) => rows.map((row) {
            return ExpenseWithCategory(
              expense: row.readTable(db.expenses),
              category: row.readTable(db.categories),
            );
          }).toList());
}

@riverpod
Stream<List<Category>> categories(Ref ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.categories).watch();
}
