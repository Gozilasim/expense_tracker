import 'dart:typed_data';

import 'package:expense_tracker/data/local/database.dart';
import 'package:expense_tracker/data/receipt_ocr.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker/image_picker.dart';
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

  test('parses a generated category entry and ignores backend category id', () {
    final entries = parseReceiptEntries(
      responseBody: '''
      {
        "entries": [
          {
            "amount": 11.0,
            "date": "2026-04-10",
            "note": "F02 Fish Ball Noodle",
            "category_kind": "generated",
            "category_id": 1,
            "category_name": "Food"
          }
        ]
      }
      ''',
      categories: const [],
    );

    expect(entries, hasLength(1));
    expect(entries.first.amount, 11.0);
    expect(entries.first.categoryKind, ReceiptCategoryKind.newCategory);
    expect(entries.first.categoryId, isNull);
    expect(entries.first.categoryName, 'Food');
  });

  test('parses mixed existing and generated category entries', () {
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
            "category_kind": "generated",
            "category_id": 10,
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

  test('keeps new as a backward-compatible category_kind alias', () {
    final entries = parseReceiptEntries(
      responseBody: '''
      {
        "entries": [
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

    expect(entries.single.categoryKind, ReceiptCategoryKind.newCategory);
    expect(entries.single.categoryName, 'Snacks');
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
        responseBody:
            '{"entries":[{"amount": 10, "date": "2026-04-19", "category_kind": "generated", "category_id": 1, "category_name": ""}]}',
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

  group('ReceiptOcrApiClient errors', () {
    test('maps known 400 details to user input errors', () async {
      final exception = await _scanExceptionForResponse(
        statusCode: 400,
        body: '{"status":"error","detail":"Image is not a receipt"}',
      );

      expect(exception.kind, ReceiptScanFailureKind.userInput);
      expect(exception.statusCode, 400);
      expect(exception.backendDetail, 'Image is not a receipt');
      expect(exception.userMessage, 'Please upload a clear receipt photo.');
      expect(exception.canRetry, isFalse);
    });

    test('maps unknown 400 details to the default user input message',
        () async {
      final exception = await _scanExceptionForResponse(
        statusCode: 400,
        body: '{"status":"error","detail":"Unexpected validation issue"}',
      );

      expect(exception.kind, ReceiptScanFailureKind.userInput);
      expect(exception.backendDetail, 'Unexpected validation issue');
      expect(exception.userMessage, 'Please upload a clear receipt photo.');
    });

    test('maps 502 details to retryable service errors', () async {
      final exception = await _scanExceptionForResponse(
        statusCode: 502,
        body: '{"status":"error","detail":"Groq OCR returned invalid JSON"}',
      );

      expect(exception.kind, ReceiptScanFailureKind.serviceUnavailable);
      expect(exception.statusCode, 502);
      expect(exception.backendDetail, 'Groq OCR returned invalid JSON');
      expect(
        exception.userMessage,
        'Recognition service is temporarily unavailable. Please try again later.',
      );
      expect(exception.canRetry, isTrue);
    });

    test('maps 422 details to app bug errors', () async {
      final exception = await _scanExceptionForResponse(
        statusCode: 422,
        body: '{"status":"error","detail":"Field required"}',
      );

      expect(exception.kind, ReceiptScanFailureKind.appBug);
      expect(exception.statusCode, 422);
      expect(exception.backendDetail, 'Field required');
    });

    test('maps 500 details to server errors', () async {
      final exception = await _scanExceptionForResponse(
        statusCode: 500,
        body: '{"status":"error","detail":"Internal server error"}',
      );

      expect(exception.kind, ReceiptScanFailureKind.serverError);
      expect(exception.statusCode, 500);
      expect(exception.backendDetail, 'Internal server error');
    });

    test('maps malformed error bodies to unknown errors', () async {
      final exception = await _scanExceptionForResponse(
        statusCode: 502,
        body: 'not json',
      );

      expect(exception.kind, ReceiptScanFailureKind.unknown);
      expect(exception.statusCode, 502);
      expect(exception.backendDetail, isNull);
      expect(exception.responseBody, 'not json');
      expect(exception.canRetry, isFalse);
    });
  });
}

Future<ReceiptScanException> _scanExceptionForResponse({
  required int statusCode,
  required String body,
}) async {
  final client = MockClient((request) async {
    return http.Response(
      body,
      statusCode,
      headers: {'content-type': 'application/json'},
    );
  });

  final imageFile = XFile.fromData(
    Uint8List.fromList([1, 2, 3]),
    name: 'receipt.jpg',
    mimeType: 'image/jpeg',
  );

  try {
    await ReceiptOcrApiClient().scanReceipt(
      apiUrl: Uri.parse('https://api.example.com/ocr/import'),
      imageFile: imageFile,
      categories: const [],
      client: client,
    );
  } on ReceiptScanException catch (error) {
    return error;
  }

  fail('Expected ReceiptScanException.');
}
