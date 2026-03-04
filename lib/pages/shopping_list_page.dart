import 'package:flutter/material.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../data/app_data.dart';

class ShoppingListPage extends StatefulWidget {
  final ShoppingList list;

  const ShoppingListPage({super.key, required this.list});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  /// 🎨 CATEGORY COLOR GENERATOR
  Color _getCategoryColor(String category) {
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
    ];

    final index = category.toLowerCase().hashCode % colors.length;
    return colors[index.abs()];
  }

  void _resetBoughtItems() {
    setState(() {
      for (var item in widget.list.items) {
        item.isBought = false;
      }
      widget.list.save();
    });
  }

  void _addItem() {
    _nameController.clear();
    _priceController.clear();
    _categoryController.clear();
    _quantityController.text = "1";

    showDialog(
      context: context,
      builder: (_) => _buildItemDialog(isEditing: false),
    );
  }

  void _editItem(ShoppingItem item) {
    _nameController.text = item.name;
    _categoryController.text = item.category;
    _quantityController.text = item.quantity.toString();
    _priceController.text = item.pricePerItem.toString();

    showDialog(
      context: context,
      builder: (_) => _buildItemDialog(isEditing: true, item: item),
    );
  }

  Widget _buildItemDialog({required bool isEditing, ShoppingItem? item}) {
    return AlertDialog(
      title: Text(isEditing ? "Edit Item" : "Add Item"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: "Category"),
          ),
          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(labelText: "Quantity"),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: "Price per item"),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            final category = _categoryController.text.trim().isEmpty
                ? "Other"
                : _categoryController.text.trim();
            final quantity =
                int.tryParse(_quantityController.text.trim()) ?? 1;
            final price =
                double.tryParse(_priceController.text.trim()) ?? 0.0;

            if (name.isEmpty) return;

            setState(() {
              if (isEditing && item != null) {
                item.name = name;
                item.category = category;
                item.quantity = quantity;
                item.pricePerItem = price;
              } else {
                widget.list.items.add(
                  ShoppingItem(
                    name: name,
                    category: category,
                    quantity: quantity,
                    pricePerItem: price,
                  ),
                );
              }
              widget.list.save();
            });

            Navigator.pop(context);
          },
          child: Text(isEditing ? "Save" : "Add"),
        ),
      ],
    );
  }

  void _deleteItem(ShoppingItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Item"),
        content: Text("Are you sure you want to delete '${item.name}'?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                widget.list.items.remove(item);
                widget.list.save();
              });
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  double get total =>
      widget.list.items.fold(0.0, (sum, item) => sum + item.totalPrice);

  @override
  Widget build(BuildContext context) {
    final sortedItems = [...widget.list.items];
    sortedItems.sort((a, b) =>
        a.category.toLowerCase().compareTo(b.category.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list.name),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetBoughtItems,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.green[100],
            padding: const EdgeInsets.all(12),
            child: Text(
              "Total: ${AppData.currencySymbols[AppData.selectedCurrency]}${total.toStringAsFixed(2)}",
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: sortedItems.isEmpty
                ? const Center(child: Text("No items yet"))
                : ListView.builder(
                    itemCount: sortedItems.length,
                    itemBuilder: (context, index) {
                      final item = sortedItems[index];
                      final categoryColor =
                          _getCategoryColor(item.category);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: categoryColor,
                            child: Text(
                              item.category[0].toUpperCase(),
                              style:
                                  const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(
                              decoration: item.isBought
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(
                              "${item.category} • ${item.quantity} x ${AppData.currencySymbols[AppData.selectedCurrency]}${item.pricePerItem.toStringAsFixed(2)} = ${AppData.currencySymbols[AppData.selectedCurrency]}${item.totalPrice.toStringAsFixed(2)}"),

                          /// ⭐ + ☑ + ⋮ MENU
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // FAVORITE BUTTON
                              IconButton(
                                icon: Icon(
                                  item.isFavorite
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                ),
                                onPressed: () {
                                  setState(() {
                                    item.isFavorite =
                                        !item.isFavorite;
                                    widget.list.save();
                                  });
                                },
                              ),

                              // CHECKBOX
                              Checkbox(
                                value: item.isBought,
                                onChanged: (value) {
                                  setState(() {
                                    item.isBought = value ?? false;
                                    widget.list.save();
                                  });
                                },
                              ),

                              // POPUP MENU (NEAR ITEM)
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _editItem(item);
                                  } else if (value == 'delete') {
                                    _deleteItem(item);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text("Edit"),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text("Delete"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}