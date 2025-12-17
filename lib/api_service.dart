// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'main.dart' show currentUserId;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  // ------------- CREATE & LIST REQUESTS ------------ //

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
        'created_by': currentUserId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
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
      print('nearbyRequests error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load nearby requests');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  // ------------- ACCEPT / HELPING LIST ------------ //

  static Future<void> acceptRequest(int id, String helperId) async {
    final url =
    Uri.parse('$baseUrl/api/requests/$id/accept?helper_id=$helperId');
    final response = await http.post(url);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to accept request');
    }
  }

  static Future<List<Map<String, dynamic>>> getHelpingRequests(
      String helperId,
      ) async {
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

  /// For requester side: return newest active+accepted request, or null.
  static Future<Map<String, dynamic>?> getLatestAccepted(
      String userId,
      ) async {
    final url = Uri.parse('$baseUrl/api/my-requests?created_by=$userId');
    final response = await http.get(url);

    print('getLatestAccepted($userId) status=${response.statusCode}');
    print('body=${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to load my requests');
    }

    final List<dynamic> data = jsonDecode(response.body);
    if (data.isEmpty) return null;

    // pick newest accepted & active request
    for (var i = data.length - 1; i >= 0; i--) {
      final m = data[i] as Map<String, dynamic>;
      if (m['status'] == 'accepted' && (m['is_active'] ?? true) == true) {
        return m;
      }
    }

    // if none active+accepted, return null
    return null;
  }

  // ------------- CHAT ------------ //

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
      body: jsonEncode({'message': text}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to send message');
    }
  }

  static Future<List<Map<String, dynamic>>> getMessages(
      int requestId,
      ) async {
    final url = Uri.parse('$baseUrl/api/requests/$requestId/messages');

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load messages');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  // ------------- ALARM & DISCONNECT ------------ //

  static Future<void> setAlarm(int requestId, bool on) async {
    final url = Uri.parse('$baseUrl/api/requests/$requestId/alarm');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'on': on}),
    );
    print('setAlarm status: ${response.statusCode} body: ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update alarm');
    }
  }

  static Future<void> disconnectRequest(int requestId) async {
    final url = Uri.parse('$baseUrl/api/requests/$requestId/disconnect');
    final response = await http.post(url);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to disconnect request');
    }
  }
}
