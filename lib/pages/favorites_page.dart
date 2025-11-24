import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/shopping_item.dart';
// import '../models/shopping_list.dart';
// import '../pages/shopping_list_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final Map<String, bool> _expandedCategories = {};

  Map<String, List<ShoppingItem>> get _favoritesByCategory {
    Map<String, List<ShoppingItem>> map = {};
    for (var list in AppData.shoppingLists) {
      for (var item in list.items) {
        if (item.isFavorite) {
          map.putIfAbsent(item.category, () => []).add(item);
          _expandedCategories.putIfAbsent(item.category, () => true);
        }
      }
    }
    return map;
  }

  void _unfavoriteItem(ShoppingItem item) {
    setState(() {
      item.isFavorite = false;
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
              itemCount: AppData.shoppingLists.length,
              itemBuilder: (context, index) {
                final list = AppData.shoppingLists[index];
                return ListTile(
                  title: Text(list.name),
                  onTap: () {
                    setState(() {
                      list.items.add(item.copyWith());
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

  void _editItem(ShoppingItem item) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController(text: item.name);
        final categoryController = TextEditingController(text: item.category);
        final priceController = TextEditingController(text: item.price.toStringAsFixed(2));
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
                  item.price = double.tryParse(priceController.text.trim()) ?? 0.0;
                  item.isFavorite = isFav;
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
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green[200],
                  child: Text(item.category.isNotEmpty ? item.category[0].toUpperCase() : "?"),
                ),
                title: Text(item.name),
                subtitle: Text("\$${item.price.toStringAsFixed(2)}"),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case "add":
                        _addToList(item);
                        break;
                      case "edit":
                        _editItem(item);
                        break;
                      case "unfav":
                        _unfavoriteItem(item);
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

