import 'package:flutter/material.dart';
import 'package:event_calendar/services/user_service.dart';
import 'package:event_calendar/create_user_screen.dart';
import 'package:event_calendar/edit_user_screen.dart';
import 'package:intl/intl.dart';
import 'services/subscription_service.dart';
import 'dart:math';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final userService = UserService();
  late Future<List<Map<String, dynamic>>> futureUsers;
  final subscriptionService = SubscriptionService();
  final List<String> ProfilPictures = [
    'assets/profile_picture_placeholder.jpg',
    'assets/profile_picture_placeholder_1.jpg',
    'assets/profile_picture_placeholder_2.jpg',
    'assets/profile_picture_placeholder_3.jpg',
  ];

  String getRandomImage() {
    final random = Random();
    return ProfilPictures[random.nextInt(ProfilPictures.length)];
  }

  int? activeCardIndex;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      futureUsers = userService.fetchUsers().then((users) {
        final random = Random();
        for (var user in users) {
          user['profile_image'] = ProfilPictures[random.nextInt(ProfilPictures.length)];
        }
        return users;
      });
    });
  }

  String formatDate(String isoDateString) {
    DateTime dateTime = DateTime.parse(isoDateString);
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  Widget _buildUserCard(Map<String, dynamic> user, int index) {
    final profileImage = user['profile_image'];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onLongPress: () {
          setState(() {
            activeCardIndex = index;
          });
        },
        onTap: () {
          setState(() {
            activeCardIndex = null; // Deselect on tap
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image above the name (using Image.asset)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        profileImage,
                        width: double.infinity,  // Make the image fill the card width
                        height: 240,  // Set the desired height for the image
                        fit: BoxFit.cover,  // Ensure the image scales properly
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Name
                    Text(
                      '${user['first_name']} ${user['last_name']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Email
                    Text(
                      user['email'],
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 2),
                    // Creation Date
                    Text(
                      'Matriculation Number: ${user['matriculation_number']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Creation Date: ${formatDate(user['created_at'])}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    FutureBuilder<int>(
                      future: subscriptionService.fetchUserSubscriptionsCount(user['matriculation_number']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return Row(
                            children: [
                              const Icon(Icons.people, size: 18, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Subscriptions: ${snapshot.data} Trainings', // Display the count
                                style: const TextStyle(fontSize: 14, color: Colors.blue),
                              ),
                            ],
                          );
                        }
                        return const Text('No data available');
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (activeCardIndex == index)
              Row(
                children: [
                  // Edit Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditUserPage(
                                user: user),
                          ),
                        );
                        if (result != null && result) {
                          _loadUsers();
                        }
                      },
                      child: Container(
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            topLeft: Radius.circular(12),
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  // Delete Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          await userService.deleteUser(
                            matriculationNumber: '${user['matriculation_number']}',
                          );
                          print('User deleted successfully!');
                          _loadUsers();
                        } catch (error) {
                          print('Error: $error');
                        }
                      },
                      child: Container(
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildSection(String title, List<Map<String, dynamic>> users, bool isLecturers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 470,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Container(
                width: MediaQuery.of(context).size.width * 0.7, // 70% of the screen width
                margin: const EdgeInsets.symmetric(horizontal: 1),
                child: _buildUserCard(user, index + (isLecturers ? 0 : 1000)),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateUserPage()),
              );
              if (result != null && result) {
                _loadUsers();
              }
            },
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No User available'));
          } else {
            final users = snapshot.data!;
            final lecturers = users.where((user) => user['role'] == 'Lecturer').toList();
            final students = users.where((user) => user['role'] == 'Student').toList();

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildSection('Lecturers', lecturers, true),
                  _buildSection('Students', students, false),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
