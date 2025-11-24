import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/shopping_list.dart';
import 'shopping_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _listNameController = TextEditingController();

  void _createNewList() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Shopping List'),
          content: TextField(
            controller: _listNameController,
            decoration: const InputDecoration(hintText: "List name"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _listNameController.clear();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _listNameController.text.trim();
                if (name.isEmpty) return;
                setState(() {
                  AppData.shoppingLists.add(ShoppingList(name: name));
                });
                _listNameController.clear();
                Navigator.pop(context);
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteList(int index) {
    final list = AppData.shoppingLists[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete list?'),
          content: Text('Delete "${list.name}" and all its items?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  AppData.shoppingLists.removeAt(index);
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

  @override
  void dispose() {
    _listNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Shopping Lists"),
        backgroundColor: Colors.green[700],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewList,
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add),
      ),
      body: AppData.shoppingLists.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "No shopping lists yet",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Create a new list using the + button below.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Create your first list"),
                      onPressed: _createNewList,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: AppData.shoppingLists.length,
              itemBuilder: (context, index) {
                final list = AppData.shoppingLists[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  elevation: 3,
                  child: ListTile(
                    title: Text(list.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    subtitle: Text("${list.items.length} items"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete list',
                          onPressed: () => _confirmDeleteList(index),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShoppingListPage(list: list),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  ),
                );
              },
            ),
    );
  }
}
