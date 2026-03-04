import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/app_data.dart';
import '../models/shopping_item.dart';
import '../models/shopping_list.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final Map<String, bool> _expandedCategories = {};

  // Group favorite items by category
  Map<String, List<ShoppingItem>> get _favoritesByCategory {
    Map<String, List<ShoppingItem>> map = {};
    for (int i = 0; i < AppData.shoppingListsBox.length; i++) {
      final shoppingList = AppData.shoppingListsBox.getAt(i)!;
      for (var item in shoppingList.items) {
        if (item.isFavorite) {
          map.putIfAbsent(item.category, () => []).add(item);
          _expandedCategories.putIfAbsent(item.category, () => true);
        }
      }
    }
    return map;
  }

  // Unfavorite a single item
  void _unfavoriteItem(ShoppingItem item, ShoppingList shoppingList) {
    setState(() {
      item.isFavorite = false;
      shoppingList.save();
    });
  }

  // Edit item
  void _editItem(ShoppingItem item, ShoppingList shoppingList) {
    final nameController = TextEditingController(text: item.name);
    final categoryController = TextEditingController(text: item.category);
    final priceController = TextEditingController(text: item.pricePerItem.toStringAsFixed(2));
    bool isFav = item.isFavorite;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Favorite Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: "Category")),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "Price"),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            Row(
              children: [
                const Text("Favorite:"),
                Checkbox(value: isFav, onChanged: (v) => isFav = v ?? true),
              ],
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                item.name = nameController.text.trim();
                item.category = categoryController.text.trim().isEmpty ? "Other" : categoryController.text.trim();
                item.pricePerItem = double.tryParse(priceController.text.trim()) ?? 0.0;
                item.isFavorite = isFav;
                shoppingList.save();
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritesMap = _favoritesByCategory;

    if (favoritesMap.isEmpty) {
      return const Center(child: Text("No favorites yet"));
    }

    return ListView(
      children: favoritesMap.entries.map((entry) {
        final category = entry.key;
        final items = entry.value;
        final isExpanded = _expandedCategories[category] ?? true;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ExpansionTile(
            initiallyExpanded: isExpanded,
            onExpansionChanged: (val) => setState(() => _expandedCategories[category] = val),
            title: Text(
              "$category (${items.length})",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            children: items.map((item) {
              final shoppingListContainingItem = AppData.shoppingListsBox.allLists.firstWhere(
                (list) => list.items.contains(item),
              );
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green[200],
                  child: Text(item.category.isNotEmpty ? item.category[0].toUpperCase() : "?"),
                ),
                title: Text(item.name),
                subtitle: Text("\$${item.pricePerItem.toStringAsFixed(2)}"),
                trailing: IconButton(
                  icon: Icon(Icons.favorite, color: item.isFavorite ? Colors.red : Colors.grey),
                  onPressed: () => _unfavoriteItem(item, shoppingListContainingItem),
                ),
                onTap: () => _editItemDialog(item),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  // Show options for editing/deleting when tapping an item
  void _editItemDialog(ShoppingItem item) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final shoppingListContainingItem = AppData.shoppingListsBox.allLists.firstWhere(
          (list) => list.items.contains(item),
        );
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit Item"),
              onTap: () {
                Navigator.pop(context);
                _editItem(item, shoppingListContainingItem);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Delete Item"),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(item, shoppingListContainingItem);
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(ShoppingItem item, ShoppingList shoppingList) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item?"),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                shoppingList.items.remove(item);
                shoppingList.save();
              });
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}

// Optional extension for iterating Hive Box
extension HiveLists on Box<ShoppingList> {
  Iterable<ShoppingList> get allLists sync* {
    for (int i = 0; i < length; i++) {
      yield getAt(i)!;
    }
  }
}