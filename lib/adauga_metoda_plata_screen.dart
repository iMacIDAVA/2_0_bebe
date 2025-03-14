import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:sos_bebe_app/plata_esuata_screen.dart';
import 'package:sos_bebe_app/plata_succes_screen.dart';
import 'package:sos_bebe_app/utils/consts.dart';
import 'package:http/http.dart' as http;
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:sos_bebe_app/utils_api/api_config.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';

import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/vezi_toti_medicii_screen.dart';

import 'datefacturare/date_facturare_completare_rapida.dart';

class PaymentScreen extends StatefulWidget {
  final int tipServiciu;
  final ContClientMobile contClientMobile;
  final MedicMobile medicDetalii;
  final String pret;
  final String currency;
  final bool fromChatScreen;

  const PaymentScreen({
    super.key,
    required this.tipServiciu,
    required this.contClientMobile,
    required this.medicDetalii,
    required this.pret,
    required this.currency,
    required this.fromChatScreen,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  bool _isCardFieldInitialized = false;

  Key _cardFormKey = UniqueKey();

  bool _isProcessingPayment = false;

  CardFieldInputDetails? _cardDetails;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final cardKey = GlobalKey<FormState>();

  int remainingTime = 180;
  Timer? countdownTimer;

  ApiCallFunctions apiCallFunctions = ApiCallFunctions();

  List<MedicMobile> listaMedici = [];
  ContClientMobile? resGetCont;

  ValueNotifier<int> remainingTimeNotifier = ValueNotifier(180);

  Future<void> getContUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    if (user.isEmpty || userPassMD5.isEmpty) {
      throw Exception("Missing user credentials");
    }

    resGetCont = await apiCallFunctions.getContClient(
      pUser: user,
      pParola: userPassMD5,
      pDeviceToken: prefs.getString('oneSignalId') ?? "",
      pTipDispozitiv: Platform.isAndroid ? '1' : '2',
      pModelDispozitiv: await apiCallFunctions.getDeviceInfo(),
      pTokenVoip: '',
    );

    if (resGetCont == null) {
      throw Exception("Failed to fetch account data");
    }
  }

  Future<void> notificaDoctor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
    apiCallFunctions.anuntaMedicDeServiciuTerminat(
        pUser: user,
        pParola: userPassMD5,
        pIdMedic: widget.medicDetalii.id.toString(),
        tipPlata: widget.tipServiciu.toString());
  }

  Future<void> getListaMedici() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    listaMedici = await apiCallFunctions.getListaMedici(
      pUser: user,
      pParola: userPassMD5,
    ) ??
        [];
  }

  Future<void> fetchDataBeforeNavigation() async {
    try {
      // ✅ Fetch account details if not already loaded
      if (resGetCont == null) {
        await getContUser();
      }

      // ✅ Fetch list of doctors
      await getListaMedici();

      // ✅ Ensure at least 1 doctor is in the list
      while (listaMedici.isEmpty) {
        print("🔄 Waiting for doctors list...");
        await Future.delayed(const Duration(seconds: 1));
        await getListaMedici();
      }

    } catch (e) {
      print("❌ Error loading data before navigation: $e");
    }
  }


  void startTimer() {
    print("⏳ Timer started...");

    countdownTimer?.cancel(); // ✅ Ensure no duplicate timers

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        print("🛑 Timer stopped because the screen is no longer mounted.");
        timer.cancel();
        return;
      }

      if (remainingTimeNotifier.value > 0) {
        remainingTimeNotifier.value--;
      } else {
        print("⌛ Timer finished, navigating away...");
        timer.cancel();
        await sendExitNotificationToDoctor();
        await fetchDataBeforeNavigation();

        await notificaDoctor();

        if (mounted && resGetCont != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VeziTotiMediciiScreen(
                listaMedici: listaMedici,
                contClientMobile: resGetCont!,
              ),
            ),
          );
        }
      }
    });
  }





  Future<void> sendExitNotificationToDoctor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String pCheie = keyAppPacienti; // App key for patients
    int pIdMedic = widget.medicDetalii.id; // Doctor ID
    String pTip = widget.tipServiciu.toString();

    String patientId = prefs.getString(pref_keys.userId) ?? '';
    String patientNume = prefs.getString(pref_keys.userNume) ?? '';
    String patientPrenume = prefs.getString(pref_keys.userPrenume) ?? '';

    String pObservatii = '$patientId\$#\$$patientPrenume $patientNume';

    // Exit message
    String pMesaj = "Pacientul a părăsit sesiunea după 3 minute de inactivitate.";

    await apiCallFunctions.trimitePushPrinOneSignalCatreMedic(
      pCheie: pCheie,
      pIdMedic: pIdMedic,
      pTip: pTip,
      pMesaj: pMesaj,
      pObservatii: pObservatii,
    );

    print("📢 Exit notification sent to doctor!");
  }

  String? savedPaymentMethodId;
  String? savedCustomerId;

  bool _isCardFormVisible = false;


  @override
  void initState() {
    super.initState();
    Stripe.publishableKey = stripePublishableKey;
    Stripe.instance.applySettings();

    print("🔄 initState called");

    // 🛠 **Delay creation to avoid PlatformView errors**
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isCardFormVisible = true;
          _cardFormKey = UniqueKey();
          print("✅ CardFormField is being recreated with new key: $_cardFormKey");
        });
      }
    });

    startTimer();

    // double pretValue = double.tryParse(widget.pret) ?? 0.0;
    // print('InitState: pret value is $pretValue');

    // // Only navigate directly if the price is zero
    // if (pretValue <= 0.0) {
    //   print('InitState: pret is 0, navigating to success screen');
    //   _directSuccessNavigation();
    // } else {
    //   print('InitState: pret is greater than 0, waiting for payment completion');
    //   _checkForSavedPaymentDetails(); // Validate or wait for user to complete payment
    // }
  }

  @override
  void dispose() {
    print("🛑 dispose called - Cleaning up PaymentScreen");

    countdownTimer?.cancel();
    remainingTimeNotifier.dispose();

    // **Destroy Stripe's CardFormField completely**
    Stripe.instance.applySettings(); // Reset Stripe state
    _isCardFormVisible = false;
    _cardFormKey = UniqueKey(); // ❌ Remove this line, not needed

    print("🗑️ CardFormField fully disposed. New key will be generated on re-entry.");

    super.dispose();
  }




  Future<void> _directSuccessNavigation() async {
    print("🛑 Cleaning up before navigating to success screen...");

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) { // ✅ Always check if widget is still mounted before navigating
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlataRealizataCuSuccesScreen(
                tipServiciu: widget.tipServiciu,
                contClientMobile: widget.contClientMobile,
                medicDetalii: widget.medicDetalii,
                pret: widget.pret,
                skipQuestionnaire: widget.fromChatScreen,
              );
            },
          ),
        );
      }
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
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PlataEsuataScreen()), // Replace with your failure screen
        );

      }
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

    double pretValue = double.tryParse(widget.pret) ?? 0.0;

    if (pretValue == 0) {
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return PlataRealizataCuSuccesScreen(
              tipServiciu: widget.tipServiciu,
              contClientMobile: widget.contClientMobile,
              medicDetalii: widget.medicDetalii,
              pret: widget.pret,
              skipQuestionnaire: widget.fromChatScreen,
            );
          },
        ));
      });
      return;
    }

    final url = Uri.parse('https://sosbebe.crmonline.ro/api/OnlineShopAPI/ChargeCustomer');

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

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('paymentMethodId', paymentMethodId);
      await prefs.setString('customerId', customerId);

      String patientId = prefs.getString(pref_keys.userId) ?? '';
      String patientNume = prefs.getString(pref_keys.userNume) ?? '';
      String patientPrenume = prefs.getString(pref_keys.userPrenume) ?? '';

      String pObservatii = '$patientId\$#\$$patientPrenume $patientNume';

      String pCheie = keyAppPacienti;
      int pIdMedic = widget.medicDetalii.id;
      String pTip = widget.tipServiciu.toString();
      String pMesaj = 'Starea plății de la $patientPrenume $patientNume: plătit';

      await apiCallFunctions.trimitePushPrinOneSignalCatreMedic(
        pCheie: pCheie,
        pIdMedic: pIdMedic,
        pTip: pTip,
        pMesaj: pMesaj,
        pObservatii: pObservatii,
      );

      print("🛑 Cleaning up before navigating to success screen...");

      _directSuccessNavigation();
    } else {
      // showDialog(
      //   context: context,
      //   builder: (context) => AlertDialog(
      //     title: const Text('Plata a eșuat'),
      //     content: const Text('A apărut o eroare la procesarea plății dvs.'),
      //     actions: [
      //       TextButton(
      //         onPressed: () {
      //           Navigator.pop(context);
      //         },
      //         child: const Text('OK'),
      //       ),
      //     ],
      //   ),
      // );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PlataEsuataScreen()),
      );

      await Future.delayed(const Duration(seconds: 2));

      SharedPreferences prefs = await SharedPreferences.getInstance();

      String patientId = prefs.getString(pref_keys.userId) ?? '';
      String patientNume = prefs.getString(pref_keys.userNume) ?? '';
      String patientPrenume = prefs.getString(pref_keys.userPrenume) ?? '';

      String pObservatii = '$patientId\$#\$$patientPrenume $patientNume';

      String pCheie = keyAppPacienti;
      int pIdMedic = widget.medicDetalii.id;
      String pTip = widget.tipServiciu.toString();
      String pMesaj = 'Starea plății de la $patientPrenume $patientNume: a eșuat';

      await apiCallFunctions.trimitePushPrinOneSignalCatreMedic(
        pCheie: pCheie,
        pIdMedic: pIdMedic,
        pTip: pTip,
        pMesaj: pMesaj,
        pObservatii: pObservatii,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double pretValue = double.tryParse(widget.pret) ?? 0.0;

    print("🔄 build() called - Current _cardFormKey: $_cardFormKey");

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.close),
                color: Colors.black,
                onPressed: () async {
                  await sendExitNotificationToDoctor();

                  // ✅ Load required data before navigating
                  await fetchDataBeforeNavigation();

                  // ✅ Optional: Add a delay to ensure UI loads properly
                  await Future.delayed(const Duration(seconds: 2));

                  await notificaDoctor();

                  if (mounted && resGetCont != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VeziTotiMediciiScreen(
                          listaMedici: listaMedici,
                          contClientMobile: resGetCont!,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
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
                      ? const Text(
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
                            border: Border.all(color: Colors.green, width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 18.0),
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
                        )
                      : const Center(child: Text('Folosind metoda de plată salvată')),
                  const SizedBox(height: 160),
                  Padding(
                    padding: const EdgeInsets.only(left: 128.0, right: 128.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ValueListenableBuilder<int>(
                            valueListenable: remainingTimeNotifier,
                            builder: (context, remainingTime, _) {
                              return Text(
                                "${remainingTime ~/ 60}:${(remainingTime % 60).toString().padLeft(2, '0')}", // Format as MM:SS
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.timer,
                            color: Colors.red,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  savedPaymentMethodId != null || pretValue != 0.0
                      ? Padding(
                    padding: const EdgeInsets.only(left: 28.0, right: 28.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: MaterialButton(
                        onPressed: _isProcessingPayment ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            if (_cardDetails == null || !_cardDetails!.complete) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Completați detaliile cardului'),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _isProcessingPayment = true; // Disable button and show loader
                            });

                            try {
                              await createPaymentIntent(); // Process payment

                              // If successful, navigate to the success screen
                              _directSuccessNavigation();
                            } catch (e) {
                              // If payment fails, re-enable button
                              setState(() {
                                _isProcessingPayment = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Plata a eșuat: ${e.toString()}')),
                              );
                            }
                          }
                        },
                        color: Colors.green,
                        height: 50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _isProcessingPayment
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
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
      ),
    );
  }
}
