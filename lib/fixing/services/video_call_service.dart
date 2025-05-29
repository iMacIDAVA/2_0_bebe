// lib/services/video_call_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sos_bebe_app/fixing/screens/api_config.dart';

class VideoCallService {
  final String baseUrl  = ApiConfig.baseUrl;

  // End the video call
  Future<Map<String, dynamic>> endCall(int sessionId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/consultation/$sessionId/callEnded/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to end call');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get call status
  Future<Map<String, dynamic>> getCallStatus(int sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/consultation/$sessionId/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get call status');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Start the video call
  Future<Map<String, dynamic>> startCall(int sessionId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/consultation/$sessionId/callStarted/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to start call');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get call ready status
  Future<Map<String, dynamic>> getCallReady(int sessionId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/consultation/$sessionId/callReady/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get call ready');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}