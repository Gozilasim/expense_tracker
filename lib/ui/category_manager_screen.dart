import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../data/providers.dart';
import '../data/local/database.dart';

class CategoryManagerScreen extends ConsumerStatefulWidget {
  const CategoryManagerScreen({super.key});

  @override
  ConsumerState<CategoryManagerScreen> createState() => _CategoryManagerScreenState();
}

class _CategoryManagerScreenState extends ConsumerState<CategoryManagerScreen> {
  
  Future<void> _backupData() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbFolder.path, 'db.sqlite');
      final file = File(dbPath);

      if (!await file.exists()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No database found to backup!')));
        return;
      }

      // Share expects XFile
      await Share.shareXFiles([XFile(dbPath)], text: 'Expense Tracker Backup (db.sqlite)');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    }
  }

  Future<void> _restoreData() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        final sourcePath = result.files.single.path!;
        final dbFolder = await getApplicationDocumentsDirectory();
        final dbPath = p.join(dbFolder.path, 'db.sqlite');

        if (!mounted) return;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restore Backup?'),
            content: const Text('WARNING: This will overwritten ALL current data. This action cannot be undone.\n\nAre you sure you want to restore?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Restore'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          // Overwrite the file
          await File(sourcePath).copy(dbPath);
          
          // Invalidate providers to force reload/re-open logic if possible
          ref.invalidate(databaseProvider);
          ref.invalidate(categoriesProvider);
          ref.invalidate(expensesProvider);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restored successfully! Restarting app is recommended.')));
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'backup') _backupData();
              if (value == 'restore') _restoreData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'backup',
                child: Row(
                  children: [Icon(Icons.upload, color: Colors.grey), SizedBox(width: 8), Text('Backup Data (Export)')],
                ),
              ),
              const PopupMenuItem(
                value: 'restore',
                child: Row(
                  children: [Icon(Icons.download, color: Colors.grey), SizedBox(width: 8), Text('Restore Data (Import)')],
                ),
              ),
            ],
          )
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
           return Column(
             children: [
               // Header
               Container(
                 width: double.infinity,
                 padding: const EdgeInsets.all(16),
                 color: Colors.grey[100],
                 child: const Text("CATEGORIES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
               ),
               Expanded(
                 child: categories.isEmpty
                     ? const Center(child: Text('No categories available.'))
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
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              final db = ref.read(databaseProvider);
                              (db.delete(db.categories)..where((t) => t.id.equals(category.id))).go();
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Color(category.color),
                                foregroundColor: Colors.white,
                                radius: 20,
                                child: Icon(
                                  category.icon != null 
                                    ? IconData(int.tryParse(category.icon!) ?? Icons.attach_money.codePoint, fontFamily: 'MaterialIcons')
                                    : Icons.attach_money,
                                  size: 20,
                                ),
                              ),
                              title: Text(category.name),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.grey),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Category?'),
                                      content: Text('Delete "${category.name}"? Related expenses might be affected.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                                          child: const Text('Delete')
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                     final db = ref.read(databaseProvider);
                                     (db.delete(db.categories)..where((t) => t.id.equals(category.id))).go();
                                  }
                                },
                              ),
                              onTap: () => _showCategoryDialog(context, ref, categories, categoryToEdit: category),
                            ),
                          );
                        },
                      ),
               ),
             ],
           );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
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
    BuildContext context, 
    WidgetRef ref, 
    List<Category> existingCategories, 
    {Category? categoryToEdit}
  ) {
    final isEditing = categoryToEdit != null;
    final controller = TextEditingController(text: isEditing ? categoryToEdit.name : '');
    
    // Curated palette
    final List<Color> palette = [
      ...Colors.primaries,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
    ];

    // Initial color
    int selectedColorValue = isEditing 
        ? categoryToEdit.color 
        : palette.first.value;

    // Available Icons
    const List<IconData> _availableIcons = [
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
        : _availableIcons.first.codePoint;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Category' : 'New Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    const Align(alignment: Alignment.centerLeft, child: Text("Pick a Color:")),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: palette.map((color) {
                        final isSelected = color.value == selectedColorValue;
                        // Check usage
                        final isUsed = existingCategories.any((c) => 
                          c.color == color.value && 
                          (categoryToEdit == null || c.id != categoryToEdit.id) // Ignore self if editing
                        );

                        return GestureDetector(
                          onTap: isUsed ? null : () {
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
                              border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                              // Dim if used
                              boxShadow: isUsed ? null : [
                                if (isSelected) BoxShadow(color: Colors.black26, blurRadius: 4)
                              ],
                            ),
                            child: isUsed 
                              ? Icon(Icons.block, size: 16, color: Colors.white.withOpacity(0.5)) 
                              : (isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Align(alignment: Alignment.centerLeft, child: Text("Pick an Icon:")),
                    const SizedBox(height: 8),
                    Container(
                      height: 150, // Limit height for grid
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: _availableIcons.length,
                        itemBuilder: (context, index) {
                          final iconData = _availableIcons[index];
                          final isSelected = selectedIconCodePoint == iconData.codePoint;
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIconCodePoint = iconData.codePoint;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Color(selectedColorValue).withOpacity(0.2) : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected ? Border.all(color: Color(selectedColorValue), width: 2) : null,
                              ),
                              child: Icon(
                                iconData,
                                color: isSelected ? Color(selectedColorValue) : Colors.grey,
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
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isEmpty) return;

                    // Final Validation
                    final isColorTaken = existingCategories.any((c) => 
                        c.color == selectedColorValue && 
                        (categoryToEdit == null || c.id != categoryToEdit.id)
                    );

                    if (isColorTaken) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Color already taken! Please pick another.')),
                      );
                      return;
                    }

                    final db = ref.read(databaseProvider);
                    
                    if (isEditing) {
                      (db.update(db.categories)..where((t) => t.id.equals(categoryToEdit.id)))
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
                  child: Text(isEditing ? 'Save' : 'Add'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
