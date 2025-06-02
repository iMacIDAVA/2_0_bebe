import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:http/http.dart' as http;
import 'package:sos_bebe_app/utils_api/classes.dart';
import 'package:sos_bebe_app/utils_api/functions.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:sos_bebe_app/localizations/1_localizations.dart';
import 'package:sos_bebe_app/vezi_toti_medicii_screen.dart';

ApiCallFunctions apiCallFunctions = ApiCallFunctions();

class TestimonialScreenSimple extends StatefulWidget {
  final int idMedic;

  const TestimonialScreenSimple({super.key, required this.idMedic});

  @override
  State<TestimonialScreenSimple> createState() => _TestimonialScreenSimpleState();
}

class _TestimonialScreenSimpleState extends State<TestimonialScreenSimple> {
  final registerKey = GlobalKey<FormState>();
  bool testimonialAveaDate = false;

  double? _ratingValue = 1.0;
  bool feedbackCorect = false;
  bool showButonTrimiteTestimonial = true;

  ApiCallFunctions apiCallFunctions = ApiCallFunctions();

  List<MedicMobile> listaMedici = [];
  ContClientMobile? resGetCont;

  final controllerTestimonialText = TextEditingController();

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
      if (resGetCont == null) {
        await getContUser();
      }

      await getListaMedici();

      while (listaMedici.isEmpty) {
        await Future.delayed(const Duration(seconds: 1));
        await getListaMedici();
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    controllerTestimonialText.dispose();
    _isMounted = false;
    super.dispose();
  }

  Future<http.Response?> adaugaFeedbackDinContClient() async {
    LocalizationsApp l = LocalizationsApp.of(context)!;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String user = prefs.getString('user') ?? 'Test@t.com';
    // String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '123456789';

    String user =  'test@t.com';
    String userPassMD5 = '123456789';

    String textMessage = '';
    Color backgroundColor = Colors.red;
    Color textColor = Colors.black;

    print("📤 Sending feedback to server:");
    print("User: $user");
    print("Password (MD5): $userPassMD5");
    print("ID Medic: ${widget.idMedic}");
    print("Nota: $_ratingValue");
    print("Comentariu: ${controllerTestimonialText.text}");

    http.Response? resAdaugaFeedback = await apiCallFunctions.adaugaFeedbackDinContClient(
      pUser: user,
      pParola: userPassMD5,
      pIdMedic: widget.idMedic.toString(),
      pIdFactura: "0", // Using 0 as default since we don't have factura
      pNota: _ratingValue!.toString().split('.')[0],
      pComentariu: controllerTestimonialText.text,
    );
    print('Debug!');
    print(resAdaugaFeedback);



    if (!_isMounted) return null;

    print('adaugaFeedbackDinContClient resAdaugaCont.body ${resAdaugaFeedback!.body}');

    if (int.parse(resAdaugaFeedback.body) == 200) {
      if (_isMounted) {
        setState(() {
          feedbackCorect = true;
          showButonTrimiteTestimonial = false;
        });
      }

      await fetchDataBeforeNavigation();

      await Future.delayed(const Duration(seconds: 2));
      if (_isMounted) {
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

      textMessage = l.testimonialFeedbackTrimisCuSucces;
      backgroundColor = const Color.fromARGB(255, 14, 190, 127);
      textColor = Colors.white;
    } else if (int.parse(resAdaugaFeedback.body) == 400) {
      if (_isMounted) {
        setState(() {
          feedbackCorect = false;
          showButonTrimiteTestimonial = true;
        });
      }

      textMessage = l.testimonialApelInvalid;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resAdaugaFeedback.body) == 401) {
      if (_isMounted) {
        setState(() {
          feedbackCorect = false;
          showButonTrimiteTestimonial = true;
        });
      }

      textMessage = l.testimonialFeedbackNetrimis;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resAdaugaFeedback.body) == 405) {
      if (_isMounted) {
        setState(() {
          feedbackCorect = false;
          showButonTrimiteTestimonial = true;
        });
      }

      textMessage = l.testimonialInformatiiInsuficiente;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else {
      if (_isMounted) {
        setState(() {
          feedbackCorect = false;
          showButonTrimiteTestimonial = true;
        });
      }

      textMessage = l.testimonialAAparutOEroare;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    }

    if (context.mounted) {
      showSnackbar(context, textMessage ,  backgroundColor, textColor);
      return resAdaugaFeedback;
    }

    return null;
  }

  bool isSending = false;
  bool sentWithSucces = false;
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    return WillPopScope(
      onWillPop: () async => false,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.black,
                  onPressed: () async {
                    await fetchDataBeforeNavigation();
                    await Future.delayed(const Duration(seconds: 2));
                    if (_isMounted) {
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
                  },
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l.testimonialVaMultumim,
                        style: GoogleFonts.rubik(
                          color: const Color.fromRGBO(103, 114, 148, 1),
                          fontSize: 26,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Image.asset('./assets/images/testimonial_icon.png'),
                  const SizedBox(height: 110),
                  if (sentWithSucces)
                    Text(
                      "Trimis cu succes!",
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 26,
                      ),
                    ),
                  if (sentWithSucces)
                    const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () async {
                      await fetchDataBeforeNavigation();
                      await Future.delayed(const Duration(seconds: 2));
                      if (_isMounted) {
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
                    },
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(25, 0, 25, 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromRGBO(14, 190, 127, 1),
                      ),
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Întoarce-te la ecranul anterior",
                            style: GoogleFonts.rubik(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!sentWithSucces)
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                l.testimonialRating,
                                style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RatingBar(
                                initialRating: 0.0,
                                minRating: 1.0,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 40,
                                itemPadding: const EdgeInsets.symmetric(horizontal: 0.5, vertical: 5.0),
                                ratingWidget: RatingWidget(
                                  full: const Icon(Icons.star, color: Color.fromRGBO(195, 161, 110, 1)),
                                  half: const Icon(
                                    Icons.star_half,
                                    color: Color.fromRGBO(252, 220, 85, 1),
                                  ),
                                  empty: const Icon(
                                    Icons.star_outline,
                                    color: Color.fromRGBO(195, 161, 110, 1),
                                  ),
                                ),
                                onRatingUpdate: (value) {
                                  if (_isMounted) {
                                    setState(() {
                                      _ratingValue = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (!sentWithSucces)
                    Container(
                      margin: const EdgeInsets.only(left: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            l.testimonialTeRugamSaLasiUnTestimonial,
                            style: GoogleFonts.rubik(
                              color: const Color.fromRGBO(103, 114, 148, 1),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 35),
                  if (!sentWithSucces)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: TextField(
                        controller: controllerTestimonialText,
                        maxLines: 5,
                        decoration: InputDecoration(
                         // hintText: l.testimonialScrieUnTestimonial,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 35),
                  if (!sentWithSucces)
                    isSending
                        ? const CircularProgressIndicator()
                        : (!showButonTrimiteTestimonial)
                            ? Text(
                                l.testimonialSeIncearcaTrimiterea,
                                style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : GestureDetector(
                                onTap: () async {

                                  if (controllerTestimonialText.text.isNotEmpty) {
                                    if (_isMounted) {
                                      setState(() {
                                        isSending = true;
                                        feedbackCorect = false;
                                        showButonTrimiteTestimonial = false;
                                      });
                                    }

                                    http.Response? resAdaugaFeedback = await adaugaFeedbackDinContClient();


                                    if (context.mounted) {
                                      if (int.parse(resAdaugaFeedback!.body) == 200) {
                                        isSending = false;
                                        sentWithSucces = true;
                                        if (_isMounted) {
                                          setState(() {});
                                        }
                                      } else {
                                        if (_isMounted) {
                                          setState(() {
                                            isSending = false;
                                            feedbackCorect = false;
                                            showButonTrimiteTestimonial = true;
                                          });
                                        }
                                      }
                                    }
                                  } else {
                                    Fluttertoast.showToast(msg: "Va rugam lasati un mesaj");
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(25, 0, 25, 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color.fromRGBO(14, 190, 127, 1),
                                  ),
                                  height: 60,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        l.testimonialTrimiteTestimonialul,
                                        style: GoogleFonts.rubik(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}