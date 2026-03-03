import 'package:flutter/material.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';

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

  void _addItem() {
    _nameController.clear();
    _priceController.clear();
    _categoryController.clear();
    _quantityController.text = "1"; // default quantity

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category (optional)'),
              ),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price per item'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text.trim();
                final category = _categoryController.text.trim().isEmpty ? 'Other' : _categoryController.text.trim();
                final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
                final pricePerItem = double.tryParse(_priceController.text.trim()) ?? 0.0;

                if (name.isEmpty) return;

                setState(() {
                  widget.list.items.add(
                    ShoppingItem(
                      name: name,
                      category: category,
                      quantity: quantity,
                      pricePerItem: pricePerItem,
                    ),
                  );
                  widget.list.save(); // SAVE changes
                });

                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editItem(int index) {
    final item = widget.list.items[index];
    _nameController.text = item.name;
    _categoryController.text = item.category;
    _quantityController.text = item.quantity.toString();
    _priceController.text = item.pricePerItem.toStringAsFixed(2);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Category')),
              TextField(controller: _quantityController, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
              TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price per item'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              Row(
                children: [
                  const Text('Favorite:'),
                  const SizedBox(width: 8),
                  Checkbox(
                    value: item.isFavorite,
                    onChanged: (v) {
                      setState(() {
                        item.isFavorite = v ?? false;
                        widget.list.save();
                      });
                    },
                  )
                ],
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final newName = _nameController.text.trim();
                final newCategory = _categoryController.text.trim().isEmpty ? 'Other' : _categoryController.text.trim();
                final newQuantity = int.tryParse(_quantityController.text.trim()) ?? 1;
                final newPricePerItem = double.tryParse(_priceController.text.trim()) ?? 0.0;

                if (newName.isEmpty) return;

                setState(() {
                  widget.list.items[index] = widget.list.items[index].copyWith(
                    name: newName,
                    category: newCategory,
                    quantity: newQuantity,
                    pricePerItem: newPricePerItem,
                  );
                  widget.list.save(); // SAVE edits
                });

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteItem(int index) {
    final item = widget.list.items[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete item?'),
          content: Text('Delete "${item.name}" from this list?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.list.items.removeAt(index);
                  widget.list.save();
                });
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _toggleFavorite(int index) {
    setState(() {
      widget.list.items[index].isFavorite = !widget.list.items[index].isFavorite;
      widget.list.save();
    });
  }

  double get total => widget.list.items.fold(0.0, (sum, item) => sum + item.totalPrice);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list.name),
        backgroundColor: Colors.green[700],
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
              'Total: \$${total.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: widget.list.items.isEmpty
                ? const Center(child: Text('No items in this list yet'))
                : ListView.builder(
                    itemCount: widget.list.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.list.items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[200],
                            child: Text(item.category.isNotEmpty ? item.category[0].toUpperCase() : '?'),
                          ),
                          title: Text(item.name),
                          subtitle: Text(
                              '${item.category} • ${item.quantity} x \$${item.pricePerItem.toStringAsFixed(2)} = \$${item.totalPrice.toStringAsFixed(2)}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  _editItem(index);
                                  break;
                                case 'delete':
                                  _confirmDeleteItem(index);
                                  break;
                                case 'fav':
                                  _toggleFavorite(index);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'edit', child: Text('Edit')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete')),
                              PopupMenuItem(
                                value: 'fav',
                                child: Text(item.isFavorite ? 'Unfavorite' : 'Add to favorites'),
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