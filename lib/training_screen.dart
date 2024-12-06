import 'package:flutter/material.dart';
import 'package:event_calendar/services/training_service.dart';
import 'package:intl/intl.dart';
import 'services/subscription_service.dart';
import 'package:provider/provider.dart';
import 'package:event_calendar/providers/user_provider.dart';
import 'dart:math';

class AppointmentListPage extends StatefulWidget {
  const AppointmentListPage({super.key});

  @override
  _AppointmentListPageState createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
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
  final subscriptionService = SubscriptionService();
  late Future<List<Map<String, dynamic>>> futureTrainings;
  Map<String, bool> subscriptionStatus = {};
  Map<String, int> subscriptionCount = {};

  // Track the index of the long-pressed card
  int? activeCardIndex;

  // Variable to track max capacity reached
  Map<String, bool> maxCapacityReached = {};

  void _checkCapacity(Map<String, dynamic> training) async {
    final subscribedCount =
    await subscriptionService.fetchSubscribedStudentsCount(training['code']);
    final maxStudents = training['max_enrolled_students'];

    setState(() {
      maxCapacityReached[training['code']] = subscribedCount >= maxStudents;
      subscriptionCount[training['code']] = subscribedCount;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTrainings();
  }

  // Fetch the latest trainings from the database
  void _loadTrainings() {
    setState(() {
      futureTrainings = trainingService.fetchTrainings().then((trainings){
      _initializeSubscriptionStatus(trainings);
      for (int i = 0; i < trainings.length; i++) {
        trainings[i]['backgroundImage'] =
        backgroundImages[i % backgroundImages.length];
      }
      return trainings;
    });
    });
  }

  // Generate a random background image
  String getRandomImage() {
    final random = Random();
    return backgroundImages[random.nextInt(backgroundImages.length)];
  }

  // Initialize subscription status for all trainings
  void _initializeSubscriptionStatus(List<Map<String, dynamic>> trainings) async {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    final matriculationNumber = userProvider.user.matriculationNumber;

    for (var training in trainings) {
      final trainingCode = training['code'];
      try {
        final isSubscribed =
        await subscriptionService.checkSubscription(matriculationNumber, trainingCode);
        subscriptionCount[trainingCode] =
        await subscriptionService.fetchSubscribedStudentsCount(trainingCode);
        final maxStudents = training['max_enrolled_students'];
        final subscribersCount = subscriptionCount[trainingCode];
        setState(() {
          subscriptionStatus[trainingCode] = isSubscribed;
          maxCapacityReached[trainingCode] = subscribersCount! >= maxStudents;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking subscription for $trainingCode <-> $matriculationNumber: $e')),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainings'),
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
                final trainingCode = training['code'];
                final isSubscribed = subscriptionStatus[trainingCode] ?? false;
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
                                        style: const TextStyle(
                                            fontSize: 16),
                                      ),
                                      const SizedBox(height: 8),
                                      // Dates and Times
                                      Row(
                                        children: [
                                          Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.purple.shade200.withOpacity(0.2), // Transparent blue background
                                              border: Border.all(color: Colors.purple.shade200, width: 1.5), // Blue border
                                              borderRadius: BorderRadius.circular(12), // Rounded corners
                                            ),
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 10),
                                                Icon(Icons.calendar_month, size: 18, color: Colors.purple), // Blue icon
                                                const SizedBox(width: 5),
                                                Text(
                                                  training['start_date'] == training['end_date']
                                                      ? formatDate(training['start_date']) // Only show one date if they are the same
                                                      : '${formatDate(training['start_date'])} - ${formatDate(training['end_date'])}', // Show range if different
                                                  style: const TextStyle(fontSize: 14, color: Colors.purple), // Text style
                                                ),
                                                const SizedBox(width: 10),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.purple.shade200.withOpacity(0.2), // Transparent blue background
                                              border: Border.all(color: Colors.purple.shade200, width: 1.5), // Blue border
                                              borderRadius: BorderRadius.circular(12), // Rounded corners
                                            ),
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 10),
                                                Icon(Icons.alarm, size: 18, color: Colors.purple), // Blue icon
                                                const SizedBox(width: 5),
                                                Text(
                                                  '${formatTime(training['start_time'])} - ${formatTime(training['end_time'])}',
                                                  style: const TextStyle(fontSize: 14, color: Colors.purple), // Blue text
                                                ),
                                                const SizedBox(width: 10),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Maximum Students
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade200.withOpacity(0.2), // Transparent blue background
                                              border: Border.all(color: Colors.blue.shade200, width: 1.5), // Blue border
                                              borderRadius: BorderRadius.circular(12), // Rounded corners
                                            ),
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 10),
                                                Icon(Icons.people_alt, size: 18, color: Colors.blue), // Blue icon
                                                const SizedBox(width: 5),
                                                Text(
                                                  'Students: ${training['min_enrolled_students']} | ${training['max_enrolled_students']}',
                                                  style: TextStyle(fontSize: 14, color: Colors.blue), // Blue text
                                                ),
                                                const SizedBox(width: 10),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Row(
                                                  children: [
                                                    Container(
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        color: Colors.green.shade200.withOpacity(0.2), // Transparent blue background
                                                        border: Border.all(color: Colors.blue.shade200, width: 1.5), // Blue border
                                                        borderRadius: BorderRadius.circular(12), // Rounded corners
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(width: 8),
                                                          Icon(Icons.check_circle, size: 18, color: Colors.green), // Blue icon
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            'Enrolled: ${subscriptionCount[training['code']]}',
                                                            style: TextStyle(fontSize: 14, color: Colors.green), // Blue text
                                                          ),
                                                          const SizedBox(width: 8),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ],
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
                              Expanded(
                                child: GestureDetector(
                                  onTap: maxCapacityReached[training['code']] == true && !isSubscribed
                                      ? null : () async {
                                    var userProvider = Provider.of<UserProvider>(context, listen: false);
                                    final matriculationNumber = userProvider.user.matriculationNumber;

                                    try {
                                      if (isSubscribed) {
                                        await subscriptionService.unsubscribeFromTraining(
                                            matriculationNumber, trainingCode);
                                        setState(() {
                                          subscriptionStatus[trainingCode] = false;
                                        });
                                        _checkCapacity(training);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Unsubscribed from $trainingCode-${training['title']}')),
                                        );
                                      } else {
                                        await subscriptionService.subscribeToTraining(
                                            matriculationNumber, trainingCode);
                                        setState(() {
                                          subscriptionStatus[trainingCode] = true;
                                        });
                                        _checkCapacity(training);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Subscribed to $trainingCode-$trainingCode-${training['title']}')),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: maxCapacityReached[training['code']] == true && !isSubscribed
                                          ? Colors.grey.shade200.withOpacity(0.2) // Greyed out only if full and not subscribed
                                          : (isSubscribed ? Colors.red.shade200.withOpacity(0.2) : Colors.green.shade200.withOpacity(0.2)),
                                      border: Border.all(
                                        color: maxCapacityReached[training['code']] == true && !isSubscribed
                                            ? Colors.grey // Greyed out only if full and not subscribed
                                            : (isSubscribed ? Colors.red : Colors.green), // Blue border color
                                        width: 2.0, // Border thickness
                                      ),// Background color
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                        bottomRight: Radius.circular(12),// Rounded left corners
                                      ),
                                    ),
                                    child: Center(
                                      child:
                                      Icon( maxCapacityReached[training['code']] == true && !isSubscribed
                                          ? Icons.disabled_by_default
                                          : (isSubscribed ? Icons.delete_forever : Icons.add_box ) , color: maxCapacityReached[training['code']] == true && !isSubscribed
                                          ? Colors.grey // Greyed out only if full and not subscribed
                                          : (isSubscribed ? Colors.red : Colors.green),),
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
