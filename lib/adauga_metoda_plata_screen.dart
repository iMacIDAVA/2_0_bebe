import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:sos_bebe_app/plata_succes_screen.dart';
import 'package:sos_bebe_app/utils/consts.dart';
import 'package:http/http.dart' as http;
import 'package:sos_bebe_app/utils_api/classes.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final int tipServiciu;
  final ContClientMobile contClientMobile;
  final MedicMobile medicDetalii;
  final String pret;
  final String currency;

  const HomePage({
    super.key,
    required this.tipServiciu,
    required this.contClientMobile,
    required this.medicDetalii,
    required this.pret,
    required this.currency,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CardFieldInputDetails? _cardDetails;
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final cardKey = GlobalKey<FormState>();

  String? savedPaymentMethodId;
  String? savedCustomerId;

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey = stripePublishableKey;
    Stripe.instance.applySettings();


    double pretValue = double.tryParse(widget.pret) ?? 0.0;
    print('InitState: pret value is $pretValue');


    if (pretValue == 0) {
      print('InitState: pret is 0, navigating to success screen');
      _directSuccessNavigation();
    } else {
      print('InitState: pret is not 0, checking for saved payment details');
      _checkForSavedPaymentDetails();
    }
  }

  Future<void> _directSuccessNavigation() async {

    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return PlataRealizataCuSuccesScreen(
            tipServiciu: widget.tipServiciu,
            contClientMobile: widget.contClientMobile,
            medicDetalii: widget.medicDetalii,
            pret: widget.pret,
          );
        },
      ));
    });
  }

  Future<void> _checkForSavedPaymentDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedPaymentMethodId = prefs.getString('paymentMethodId');
    savedCustomerId = prefs.getString('customerId');

    if (savedPaymentMethodId != null && savedCustomerId != null) {

      _useSavedPaymentMethod(savedPaymentMethodId!, savedCustomerId!);
    }

    setState(() {});
  }

  Future<void> _useSavedPaymentMethod(String paymentMethodId, String customerId) async {
    processPayment(paymentMethodId, customerId);
  }

  int _calculateAmount(String amount) {
    try {
      double parsedAmount = double.parse(amount);
      final calculatedAmount = (parsedAmount * 100).toInt();
      return calculatedAmount;
    } catch (e) {
      return 0;
    }
  }

  Future<String> createCustomer() async {
    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/customers'),
      headers: {
        'Authorization': 'Bearer $stripeSecretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'description': 'Customer for test payment',
        'metadata[user_id]': widget.contClientMobile.id.toString(),
      },
    );

    if (response.statusCode == 200) {
      final customerData = jsonDecode(response.body);
      return customerData['id'];
    } else {
      throw Exception('Customer creation failed');
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

      final calculatedAmount = _calculateAmount(widget.pret);

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
        processPayment(paymentMethodId, customerId);
      } else {}
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eroare'),
          content: const Text('Nu s-a putut crea intenția de plată'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
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

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to attach PaymentMethod');
    }
  }

  Future<void> processPayment(String paymentMethodId, String customerId) async {
    final calculatedAmount = _calculateAmount(widget.pret);

    // Convert widget.pret to double and compare
    double pretValue = double.tryParse(widget.pret) ?? 0.0;
    print('processPayment: pret value is $pretValue');
    print('processPayment: calculatedAmount value is $calculatedAmount');


    if (pretValue == 0) {
      print('processPayment: pret is 0, navigating to success screen');
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return PlataRealizataCuSuccesScreen(
              tipServiciu: widget.tipServiciu,
              contClientMobile: widget.contClientMobile,
              medicDetalii: widget.medicDetalii,
              pret: widget.pret,
            );
          },
        ));
      });
      return;
    }


    print('processPayment: pret is not 0, proceeding with payment process');
    final url = Uri.parse('https://sosbebe.crmonline.ro/api/OnlineShopAPI/ChargeCustomer');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'CustomerId': customerId,
          'PaymentMethodId': paymentMethodId,
          'Amount': calculatedAmount.toString(),
          'Currency': 'RON',
        }),
      );

      print('processPayment: response status is ${response.statusCode}');


      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('paymentMethodId', paymentMethodId);
        await prefs.setString('customerId', customerId);

        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return PlataRealizataCuSuccesScreen(
                tipServiciu: widget.tipServiciu,
                contClientMobile: widget.contClientMobile,
                medicDetalii: widget.medicDetalii,
                pret: widget.pret,
              );
            },
          ));
        });
      } else {
        print('processPayment: payment failed, showing error dialog');

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Plata a eșuat'),
            content: const Text('A apărut o eroare la procesarea plății dvs.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('processPayment: error occurred $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double pretValue = double.tryParse(widget.pret) ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 46.0, bottom: 46.0, left: 23.0, right: 23.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                savedPaymentMethodId != null || pretValue != 0.0
                    ? Text(
                        'Introduceti detele cardului',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      )
                    : const SizedBox(height: 20),
                const SizedBox(height: 20),
                // Container(
                //   child: TextFormField(
                //     controller: _nameController,
                //     decoration: InputDecoration(
                //       labelText: 'Nume pe card',
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(8),
                //         borderSide:
                //         const BorderSide(color: Colors.red, width: 1),
                //       ),
                //     ),
                //     validator: (value) {
                //       if (value == null || value.isEmpty) {
                //         return 'Introduceți numele de pe card';
                //       }
                //       return null;
                //     },
                //   ),
                // ),
                const SizedBox(height: 20),
                savedPaymentMethodId != null || pretValue != 0.0
                    ? Container(
                        height: 280,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 18.0),
                          child: CardFormField(
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
                      )
                    : const Center(child: Text('Folosind metoda de plată salvată')),
                const SizedBox(height: 160),
                savedPaymentMethodId != null || pretValue != 0.0
                    ? Padding(
                        padding: const EdgeInsets.only(left: 28.0, right: 28.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: MaterialButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (_cardDetails == null || !_cardDetails!.complete) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Completați detaliile cardului'),
                                    ),
                                  );
                                  return;
                                }

                                createPaymentIntent();
                              }
                            },
                            color: Colors.green,
                            height: 50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "CONFIRMĂ PLATA",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
