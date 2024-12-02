import 'dart:convert';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String role;
  final String createdAt;
  final String matriculationNumber;
  final String token;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.role,
    required this.createdAt,
    required this.matriculationNumber,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_user': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'role': role,
      'created_at': createdAt,
      'matriculation_number': matriculationNumber,
      'token' : token,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id_user'] != null ? map['id_user'] as String : '',
      firstName: map['first_name'] != null ? map['first_name'] as String : '',
      lastName: map['last_name'] != null ? map['last_name'] as String : '',
      email: map['email'] != null ? map['email'] as String : '',
      password: map['password'] != null ? map['password'] as String : '',
      role: map['role'] != null ? map['role'] as String : '',
      createdAt: map['created_at'] != null ? map['created_at'] as String : '',
      matriculationNumber: map['matriculation_number'] != null ? map['matriculation_number'] as String : '',
      token: map['token'] != null ? map['token'] as String : '',

    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}