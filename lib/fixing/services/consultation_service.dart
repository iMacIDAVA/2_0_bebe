

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sos_bebe_app/fixing/screens/api_config.dart';

class ConsultationService {
  String _baseUrl = ApiConfig.baseUrl;

  // Request a new consultation
  Future<Map<String, dynamic>> requestConsultation({
    required int patientId,
    required int doctorId,
    required String sessionType,
  }) async
  {
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
  Future<Map<String, dynamic>> getCurrentConsultation({required int patientId}) async {
    try {
      final response = await http.get(
        // Uri.parse('$_baseUrl/consultation/current/$patientId/'),
        Uri.parse('${_baseUrl}/consultation/current/patient/${patientId}/'),
      );

      print('${_baseUrl}/consultation/current/patient/${patientId}/') ;
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Faixxxled to load consultation ${response.body}');
        throw Exception('Faixxxled to load consultation ${response.body}');
      }
    } catch (e) {
      print('Error loading consultation: $e') ;
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

          case 'callEnded':
          endpoint = '$_baseUrl/consultation/$consultationId/callEnded/';
          break;

          case 'FormSubmitted':
            return;
          break;


        default:
          print('defalt $status');
          throw Exception('Invalid statusxxxx: $status');
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

  // // Submit medical questionnaire
  // Future<Map<String, dynamic>> submitQuestionnaire(
  //     int consultationId,
  //     Map<String, dynamic> formData,
  //     ) async
  // {
  //   try {
  //     final response = await http.put(
  //       Uri.parse('$_baseUrl/consultation/$consultationId/form/'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode(formData),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return json.decode(response.body);
  //     } else {
  //       throw Exception('Failed to submit questionnaire');
  //     }
  //   } catch (e) {
  //     throw Exception('Error: $e');
  //   }
  // }

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

  // Submit questionnaire and link it to consultation
  Future<Map<String, dynamic>> submitQuestionnaire(
      int sessionId,
      Map<String, dynamic> questionnaireData,
      ) async {
    //print("<>");
    // print("response.body");
    // return {};
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/consultation/$sessionId/create-questionnaire/'),
        headers: {'Content-Type': 'application/json',},
        body: json.encode(questionnaireData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to submit questionnaire');
      }
    } catch (e) {
      throw Exception('Errdddor: $e');
    }
  }


}