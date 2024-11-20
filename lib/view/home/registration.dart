// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fendhaaroo/models/users.dart';
import 'package:fendhaaroo/view/home/login.dart';
import 'package:fendhaaroo/view/home/home_view.dart'; // Add this import
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math'; // Import for generating random ID

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late Box<User> _userBox;

  @override
  void initState() {
    super.initState();
    _openUserBox();
  }

  Future<void> _openUserBox() async {
    _userBox = await Hive.openBox<User>('users');
  }

  String _generateUserId() {
    var random = Random();
    return (random.nextInt(900000) + 100000).toString();
  }

  void _register() async {
    if (!_userBox.isOpen) {
      await _openUserBox();
    }

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String id = _generateUserId();

    User? existingUser;
    try {
      existingUser = _userBox.values.firstWhere(
        (user) => user.username == username,
      );
    } catch (e) {
      existingUser = null;
    }

    if (existingUser != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username already exists')),
      );
    } else {
      User newUser = User(
        id: id,
        username: username,
        password: password,
        userLevel: UserLevel.employee,
      );
      await _userBox.add(newUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeView(user: newUser),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register',
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: _register,
                child: const Text(
                  'Register',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'Already a user? Login',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
