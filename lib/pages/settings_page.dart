import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/shopping_list.dart';
import '../data/app_data.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<String> _currencies = ['USD', 'KES', 'EUR', 'GBP', 'JPY'];

  @override
  Widget build(BuildContext context) {
    final totalLists = AppData.shoppingListsBox.length;
    int totalItems = 0;

    for (var list in AppData.shoppingListsBox.allLists) {
      totalItems += list.items.length;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            // Currency Selector
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: const Text("Currency"),
              trailing: DropdownButton<String>(
                value: AppData.selectedCurrency,
                items: _currencies
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      AppData.selectedCurrency = value;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "App Info",
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            ListTile(
              title: const Text("Smart Grocery"),
              subtitle: Text(
                  "Version 1.0 • $totalLists lists • $totalItems items"),
              leading: const Icon(Icons.info_outline),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  AppData.shoppingListsBox.clear();
                  AppData.categories =
                      AppData.defaultCategories.toList();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Reset All Data"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}

extension HiveLists on Box<ShoppingList> {
  Iterable<ShoppingList> get allLists sync* {
    for (int i = 0; i < length; i++) {
      yield getAt(i)!;
    }
  }
}