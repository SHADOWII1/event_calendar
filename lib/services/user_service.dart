import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = 'http://10.0.2.2:3000/api/user';

  Future<void> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    required String createdAt,
    required String matriculationNumber,
  }) async {
    final url = Uri.parse('$baseUrl/add'); // Update with your actual endpoint
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'role': role,
        'created_at': createdAt,
        'matriculation_number': matriculationNumber,
      }),
    );

    if (response.statusCode == 200) {
      print('User created successfully');
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/get-all-users'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load Users');
    }
  }

  Future<void> deleteUser({required String matriculationNumber}) async {
    final url = Uri.parse('$baseUrl/delete-by-matriculation-number');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'matriculation_number': matriculationNumber}),
    );

    if (response.statusCode == 200) {
      print('User deleted successfully');
    } else {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }

  Future<void> updateUser({
    required String matriculationNumber,
    required String firstName,
    required String lastName,
    required String email,
    required String role,
    String? password, // Optional password parameter
  }) async {
    final url = Uri.parse('$baseUrl/update');

    // Build the body dynamically to include password only if provided
    final Map<String, dynamic> body = {
      'matriculation_number': matriculationNumber,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'role': role,
    };

    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      print('User updated successfully');
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

}