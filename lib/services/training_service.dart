import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

final String baseUrl = '${getBaseUrl()}/api/training';

String getBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:3000'; // Use actual machine IP for web
  } else {
    return 'http://10.0.2.2:3000'; // For Android emulator
  }
}

class TrainingService {

  Future<void> createTraining({
    required String title,
    required String code,
    required String description,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime,
    required int maxEnrolledStudents,
    required int minEnrolledStudents,
  }) async {
    final url = Uri.parse('$baseUrl/add');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': title,
        'code': code,
        'description': description,
        'start_date': startDate,
        'end_date': endDate,
        'start_time': startTime,
        'end_time': endTime,
        'max_enrolled_students': maxEnrolledStudents,
        'min_enrolled_students': minEnrolledStudents,
      }),
    );

    if (response.statusCode == 200) {
      print('Training created successfully');
    } else {
      throw Exception('Failed to create training: ${response.body}');
    }
  }

  Future<void> deleteTraining({required String code}) async {
    final url = Uri.parse('$baseUrl/delete-by-code');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'code': code}),
    );

    if (response.statusCode == 200) {
      print('Training deleted successfully');
    } else {
      throw Exception('Failed to delete training: ${response.body}');
    }
  }

  Future<void> updateTraining({
    required String code,
    required String title,
    required String description,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime,
    required int maxEnrolledStudents,
    required int minEnrolledStudents,
  }) async {
    final url = Uri.parse('$baseUrl/update');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'code': code,
        'title': title,
        'description': description,
        'start_date': startDate,
        'end_date': endDate,
        'start_time': startTime,
        'end_time': endTime,
        'max_enrolled_students': maxEnrolledStudents,
        'min_enrolled_students': minEnrolledStudents,
      }),
    );

    if (response.statusCode == 200) {
      print('Training updated successfully');
    } else {
      throw Exception('Failed to update training: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTrainings() async {
    final response = await http.get(Uri.parse('$baseUrl/get-all-trainings'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load trainings');
    }
  }

}




