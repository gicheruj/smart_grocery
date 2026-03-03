import 'package:hive/hive.dart';

part 'shopping_item.g.dart';

class ShoppingItem {
  String name;
  String category;
  int quantity;
  double pricePerItem;
  bool isFavorite;

  ShoppingItem({
    required this.name,
    required this.category,
    this.quantity = 1,
    required this.pricePerItem,
    this.isFavorite = false,
  });

  // Total price = quantity * pricePerItem
  double get totalPrice => quantity * pricePerItem;

  ShoppingItem copyWith({
    String? name,
    String? category,
    int? quantity,
    double? pricePerItem,
    bool? isFavorite,
  }) {
    return ShoppingItem(
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      pricePerItem: pricePerItem ?? this.pricePerItem,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}