import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<void> createRequest({
    required String description,
    required String urgency,
  }) async {
    final url = Uri.parse('$baseUrl/api/requests');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'description': description,
        'urgency': urgency,
        'created_by': 'user2', // or 'user1' in that build
      }),
    );

    if (response.statusCode != 200) {
      print('createRequest error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to create request');
    }
  }

  static Future<List<Map<String, dynamic>>> getRequests() async {
    final url = Uri.parse('$baseUrl/api/requests');
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load requests');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> getMyRequests(String userId) async {
    final url = Uri.parse('$baseUrl/api/my-requests?created_by=$userId');
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load my requests');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> getNearbyRequests(
      String userId, {
        int limit = 10,
      }) async {
    final url = Uri.parse(
      '$baseUrl/api/nearby-requests?created_by=$userId&limit=$limit',
    );
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load nearby requests');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  static Future<void> acceptRequest(int id, String helperId) async {
    final url =
    Uri.parse('$baseUrl/api/requests/$id/accept?helper_id=$helperId');
    final response = await http.post(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to accept request');
    }
  }

  static Future<Map<String, dynamic>?> getLatestAccepted(String userId) async {
    final url = Uri.parse('$baseUrl/api/my-requests?created_by=$userId');
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load my requests');
    }
    final List<dynamic> data = jsonDecode(response.body);
    for (final r in data) {
      if (r['status'] == 'accepted' && r['helper_id'] != null) {
        return r as Map<String, dynamic>;
      }
    }
    return null;
  }

  static Future<void> sendMessage({
    required int requestId,
    required String senderId,
    required String text,
  }) async {
    final url = Uri.parse(
      '$baseUrl/api/requests/$requestId/messages?sender_id=$senderId',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send message');
    }
  }

  static Future<List<Map<String, dynamic>>> getMessages(int requestId) async {
    final url = Uri.parse('$baseUrl/api/requests/$requestId/messages');

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load messages');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> getHelpingRequests(
      String helperId) async {
    final url =
    Uri.parse('$baseUrl/api/helping-requests?helper_id=$helperId');

    final response = await http.get(url);
    if (response.statusCode != 200) {
      print('helpingRequests error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load helping requests');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

}
