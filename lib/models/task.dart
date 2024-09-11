import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  Task({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAtTime,
    required this.createdAtDate,
    required this.isCompleted,
    required this.userId,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String subtitle;

  @HiveField(3)
  DateTime createdAtTime;

  @HiveField(4)
  DateTime createdAtDate;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  String userId;

  factory Task.create({
    required String title,
    required String subtitle,
    required String userId,
    DateTime? createdAtTime,
    DateTime? createdAtDate,
  }) =>
      Task(
        id: const Uuid().v4(),
        title: title,
        subtitle: subtitle,
        createdAtTime: createdAtTime ?? DateTime.now(),
        isCompleted: false,
        createdAtDate: createdAtDate ?? DateTime.now(),
        userId: userId,
      );
}
