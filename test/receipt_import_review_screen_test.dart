import 'package:expense_tracker/data/local/database.dart';
import 'package:expense_tracker/data/receipt_ocr.dart';
import 'package:expense_tracker/ui/receipt_import_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_localizations.dart';

void main() {
  const categories = [
    Category(id: 1, name: 'Food', icon: null, color: 0xFF000001),
    Category(id: 2, name: 'Transport', icon: null, color: 0xFF000002),
  ];

  Widget buildScreen({
    required List<ReceiptOcrEntry> entries,
    required Future<void> Function(List<ReviewedReceiptEntry>) onSaveEntries,
  }) {
    return ProviderScope(
      child: localizedTestApp(
        home: ReceiptImportReviewScreen(
          entries: entries,
          categories: categories,
          onSaveEntries: onSaveEntries,
        ),
      ),
    );
  }

  testWidgets('saves a single reviewed entry', (tester) async {
    List<ReviewedReceiptEntry>? savedEntries;

    await tester.pumpWidget(
      buildScreen(
        entries: [
          ReceiptOcrEntry(
            amount: 12.8,
            date: DateTime(2026, 4, 19, 12),
            note: 'Lunch set',
            categoryKind: ReceiptCategoryKind.existing,
            categoryId: 1,
            categoryName: 'Food',
          ),
        ],
        onSaveEntries: (entries) async {
          savedEntries = entries;
        },
      ),
    );

    await tester.tap(find.byKey(const Key('review-save-button')));
    await tester.pumpAndSettle();

    expect(savedEntries, isNotNull);
    expect(savedEntries, hasLength(1));
    expect(savedEntries!.single.amount, 12.8);
    expect(savedEntries!.single.categoryId, 1);
  });

  testWidgets('shows validation when a new category name is cleared',
      (tester) async {
    var saveCalls = 0;

    await tester.pumpWidget(
      buildScreen(
        entries: [
          ReceiptOcrEntry(
            amount: 4.5,
            date: DateTime(2026, 4, 19, 12),
            note: null,
            categoryKind: ReceiptCategoryKind.newCategory,
            categoryId: null,
            categoryName: 'Snacks',
          ),
        ],
        onSaveEntries: (_) async {
          saveCalls += 1;
        },
      ),
    );

    await tester.enterText(
      find.byKey(const Key('review-entry-new-category-0')),
      '',
    );
    await tester.tap(find.byKey(const Key('review-save-button')));
    await tester.pumpAndSettle();

    expect(
        find.textContaining('must have a new category name'), findsOneWidget);
    expect(saveCalls, 0);
  });

  testWidgets('saves multiple reviewed entries together', (tester) async {
    List<ReviewedReceiptEntry>? savedEntries;

    await tester.pumpWidget(
      buildScreen(
        entries: [
          ReceiptOcrEntry(
            amount: 12.8,
            date: DateTime(2026, 4, 19, 12),
            note: 'Lunch set',
            categoryKind: ReceiptCategoryKind.existing,
            categoryId: 1,
            categoryName: 'Food',
          ),
          ReceiptOcrEntry(
            amount: 4.5,
            date: DateTime(2026, 4, 19, 12),
            note: 'Snack',
            categoryKind: ReceiptCategoryKind.newCategory,
            categoryId: null,
            categoryName: 'Snacks',
          ),
        ],
        onSaveEntries: (entries) async {
          savedEntries = entries;
        },
      ),
    );

    await tester.tap(find.byKey(const Key('review-save-button')));
    await tester.pumpAndSettle();

    expect(savedEntries, isNotNull);
    expect(savedEntries, hasLength(2));
    expect(savedEntries!.last.newCategoryName, 'Snacks');
  });
}
