import 'package:flutter/material.dart';
import '../data/app_data.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _newCategoryController = TextEditingController();

  void _addCategory() {
    final name = _newCategoryController.text.trim();
    if (name.isEmpty) return;
    if (!AppData.categories.contains(name)) {
      setState(() {
        AppData.categories.add(name);
      });
      _newCategoryController.clear();
    }
  }

  void _editCategory(int index) {
    final controller = TextEditingController(text: AppData.categories[index]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Category"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                AppData.categories[index] = controller.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(int index) {
    final category = AppData.categories[index];

    // Prevent deletion if items exist in this category
    bool used = AppData.shoppingListsBox.values.toList().any((list) =>
        list.items.any((item) => item.category == category));

    if (used) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot delete category: items exist in it")),
      );
      return;
    }

    setState(() {
      AppData.categories.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            // Dark/Light Mode Toggle
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: AppData.isDarkMode,
              onChanged: (val) {
                setState(() {
                  AppData.isDarkMode = val;
                });
              },
              secondary: const Icon(Icons.brightness_6),
            ),
            const SizedBox(height: 12),

            // Categories Section
            const Text(
              "Categories",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...AppData.categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              return Card(
                child: ListTile(
                  title: Text(category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editCategory(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteCategory(index),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),

            // Add new category
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCategoryController,
                    decoration: const InputDecoration(
                      labelText: "New Category",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addCategory,
                  child: const Text("Add"),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // App Info Section
            const Text(
              "App Info",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const ListTile(
              title: Text("Smart Grocery"),
              subtitle: Text("Version 1.0"),
              leading: Icon(Icons.info_outline),
            ),
            const SizedBox(height: 12),

            // Reset All Data
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  AppData.shoppingListsBox.values.toList().clear();
                  AppData.categories = AppData.defaultCategories.toList();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Reset All Data"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}
