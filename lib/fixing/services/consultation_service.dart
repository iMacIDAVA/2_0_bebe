

import 'dart:convert';
import 'package:http/http.dart' as http;

class ConsultationService {
  String _baseUrl = 'http://10.0.2.2:8000/api';

  // Request a new consultation
  Future<Map<String, dynamic>> requestConsultation({
    required int patientId,
    required int doctorId,
    required String sessionType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/consultation/request/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'patient_id': patientId,
          'doctor_id': doctorId,
          'session_type': sessionType,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to request consultation');
      }
    } catch (e) {
      throw Exception('Error requesting consultation: $e');
    }
  }

  // Get current consultation for patient
  Future<Map<String, dynamic>> getCurrentConsultation(int patientId) async {
    try {
      final response = await http.get(
        // Uri.parse('$_baseUrl/consultation/current/$patientId/'),
        Uri.parse('${_baseUrl}/consultation/current/patient/1/'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Faixxxled to load consultation ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading consultation: $e');
    }
  }

  // Update consultation status
  Future<void> updateConsultationStatus(int consultationId, String status) async {
    try {
      String endpoint;
      switch (status) {
        case 'payment_pending':
          endpoint = '$_baseUrl/consultation/$consultationId/paymentPending/';
          break;
        case 'payment_completed':
          endpoint = '$_baseUrl/consultation/$consultationId/paymentCompleted/';
          break;
        case 'reject':
          endpoint = '$_baseUrl/consultation/$consultationId/reject/';
          break;
        case 'form_pending':
          endpoint = '$_baseUrl/consultation/$consultationId/formPending/';
          break;

        default:
          print('defalt $status');
          throw Exception('Invalid status: $status');
      }


      final response = await http.put(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
      );
      print("888888888888888");
      print(response.body);


      if (response.statusCode != 200) {
        print(response.body);
        throw Exception('Failed to update consultation status , ${response.body}');
      }

    } catch (e) {
      throw Exception('Error updating consultation status: $e ');
    }
  }

  // Submit medical questionnaire
  Future<Map<String, dynamic>> submitQuestionnaire(
      int consultationId,
      Map<String, dynamic> formData,
      ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/consultation/$consultationId/form/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(formData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to submit questionnaire');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get consultation history
  Future<List<Map<String, dynamic>>> getConsultationHistory(int patientId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/consultation/history/$patientId/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load consultation history');
      }
    } catch (e) {
      throw Exception('Error loading consultation history: $e');
    }
  }
}