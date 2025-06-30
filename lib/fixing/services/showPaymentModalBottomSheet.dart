import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../datefacturare/date_facturare_completare_rapida.dart';
import '../../utils/consts.dart';
import '../../utils_api/shared_pref_keys.dart' as pref_keys;
import '../services/consultation_service.dart';

void showPaymentModalBottomSheet({
  required BuildContext context,
  required double amount,
  // required int currentConsultation,
  required VoidCallback onSuccess, // Added callback for success
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (context) => _PaymentModalContent(
      amount: amount,
     // currentConsultation: currentConsultation,
      onSuccess: onSuccess,
    ),
  );
}

class _PaymentModalContent extends StatefulWidget {
  final double amount;
 // final int currentConsultation;
  final VoidCallback onSuccess;

  const _PaymentModalContent({
    required this.amount,
   // required this.currentConsultation,
    required this.onSuccess,
  });

  @override
  __PaymentModalContentState createState() => __PaymentModalContentState();
}

class __PaymentModalContentState extends State<_PaymentModalContent> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessingPayment = false;
  String? _error;
  String? _successMessage;
  CardFieldInputDetails? _cardDetails;
  bool _isCardFormVisible = false;
  Key _cardFormKey = UniqueKey();
  final ConsultationService _consultationService = ConsultationService();

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey = stripePublishableKey;
    Stripe.instance.applySettings();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isCardFormVisible = true;
          _cardFormKey = UniqueKey();
        });
      }
    });
  }

  @override
  void dispose() {
    Stripe.instance.applySettings();
    _isCardFormVisible = false;
    _cardFormKey = UniqueKey();
    super.dispose();
  }

  Future<String> createCustomer() async {
    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/customers'),
      headers: {
        'Authorization': 'Bearer $stripeSecretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'description': 'Customer for consultation payment',
      },
    );

    if (response.statusCode == 200) {
      final customerData = jsonDecode(response.body);
      return customerData['id'];
    } else {
      throw Exception('Eroare la crearea clientului. Vă rugăm să încercați din nou.');
    }
  }

  Future<void> attachPaymentMethodToCustomer(String paymentMethodId, String customerId) async {
    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_methods/$paymentMethodId/attach'),
      headers: {
        'Authorization': 'Bearer $stripeSecretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'customer': customerId,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Eroare la asocierea metodei de plată.');
    }
  }

  Future<void> createPaymentIntent() async {
    try {
      final customerId = await createCustomer();

      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      final paymentMethodId = paymentMethod.id;

      await attachPaymentMethodToCustomer(paymentMethodId, customerId);

      final calculatedAmount = (widget.amount * 100).toInt();
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': calculatedAmount.toString(),
          'currency': 'RON',
          'customer': customerId,
          'payment_method': paymentMethodId,
          'confirm': 'true',
          'automatic_payment_methods[enabled]': 'true',
          'automatic_payment_methods[allow_redirects]': 'never',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'succeeded') {
          await processPayment(paymentMethodId, customerId);
          setState(() {
            _successMessage = 'Plata a fost procesată cu succes!';
            _isProcessingPayment = false;
          });
          widget.onSuccess(); // Trigger success callback
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context, true);
          });
        } else {
          throw Exception('Plata nu a fost finalizată. Vă rugăm să încercați din nou.');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error']?['message'] ?? 'Eroare la procesarea plății.');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<void> processPayment(String paymentMethodId, String customerId) async {
    try {
      final calculatedAmount = (widget.amount * 100).toInt();

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': calculatedAmount.toString(),
          'currency': 'RON',
          'customer': customerId,
          'payment_method': paymentMethodId,
          'confirm': 'true',
          'off_session': 'true',
          'confirmation_method': 'automatic',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] != 'succeeded') {
          throw Exception('Plata nu a fost finalizată.');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error']?['message'] ?? 'Eroare la procesarea plății.');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.black54,
                            size: 28,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Header with Amount
                    Container(
                      height: 100,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/images/f.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Plată Consultare',
                            style: GoogleFonts.rubik(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${widget.amount.toStringAsFixed(2)} RON',
                            style: GoogleFonts.rubik(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Card Form
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[50],
                      ),
                      child: Visibility(
                        visible: _isCardFormVisible,
                        child: CardFormField(
                          key: _cardFormKey,
                          onCardChanged: (cardDetails) {
                            setState(() {
                              _cardDetails = cardDetails;
                            });
                          },
                          style: CardFormStyle(
                            textColor: Colors.black87,
                            placeholderColor: Colors.black45,
                            backgroundColor: Colors.grey[100],
                            fontSize: 16,
                            textErrorColor: Colors.redAccent,
                            cursorColor: Colors.black,
                          ),
                          countryCode: 'RO',
                          enablePostalCode: false,
                          autofocus: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Success Message
                    if (_successMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _successMessage!,
                          style: GoogleFonts.rubik(
                            color: const Color(0xFF0EBE7F),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Error Message
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _error!,
                          style: GoogleFonts.rubik(
                            color: const Color(0xFFE53935),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (_error != null || _successMessage != null) const SizedBox(height: 16),

                    // Payment Button
                    ElevatedButton(
                      onPressed: _isProcessingPayment
                          ? null
                          : () async {
                        if (_formKey.currentState!.validate()) {
                          if (_cardDetails == null || !_cardDetails!.complete) {
                            setState(() {
                              _error = 'Vă rugăm să completați detaliile cardului.';
                              _successMessage = null;
                            });
                            return;
                          }

                          setState(() {
                            _isProcessingPayment = true;
                            _error = null;
                            _successMessage = null;
                          });

                          try {
                            await createPaymentIntent();
                          } catch (e) {
                            setState(() {
                              _error = e.toString().replaceFirst('Exception: ', '');
                              _isProcessingPayment = false;
                              _successMessage = null;
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0EBE7F),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isProcessingPayment
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        'Plăti ${widget.amount.toStringAsFixed(2)} RON',
                        style: GoogleFonts.rubik(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
