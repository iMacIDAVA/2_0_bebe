import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/fixing/CountdownWrapper.dart';
import 'package:sos_bebe_app/intro_screen.dart';
import 'package:sos_bebe_app/utils/consts.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;
import '../../datefacturare/date_facturare_completare_rapida.dart';
import '../services/consultation_service.dart';



class PaymentScreen extends StatefulWidget {
  final double amount;
  final int currentConsultation ;
  final int doctorID ;


  const PaymentScreen({
    Key? key,
    required this.amount,
    required this.currentConsultation ,
    required this.doctorID

  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessingPayment = false;
  String? _error;
  CardFormEditController? _cardFormController;
  bool _isCardFormVisible = false;
  Key _cardFormKey = UniqueKey();
  CardFieldInputDetails? _cardDetails;
  final ConsultationService _consultationService = ConsultationService();

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey = stripePublishableKey;
    Stripe.instance.applySettings();

    // Delay creation to avoid PlatformView errors
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
      throw Exception('Customer creation failed');
    }
  }

  // Future<void> createPaymentIntent() async {
  //   try {
  //     final customerId = await createCustomer();
  //
  //     final paymentMethod = await Stripe.instance.createPaymentMethod(
  //       params: const PaymentMethodParams.card(
  //         paymentMethodData: PaymentMethodData(),
  //       ),
  //     );
  //
  //     final paymentMethodId = paymentMethod.id;
  //
  //     await attachPaymentMethodToCustomer(paymentMethodId, customerId);
  //
  //     final calculatedAmount = (widget.amount * 100).toInt();
  //
  //     final response = await http.post(
  //       Uri.parse('https://api.stripe.com/v1/payment_intents'),
  //       headers: {
  //         'Authorization': 'Bearer $stripeSecretKey',
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //       },
  //       body: {
  //         'amount': calculatedAmount.toString(),
  //         'currency': 'RON',
  //         'customer': customerId,
  //         'payment_method': paymentMethodId,
  //         'confirm': 'true',
  //         'automatic_payment_methods[enabled]': 'true',
  //         'automatic_payment_methods[allow_redirects]': 'never',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       await processPayment(paymentMethodId, customerId);
  //     } else {
  //       throw Exception('Failed to create payment intent');
  //     }
  //   } catch (e) {
  //     throw Exception('Error creating payment intent: $e');
  //   }
  // }

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
      throw Exception('Failed to attach PaymentMethod');
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
        } else {
          throw Exception('Payment intent not succeeded');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error']?['message'] ?? 'Failed to create payment intent');
      }
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
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
          'confirmation_method': 'automatic',        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'succeeded') {
          Navigator.pop(context, true); // Return success
        } else {
          throw Exception('Payment not succeeded');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error']?['message'] ?? 'Payment failed');
      }
    } catch (e) {
      throw Exception('Payment processing failed: $e');
    }
  }

  // Future<void> processPayment(String paymentMethodId, String customerId) async {
  //   final calculatedAmount = (widget.amount * 100).toInt();
  //
  //   final response = await http.post(
  //     Uri.parse('https://api.stripe.com/v1/payment_intents'),
  //     headers: {
  //       'Authorization': 'Bearer $stripeSecretKey',
  //       'Content-Type': 'application/x-www-form-urlencoded',
  //     },
  //     body: {
  //       'amount': calculatedAmount.toString(),
  //       'currency': 'RON',
  //       'customer': customerId,
  //       'payment_method': paymentMethodId,
  //       'confirm': 'true',
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     Navigator.pop(context, true); // Return success
  //   } else {
  //     throw Exception('Payment failed');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Plată',
          style: GoogleFonts.rubik(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF0EBE7F),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child:

          CountdownWrapper(
            onTimeout: () async {

              await _consultationService.updateConsultationStatus(
                widget.currentConsultation,
                'callEnded',
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const IntroScreen(),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Consultation Details
                // Container(
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(8),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black.withOpacity(0.1),
                //         blurRadius: 4,
                //         offset: const Offset(0, 2),
                //       ),
                //     ],
                //   ),
                //   padding: const EdgeInsets.all(16),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         'Detalii consultație',
                //         style: GoogleFonts.rubik(
                //           fontSize: 18,
                //           fontWeight: FontWeight.w500,
                //           color: const Color(0xFF0EBE7F),
                //         ),
                //       ),
                //       const SizedBox(height: 12),
                //
                //       const SizedBox(height: 8),
                //       Text(
                //         'sumă: \$${widget.amount.toStringAsFixed(2)}',
                //         style: GoogleFonts.rubik(
                //           fontSize: 16,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.black87,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
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
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Servicii Pediatrie',
                            style: GoogleFonts.rubik(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Adresati o întrebare medicului',
                            style: GoogleFonts.rubik(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${widget.amount.toStringAsFixed(2)} RON',
                        style: GoogleFonts.rubik(
                          fontSize: 20,
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
                  height: 280,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
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

                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: Color(0xFFE53935),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 16),

                // Payment Button
                ElevatedButton(
                  onPressed: _isProcessingPayment ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      if (_cardDetails == null || !_cardDetails!.complete) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please complete card details'),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _isProcessingPayment = true;
                        _error = null;
                      });

                      try {
                        await createPaymentIntent();

                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String user = prefs.getString('user') ?? '';
                        String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

                        await apiCallFunctions.anuntaMedicDeServiciuTerminat(
                          pUser: user,
                          pParola: userPassMD5,
                          pIdMedic: widget.doctorID.toString() ,//widget.doctorId.toString(),
                          tipPlata: "1",
                        );

                      } catch (e) {
                        setState(() {
                          _error = e.toString()+ "<<<<<";
                          print(_error);
                          _isProcessingPayment = false;
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0EBE7F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                    'Plătește ${widget.amount.toStringAsFixed(2)} RON',
                    style: GoogleFonts.rubik(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}