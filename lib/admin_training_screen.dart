import 'package:flutter/material.dart';
import 'package:event_calendar/services/training_service.dart';
import 'package:event_calendar/edit_training_screen.dart';
import 'package:event_calendar/create_training_screen.dart';
import 'package:intl/intl.dart';
import 'services/subscription_service.dart';
import 'dart:math';

class AdminTrainingsPage extends StatefulWidget {
  const AdminTrainingsPage({super.key});

  @override
  _AdminTrainingsPageState createState() => _AdminTrainingsPageState();
}

class _AdminTrainingsPageState extends State<AdminTrainingsPage> {
  final List<String> backgroundImages = [
    'assets/background-cards/image1.jpg',
    'assets/background-cards/image2.jpg',
    'assets/background-cards/image3.jpg',
    'assets/background-cards/image4.jpg',
    'assets/background-cards/image5.jpg',
    'assets/background-cards/image6.jpg',
    'assets/background-cards/image7.jpg',
    'assets/background-cards/image8.jpg',
    'assets/background-cards/image9.jpg',
    'assets/background-cards/image10.jpg',
  ];
  final trainingService = TrainingService();
  late Future<List<Map<String, dynamic>>> futureTrainings;
  final subscriptionService = SubscriptionService();

  // Track the index of the long-pressed card
  int? activeCardIndex;

  @override
  void initState() {
    super.initState();
    _loadTrainings();
  }

  // Fetch the latest trainings from the database
  void _loadTrainings() {
    setState(() {
      futureTrainings = trainingService.fetchTrainings().then((trainings) {
        // Assign a consistent background image based on the index
        for (int i = 0; i < trainings.length; i++) {
          trainings[i]['backgroundImage'] =
          backgroundImages[i % backgroundImages.length];
        }
        return trainings;
      });
    });
  }

  // Format the date to show only the date part
  String formatDate(String isoDateString) {
    DateTime dateTime = DateTime.parse(isoDateString);
    return DateFormat('yyyy-MM-dd').format(dateTime); // Format as 'YYYY-MM-DD'
  }

  String formatTime(String time) {
    final dateTime = DateFormat("HH:mm:ss").parse(time);
    return DateFormat("HH:mm").format(dateTime); // Format as 'HH:mm'
  }

  // Generate a random background image
  String getRandomImage() {
    final random = Random();
    return backgroundImages[random.nextInt(backgroundImages.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateTrainingPage()),
              );
              if (result != null && result) {
                _loadTrainings();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureTrainings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No trainings available'));
          } else {
            final trainings = snapshot.data!;
            return ListView.builder(
              itemCount: trainings.length,
              itemBuilder: (context, index) {
                final training = trainings[index];
                final backgroundImage = training['backgroundImage'];
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
                          child: Stack(
                            children: [
                              // Background Image
                              Image.asset(
                                backgroundImage,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                opacity: const AlwaysStoppedAnimation(.3),
                                height: 200, // Adjust height as needed
                              ),
                              // Overlay and Training Details
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Training Title
                                    Text(
                                      training['title'],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Training Description
                                    Text(
                                      training['description'],
                                      style: TextStyle(
                                          fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    // Dates and Times
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_month,
                                            size: 18, color: Colors.black),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${formatDate(training['start_date'])} - ${formatDate(training['end_date'])}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.alarm,
                                            size: 18, color: Colors.black),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${formatTime(training['start_time'])} - ${formatTime(training['end_time'])}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    // Maximum Students
                                    Row(
                                      children: [
                                        const Icon(Icons.people,
                                            size: 18, color: Colors.black),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Min | Max Students: ${training['min_enrolled_students']} | ${training['max_enrolled_students']}',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    FutureBuilder<int>(
                                      future: subscriptionService
                                          .fetchSubscribedStudentsCount(
                                          training['code']),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else if (snapshot.hasData) {
                                          return Row(
                                            children: [
                                              const Icon(Icons.people,
                                                  size: 18, color: Colors.blue),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${snapshot.data} students subscribed', // Display the count
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.blue),
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
                            ],
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
                                        builder: (context) => EditTrainingPage(
                                            training: training),
                                      ),
                                    );
                                    if (result != null && result) {
                                      _loadTrainings();
                                    }
                                  },
                                  child: Container(
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue, // Background color
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        topLeft: Radius.circular(
                                            12), // Rounded left corners
                                      ),
                                    ),
                                    child: const Center(
                                      child:
                                          Icon(Icons.edit, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              // Delete Button
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    try {
                                      await trainingService.deleteTraining(
                                        code: '${training['code']}',
                                      );
                                      print('Training deleted successfully!');
                                      _loadTrainings();
                                    } catch (error) {
                                      print('Error: $error');
                                    }
                                  },
                                  child: Container(
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: Colors.red, // Background color
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(12),
                                        topRight: Radius.circular(
                                            12), // Rounded right corners
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.delete,
                                          color: Colors.white),
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
              },
            );
          }
        },
      ),
    );
  }
}
