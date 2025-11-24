import '../models/shopping_list.dart';

class AppData {
  // Default categories
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

  static List<ShoppingList> shoppingLists = [];

  static bool isDarkMode = false;
}
