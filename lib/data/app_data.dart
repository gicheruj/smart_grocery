import 'package:hive/hive.dart';
import '../models/shopping_list.dart';

class AppData {
  static bool isDarkMode = false;

  // Persistent currency selection
  static String selectedCurrency = 'USD';

  static const Map<String, String> currencySymbols = {
    'USD': '\$',
    'KES': 'KSh ',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
  };

  static Box<ShoppingList> get shoppingListsBox =>
      Hive.box<ShoppingList>('shoppingLists');

  static List<String> defaultCategories = [
    'Fruits',
    'Vegetables',
    'Dairy',
    'Meat',
    'Bakery',
  ];

  static List<String> categories = defaultCategories.toList();
}