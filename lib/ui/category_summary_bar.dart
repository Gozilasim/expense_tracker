import 'package:flutter/material.dart';
import '../data/providers.dart';
import '../data/local/database.dart'; // Need Category type

class CategorySummaryBar extends StatelessWidget {
  final List<ExpenseWithCategory> allExpenses;

  const CategorySummaryBar({super.key, required this.allExpenses});

  @override
  Widget build(BuildContext context) {
    // 1. Filter for current month
    final now = DateTime.now();
    final thisMonthExpenses = allExpenses.where((e) => 
      e.expense.date.year == now.year && 
      e.expense.date.month == now.month
    ).toList();

    if (thisMonthExpenses.isEmpty) return const SizedBox.shrink();

    // 2. Group by Category and Sum
    final Map<int, double> totals = {};
    final Map<int, Category> categoryMap = {};

    for (var item in thisMonthExpenses) {
      final id = item.category.id;
      totals[id] = (totals[id] ?? 0) + item.expense.amount;
      categoryMap[id] = item.category;
    }

    // 3. Convert to List
    final summaryList = totals.entries.map((e) {
      return (category: categoryMap[e.key]!, total: e.value);
    }).toList();
    
    // Sort by highest amount
    summaryList.sort((a, b) => b.total.compareTo(a.total));

    return SizedBox(
      height: 100, // Fixed height for the bar
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: summaryList.length,
        itemBuilder: (context, index) {
          final item = summaryList[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(right: 12),
            child: Container(
              width: 120,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Row(
                     children: [
                       Container(
                         width: 10, height: 10,
                         decoration: BoxDecoration(
                           color: Color(item.category.color),
                           shape: BoxShape.circle,
                         ),
                       ),
                       const SizedBox(width: 8),
                       Expanded(
                         child: Text(
                           item.category.name,
                           style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                           overflow: TextOverflow.ellipsis,
                         ),
                       ),
                     ],
                   ),
                   const Spacer(),
                   Text(
                     '\$${item.total.toStringAsFixed(0)}',
                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                   ),
                   const Text(
                     'This Month',
                     style: TextStyle(fontSize: 10, color: Colors.grey),
                   )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
