import 'package:hive_ce/hive.dart';

part 'checklist_item.g.dart';

@HiveType(typeId: 4)
class ChecklistItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String checklistId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String quantity;

  @HiveField(4)
  bool isChecked;

  @HiveField(5)
  DateTime createdAt;

  ChecklistItem({
    required this.id,
    required this.checklistId,
    required this.name,
    this.quantity = '',
    this.isChecked = false,
    required this.createdAt,
  });

  ChecklistItem copyWith({
    String? name,
    String? quantity,
    bool? isChecked,
  }) {
    return ChecklistItem(
      id: id,
      checklistId: checklistId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'checklistId': checklistId,
        'name': name,
        'quantity': quantity,
        'isChecked': isChecked,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        id: json['id'] as String,
        checklistId: json['checklistId'] as String,
        name: json['name'] as String? ?? '',
        quantity: json['quantity'] as String? ?? '',
        isChecked: json['isChecked'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
