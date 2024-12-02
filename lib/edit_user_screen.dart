import 'package:flutter/material.dart';
import 'package:event_calendar/services/user_service.dart';
import 'dart:convert'; // For hashing
import 'package:crypto/crypto.dart'; // For SHA-256

class EditUserPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final userService = UserService();

  EditUserPage({super.key, required this.user});

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  late TextEditingController matriculationNumberController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController roleController;
  late TextEditingController passwordController;

  // Method to hash the password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password); // Convert to bytes
    final digest = sha256.convert(bytes); // Generate SHA-256 hash
    return digest.toString(); // Convert to string
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the existing user data
    matriculationNumberController =
        TextEditingController(text: widget.user['matriculation_number']);
    firstNameController = TextEditingController(text: widget.user['first_name']);
    lastNameController = TextEditingController(text: widget.user['last_name']);
    emailController = TextEditingController(text: widget.user['email']);
    roleController = TextEditingController(text: widget.user['role']);
    passwordController = TextEditingController(); // Password is not pre-filled
  }

  @override
  void dispose() {
    matriculationNumberController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    roleController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> updateUser() async {
    try {
      String? password = passwordController.text.isNotEmpty
          ? _hashPassword(passwordController.text)
          : null;

      await UserService().updateUser(
        matriculationNumber: matriculationNumberController.text,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
        role: roleController.text,
        password: password,
      );
      print('User updated successfully');
      Navigator.pop(context, true); // Return to the previous screen
    } catch (error) {
      print('Error updating user: $error');
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: matriculationNumberController,
              decoration: const InputDecoration(labelText: 'Matriculation Number'),
              readOnly: true, // Typically non-editable
            ),
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true, // Hides password input
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateUser,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
