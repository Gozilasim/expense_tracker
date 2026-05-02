import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/local/database.dart';
import '../data/receipt_ocr.dart';
import '../l10n/app_l10n.dart';

class ReceiptImportReviewScreen extends ConsumerStatefulWidget {
  const ReceiptImportReviewScreen({
    super.key,
    required this.entries,
    required this.categories,
    this.onSaveEntries,
  });

  final List<ReceiptOcrEntry> entries;
  final List<Category> categories;
  final Future<void> Function(List<ReviewedReceiptEntry> entries)?
      onSaveEntries;

  @override
  ConsumerState<ReceiptImportReviewScreen> createState() =>
      _ReceiptImportReviewScreenState();
}

class _ReceiptImportReviewScreenState
    extends ConsumerState<ReceiptImportReviewScreen> {
  late final List<_ReceiptEntryDraft> _drafts;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _drafts = widget.entries
        .map(
          (entry) => _ReceiptEntryDraft(
            amountText: entry.amount.toStringAsFixed(2),
            date: entry.date,
            note: entry.note ?? '',
            isIncluded: true,
            useNewCategory:
                entry.categoryKind == ReceiptCategoryKind.newCategory,
            selectedCategoryId: entry.categoryId,
            newCategoryName:
                entry.categoryKind == ReceiptCategoryKind.newCategory
                    ? entry.categoryName
                    : '',
          ),
        )
        .toList();
  }

  Future<void> _pickDate(int index) async {
    final draft = _drafts[index];
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked == null) return;

    setState(() {
      draft.date = DateTime(picked.year, picked.month, picked.day, 12);
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;

    final includedDrafts = _drafts.where((draft) => draft.isIncluded).toList();
    if (includedDrafts.isEmpty) {
      _showSnackBar(context.l10n.selectAtLeastOneEntry);
      return;
    }

    final reviewedEntries = <ReviewedReceiptEntry>[];

    for (final draft in includedDrafts) {
      final entryLabel = context.l10n.entryLabel(_drafts.indexOf(draft) + 1);

      final amount = double.tryParse(draft.amountText.trim());
      if (amount == null || amount <= 0) {
        _showSnackBar(context.l10n.entryValidAmount(entryLabel));
        return;
      }

      if (draft.useNewCategory) {
        final name = draft.newCategoryName.trim();
        if (name.isEmpty) {
          _showSnackBar(context.l10n.entryNewCategoryName(entryLabel));
          return;
        }

        reviewedEntries.add(
          ReviewedReceiptEntry(
            amount: amount,
            date: draft.date,
            note: draft.note.trim().isEmpty ? null : draft.note.trim(),
            useNewCategory: true,
            newCategoryName: name,
          ),
        );
        continue;
      }

      if (draft.selectedCategoryId == null) {
        _showSnackBar(context.l10n.entryCategorySelected(entryLabel));
        return;
      }

      reviewedEntries.add(
        ReviewedReceiptEntry(
          amount: amount,
          date: draft.date,
          note: draft.note.trim().isEmpty ? null : draft.note.trim(),
          useNewCategory: false,
          categoryId: draft.selectedCategoryId,
        ),
      );
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final onSaveEntries = widget.onSaveEntries ??
          ref.read(receiptImportServiceProvider).importEntries;
      await onSaveEntries(reviewedEntries);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      _showSnackBar(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reviewOcrEntries),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.reviewOcrDescription,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _drafts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final draft = _drafts[index];
                return _ReceiptEntryCard(
                  index: index,
                  draft: draft,
                  categories: widget.categories,
                  onIncludeChanged: (value) {
                    setState(() {
                      draft.isIncluded = value;
                    });
                  },
                  onAmountChanged: (value) => draft.amountText = value,
                  onDateTap: () => _pickDate(index),
                  onCategoryChanged: (value) {
                    setState(() {
                      if (value == _newCategoryDropdownValue) {
                        draft.useNewCategory = true;
                        draft.selectedCategoryId = null;
                        return;
                      }

                      draft.useNewCategory = false;
                      draft.selectedCategoryId = int.tryParse(value ?? '');
                    });
                  },
                  onNewCategoryNameChanged: (value) =>
                      draft.newCategoryName = value,
                  onNoteChanged: (value) => draft.note = value,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              key: const Key('review-save-button'),
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? l10n.saving : l10n.saveSelectedEntries),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptEntryCard extends StatelessWidget {
  const _ReceiptEntryCard({
    required this.index,
    required this.draft,
    required this.categories,
    required this.onIncludeChanged,
    required this.onAmountChanged,
    required this.onDateTap,
    required this.onCategoryChanged,
    required this.onNewCategoryNameChanged,
    required this.onNoteChanged,
  });

  final int index;
  final _ReceiptEntryDraft draft;
  final List<Category> categories;
  final ValueChanged<bool> onIncludeChanged;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onDateTap;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String> onNewCategoryNameChanged;
  final ValueChanged<String> onNoteChanged;

  @override
  Widget build(BuildContext context) {
    final categoryDropdownValue = draft.useNewCategory
        ? _newCategoryDropdownValue
        : draft.selectedCategoryId?.toString();
    final l10n = context.l10n;
    final localeName = Localizations.localeOf(context).toLanguageTag();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.entryLabel(index + 1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Checkbox(
                  key: Key('review-entry-include-$index'),
                  value: draft.isIncluded,
                  onChanged: (value) => onIncludeChanged(value ?? false),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: Key('review-entry-amount-$index'),
              initialValue: draft.amountText,
              onChanged: onAmountChanged,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.amount,
                prefixText: '\$ ',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              key: Key('review-entry-date-$index'),
              onTap: onDateTap,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.date,
                  border: const OutlineInputBorder(),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Text(DateFormat('yyyy-MM-dd', localeName)
                        .format(draft.date)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: Key('review-entry-category-$index'),
              value: categoryDropdownValue,
              decoration: InputDecoration(
                labelText: l10n.category,
                border: const OutlineInputBorder(),
              ),
              items: [
                ...categories.map(
                  (category) => DropdownMenuItem<String>(
                    value: category.id.toString(),
                    child: Text(category.name),
                  ),
                ),
                DropdownMenuItem<String>(
                  value: _newCategoryDropdownValue,
                  child: Text(l10n.createNew),
                ),
              ],
              onChanged: onCategoryChanged,
            ),
            if (draft.useNewCategory) ...[
              const SizedBox(height: 12),
              TextFormField(
                key: Key('review-entry-new-category-$index'),
                initialValue: draft.newCategoryName,
                onChanged: onNewCategoryNameChanged,
                decoration: InputDecoration(
                  labelText: l10n.newCategoryName,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              key: Key('review-entry-note-$index'),
              initialValue: draft.note,
              onChanged: onNoteChanged,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.note,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptEntryDraft {
  _ReceiptEntryDraft({
    required this.amountText,
    required this.date,
    required this.note,
    required this.isIncluded,
    required this.useNewCategory,
    required this.selectedCategoryId,
    required this.newCategoryName,
  });

  String amountText;
  DateTime date;
  String note;
  bool isIncluded;
  bool useNewCategory;
  int? selectedCategoryId;
  String newCategoryName;
}

const _newCategoryDropdownValue = '__new_category__';
