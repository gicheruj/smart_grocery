import 'package:hive/hive.dart';

part 'shopping_item.g.dart';

@HiveType(typeId: 0)
class ShoppingItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String category;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  double pricePerItem;

  @HiveField(4)
  bool isFavorite;

  @HiveField(5)
  bool isBought; // NEW FIELD

  ShoppingItem({
    required this.name,
    required this.category,
    this.quantity = 1,
    required this.pricePerItem,
    this.isFavorite = false,
    this.isBought = false,
  });

  double get totalPrice => quantity * pricePerItem;

  ShoppingItem copyWith({
    String? name,
    String? category,
    int? quantity,
    double? pricePerItem,
    bool? isFavorite,
    bool? isBought,
  }) {
    return ShoppingItem(
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      pricePerItem: pricePerItem ?? this.pricePerItem,
      isFavorite: isFavorite ?? this.isFavorite,
      isBought: isBought ?? this.isBought,
    );
  }
}