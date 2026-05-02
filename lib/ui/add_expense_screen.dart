import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../data/providers.dart';
import '../data/local/database.dart';
import '../l10n/app_l10n.dart';

import 'package:intl/intl.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final Expense? expenseToEdit; // If null, it's a new expense
  const AddExpenseScreen({super.key, this.expenseToEdit});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      final e = widget.expenseToEdit!;
      _amountController.text = e.amount.toString();
      _noteController.text = e.note ?? '';
      _selectedCategoryId = e.categoryId;
      _selectedDate = e.date;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate:
          DateTime.now().add(const Duration(days: 365)), // Allow future dates?
    );
    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        _selectedDate = DateTime(
            picked.year, picked.month, picked.day, now.hour, now.minute);
      });
    }
  }

  Future<void> _save() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pleaseSelectCategory)),
      );
      return;
    }

    final amountText = _amountController.text;
    if (amountText.isEmpty) return;

    final amount = double.tryParse(amountText);
    if (amount == null) return;

    final db = ref.read(databaseProvider);

    if (widget.expenseToEdit != null) {
      // Update existing
      await (db.update(db.expenses)
            ..where((tbl) => tbl.id.equals(widget.expenseToEdit!.id)))
          .write(ExpensesCompanion(
        amount: drift.Value(amount),
        note: drift.Value(
            _noteController.text.isNotEmpty ? _noteController.text : null),
        categoryId: drift.Value(_selectedCategoryId!),
        date: drift.Value(_selectedDate),
      ));
    } else {
      // Insert new
      await db.into(db.expenses).insert(ExpensesCompanion(
            amount: drift.Value(amount),
            date: drift.Value(_selectedDate),
            note: drift.Value(
                _noteController.text.isNotEmpty ? _noteController.text : null),
            categoryId: drift.Value(_selectedCategoryId!),
          ));
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (widget.expenseToEdit == null) return;
    final l10n = context.l10n;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteExpenseTitle),
        content: Text(l10n.deleteExpenseMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.delete)),
        ],
      ),
    );

    if (confirm == true) {
      final db = ref.read(databaseProvider);
      await (db.delete(db.expenses)
            ..where((tbl) => tbl.id.equals(widget.expenseToEdit!.id)))
          .go();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final isEditing = widget.expenseToEdit != null;
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editExpense : l10n.newExpense),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: _delete,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: l10n.amount,
                prefixText: '\$ ',
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            // Date Picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outline),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('yyyy-MM-dd').format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_drop_down,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return Text(l10n.noCategoriesSeed);
                }
                // Auto-select first if new and nothing selected
                if (_selectedCategoryId == null && !isEditing) {
                  _selectedCategoryId = categories.first.id;
                }
                return DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: l10n.category,
                    border: const OutlineInputBorder(),
                  ),
                  items: categories.map((c) {
                    return DropdownMenuItem(
                      value: c.id,
                      child: Row(
                        children: [
                          // Icon + Color
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                                color:
                                    c.color != 0 ? Color(c.color) : Colors.grey,
                                shape: BoxShape.circle),
                            child: Icon(
                              c.icon != null
                                  ? IconData(
                                      int.tryParse(c.icon!) ??
                                          Icons.attach_money.codePoint,
                                      fontFamily: 'MaterialIcons')
                                  : Icons.attach_money,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(c.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategoryId = val;
                    });
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text(l10n.errorMessage('$e')),
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: l10n.noteOptional,
                border: const OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _save,
                child: Text(isEditing ? l10n.updateExpense : l10n.saveExpense),
              ),
            ),
            const SizedBox(height: 16), // Bottom padding
          ],
        ),
      ),
    );
  }
}
