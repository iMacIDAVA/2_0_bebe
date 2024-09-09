import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:convert';
import '../utils_api/classes.dart';
import 'consts.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  // Accept dynamic parameters for amount, currency, customer, etc.
  Future<void> makePayment({
    required String customerId,
    required String paymentMethodId,
    required String amount,
    required String currency,
    required int tipServiciu,
    required MedicMobile medicDetalii,
  }) async {
    try {
      print("Starting payment process...");

      // Instead of creating a customer and payment method again, use the ones passed
      await _sendPaymentDetailsToBackend(
        customerId,
        paymentMethodId,
        amount,
        currency,
      );
    } catch (e) {
      print("Error during payment process: $e");
    }
  }

  Future<void> _sendPaymentDetailsToBackend(
      String customerId, String paymentMethodId, String amount, String currency) async {
    try {
      Map<String, dynamic> requestData = {
        "CustomerId": customerId,
        "PaymentMethodId": paymentMethodId,
        "Amount": _calculateAmount(amount), // Pass amount to calculate correctly
        "Currency": currency,
      };

      print("Sending payment details to backend: $requestData");

      var response = await http.post(
        Uri.parse("https://sosbebe.crmonline.ro/api/OnlineShopAPI/ChargeCustomer"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      print("Response status code from backend: ${response.statusCode}");
      print("Response body from backend: ${response.body}");

      if (response.statusCode == 200) {
        print("Payment successful!");
      } else {
        print('Failed to process payment: ${response.body}');
      }
    } catch (e) {
      print("Error sending payment details to backend: $e");
    }
  }

  // Updated to handle amount parsing
  String _calculateAmount(String amount) {
    try {
      // Parse the amount as a double first to handle decimal values
      double parsedAmount = double.parse(amount);

      // Multiply by 100 to get the amount in the smallest unit (cents)
      final calculatedAmount = (parsedAmount * 100).toInt();

      print("Calculated amount in cents: $calculatedAmount");
      return calculatedAmount.toString();
    } catch (e) {
      print("Error parsing amount: $e");
      return "0"; // Return 0 or handle error as appropriate
    }
  }
}
