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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isBookmarked': isBookmarked,
      };

  factory Checklist.fromJson(Map<String, dynamic> json) => Checklist(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        isBookmarked: json['isBookmarked'] as bool? ?? false,
      );
}
