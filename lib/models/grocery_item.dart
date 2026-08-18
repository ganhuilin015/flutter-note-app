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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'isChecked': isChecked,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GroceryItem.fromJson(Map<String, dynamic> json) => GroceryItem(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        quantity: json['quantity'] as String? ?? '',
        isChecked: json['isChecked'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}