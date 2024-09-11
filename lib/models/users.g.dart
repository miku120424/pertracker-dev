// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 2;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      username: fields[2] as String,
      password: fields[3] as String,
      userLevel: fields[4] as UserLevel,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.userLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserLevelAdapter extends TypeAdapter<UserLevel> {
  @override
  final int typeId = 1;

  @override
  UserLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserLevel.manager;
      case 1:
        return UserLevel.supervisor;
      case 2:
        return UserLevel.employee;
      case 3:
        return UserLevel.intern;
      default:
        return UserLevel.manager;
    }
  }

  @override
  void write(BinaryWriter writer, UserLevel obj) {
    switch (obj) {
      case UserLevel.manager:
        writer.writeByte(0);
        break;
      case UserLevel.supervisor:
        writer.writeByte(1);
        break;
      case UserLevel.employee:
        writer.writeByte(2);
        break;
      case UserLevel.intern:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
