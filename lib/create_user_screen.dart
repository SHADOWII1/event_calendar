import 'dart:convert'; // For hashing
import 'package:crypto/crypto.dart'; // For SHA-256
import 'package:flutter/material.dart';
import 'package:event_calendar/services/user_service.dart'; // Update with your user service path

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  _CreateUserPageState createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService(); // Replace with your user service implementation
  String? _selectedRole;

  // Controllers for each input field
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _matriculationNumberController = TextEditingController();

  // Method to hash the password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password); // Convert to bytes
    final digest = sha256.convert(bytes); // Generate SHA-256 hash
    return digest.toString(); // Convert to string
  }

  // Method to handle form submission
  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final hashedPassword = _hashPassword(_passwordController.text);

        await _userService.createUser(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          password: hashedPassword,
          role:_selectedRole ?? '',
          createdAt: DateTime.now().toIso8601String(),
          matriculationNumber: _matriculationNumberController.text,
        );
        Navigator.pop(context, true); // Go back after successful creation
        print('User created successfully!');
      } catch (error) {
        print('Error: $error');
        Navigator.pop(context, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter an email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a password';
                  } else if (value!.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: ['Admin', 'Lecturer', 'Student'].map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _matriculationNumberController,
                decoration: const InputDecoration(labelText: 'Matriculation Number'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a Matriculation Number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Create User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
