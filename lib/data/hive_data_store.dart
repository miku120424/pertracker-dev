import 'package:flutter/foundation.dart';
import 'package:fendhaaroo/models/task.dart';
import 'package:fendhaaroo/models/users.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveDataStore {
  static const boxName = "tasksBox";
  static const boxNameUser = "usersBox";

  late final Box<Task> box;
  late final Box<User> boxUser;

  HiveDataStore._internal() {
    box = Hive.box<Task>(boxName);
    boxUser = Hive.box<User>(boxNameUser);
  }

  static final HiveDataStore _instance = HiveDataStore._internal();

  factory HiveDataStore() => _instance;

  Future<void> addUser({required User user}) async {
    await boxUser.put(user.id, user);
  }

  Future<User?> getUser({required String id}) async {
    return boxUser.get(id);
  }

  Future<void> updateUser({required User user}) async {
    await boxUser.put(user.id, user);
  }

  Future<void> deleteUser({required User user}) async {
    await boxUser.delete(user.id);
  }

  ValueListenable<Box<User>> listenToUsers() {
    return boxUser.listenable();
  }

  List<User> getUsersByLevel(UserLevel level) {
    return boxUser.values.where((user) => user.userLevel == level).toList();
  }

  Future<void> addTask({required Task task}) async {
    await box.put(task.id, task);
  }

  Future<Task?> getTask({required String id}) async {
    return box.get(id);
  }

  Future<void> updateTask({required Task task}) async {
    await box.put(task.id, task);
  }

  Future<void> deleteTask({required Task task}) async {
    await box.delete(task.id);
  }

  ValueListenable<Box<Task>> listenToTasks() {
    return box.listenable();
  }
}
