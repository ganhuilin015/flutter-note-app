import 'package:hive_ce/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 1)
class Reminder extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime dateTime;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  DateTime createdAt;

  Reminder({
    required this.id,
    required this.title,
    this.description = '',
    required this.dateTime,
    this.isCompleted = false,
    required this.createdAt,
  });

  bool get isPast => dateTime.isBefore(DateTime.now());

  Reminder copyWith({
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
  }) {
    return Reminder(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}