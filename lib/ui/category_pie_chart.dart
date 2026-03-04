import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/providers.dart';
import '../data/local/database.dart';

class CategoryPieChart extends StatefulWidget {
  final List<ExpenseWithCategory> expenses;
  final int totalDays;

  const CategoryPieChart({super.key, required this.expenses, required this.totalDays});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;
  bool showDailyAverage = false; // Toggle state

  @override
  Widget build(BuildContext context) {
    // We remove the empty check return to allow showing "0" or just empty chart with average 0
    // But keeping it for now if expenses is empty, average is 0 anyway. 
    // Wait, if expenses is empty, we might still want to show "0"
    // The previous code returned "No data".
    // Let's keep "No data" if no expenses, but maybe users want to see "Daily Prev: 0"?
    // Let's stick to existing behavior for empty list first, but logic needs to be robust.
    
    if (widget.expenses.isEmpty) {
       // If no expenses, just show 0? Or the "No Data" widget?
       // The user request is about logic.
       // Let's keep "No data" for empty states for now.
       return const SizedBox(
        height: 300, 
        child: Center(
          child: Text("No data for this period", style: TextStyle(color: Colors.grey))
        )
      );
    }

    // 1. Calculations
    final Map<int, double> totals = {};
    final Map<int, Category> categoryMap = {};
    double grandTotal = 0;
    
    for (var item in widget.expenses) {
      final id = item.category.id;
      totals[id] = (totals[id] ?? 0) + item.expense.amount;
      categoryMap[id] = item.category;
      grandTotal += item.expense.amount;
    }

    final sortedEntries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Calculate Daily Average using passed totalDays
    final dailyAvg = widget.totalDays > 0 ? grandTotal / widget.totalDays : 0.0;

    // 2. Prepare Center Data
    final displayLabel = showDailyAverage ? "Daily Average" : "Total Spending";
    final displayAmount = showDailyAverage ? dailyAvg : grandTotal;

    return SizedBox(
      height: 320, // Increased height for badges
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The Chart
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 80,
              sections: showingSections(sortedEntries, categoryMap, grandTotal),
            ),
          ),
          
          // The Interactive Center
          GestureDetector(
            onTap: () {
              setState(() {
                showDailyAverage = !showDailyAverage;
              });
            },
            child: Container(
              color: Colors.transparent, // Hit test target
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    showDailyAverage ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_up, 
                    size: 24, 
                    color: Colors.grey[400]
                  ),
                  Text(
                    displayLabel,
                    style: const TextStyle(
                      fontSize: 14, 
                      color: Colors.grey,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${displayAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 30, // Slightly bigger
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(
                    showDailyAverage ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_down, 
                    size: 24, 
                    color: Colors.grey[400]
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(
    List<MapEntry<int, double>> entries,
    Map<int, Category> categoryMap,
    double grandTotal,
  ) {
    return List.generate(entries.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 40.0 : 30.0;
      final entry = entries[i];
      final category = categoryMap[entry.key]!;
      final percent = (entry.value / grandTotal * 100).toStringAsFixed(0);
      
      return PieChartSectionData(
        color: Color(category.color),
        value: entry.value,
        title: '', // No internal title
        radius: radius,
        badgeWidget: isTouched ? _buildBadge(category, entry.value, percent) : null,
        badgePositionPercentageOffset: 1.3, // Outside the ring
      );
    });
  }

  Widget _buildBadge(Category category, double amount, String percent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
        border: Border.all(color: Color(category.color), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.name, style: TextStyle(color: Color(category.color), fontSize: 10, fontWeight: FontWeight.bold)),
          Text('\$${amount.toStringAsFixed(0)} ($percent%)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
