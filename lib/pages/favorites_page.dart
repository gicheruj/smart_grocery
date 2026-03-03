import 'package:flutter/material.dart';
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

  Map<String, List<ShoppingItem>> get _favoritesByCategory {
    Map<String, List<ShoppingItem>> map = {};
    for (var list in AppData.shoppingListsBox.values) {
      for (var item in list.items) {
        if (item.isFavorite) {
          map.putIfAbsent(item.category, () => []).add(item);
          _expandedCategories.putIfAbsent(item.category, () => true);
        }
      }
    }
    return map;
  }

  void _unfavoriteItem(ShoppingItem item, ShoppingList list) {
    setState(() {
      item.isFavorite = false;
      list.save(); // <- SAVE favorite removal
    });
  }

  void _addToList(ShoppingItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add to Shopping List"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: AppData.shoppingListsBox.length,
              itemBuilder: (context, index) {
                final list = AppData.shoppingListsBox.getAt(index)!;
                return ListTile(
                  title: Text(list.name),
                  onTap: () {
                    setState(() {
                      list.items.add(item.copyWith());
                      list.save(); // <- SAVE addition
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _editItem(ShoppingItem item, ShoppingList list) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController(text: item.name);
        final categoryController = TextEditingController(text: item.category);
        final priceController =
            TextEditingController(text: item.pricePerItem.toStringAsFixed(2));
        bool isFav = item.isFavorite;

        return AlertDialog(
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
                  list.save(); // <- SAVE edits
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
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
              category,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            children: items.map((item) {
              // Find the list that contains this item
              final parentList = AppData.shoppingListsBox.values.firstWhere(
                  (list) => list.items.contains(item));

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green[200],
                  child: Text(item.category.isNotEmpty ? item.category[0].toUpperCase() : "?"),
                ),
                title: Text(item.name),
                subtitle: Text("\$${item.pricePerItem.toStringAsFixed(2)}"),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case "add":
                        _addToList(item);
                        break;
                      case "edit":
                        _editItem(item, parentList);
                        break;
                      case "unfav":
                        _unfavoriteItem(item, parentList);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: "add", child: Text("Add to list")),
                    const PopupMenuItem(value: "edit", child: Text("Edit")),
                    const PopupMenuItem(value: "unfav", child: Text("Unfavorite")),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}