import 'package:expense_tracker/data/local/database.dart';
import 'package:expense_tracker/data/receipt_ocr.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const existingCategories = [
    Category(id: 1, name: 'General', icon: null, color: 0xFF9E9E9E),
    Category(id: 2, name: 'Groceries', icon: null, color: 0xFF00AA00),
  ];

  test('keeps existing category ids when user selects an existing category',
      () {
    final plan = planReceiptImport(
      entries: [
        ReviewedReceiptEntry(
          amount: 20.5,
          date: DateTime(2026, 4, 19, 12),
          note: 'Dinner',
          useNewCategory: false,
          categoryId: 1,
        ),
      ],
      existingCategories: existingCategories,
    );

    expect(plan.newCategoryNames, isEmpty);
    expect(plan.expenses, hasLength(1));
    expect(plan.expenses.single.existingCategoryId, 1);
  });

  test('deduplicates new categories across multiple entries', () {
    final plan = planReceiptImport(
      entries: [
        ReviewedReceiptEntry(
          amount: 5.0,
          date: DateTime(2026, 4, 19, 12),
          note: 'Snack',
          useNewCategory: true,
          newCategoryName: 'Snacks',
        ),
        ReviewedReceiptEntry(
          amount: 7.5,
          date: DateTime(2026, 4, 19, 12),
          note: 'More snacks',
          useNewCategory: true,
          newCategoryName: 'snacks',
        ),
      ],
      existingCategories: existingCategories,
    );

    expect(plan.newCategoryNames, ['Snacks']);
    expect(plan.expenses, hasLength(2));
    expect(plan.expenses[0].newCategoryName, 'Snacks');
    expect(plan.expenses[1].newCategoryName, 'Snacks');
  });

  test('reuses an existing category when a new suggestion matches by name', () {
    final plan = planReceiptImport(
      entries: [
        ReviewedReceiptEntry(
          amount: 18.0,
          date: DateTime(2026, 4, 19, 12),
          note: 'Market',
          useNewCategory: true,
          newCategoryName: 'groceries',
        ),
      ],
      existingCategories: existingCategories,
    );

    expect(plan.newCategoryNames, isEmpty);
    expect(plan.expenses.single.existingCategoryId, 2);
    expect(plan.expenses.single.newCategoryName, isNull);
  });
}
