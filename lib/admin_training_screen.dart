import 'package:flutter/material.dart';
import 'package:event_calendar/services/training_service.dart';
import 'package:event_calendar/edit_training_screen.dart';
import 'package:event_calendar/create_training_screen.dart';
import 'package:intl/intl.dart';
import 'services/subscription_service.dart';
import 'dart:math';

List<Map<String, dynamic>> allTrainings = [];
int? activeCardIndex;
final subscriptionService = SubscriptionService();

// Format the date to show only the date part
String formatDate(String isoDateString) {
  DateTime dateTime = DateTime.parse(isoDateString);
  return DateFormat('yyyy-MM-dd').format(dateTime);
}

String formatTime(String time) {
  final dateTime = DateFormat("HH:mm:ss").parse(time);
  return DateFormat("HH:mm").format(dateTime);
}

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

  List<Map<String, dynamic>> filteredTrainings = [];
  String searchQuery = '';




  @override
  void initState() {
    super.initState();
    _loadTrainings();
  }

  void _loadTrainings() {
    setState(() {
      futureTrainings = trainingService.fetchTrainings().then((trainings) {
        allTrainings = trainings;
        filteredTrainings = allTrainings;
        for (int i = 0; i < allTrainings.length; i++) {
          allTrainings[i]['backgroundImage'] =
          backgroundImages[i % backgroundImages.length];
        }
        return allTrainings;
      });
    });
  }



  void _searchTrainings(String query) {
    setState(() {
      searchQuery = query;
      filteredTrainings = allTrainings
          .where((training) => training['title']
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.event),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateTrainingPage(),
                  ),
                );
                if (result != null && result) {
                  _loadTrainings();
                }
              },
            ),
            const SizedBox(width: 8), // Spacing between icon and search bar
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showSearch(
                    context: context,
                    delegate: TrainingSearchDelegate(
                      searchQuery: searchQuery,
                      onSearchChanged: _searchTrainings,
                      cardIndex: activeCardIndex,
                    ),
                  );
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white, // Adjust to fit your theme
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade400), // Optional border
                  ),
                  child: Row(
                    children: const [
                      SizedBox(width: 8),
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Search trainings...',
                        style: TextStyle(color: Colors.grey,fontSize: 16,),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
                                                          'Enrolled: ${snapshot.data}',
                                                          style: TextStyle(fontSize: 14, color: Colors.green), // Blue text
                                                        ),
                                                        const SizedBox(width: 8),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                            return const Text('No data available');
                                          },
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
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade200.withOpacity(0.2), // Blue with transparency
                                      border: Border.all(
                                        color: Colors.blue.shade200, // Blue border color
                                        width: 2.0, // Border thickness
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        topLeft: Radius.circular(12),
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.blue.shade200, // Same color as the border
                                      ),
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
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade200.withOpacity(0.2), // Blue with transparency
                                      border: Border.all(
                                        color: Colors.redAccent, // Blue border color
                                        width: 2.0, // Border thickness
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        bottomRight: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.red.shade200, // Same color as the border
                                      ),
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

class TrainingSearchDelegate extends SearchDelegate {
  final String searchQuery;
  final Function(String) onSearchChanged;
  int? cardIndex;

  TrainingSearchDelegate({
    required this.searchQuery,
    required this.onSearchChanged,
    required this.cardIndex,
  });

  @override
  String get searchFieldLabel => 'Search for trainings...';

  @override
  TextInputAction get textInputAction => TextInputAction.search;

  @override
  void showResults(BuildContext context) {
    // Delay the search update to prevent triggering during build
    Future.delayed(Duration(milliseconds: 100), () {
      onSearchChanged(query);
    });
    super.showResults(context);
  }

  @override
  @override
  Widget buildSuggestions(BuildContext context) {
    // Delay the search update to prevent triggering during build
    Future.delayed(Duration(milliseconds: 100), () {
      onSearchChanged(query); // Call the function that handles search filtering
    });

    // Show filtered results based on the query
    final filteredSuggestions = allTrainings
        .where((training) =>
        training['title'].toLowerCase().contains(query.toLowerCase()) || training['description'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    // If there are no suggestions, show a message saying no results found
    if (filteredSuggestions.isEmpty) {
      return const Center(
        child: Text('No Results Found', style: TextStyle(fontSize: 24)),
      );
    }

    // Otherwise, show the filtered trainings as suggestions
    return ListView.builder(
      itemCount: filteredSuggestions.length,
      itemBuilder: (context, index) {
        final training = filteredSuggestions[index];
        final backgroundImage = training['backgroundImage'];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
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
                                                  'Enrolled: ${snapshot.data}',
                                                  style: TextStyle(fontSize: 14, color: Colors.green), // Blue text
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return const Text('No data available');
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget buildResults(BuildContext context) {
    // Delay the search update to prevent triggering during build
    Future.delayed(Duration(milliseconds: 100), () {
      onSearchChanged(query);
    });
    // Show filtered results based on the query
    final filteredSuggestions = allTrainings
        .where((training) =>
        training['title'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    // If there are no suggestions, show a message saying no results found
    if (filteredSuggestions.isEmpty) {
      return const Center(
        child: Text('No Results Found', style: TextStyle(fontSize: 24)),
      );
    }

    // Otherwise, show the filtered trainings as suggestions
    return ListView.builder(
      itemCount: filteredSuggestions.length,
      itemBuilder: (context, index) {
        final training = filteredSuggestions[index];
        final backgroundImage = training['backgroundImage'];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
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
                                                  'Enrolled: ${snapshot.data}',
                                                  style: TextStyle(fontSize: 14, color: Colors.green), // Blue text
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return const Text('No data available');
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      // Action button to clear the search query
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          // Delay the update to avoid calling during the build process
          Future.delayed(Duration(milliseconds: 100), () {
            onSearchChanged(query);
          });
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);  // Close the search
      },
    );
  }
}
