import 'package:hive/hive.dart';
import 'shopping_item.dart';

part 'shopping_list.g.dart';

@HiveType(typeId: 1)
class ShoppingList extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  List<ShoppingItem> items;

  ShoppingList({
    required this.name,
    this.items = const [],
  });
}