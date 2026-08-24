import 'package:hive_ce/hive.dart';

part 'checklist.g.dart';

@HiveType(typeId: 2)
class Checklist extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4)
  bool isBookmarked;

  Checklist({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.isBookmarked = false,
  });

  Checklist copyWith({
    String? name,
    DateTime? updatedAt,
    bool? isBookmarked,
  }) {
    return Checklist(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
