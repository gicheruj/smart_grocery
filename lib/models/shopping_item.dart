
class ShoppingItem {
  String name;
  String category;
  double price;
  bool isFavorite;

  ShoppingItem({
    required this.name,
    required this.category,
    required this.price,
    this.isFavorite = false,
  });

  ShoppingItem copyWith({
    String? name,
    String? category,
    double? price,
    bool? isFavorite,
  }) {
    return ShoppingItem(
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

