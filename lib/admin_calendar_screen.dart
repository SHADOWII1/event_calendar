import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:event_calendar/services/training_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:event_calendar/providers/user_provider.dart';
import 'services/subscription_service.dart';
import 'dart:math';


class AdminCalendarViewPage extends StatefulWidget {
  const AdminCalendarViewPage({super.key});

  @override
  _AdminCalendarViewPageState createState() => _AdminCalendarViewPageState();
}

class _AdminCalendarViewPageState extends State<AdminCalendarViewPage> {
  final trainingService = TrainingService();
  late List<Map<String, dynamic>> filteredTrainings;
  late Future<List<Map<String, dynamic>>> allTrainings;
  final Map<DateTime, List<Map<String, dynamic>>> _trainings = {};
  Map<DateTime, List<Map<String, dynamic>>> _trainingsCounter = {};
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  final subscriptionService = SubscriptionService();

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

  int _currentPageIndex = 0;
  late CarouselSliderController _carouselController;

  void _loadTrainings() {
    allTrainings = trainingService.fetchTrainings();

    allTrainings.then((trainings) {
      final Map<DateTime, List<Map<String, dynamic>>> counterMap = {};

      for (var training in trainings) {
        final startDate = _normalizeDate(DateTime.parse(training['start_date']));
        final endDate = _normalizeDate(DateTime.parse(training['end_date']));
        DateTime currentDate = startDate;

        // Iterate through the range and add the training to each date
        while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
          if (counterMap[currentDate] == null) {
            counterMap[currentDate] = [];
          }
          counterMap[currentDate]!.add(training);

          currentDate = currentDate.add(const Duration(days: 1)); // Move to the next day
        }
      }

      setState(() {
        _trainingsCounter = counterMap;
      });
    }).catchError((error) {
      print("Error loading trainings: $error");
    });
  }

  // Generate a random background image
  String getRandomImage() {
    final random = Random();
    return backgroundImages[random.nextInt(backgroundImages.length)];
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Format the date to show only the date part
  String formatDate(String isoDateString) {
    DateTime dateTime = DateTime.parse(isoDateString);
    return DateFormat('yyyy-MM-dd').format(dateTime); // Format as 'YYYY-MM-DD'
  }

  void _filterTrainings(DateTime selectedDay) {
    setState(() {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      String matriculationNumber = userProvider.user.matriculationNumber;

      _selectedDay = selectedDay;
      allTrainings = trainingService.fetchTrainings().then((trainings) {
        return trainings.where((training) {
          DateTime trainingDateStart = DateTime.parse(training['start_date']);
          DateTime trainingDateEnd = DateTime.parse(training['end_date']);
          // Assign a consistent background image based on the index
          for (int i = 0; i < trainings.length; i++) {
            trainings[i]['backgroundImage'] =
            backgroundImages[i % backgroundImages.length];
          }
          bool isWithinRange = (selectedDay.isAfter(
              trainingDateStart.subtract(const Duration(days: 1)))) &&
              (selectedDay.isAtSameMomentAs(trainingDateEnd) ||
                  selectedDay.isBefore(trainingDateEnd));

// Add the training to the corresponding date if it's within the range
          if (isWithinRange) {
            if (_trainings[trainingDateStart] == null) {
              _trainings[trainingDateStart] = [];
            }
            _trainings[trainingDateStart]!
                .add(training); // Add training to the corresponding date
          }
          return isWithinRange; // Return true if the selected day is within the training period
        }).toList();
      });
    });
  }

  void _showTrainingDetails(BuildContext context, Map<String, dynamic> training) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                        fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  // Dates and Times
                  Text(
                    'Start Date: ${formatDate(training['start_date'])}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Time: ${training['start_time']} - ${training['end_time']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<int>(
                    future: subscriptionService.fetchSubscribedStudentsCount(training['code']),
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
                              '${snapshot.data} students subscribed', // Display the count
                              style: const TextStyle(fontSize: 14, color: Colors.blue),
                            ),
                          ],
                        );
                      }
                      return const Text('No data available');
                    },
                  ),
                  // Maximum Students
                  Row(
                    children: [
                      const Icon(Icons.people,
                          size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Min | Max Students: ${training['min_enrolled_students']} | ${training['max_enrolled_students']}',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _carouselController = CarouselSliderController();
    _loadTrainings();
    _filterTrainings(_selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Training Calendar')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _filterTrainings(selectedDay);
              });
            },
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              leftChevronIcon: Icon(Icons.arrow_back_ios, color: Colors.blue),
              rightChevronIcon: Icon(Icons.arrow_forward_ios, color: Colors.blue),
            ),
            calendarStyle: const CalendarStyle(
              todayTextStyle: TextStyle(color: Colors.white),
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final dateWithoutTime =
                DateTime(date.year, date.month, date.day);
                // Check if there are trainings for this day
                if (_trainingsCounter[dateWithoutTime] != null &&
                    _trainingsCounter[dateWithoutTime]!.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        '${_trainingsCounter[dateWithoutTime]!.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: allTrainings,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data!.isNotEmpty) {
                final trainings = snapshot.data!;
                return Expanded(
                  child: CarouselSlider.builder(
                    itemCount: trainings.length,
                    options: CarouselOptions(
                      height: double.infinity,
                      enableInfiniteScroll: false,
                      viewportFraction: 0.55,
                      enlargeCenterPage: true,
                      enlargeFactor: 0.3,
                      enlargeStrategy: CenterPageEnlargeStrategy.height,
                      scrollDirection: Axis.vertical,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentPageIndex = index;
                        });
                      },
                    ),
                    carouselController: _carouselController,
                    itemBuilder: (context, index, realIndex) {
                      final training = trainings[index];
                      final isActive = index == _currentPageIndex;
                      final backgroundImage = training['backgroundImage'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: isActive ? 300 : 200,
                          child: Card(
                            elevation: isActive ? 10 : 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                _showTrainingDetails(context, training);
                              },
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
                                  Container(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          training['title'],
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                            'Start Date: ${formatDate(training['start_date'])}'),
                                        Text('End Date: ${formatDate(training['end_date'])}'),
                                        const SizedBox(height: 20),
                                        Text(
                                            'Time: ${training['start_time'].substring(0,5)} - ${training['end_time'].substring(0,5)}'),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 100),
                      Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text('No Training Available Today.'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          // Only render the PageViewDotIndicator when the data is available
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: allTrainings, // Your Future variable
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show loading indicator while waiting
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}'); // Handle errors
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink(); // No data case
                } else {
                  // Data is available, build the PageViewDotIndicator
                  return PageViewDotIndicator(
                    currentItem: _currentPageIndex,
                    count: snapshot.data!.length,
                    unselectedColor: Colors.black26,
                    selectedColor: Colors.blue,
                    duration: const Duration(milliseconds: 300),
                    boxShape: BoxShape.rectangle,
                    size: const Size(20, 5),
                    unselectedSize: const Size(5, 5),
                    borderRadius: BorderRadius.circular(5),
                    onItemClicked: (index) {
                      _carouselController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
