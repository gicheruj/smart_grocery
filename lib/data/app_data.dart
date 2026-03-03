import 'package:hive/hive.dart';
import '../models/shopping_list.dart';

class AppData {
  static List<String> defaultCategories = [
    "Dairy",
    "Vegetables",
    "Fruits",
    "Meat",
    "Snacks",
    "Beverages",
    "Grains",
    "Household",
    "Frozen",
    "Other",
  ];

  static List<String> categories = List.from(defaultCategories);

  static Box<ShoppingList> get shoppingListsBox =>
      Hive.box<ShoppingList>('shoppingLists');

  static bool isDarkMode = false;
}