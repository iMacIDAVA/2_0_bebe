import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:sos_bebe_app/plata_succes_screen.dart';
import 'package:sos_bebe_app/utils/stripe_service.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';

class HomePage extends StatefulWidget {
  final int tipServiciu;
  final ContClientMobile contClientMobile;
  final MedicMobile medicDetalii;
  final String pret;  // dynamically passed amount in string
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
              top: 46.0, bottom: 46.0, left: 23.0, right: 23.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Introduceti detele cardului',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nume pe card',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                        const BorderSide(color: Colors.red, width: 1),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduceți numele de pe card';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 280,
                  padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                ),
                const SizedBox(height: 160),
                Padding(
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

                          await _processPayment();
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: _nameController.text,
            ),
          ),
        ),
      );

      print('Payment method created: ${paymentMethod.id}');

      // Pass dynamic values to the Stripe service
      await StripeService.instance.makePayment(
        customerId: widget.contClientMobile.id.toString(), // Assuming ContClientMobile has an id field
        paymentMethodId: paymentMethod.id,
        amount: '100', // Pass the amount as a string
        currency: widget.currency,
        tipServiciu: widget.tipServiciu,
        medicDetalii: widget.medicDetalii,
      );

      // Navigate to success screen after payment is completed
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlataRealizataCuSuccesScreen(
            tipServiciu: widget.tipServiciu,
            contClientMobile: widget.contClientMobile,
            medicDetalii: widget.medicDetalii,
            pret: widget.pret,
          ),
        ),
      );
    } catch (e) {
      print('Error creating payment method: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plata a eșuat: $e'),
        ),
      );
    }
  }
}
