import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../data/ocr_api_settings.dart';
import '../data/providers.dart';
import '../data/receipt_ocr.dart';
import '../data/local/database.dart'; // Need Expense type
import '../l10n/app_l10n.dart';
import '../l10n/generated/app_localizations.dart';
import 'add_expense_screen.dart';
import 'backend_settings_screen.dart';
import 'category_pie_chart.dart';
import 'receipt_import_review_screen.dart';
import 'settings_hub_screen.dart';

enum FilterMode { monthly, yearly, custom }

Future<bool> confirmDeleteExpense(BuildContext context) async {
  final l10n = context.l10n;
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.deleteExpenseTitle),
      content: Text(
        l10n.deleteExpenseMessage,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );

  return confirm == true;
}

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
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    // Default custom range to today if ever needed
    final now = DateTime.now();
    _customRange = DateTimeRange(
        start: DateTime(now.year, now.month, now.day),
        end: DateTime(now.year, now.month, now.day, 23, 59, 59));
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
      _selectedCategoryId =
          null; // Optional: Reset category filter when changing date
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
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: Theme.of(context).colorScheme.primary,
                  ),
            ),
            child: child!,
          );
        });

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
        final end =
            DateTime(_focusedDate.year, _focusedDate.month + 1, 0, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
      case FilterMode.yearly:
        final start = DateTime(_focusedDate.year, 1, 1);
        final end = DateTime(_focusedDate.year, 12, 31, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
      case FilterMode.custom:
        return _customRange!;
    }
  }

  String _getDisplayDate(String localeName) {
    switch (_filterMode) {
      case FilterMode.monthly:
        return DateFormat('MMMM y', localeName).format(_focusedDate);
      case FilterMode.yearly:
        return DateFormat('y', localeName).format(_focusedDate);
      case FilterMode.custom:
        final start = _customRange!.start;
        final end = _customRange!.end;
        if (start.year == end.year &&
            start.month == end.month &&
            start.day == end.day) {
          return DateFormat('MMM d, y', localeName).format(start);
        }
        return '${DateFormat('MMM d', localeName).format(start)} - ${DateFormat('MMM d', localeName).format(end)}';
    }
  }

  Future<ImageSource?> _pickReceiptImageSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(context.l10n.takePhoto),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(context.l10n.chooseFromGallery),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanReceipt() async {
    if (_isScanning) return;

    final apiUrlState = ref.read(ocrApiUrlControllerProvider);
    final savedApiUrl = apiUrlState.valueOrNull;
    final l10n = context.l10n;

    if (apiUrlState.isLoading) {
      _showMessage(l10n.loadingOcrApiUrl);
      return;
    }

    final apiUrl = parseStoredOcrApiUrl(savedApiUrl);
    if (apiUrl == null) {
      _showMessage(l10n.setOcrApiUrlFirst);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const BackendSettingsScreen()),
      );
      return;
    }

    final imageSource = await _pickReceiptImageSource();
    if (imageSource == null) return;

    final imagePicker = ImagePicker();
    final imageFile = await imagePicker.pickImage(
      source: imageSource,
      imageQuality: 85,
    );
    if (imageFile == null) return;

    await _uploadReceiptImage(apiUrl: apiUrl, imageFile: imageFile);
  }

  Future<void> _uploadReceiptImage({
    required Uri apiUrl,
    required XFile imageFile,
  }) async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    try {
      final categories = await ref.read(categoriesProvider.future);
      final entries = await ref.read(receiptOcrApiClientProvider).scanReceipt(
            apiUrl: apiUrl,
            imageFile: imageFile,
            categories: categories,
          );

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReceiptImportReviewScreen(
            entries: entries,
            categories: categories,
          ),
        ),
      );
    } on ReceiptScanException catch (error) {
      if (!mounted) return;
      _showScanError(error, apiUrl: apiUrl, imageFile: imageFile);
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  void _showScanError(
    ReceiptScanException error, {
    required Uri apiUrl,
    required XFile imageFile,
  }) {
    final retryAction = error.canRetry
        ? SnackBarAction(
            label: context.l10n.retry,
            onPressed: () {
              _uploadReceiptImage(apiUrl: apiUrl, imageFile: imageFile);
            },
          )
        : null;

    _showMessage(
      _localizedReceiptScanMessage(error),
      action: retryAction,
      duration: retryAction == null
          ? const Duration(seconds: 4)
          : const Duration(seconds: 8),
    );
  }

  void _showMessage(
    String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: action,
          duration: duration,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final currentRange = _getCurrentRange();
    final l10n = context.l10n;
    final localeName = Localizations.localeOf(context).toLanguageTag();
    final colorScheme = Theme.of(context).colorScheme;
    // Use the optimized provider with SQL filtering
    final expensesAsync = ref.watch(expensesProvider(dateRange: currentRange));
    final ocrApiUrlAsync = ref.watch(ocrApiUrlControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SettingsHubScreen(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(l10n.settings),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: expensesAsync.when(
        data: (dateFilteredItems) {
          // 1. Filter by Category (for the List below)
          final displayItems = _selectedCategoryId == null
              ? dateFilteredItems
              : dateFilteredItems
                  .where((e) => e.category.id == _selectedCategoryId)
                  .toList();

          final groupedItems = _groupExpenses(displayItems, l10n, localeName);

          // Calculate Totals based on DATE filtered items (DateFiltered is the source of truth for the chart/breakdown)
          final totalAmount = dateFilteredItems.fold<double>(
              0, (sum, item) => sum + item.expense.amount);

          return CustomScrollView(
            slivers: [
              if (parseStoredOcrApiUrl(ocrApiUrlAsync.valueOrNull) == null)
                SliverToBoxAdapter(child: _buildOcrSetupBanner()),

              // 1. FILTER BAR
              SliverToBoxAdapter(
                child: Container(
                  key: const Key('home-filter-bar'),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: colorScheme.surfaceVariant,
                  child: Row(
                    children: [
                      DropdownButton<FilterMode>(
                        value: _filterMode,
                        underline: const SizedBox(),
                        dropdownColor: colorScheme.surfaceVariant,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          size: 20,
                          color: colorScheme.onSurface,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        onChanged: _onModeChanged,
                        items: [
                          DropdownMenuItem(
                              value: FilterMode.monthly,
                              child: Text(l10n.month)),
                          DropdownMenuItem(
                              value: FilterMode.yearly, child: Text(l10n.year)),
                          DropdownMenuItem(
                              value: FilterMode.custom,
                              child: Text(l10n.custom)),
                        ],
                      ),
                      const Spacer(),
                      if (_filterMode != FilterMode.custom) ...[
                        IconButton(
                          icon: Icon(
                            Icons.chevron_left,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: _previous,
                          visualDensity: VisualDensity.compact,
                        ),
                        Text(
                          _getDisplayDate(localeName),
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.chevron_right,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: _next,
                          visualDensity: VisualDensity.compact,
                        ),
                      ] else ...[
                        GestureDetector(
                          onTap: _pickDateRange,
                          child: Container(
                            key: const Key('home-custom-date-chip'),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: colorScheme.outlineVariant),
                              borderRadius: BorderRadius.circular(8),
                              color: colorScheme.surfaceVariant,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getDisplayDate(localeName),
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
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
                      l10n.totalAmount('\$${totalAmount.toStringAsFixed(2)}'),
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
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
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: Center(child: Text(l10n.noExpensesFound)),
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
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        );
                      } else if (item is ExpenseItem) {
                        final expense = item.data.expense;
                        final category = item.data.category;
                        return Dismissible(
                          key: Key(expense.id.toString()),
                          background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              child: const Padding(
                                  padding: EdgeInsets.only(right: 16),
                                  child:
                                      Icon(Icons.delete, color: Colors.white))),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) async {
                            return confirmDeleteExpense(context);
                          },
                          onDismissed: (_) async {
                            final db = ref.read(databaseProvider);
                            await (db.delete(db.expenses)
                                  ..where((t) => t.id.equals(expense.id)))
                                .go();
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                                backgroundColor: Color(category.color),
                                radius: 18,
                                child: Icon(
                                    category.icon != null
                                        ? IconData(
                                            int.tryParse(category.icon!) ??
                                                Icons.attach_money.codePoint,
                                            fontFamily: 'MaterialIcons')
                                        : Icons.attach_money,
                                    color: Colors.white,
                                    size: 20)),
                            title: Text(
                              expense.note?.isNotEmpty == true
                                  ? expense.note!
                                  : category.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                '${category.name} • ${DateFormat.jm(localeName).format(expense.date)}',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                )),
                            trailing: Text(
                                '\$${expense.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => AddExpenseScreen(
                                        expenseToEdit: expense))),
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
        error: (err, stack) => Center(child: Text(l10n.errorMessage('$err'))),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _isScanning || ocrApiUrlAsync.isLoading
                        ? null
                        : _scanReceipt,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: _isScanning
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.document_scanner),
                    label: Text(_isScanning ? l10n.scanning : l10n.scanReceipt),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const AddExpenseScreen()),
                      );
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(
                      l10n.addExpense,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOcrSetupBanner() {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              Icons.document_scanner,
              color: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.setOcrApiUrlBanner,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BackendSettingsScreen(),
                  ),
                );
              },
              child: Text(l10n.set),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<ExpenseWithCategory> expenses) {
    if (expenses.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

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
              label: Text(l10n.all),
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
              key: Key('home-category-chip-${category.id}'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Color(category.color).withOpacity(0.2)
                    : colorScheme.surfaceVariant,
                border: Border.all(
                    color: isSelected
                        ? Color(category.color)
                        : colorScheme.outlineVariant,
                    width: isSelected ? 2 : 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: Color(category.color), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface)),
                      Text('\$${amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                          )),
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

  List<ListItem> _groupExpenses(
    List<ExpenseWithCategory> items,
    AppLocalizations l10n,
    String localeName,
  ) {
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
        grouped.add(DateHeader(_formatDate(date, l10n, localeName)));
        lastDate = date;
      }
      grouped.add(ExpenseItem(item));
    }
    return grouped;
  }

  String _formatDate(
    DateTime date,
    AppLocalizations l10n,
    String localeName,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return l10n.today;
    if (checkDate == yesterday) return l10n.yesterday;
    return DateFormat('d MMM y', localeName).format(date);
  }

  String _localizedReceiptScanMessage(ReceiptScanException error) {
    final l10n = context.l10n;
    final detail = error.backendDetail;

    if (error.kind == ReceiptScanFailureKind.userInput) {
      switch (detail) {
        case 'Image is not a receipt':
          return l10n.uploadClearReceipt;
        case 'Receipt does not contain readable line items':
          return l10n.receiptItemsUnreadable;
        case 'categories_json must be a valid JSON array':
        case 'categories_json must be a JSON array':
        case 'categories_json must contain category objects with id and name':
          return l10n.categoryDataInvalid;
        case 'Only JPEG, PNG, and WebP images are supported':
          return l10n.unsupportedImageType;
        case 'Uploaded file is empty':
          return l10n.emptyImageFile;
        case 'Image must be 3 MB or smaller':
          return l10n.imageTooLarge;
        default:
          return l10n.uploadClearReceipt;
      }
    }

    switch (error.userMessage) {
      case 'OCR request timed out. Check that the backend is running and reachable from this phone.':
        return l10n.ocrRequestTimedOut;
      case 'Cannot resolve the OCR API host. Check the URL domain or IP address.':
        return l10n.cannotResolveOcrHost;
      case 'OCR backend refused the connection. Check that the server is running on this port.':
        return l10n.ocrConnectionRefused;
      case 'OCR backend is unreachable. Check that the phone and server are on the same network.':
        return l10n.ocrBackendUnreachable;
      case 'Cannot connect to the OCR backend. Check the API URL, Wi-Fi, and server firewall.':
        return l10n.cannotConnectOcrBackend;
      case 'HTTP traffic was blocked. Use HTTPS or allow cleartext traffic for local testing.':
        return l10n.httpTrafficBlocked;
      case 'Cannot connect to the OCR backend. Check the API URL and network.':
        return l10n.cannotConnectOcrNetwork;
    }

    switch (error.kind) {
      case ReceiptScanFailureKind.serviceUnavailable:
        return l10n.recognitionServiceUnavailable;
      case ReceiptScanFailureKind.appBug:
        return l10n.ocrRequestInvalid;
      case ReceiptScanFailureKind.serverError:
        return l10n.recognitionFailed;
      case ReceiptScanFailureKind.unknown:
      case ReceiptScanFailureKind.userInput:
        return l10n.ocrScanFailed;
    }
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
