import 'package:hive_ce/hive.dart';

part 'grocery_item.g.dart';

@HiveType(typeId: 0)
class GroceryItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String quantity;

  @HiveField(3)
  bool isChecked;

  @HiveField(4)
  DateTime createdAt;

  GroceryItem({
    required this.id,
    required this.name,
    this.quantity = '',
    this.isChecked = false,
    required this.createdAt,
  });

  GroceryItem copyWith({
    String? name,
    String? quantity,
    bool? isChecked,
  }) {
    return GroceryItem(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt,
    );
  }
}