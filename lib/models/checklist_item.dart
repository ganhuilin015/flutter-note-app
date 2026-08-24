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

  @HiveField(6)
  bool isCheckbox;

  ChecklistItem({
    required this.id,
    required this.checklistId,
    required this.name,
    this.quantity = '',
    this.isChecked = false,
    required this.createdAt,
    this.isCheckbox = true,
  });

  ChecklistItem copyWith({
    String? name,
    String? quantity,
    bool? isChecked,
    bool? isCheckbox,
  }) {
    return ChecklistItem(
      id: id,
      checklistId: checklistId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt,
      isCheckbox: isCheckbox ?? this.isCheckbox,
    );
  }
}