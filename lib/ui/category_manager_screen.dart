import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../data/providers.dart';
import '../data/local/database.dart';
import '../l10n/app_l10n.dart';

class CategoryManagerScreen extends ConsumerStatefulWidget {
  const CategoryManagerScreen({super.key});

  @override
  ConsumerState<CategoryManagerScreen> createState() =>
      _CategoryManagerScreenState();
}

class _CategoryManagerScreenState extends ConsumerState<CategoryManagerScreen> {
  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categories),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: colorScheme.surfaceVariant,
                child: Text(l10n.categoriesSection,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              Expanded(
                child: categories.isEmpty
                    ? Center(child: Text(l10n.noCategoriesAvailable))
                    : ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return Dismissible(
                            key: Key(category.id.toString()),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              final db = ref.read(databaseProvider);
                              (db.delete(db.categories)
                                    ..where((t) => t.id.equals(category.id)))
                                  .go();
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Color(category.color),
                                foregroundColor: Colors.white,
                                radius: 20,
                                child: Icon(
                                  category.icon != null
                                      ? IconData(
                                          int.tryParse(category.icon!) ??
                                              Icons.attach_money.codePoint,
                                          fontFamily: 'MaterialIcons')
                                      : Icons.attach_money,
                                  size: 20,
                                ),
                              ),
                              title: Text(category.name),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(l10n.deleteCategoryTitle),
                                      content: Text(l10n.deleteCategoryMessage(
                                          category.name)),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text(l10n.cancel)),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            style: TextButton.styleFrom(
                                                foregroundColor: Colors.red),
                                            child: Text(l10n.delete)),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    final db = ref.read(databaseProvider);
                                    (db.delete(db.categories)
                                          ..where(
                                              (t) => t.id.equals(category.id)))
                                        .go();
                                  }
                                },
                              ),
                              onTap: () => _showCategoryDialog(
                                  context, ref, categories,
                                  categoryToEdit: category),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(l10n.errorMessage('$e'))),
      ),
      floatingActionButton: categoriesAsync.when(
        data: (categories) => FloatingActionButton(
          onPressed: () => _showCategoryDialog(context, ref, categories),
          child: const Icon(Icons.add),
        ),
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  void _showCategoryDialog(
      BuildContext context, WidgetRef ref, List<Category> existingCategories,
      {Category? categoryToEdit}) {
    final isEditing = categoryToEdit != null;
    final controller =
        TextEditingController(text: isEditing ? categoryToEdit.name : '');

    // Curated palette
    final List<Color> palette = [
      ...Colors.primaries,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
    ];

    // Initial color
    int selectedColorValue =
        isEditing ? categoryToEdit.color : palette.first.value;

    // Available Icons
    const List<IconData> availableIcons = [
      Icons.attach_money,
      Icons.fastfood,
      Icons.restaurant,
      Icons.directions_car,
      Icons.directions_bus,
      Icons.flight,
      Icons.home,
      Icons.shopping_bag,
      Icons.shopping_cart,
      Icons.movie,
      Icons.sports_esports,
      Icons.fitness_center,
      Icons.medical_services,
      Icons.school,
      Icons.work,
      Icons.pets,
      Icons.celebration,
      Icons.child_care,
      Icons.local_cafe,
      Icons.local_bar,
    ];

    int selectedIconCodePoint = isEditing && categoryToEdit.icon != null
        ? int.tryParse(categoryToEdit.icon!) ?? Icons.attach_money.codePoint
        : availableIcons.first.codePoint;

    showDialog(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        final colorScheme = Theme.of(context).colorScheme;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditing ? l10n.editCategory : l10n.newCategory),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: l10n.name,
                      border: const OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(l10n.pickColor)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: palette.map((color) {
                      final isSelected = color.value == selectedColorValue;
                      // Check usage
                      final isUsed = existingCategories.any((c) =>
                              c.color == color.value &&
                              (categoryToEdit == null ||
                                  c.id !=
                                      categoryToEdit
                                          .id) // Ignore self if editing
                          );

                      return GestureDetector(
                        onTap: isUsed
                            ? null
                            : () {
                                setState(() {
                                  selectedColorValue = color.value;
                                });
                              },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: colorScheme.onSurface,
                                    width: 2,
                                  )
                                : null,
                            // Dim if used
                            boxShadow: isUsed
                                ? null
                                : [
                                    if (isSelected)
                                      BoxShadow(
                                        color: colorScheme.shadow
                                            .withOpacity(0.18),
                                        blurRadius: 4,
                                      )
                                  ],
                          ),
                          child: isUsed
                              ? Icon(Icons.block,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.5))
                              : (isSelected
                                  ? const Icon(Icons.check,
                                      size: 16, color: Colors.white)
                                  : null),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(l10n.pickIcon)),
                  const SizedBox(height: 8),
                  Container(
                    height: 150, // Limit height for grid
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: availableIcons.length,
                      itemBuilder: (context, index) {
                        final iconData = availableIcons[index];
                        final isSelected =
                            selectedIconCodePoint == iconData.codePoint;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIconCodePoint = iconData.codePoint;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(selectedColorValue).withOpacity(0.2)
                                  : colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(
                                      color: Color(selectedColorValue),
                                      width: 2)
                                  : null,
                            ),
                            child: Icon(
                              iconData,
                              color: isSelected
                                  ? Color(selectedColorValue)
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel)),
              FilledButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isEmpty) return;

                  // Final Validation
                  final isColorTaken = existingCategories.any((c) =>
                      c.color == selectedColorValue &&
                      (categoryToEdit == null || c.id != categoryToEdit.id));

                  if (isColorTaken) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.colorAlreadyTaken)),
                    );
                    return;
                  }

                  final db = ref.read(databaseProvider);

                  if (isEditing) {
                    (db.update(db.categories)
                          ..where((t) => t.id.equals(categoryToEdit.id)))
                        .write(CategoriesCompanion(
                      name: drift.Value(name),
                      color: drift.Value(selectedColorValue),
                      icon: drift.Value(selectedIconCodePoint.toString()),
                    ));
                  } else {
                    db.into(db.categories).insert(CategoriesCompanion(
                          name: drift.Value(name),
                          color: drift.Value(selectedColorValue),
                          icon: drift.Value(selectedIconCodePoint.toString()),
                        ));
                  }
                  Navigator.pop(context);
                },
                child: Text(isEditing ? l10n.save : l10n.add),
              ),
            ],
          );
        });
      },
    );
  }
}
