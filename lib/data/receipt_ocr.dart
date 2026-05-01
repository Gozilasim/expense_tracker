import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'local/database.dart';
import 'providers.dart';

class ReceiptImportException implements Exception {
  ReceiptImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

enum ReceiptCategoryKind { existing, newCategory }

class ReceiptOcrEntry {
  ReceiptOcrEntry({
    required this.amount,
    required this.date,
    required this.note,
    required this.categoryKind,
    required this.categoryId,
    required this.categoryName,
  });

  final double amount;
  final DateTime date;
  final String? note;
  final ReceiptCategoryKind categoryKind;
  final int? categoryId;
  final String categoryName;
}

class ReviewedReceiptEntry {
  ReviewedReceiptEntry({
    required this.amount,
    required this.date,
    required this.note,
    required this.useNewCategory,
    this.categoryId,
    this.newCategoryName,
  });

  final double amount;
  final DateTime date;
  final String? note;
  final bool useNewCategory;
  final int? categoryId;
  final String? newCategoryName;
}

class PlannedExpenseImport {
  PlannedExpenseImport({
    required this.amount,
    required this.date,
    required this.note,
    required this.existingCategoryId,
    required this.newCategoryName,
  });

  final double amount;
  final DateTime date;
  final String? note;
  final int? existingCategoryId;
  final String? newCategoryName;
}

class ReceiptImportPlan {
  ReceiptImportPlan({
    required this.expenses,
    required this.newCategoryNames,
  });

  final List<PlannedExpenseImport> expenses;
  final List<String> newCategoryNames;
}

List<ReceiptOcrEntry> parseReceiptEntries({
  required String responseBody,
  required List<Category> categories,
}) {
  late final Object decodedBody;

  try {
    decodedBody = jsonDecode(responseBody);
  } catch (_) {
    throw ReceiptImportException('Backend response was not valid JSON.');
  }

  if (decodedBody is! Map<String, dynamic>) {
    throw ReceiptImportException('Backend response must be a JSON object.');
  }

  final rawEntries = decodedBody['entries'];
  if (rawEntries is! List) {
    throw ReceiptImportException(
        'Backend response must include an entries array.');
  }

  if (rawEntries.isEmpty) {
    throw ReceiptImportException(
        'Backend response did not contain any entries.');
  }

  final categoriesById = {
    for (final category in categories) category.id: category,
  };

  return rawEntries.map<ReceiptOcrEntry>((rawEntry) {
    if (rawEntry is! Map<String, dynamic>) {
      throw ReceiptImportException(
          'Each entry returned by the backend must be a JSON object.');
    }

    final amount = _parseAmount(rawEntry['amount']);
    final date = _parseEntryDate(rawEntry['date']);
    final note = _parseOptionalText(rawEntry['note']);
    final categoryKind = _parseCategoryKind(rawEntry['category_kind']);
    final categoryId = _parseOptionalInt(rawEntry['category_id']);
    final categoryName = _parseOptionalText(rawEntry['category_name']) ?? '';

    if (categoryKind == ReceiptCategoryKind.existing) {
      if (categoryId == null || !categoriesById.containsKey(categoryId)) {
        throw ReceiptImportException(
          'Existing category entries must reference a valid local category_id.',
        );
      }
    } else if (categoryName.trim().isEmpty) {
      throw ReceiptImportException(
        'New category entries must include a non-empty category_name.',
      );
    }

    return ReceiptOcrEntry(
      amount: amount,
      date: date,
      note: note,
      categoryKind: categoryKind,
      categoryId: categoryId,
      categoryName: categoryName.trim(),
    );
  }).toList();
}

class ReceiptOcrApiClient {
  Future<List<ReceiptOcrEntry>> scanReceipt({
    required Uri apiUrl,
    required XFile imageFile,
    required List<Category> categories,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();

    try {
      final request = http.MultipartRequest('POST', apiUrl)
        ..fields['categories_json'] = jsonEncode(
          categories
              .map((category) => {
                    'id': category.id,
                    'name': category.name,
                  })
              .toList(),
        )
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            await imageFile.readAsBytes(),
            filename: imageFile.name,
          ),
        );

      final streamedResponse = await httpClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ReceiptImportException(
          'Backend request failed (${response.statusCode}): ${response.body}',
        );
      }

      return parseReceiptEntries(
        responseBody: response.body,
        categories: categories,
      );
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }
}

class ReceiptImportService {
  ReceiptImportService(this._database);

  final AppDatabase _database;

  Future<void> importEntries(List<ReviewedReceiptEntry> entries) async {
    if (entries.isEmpty) {
      throw ReceiptImportException('There are no reviewed entries to import.');
    }

    await _database.transaction(() async {
      final existingCategories =
          await _database.select(_database.categories).get();
      final plan = planReceiptImport(
        entries: entries,
        existingCategories: existingCategories,
      );
      final categoriesById = {
        for (final category in existingCategories) category.id: category,
      };
      final categoriesByNormalizedName = {
        for (final category in existingCategories)
          _normalizeCategoryName(category.name): category,
      };
      final usedColors = {
        for (final category in existingCategories) category.color,
      };

      for (final categoryName in plan.newCategoryNames) {
        final normalizedName = _normalizeCategoryName(categoryName);
        if (categoriesByNormalizedName.containsKey(normalizedName)) {
          continue;
        }

        final color = _pickNextCategoryColor(usedColors);
        usedColors.add(color);

        final categoryId = await _database.into(_database.categories).insert(
              CategoriesCompanion.insert(
                name: categoryName,
                color: color,
                icon: drift.Value(Icons.attach_money.codePoint.toString()),
              ),
            );

        final createdCategory = Category(
          id: categoryId,
          name: categoryName,
          icon: Icons.attach_money.codePoint.toString(),
          color: color,
        );

        categoriesById[categoryId] = createdCategory;
        categoriesByNormalizedName[normalizedName] = createdCategory;
      }

      for (final expense in plan.expenses) {
        final trimmedNote = expense.note?.trim();
        final categoryId = expense.existingCategoryId ??
            categoriesByNormalizedName[
                    _normalizeCategoryName(expense.newCategoryName ?? '')]
                ?.id;

        if (categoryId == null) {
          throw ReceiptImportException(
            'Unable to resolve a category for one of the reviewed entries.',
          );
        }

        await _database.into(_database.expenses).insert(
              ExpensesCompanion.insert(
                amount: expense.amount,
                date: expense.date,
                note: drift.Value(
                  trimmedNote == null || trimmedNote.isEmpty
                      ? null
                      : trimmedNote,
                ),
                categoryId: categoryId,
              ),
            );
      }
    });
  }

  int _pickNextCategoryColor(Set<int> usedColors) {
    for (final color in _defaultCategoryColors) {
      if (!usedColors.contains(color)) {
        return color;
      }
    }

    return Colors.grey.value;
  }
}

final receiptOcrApiClientProvider = Provider<ReceiptOcrApiClient>(
  (ref) => ReceiptOcrApiClient(),
);

final receiptImportServiceProvider = Provider<ReceiptImportService>(
  (ref) => ReceiptImportService(ref.watch(databaseProvider)),
);

ReceiptImportPlan planReceiptImport({
  required List<ReviewedReceiptEntry> entries,
  required List<Category> existingCategories,
}) {
  if (entries.isEmpty) {
    throw ReceiptImportException('There are no reviewed entries to import.');
  }

  final categoriesById = {
    for (final category in existingCategories) category.id: category,
  };
  final categoriesByNormalizedName = {
    for (final category in existingCategories)
      _normalizeCategoryName(category.name): category,
  };
  final plannedNewCategoryNames = <String, String>{};
  final expenses = <PlannedExpenseImport>[];

  for (final entry in entries) {
    if (!entry.useNewCategory) {
      final categoryId = entry.categoryId;
      if (categoryId == null || !categoriesById.containsKey(categoryId)) {
        throw ReceiptImportException(
          'Each reviewed entry must reference a valid category.',
        );
      }

      expenses.add(
        PlannedExpenseImport(
          amount: entry.amount,
          date: entry.date,
          note: entry.note,
          existingCategoryId: categoryId,
          newCategoryName: null,
        ),
      );
      continue;
    }

    final rawName = entry.newCategoryName?.trim() ?? '';
    if (rawName.isEmpty) {
      throw ReceiptImportException(
        'New categories must have a name before import.',
      );
    }

    final normalizedName = _normalizeCategoryName(rawName);
    final existingCategory = categoriesByNormalizedName[normalizedName];

    if (existingCategory != null) {
      expenses.add(
        PlannedExpenseImport(
          amount: entry.amount,
          date: entry.date,
          note: entry.note,
          existingCategoryId: existingCategory.id,
          newCategoryName: null,
        ),
      );
      continue;
    }

    final canonicalName =
        plannedNewCategoryNames.putIfAbsent(normalizedName, () => rawName);

    expenses.add(
      PlannedExpenseImport(
        amount: entry.amount,
        date: entry.date,
        note: entry.note,
        existingCategoryId: null,
        newCategoryName: canonicalName,
      ),
    );
  }

  return ReceiptImportPlan(
    expenses: expenses,
    newCategoryNames: plannedNewCategoryNames.values.toList(),
  );
}

double _parseAmount(Object? value) {
  if (value is num) {
    final amount = value.toDouble();
    if (amount <= 0) {
      throw ReceiptImportException(
          'Each entry amount must be greater than zero.');
    }
    return amount;
  }

  throw ReceiptImportException('Each entry must include a numeric amount.');
}

DateTime _parseEntryDate(Object? value) {
  if (value is! String || value.trim().isEmpty) {
    throw ReceiptImportException('Each entry must include a date.');
  }

  final trimmed = value.trim();
  final parsed = DateTime.tryParse(trimmed);
  if (parsed == null) {
    throw ReceiptImportException('Each entry must include a valid ISO date.');
  }

  if (!trimmed.contains('T')) {
    return DateTime(parsed.year, parsed.month, parsed.day, 12);
  }

  return parsed.isUtc ? parsed.toLocal() : parsed;
}

String? _parseOptionalText(Object? value) {
  if (value == null) return null;
  if (value is! String) {
    throw ReceiptImportException(
        'Entry note and category_name values must be strings.');
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

ReceiptCategoryKind _parseCategoryKind(Object? value) {
  if (value is! String) {
    throw ReceiptImportException('Each entry must include category_kind.');
  }

  switch (value.trim()) {
    case 'existing':
      return ReceiptCategoryKind.existing;
    case 'new':
      return ReceiptCategoryKind.newCategory;
    default:
      throw ReceiptImportException(
        'category_kind must be either "existing" or "new".',
      );
  }
}

int? _parseOptionalInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

String _normalizeCategoryName(String input) => input.trim().toLowerCase();

final List<int> _defaultCategoryColors = [
  ...Colors.primaries.map((color) => color.value),
  Colors.grey.value,
  Colors.blueGrey.value,
  Colors.black.value,
];
