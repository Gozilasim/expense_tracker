import 'package:expense_tracker/data/local/database.dart';
import 'package:expense_tracker/data/receipt_ocr.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const categories = [
    Category(id: 1, name: 'Food', icon: null, color: 0xFF000001),
    Category(id: 2, name: 'Transport', icon: null, color: 0xFF000002),
  ];

  test('parses a response with a single existing category entry', () {
    final entries = parseReceiptEntries(
      responseBody: '''
      {
        "entries": [
          {
            "amount": 12.8,
            "date": "2026-04-19",
            "note": "Lunch set",
            "category_kind": "existing",
            "category_id": 1,
            "category_name": "Food"
          }
        ]
      }
      ''',
      categories: categories,
    );

    expect(entries, hasLength(1));
    expect(entries.first.amount, 12.8);
    expect(entries.first.categoryKind, ReceiptCategoryKind.existing);
    expect(entries.first.categoryId, 1);
    expect(entries.first.categoryName, 'Food');
  });

  test('parses mixed existing and new category entries', () {
    final entries = parseReceiptEntries(
      responseBody: '''
      {
        "entries": [
          {
            "amount": 8.5,
            "date": "2026-04-19T09:30:00",
            "note": "Train fare",
            "category_kind": "existing",
            "category_id": 2,
            "category_name": "Transport"
          },
          {
            "amount": 4.25,
            "date": "2026-04-19",
            "note": null,
            "category_kind": "new",
            "category_id": null,
            "category_name": "Snacks"
          }
        ]
      }
      ''',
      categories: categories,
    );

    expect(entries, hasLength(2));
    expect(entries.last.categoryKind, ReceiptCategoryKind.newCategory);
    expect(entries.last.categoryId, isNull);
    expect(entries.last.categoryName, 'Snacks');
  });

  test('rejects malformed and empty responses', () {
    expect(
      () => parseReceiptEntries(
        responseBody: '{"entries":[]}',
        categories: categories,
      ),
      throwsA(isA<ReceiptImportException>()),
    );

    expect(
      () => parseReceiptEntries(
        responseBody:
            '{"entries":[{"amount": 10, "date": "2026-04-19", "category_kind": "existing", "category_id": 999}]}',
        categories: categories,
      ),
      throwsA(isA<ReceiptImportException>()),
    );

    expect(
      () => parseReceiptEntries(
        responseBody: 'not json',
        categories: categories,
      ),
      throwsA(isA<ReceiptImportException>()),
    );
  });
}
