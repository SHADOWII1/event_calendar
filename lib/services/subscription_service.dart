import 'dart:convert';
import 'package:http/http.dart' as http;

class SubscriptionService {

  final String baseUrl = 'http://10.0.2.2:3000/api/subscription';

  Future<List<Map<String, dynamic>>> fetchSubscriptions(String matriculationNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get-subscriptions?matriculation_number=$matriculationNumber'), // Send matriculation number as query parameter
      );

      if (response.statusCode == 200) {
        // Parse the training data directly from the response body
        List<dynamic> responseData = json.decode(response.body);

        // Convert the list of dynamic data into a list of maps
        return List<Map<String, dynamic>>.from(responseData);
      } else {
        throw Exception('Failed to load subscriptions');
      }
    } catch (e) {
      throw Exception('Error fetching subscriptions: $e');
    }
  }

  // Subscribe a student to a training
  Future<void> subscribeToTraining(String matriculationNumber, String trainingCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/subscribe'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'matriculation_number': matriculationNumber,
          'training_code': trainingCode,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create subscription');
      }
    } catch (e) {
      throw Exception('Error subscribing to training: $e');
    }
  }

  // Unsubscribe a student from a training
  Future<void> unsubscribeFromTraining(String matriculationNumber, String trainingCode) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/unsubscribe'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'matriculation_number': matriculationNumber,
          'training_code': trainingCode,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to unsubscribe from training');
      }
    } catch (e) {
      throw Exception('Error unsubscribing from training: $e');
    }
  }

  Future<bool> checkSubscription(String matriculationNumber, String trainingCode) async {
    try {
      // Construct the URL with query parameters for the request
      final response = await http.get(
        Uri.parse('$baseUrl/check-subscription').replace(queryParameters: {
          'matriculation_number': matriculationNumber,
          'training_code': trainingCode,
        }),
      );
      Uri url = Uri.parse('$baseUrl/check-subscription').replace(queryParameters: {
        'matriculation_number': matriculationNumber,
        'training_code': trainingCode,
      });
      print('URI: ${url}');
      print('Parameter: ${matriculationNumber} ${trainingCode}');
      print('Response: ${response.statusCode} ${response.body}');
      // Handle successful response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['isSubscribed']; // Return true or false
      } else {
        throw Exception('Failed to check subscription status');
      }
    } catch (e) {
      throw Exception('Error checking subscription: $e');
    }
  }

  Future<int> fetchSubscribedStudentsCount(String trainingCode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscribed-students-count?training_code=$trainingCode'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['subscribedStudents'];
      } else {
        throw Exception('Failed to fetch subscribed students count');
      }
    } catch (e) {
      throw Exception('Error fetching subscribed students: $e');
    }
  }

  Future<int> fetchUserSubscriptionsCount(String matriculationNumber) async {
    try {
      final Uri url = Uri.parse('$baseUrl/student-subscriptions-count?matriculation_number=$matriculationNumber');
      final response = await http.get(url);

      // Check if the response was successful
      if (response.statusCode == 200) {
        // Decode the JSON response
        final Map<String, dynamic> data = json.decode(response.body);
        // Ensure the response contains the expected key
        if (data.containsKey('subscriptionsCount')) {
          return data['subscriptionsCount'];
        } else {
          throw Exception('Subscriptions count data is missing in the response');
        }
      } else {
        throw Exception('Failed to fetch user subscriptions count. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors, including network issues or JSON parsing problems
      throw Exception('Error fetching user subscriptions: $e');
    }
  }


}
