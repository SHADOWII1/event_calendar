import 'package:event_calendar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:event_calendar/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'services/subscription_service.dart';
import 'services/auth_services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<int> _subscriptionsCountFuture;
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    _subscriptionsCountFuture = SubscriptionService().fetchUserSubscriptionsCount(user.matriculationNumber);
  }

  // Format the date to show only the date part
  String formatDate(String isoDateString) {
    DateTime dateTime = DateTime.parse(isoDateString);
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime); // Format as 'YYYY-MM-DD'
  }

  void signOutUser(BuildContext context) {
    authService.signOut(context);
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Placeholder
            const Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/profile_picture.png'), // Placeholder image
              ),
            ),
            const SizedBox(height: 20),

            // Full Name
            Center(
              child: Text(
                '${user.firstName} ${user.lastName}', // Retrieve first and last name
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Email Address
            Center(
              child: Text(
                user.email, // Retrieve email
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Role
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    user.role.toLowerCase() == 'admin' ? Icons.admin_panel_settings : Icons.person,
                    color: user.role.toLowerCase() == 'admin' ? Colors.blue : Colors.green,
                    size: 30,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    user.role, // Display the user's role
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: user.role.toLowerCase() == 'admin' ? Colors.blue : Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            // Matriculation Number
            Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: const Text('Matriculation Number'),
                subtitle: Text(user.matriculationNumber), // Retrieve matriculation number
                leading: const Icon(Icons.badge),
              ),
            ),
            // Account Created Date
            Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: const Text('Creation Date'),
                subtitle: Text(formatDate(user.createdAt)), // Retrieve account creation date
                leading: const Icon(Icons.calendar_month),
              ),
            ),
            // Display the number of subscriptions for the user
            FutureBuilder<int>(
              future: _subscriptionsCountFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: const Text('Trainings'),
                      subtitle: Text(snapshot.data.toString()),
                      leading: const Icon(Icons.event_available),
                    ),
                  );
                } else {
                  return const Center(child: Text('No subscriptions available.'));
                }
              },
            ),
            const SizedBox(height: 20),
            // Edit Profile Button
            Center(
              child: ElevatedButton(
                onPressed: () => signOutUser(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Log-Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
