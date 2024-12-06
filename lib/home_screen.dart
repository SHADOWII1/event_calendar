import 'package:flutter/material.dart';
import 'admin_training_screen.dart';
import 'training_screen.dart';
import 'calendar_screen.dart';
import 'admin_calendar_screen.dart';
import 'user_screen.dart';
import 'profile_screen.dart';

class HomePage extends StatefulWidget {
  final bool isAdmin;

  const HomePage({super.key, required this.isAdmin});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Keeps track of selected tab

  // List of pages based on user role
  List<Widget> get _pages {
    if (widget.isAdmin) {
      return [
        const AdminTrainingsPage(),  // Admin-specific appointments page
        const UsersPage(),
        const AdminCalendarViewPage(),
        const ProfilePage(),
      ];
    } else {
      return [
        const AppointmentListPage(), // Regular user appointments page
        const CalendarViewPage(),
        const ProfilePage(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],  // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;  // Update the selected tab index
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Training',
          ),
          if (widget.isAdmin)
            const BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Users',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}







