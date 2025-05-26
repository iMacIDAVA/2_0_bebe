import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentService {
  static const String _baseUrl = 'https://api.sosbebe.com/api/v1';

  Future<void> initializePayment({
    required double amount,
    required int consultationId,
  }) async {
    try {
      // Create payment intent on the server
      final response = await http.post(
        Uri.parse('$_baseUrl/payment/create-intent/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': (amount * 100).round(), // Convert to cents
          'consultation_id': consultationId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Initialize Stripe with the client secret
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: data['client_secret'],
            merchantDisplayName: 'SOS BEBE',
          ),
        );
      } else {
        throw Exception('Failed to create payment intent');
      }
    } catch (e) {
      throw Exception('Error initializing paymentssss: $e');
    }
  }

  Future<void> processPayment({
    required int consultationId,
    required double amount,
  }) async {
    try {
      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Confirm the payment on the server
      final response = await http.post(
        Uri.parse('$_baseUrl/payment/confirm/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'consultation_id': consultationId,
          'amount': amount,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to confirm payment');
      }
    } catch (e) {
      throw Exception('Error processing payment: $e');
    }
  }
}