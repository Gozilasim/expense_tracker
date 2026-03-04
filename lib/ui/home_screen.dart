import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/providers.dart';
import '../data/local/database.dart'; // Need Expense type
import 'add_expense_screen.dart';
import 'category_manager_screen.dart';
import 'category_pie_chart.dart';

enum FilterMode { monthly, yearly, custom }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  FilterMode _filterMode = FilterMode.monthly;
  DateTime _focusedDate = DateTime.now(); // For Month/Year modes
  DateTimeRange? _customRange; // For Custom mode
  int? _selectedCategoryId; // Null = Show All

  @override
  void initState() {
    super.initState();
    // Default custom range to today if ever needed
    final now = DateTime.now();
    _customRange = DateTimeRange(
      start: DateTime(now.year, now.month, now.day), 
      end: DateTime(now.year, now.month, now.day, 23, 59, 59)
    );
  }

  void _onModeChanged(FilterMode? mode) {
    if (mode == null) return;
    setState(() {
      _filterMode = mode;
      _selectedCategoryId = null; // Reset category filter on date mode change
    });
    if (mode == FilterMode.custom) {
      _pickDateRange();
    }
  }

  void _previous() {
    setState(() {
      if (_filterMode == FilterMode.monthly) {
        _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
      } else if (_filterMode == FilterMode.yearly) {
        _focusedDate = DateTime(_focusedDate.year - 1);
      }
      _selectedCategoryId = null; // Optional: Reset category filter when changing date
    });
  }

  void _next() {
    setState(() {
      if (_filterMode == FilterMode.monthly) {
        _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
      } else if (_filterMode == FilterMode.yearly) {
        _focusedDate = DateTime(_focusedDate.year + 1);
      }
      _selectedCategoryId = null;
    });
  }

  void _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _customRange,
      builder: (context, child) {
         return Theme(
           data: Theme.of(context).copyWith(
             colorScheme: const ColorScheme.light(primary: Colors.black),
           ),
           child: child!,
         );
      }
    );

    if (picked != null) {
      setState(() {
        _customRange = picked;
        _filterMode = FilterMode.custom;
        _selectedCategoryId = null;
      });
    }
  }

  DateTimeRange _getCurrentRange() {
    switch (_filterMode) {
      case FilterMode.monthly:
        final start = DateTime(_focusedDate.year, _focusedDate.month, 1);
        final end = DateTime(_focusedDate.year, _focusedDate.month + 1, 0, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
      case FilterMode.yearly:
        final start = DateTime(_focusedDate.year, 1, 1);
        final end = DateTime(_focusedDate.year, 12, 31, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
      case FilterMode.custom:
        return _customRange!;
    }
  }

  String _getDisplayDate() {
    switch (_filterMode) {
      case FilterMode.monthly:
        return DateFormat('MMMM y').format(_focusedDate);
      case FilterMode.yearly:
        return DateFormat('y').format(_focusedDate);
      case FilterMode.custom:
        final start = _customRange!.start;
        final end = _customRange!.end;
        if (start.year == end.year && start.month == end.month && start.day == end.day) {
          return DateFormat('MMM d, y').format(start);
        }
        return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d').format(end)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRange = _getCurrentRange();
    // Use the optimized provider with SQL filtering
    final expensesAsync = ref.watch(expensesProvider(dateRange: currentRange));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CategoryManagerScreen()),
              );
            },
          ),
        ],
      ),
      body: expensesAsync.when(
        data: (dateFilteredItems) {
          // 1. Filter by Category (for the List below)
          final displayItems = _selectedCategoryId == null 
              ? dateFilteredItems 
              : dateFilteredItems.where((e) => e.category.id == _selectedCategoryId).toList();

          final groupedItems = _groupExpenses(displayItems);
          
          // Calculate Totals based on DATE filtered items (DateFiltered is the source of truth for the chart/breakdown)
          final totalAmount = dateFilteredItems.fold<double>(0, (sum, item) => sum + item.expense.amount);

          return CustomScrollView(
            slivers: [
              // 1. FILTER BAR
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey[50],
                  child: Row(
                    children: [
                      DropdownButton<FilterMode>(
                        value: _filterMode,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down, size: 20),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        onChanged: _onModeChanged,
                        items: const [
                          DropdownMenuItem(value: FilterMode.monthly, child: Text('Month')),
                          DropdownMenuItem(value: FilterMode.yearly, child: Text('Year')),
                          DropdownMenuItem(value: FilterMode.custom, child: Text('Custom')),
                        ],
                      ),
                      const Spacer(),
                      if (_filterMode != FilterMode.custom) ...[
                        IconButton(
                          icon: const Icon(Icons.chevron_left), 
                          onPressed: _previous,
                          visualDensity: VisualDensity.compact,
                        ),
                        Text(
                          _getDisplayDate(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right), 
                          onPressed: _next,
                          visualDensity: VisualDensity.compact,
                        ),
                      ] else ...[
                         GestureDetector(
                           onTap: _pickDateRange,
                           child: Container(
                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                             decoration: BoxDecoration(
                               border: Border.all(color: Colors.grey[300]!),
                               borderRadius: BorderRadius.circular(8),
                               color: Colors.white
                             ),
                             child: Row(
                               children: [
                                 const Icon(Icons.calendar_today, size: 14),
                                 const SizedBox(width: 8),
                                 Text(_getDisplayDate()),
                               ],
                             ),
                           ),
                         ),
                      ],
                    ],
                  ),
                ),
              ),

              // 2. TOTAL TEXT
              SliverToBoxAdapter(
                child: Padding(
                   padding: const EdgeInsets.only(bottom: 8),
                   child: Center(
                     child: Text(
                       'Total: \$${totalAmount.toStringAsFixed(2)}',
                       style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
                     ),
                   ),
                ),
              ),

              // 3. PIE CHART
              SliverToBoxAdapter(
                child: CategoryPieChart(
                  expenses: dateFilteredItems,
                  totalDays: currentRange.duration.inDays + 1,
                ),
              ),

              // 4. CATEGORY BREAKDOWN
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildCategoryBreakdown(dateFilteredItems),
                    const Divider(height: 1),
                  ],
                ),
              ),

              // 5. EXPENSE LIST
              if (displayItems.isEmpty)
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: Center(child: Text("No expenses found.")),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = groupedItems[index];

                      if (item is DateHeader) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text(
                            item.text,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14),
                          ),
                        );
                      } else if (item is ExpenseItem) {
                        final expense = item.data.expense;
                        final category = item.data.category;
                        return Dismissible(
                          key: Key(expense.id.toString()),
                          background: Container(color: Colors.red, alignment: Alignment.centerRight, child: const Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.delete, color: Colors.white))),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) async {
                             final db = ref.read(databaseProvider);
                             await (db.delete(db.expenses)..where((t) => t.id.equals(expense.id))).go();
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(category.color), 
                              radius: 18, 
                              child: Icon(
                                category.icon != null 
                                  ? IconData(int.tryParse(category.icon!) ?? Icons.attach_money.codePoint, fontFamily: 'MaterialIcons')
                                  : Icons.attach_money,
                                color: Colors.white, 
                                size: 20
                              )
                            ),
                            title: Text(
                              expense.note?.isNotEmpty == true ? expense.note! : category.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${category.name} • ${DateFormat.jm().format(expense.date)}', 
                              style: TextStyle(color: Colors.grey[600], fontSize: 13)
                            ),
                            trailing: Text('\$${expense.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddExpenseScreen(expenseToEdit: expense))),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    childCount: groupedItems.length,
                  ),
                ),
                
              // Extra Bottom padding for the fixed footer
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },

        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
             height: 56,
             child: FilledButton.icon(
               onPressed: () {
                 Navigator.of(context).push(
                   MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                 );
               },
               style: FilledButton.styleFrom(
                 backgroundColor: Colors.black, // Premium look
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
               ),
               icon: const Icon(Icons.add, color: Colors.white),
               label: const Text("Add Expense", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
             ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<ExpenseWithCategory> expenses) {
    if (expenses.isEmpty) return const SizedBox.shrink();

    // Group by category
    final Map<int, double> totals = {};
    final Map<int, Category> categoryMap = {};
    
    for (var item in expenses) {
      final id = item.category.id;
      totals[id] = (totals[id] ?? 0) + item.expense.amount;
      categoryMap[id] = item.category;
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: sorted.length + 1, // +1 for "All" option
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" Option
            final isSelected = _selectedCategoryId == null;
            return ChoiceChip(
              label: const Text('All'),
              selected: isSelected,
              onSelected: (selected) {
                 if (selected) setState(() => _selectedCategoryId = null);
              },
            );
          }

          final entry = sorted[index - 1];
          final category = categoryMap[entry.key]!;
          final amount = entry.value;
          final isSelected = _selectedCategoryId == entry.key;

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedCategoryId = null; // Toggle off
                } else {
                  _selectedCategoryId = entry.key;
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Color(category.color).withOpacity(0.2) : Colors.white,
                border: Border.all(
                  color: isSelected ? Color(category.color) : Colors.grey[300]!,
                  width: isSelected ? 2 : 1
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(color: Color(category.color), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                      Text('\$${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }



  List<ListItem> _groupExpenses(List<ExpenseWithCategory> items) {
    if (items.isEmpty) return [];
    final List<ListItem> grouped = [];
    DateTime? lastDate;

    for (var item in items) {
      final date = item.expense.date;
      final isSameDay = lastDate != null && 
        lastDate.year == date.year && 
        lastDate.month == date.month && 
        lastDate.day == date.day;

      if (!isSameDay) {
        grouped.add(DateHeader(_formatDate(date)));
        lastDate = date;
      }
      grouped.add(ExpenseItem(item));
    }
    return grouped;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return 'Today';
    if (checkDate == yesterday) return 'Yesterday';
    return DateFormat('d MMM y').format(date);
  }
}

abstract class ListItem {}
class DateHeader extends ListItem {
  final String text;
  DateHeader(this.text);
}
class ExpenseItem extends ListItem {
  final ExpenseWithCategory data;
  ExpenseItem(this.data);
}
