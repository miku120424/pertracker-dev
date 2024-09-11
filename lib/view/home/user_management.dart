import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hive_tdo/models/users.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  User? _editingUser;

  @override
  void initState() {
    super.initState();
  }

  void _addOrUpdateUser() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState?.value;
      final id = formData?['id'];
      final userName = formData?['name'];
      final userLevel = UserLevel.values
          .firstWhere((e) => e.toString() == formData?['userLevel']);

      final user = User.create(
          id: id, userLevel: userLevel, username: userName, password: '');

      final box = Hive.box<User>('users');

      if (_editingUser == null) {
        await box.add(user);
      } else {
        final index = box.values.toList().indexOf(_editingUser!);
        await box.putAt(index, user);
      }

      Navigator.of(context).pop();
    }
  }

  void _editUser(User user) {
    setState(() {
      _editingUser = user;
    });
    _formKey.currentState?.patchValue({
      'id': user.id,
      'name': user.username,
      'userLevel': user.userLevel.toString(),
    });
    _buildUserForm();
  }

  void _deleteUser(User user) async {
    final box = Hive.box<User>('users');
    final index = box.values.toList().indexOf(user);
    await box.deleteAt(index);
  }

  void _buildUserForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'id',
                        decoration: const InputDecoration(labelText: 'ID'),
                        initialValue: _editingUser?.id,
                        enabled: _editingUser == null,
                      ),
                      FormBuilderTextField(
                        name: 'name',
                        decoration:
                            const InputDecoration(labelText: 'User name'),
                        initialValue: _editingUser?.username,
                      ),
                      FormBuilderDropdown(
                        name: 'userLevel',
                        decoration:
                            const InputDecoration(labelText: 'User Level'),
                        initialValue: _editingUser?.userLevel.toString(),
                        items: UserLevel.values
                            .map((level) => DropdownMenuItem(
                                  value: level.toString(),
                                  child: Text(level.toString().split('.').last),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _addOrUpdateUser,
                        child: Text(
                            _editingUser == null ? 'Add User' : 'Update User'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      body: ValueListenableBuilder<Box<User>>(
        valueListenable: Hive.box<User>('users').listenable(),
        builder: (context, box, _) {
          final users = box.values.toList();
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                child: Card(
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.only(left: 24, right: 8),
                    title: Text(user.username),
                    subtitle: Text(user.userLevel.toString().split('.').last),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: const EdgeInsets.all(0),
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.orangeAccent,
                          ),
                          onPressed: () => _editUser(user),
                        ),
                        IconButton(
                          padding: const EdgeInsets.all(0),
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteUser(user),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 150,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 30,
                ),
              ),
            ),
            const Text(
              "User Management",
              style: TextStyle(color: Colors.black, fontSize: 24),
            ),
            const SizedBox(width: 30),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(150);
}
