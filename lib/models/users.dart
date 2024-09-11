import 'package:hive/hive.dart';

part 'users.g.dart';

@HiveType(typeId: 1)
enum UserLevel {
  @HiveField(0)
  manager,
  @HiveField(1)
  supervisor,
  @HiveField(2)
  employee,
  @HiveField(3)
  intern,
}

@HiveType(typeId: 2)
class User extends HiveObject {
  User({
    required this.id,
    required this.username,
    required this.password,
    required this.userLevel,
  });

  /// ID
  @HiveField(0)
  final String id;

  /// USERNAME
  @HiveField(2)
  final String username;

  /// PASSWORD
  @HiveField(3)
  final String password;

  /// USER LEVEL
  @HiveField(4)
  final UserLevel userLevel;

  /// Create new User
  factory User.create({
    required String id,
    required String username,
    required String password,
    required UserLevel userLevel,
  }) =>
      User(
        id: id,
        username: username,
        password: password,
        userLevel: userLevel,
      );
}
