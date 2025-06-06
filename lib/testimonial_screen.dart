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

class TestimonialScreen extends StatefulWidget {
  final int idMedic;
  final int idFactura;
  final FacturaClientMobile factura;

  const TestimonialScreen({super.key, required this.idMedic, required this.idFactura, required this.factura});

  @override
  State<TestimonialScreen> createState() => _TestimonialScreenState();
}

class _TestimonialScreenState extends State<TestimonialScreen> {
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

  Future<http.Response?> modificaFeedbackDinContClient() async {
    LocalizationsApp l = LocalizationsApp.of(context)!;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
    http.Response? resAdaugaFeedback = await apiCallFunctions.modificaFeedbackDinContClient(
      pUser: user,
      pParola: userPassMD5,
      pIdFeedback: widget.factura.idFeedbackClient.toString(),
      pNota: _ratingValue!.toString().split('.')[0],
      pComentariu: controllerTestimonialText.text,
    );
    return resAdaugaFeedback;
  }

  Future<http.Response?> adaugaFeedbackDinContClient() async {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    String textMessage = '';
    Color backgroundColor = Colors.red;
    Color textColor = Colors.black;


    print("📤 Sending feedback to server:");
    print("User: $user");
    print("Password (MD5): $userPassMD5");
    print("ID Medic: ${widget.idMedic}");
    print("ID Factura: ${widget.idFactura}");
    print("Nota: $_ratingValue");
    print("Comentariu: ${controllerTestimonialText.text}");

    http.Response? resAdaugaFeedback = await apiCallFunctions.adaugaFeedbackDinContClient(
      pUser: user,
      pParola: userPassMD5,
      pIdMedic: widget.idMedic.toString(),
      pIdFactura: widget.idFactura.toString(),
pNota: _ratingValue!.toString().split('.')[0],
      pComentariu: controllerTestimonialText.text,
    );

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
    } else if (int.parse(resAdaugaFeedback.body) == 500) {
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
      showSnackbar(context, textMessage, backgroundColor, textColor);

      return resAdaugaFeedback;
    }

    return null;
  }

  bool isSending = false;
  bool sentWithSucces = false;

  ContClientMobile? contInfo;

  Future<void> getContDetalii() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
    contInfo = await apiCallFunctions.getContClient(
      pUser: user,
      pParola: userPassMD5,
      pDeviceToken: prefs.getString('oneSignalId') ?? "",
      pTipDispozitiv: Platform.isAndroid ? '1' : '2',
      pModelDispozitiv: await apiCallFunctions.getDeviceInfo(),
      pTokenVoip: '',
    );
  }

  bool _isMounted = true;

  @override
  void initState() {
    super.initState();

    _isMounted = true;

    // print(widget.factura.textFeedbackClient);
    // print(widget.factura.notaFeedbackClient);
    if (widget.factura.textFeedbackClient.isNotEmpty || widget.factura.notaFeedbackClient != 0) {
      testimonialAveaDate = true;

      controllerTestimonialText.text = widget.factura.textFeedbackClient;
      _ratingValue = widget.factura.notaFeedbackClient.toDouble();
    }
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
                  // Row(
                  //   children: [
                  //     IconButton(
                  //       onPressed: () => Navigator.pop(context),
                  //       icon: const Icon(Icons.arrow_back_outlined),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //children: [Text('Vă mulțumim!', style: GoogleFonts.rubik(color: Colors.black87, fontSize: 28))], old
                    children: [
                      Text(
                        //'Vă mulțumim!', //old IGV
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
                      testimonialAveaDate ? "Modificat cu succes!" : "Trimis cu succes!",
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 26,
                      ),
                    ),
                  if (sentWithSucces)
                    const SizedBox(
                      height: 30,
                    ),
                  if (sentWithSucces)
                    GestureDetector(
                      onTap: () async {
                        ContClientMobile? contNou;
                        SharedPreferences prefs = await SharedPreferences.getInstance();

                        String user = prefs.getString('user') ?? '';
                        String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
                        contNou = await apiCallFunctions.getContClient(
                          pUser: user,
                          pParola: userPassMD5,
                          pDeviceToken: prefs.getString('oneSignalId') ?? "",
                          pTipDispozitiv: Platform.isAndroid ? '1' : '2',
                          pModelDispozitiv: await apiCallFunctions.getDeviceInfo(),
                          pTokenVoip: '',
                        );
                        await fetchDataBeforeNavigation();
                        await Future.delayed(const Duration(seconds: 2));
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
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(25, 0, 25, 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            //color: Colors.green, old
                            color: const Color.fromRGBO(14, 190, 127, 1)),
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              //' TRIMITE CHESTIONARUL', old
                              // style: GoogleFonts.rubik(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18), old
                              //'TRIMITE TESTIMONIALUL', //old IGV
                              "Întoarce-te la ecranul anterior",
                              style: GoogleFonts.rubik(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
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
                                //'Rating', //old IGV
                                l.testimonialRating,
                                style: GoogleFonts.rubik(
                                    color: const Color.fromRGBO(103, 114, 148, 1),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RatingBar(
                                  //ignoreGestures: true,
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
                                      )),
                                  onRatingUpdate: (value) {
                                    if (_isMounted) {
                                      setState(() {
                                        _ratingValue = value;
                                      });
                                    }
                                  }),
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
                            //'Te rugăm să ne lași si un testimonial!', //old IGV
                            l.testimonialTeRugamSaLasiUnTestimonial,
                            style: GoogleFonts.rubik(
                                color: const Color.fromRGBO(103, 114, 148, 1), fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 35),
                  if (!sentWithSucces)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 240, 240, 240),
                      ),
                      height: 130,
                      child: TextField(
                        keyboardType: TextInputType.streetAddress,
                        textCapitalization: TextCapitalization.words,
                        controller: controllerTestimonialText,
                        style:
                            const TextStyle(color: Color.fromRGBO(103, 114, 148, 1)), //added by George Valentin Iordache
                        //decoration: InputDecoration(border: InputBorder.none, hintText: 'Doctorul a raspuns rapid...'),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          //hintText: 'Doctorul a raspuns rapid...', //old IGV
                          hintText: l.testimonialDoctorulARaspunsHint,
                          hintStyle: const TextStyle(
                              color: Color.fromRGBO(103, 114, 148, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w300), //added by George Valentin Iordache
                        ),
                        maxLines: 4,
                      ),
                    ),
                  const SizedBox(height: 15),
                  if (!sentWithSucces)
                    isSending
                        ? CircularProgressIndicator()
                        : (!showButonTrimiteTestimonial)
                            ? Text(
                                //'Se încearcă trimiterea feedback-ului!', //old IGV
                                l.testimonialSeIncearcaTrimiterea,
                                style: GoogleFonts.rubik(
                                    color: const Color.fromRGBO(103, 114, 148, 1),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              )
                            : GestureDetector(
                                onTap: () async {
                                  if (testimonialAveaDate) {
                                    if (controllerTestimonialText.text.isNotEmpty) {
                                      if (_isMounted) {
                                        setState(() {
                                          isSending = true;
                                          feedbackCorect = false;
                                          showButonTrimiteTestimonial = false;
                                        });
                                      }

                                      http.Response? resAdaugaFeedback;

                                      resAdaugaFeedback = await modificaFeedbackDinContClient();

                                      if (context.mounted) {
                                        if (int.parse(resAdaugaFeedback!.body) == 200) {
                                          await getContDetalii();
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
                                  } else {
                                    if (controllerTestimonialText.text.isNotEmpty) {
                                      if (_isMounted) {
                                        setState(() {
                                          isSending = true;
                                          feedbackCorect = false;
                                          showButonTrimiteTestimonial = false;
                                        });
                                      }

                                      http.Response? resAdaugaFeedback;

                                      resAdaugaFeedback = await adaugaFeedbackDinContClient();

                                      if (context.mounted) {
                                        if (int.parse(resAdaugaFeedback!.body) == 200) {
                                          await getContDetalii();
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
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(25, 0, 25, 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      //color: Colors.green, old
                                      color: const Color.fromRGBO(14, 190, 127, 1)),
                                  height: 60,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        //' TRIMITE CHESTIONARUL', old
                                        // style: GoogleFonts.rubik(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18), old
                                        //'TRIMITE TESTIMONIALUL', //old IGV
                                        testimonialAveaDate ? "Modifică testimonial" : l.testimonialTrimiteTestimonialul,
                                        style: GoogleFonts.rubik(
                                            color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                  if (!sentWithSucces)
                    if (testimonialAveaDate) Text("sau"),
                  const SizedBox(height: 10),
                  if (!sentWithSucces)
                    if (testimonialAveaDate)
                      GestureDetector(
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();

                          String user = prefs.getString('user') ?? '';
                          String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

                          apiCallFunctions.stergeFeedbackDinContClient(
                              pUser: user, pParola: userPassMD5, pIdFeedback: widget.factura.idFeedbackClient.toString());
                          sentWithSucces = true;
                          if (_isMounted) {
                            setState(() {});
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(25, 0, 25, 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              //color: Colors.green, old
                              color: const Color.fromRGBO(14, 190, 127, 1)),
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                //' TRIMITE CHESTIONARUL', old
                                // style: GoogleFonts.rubik(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18), old
                                //'TRIMITE TESTIMONIALUL', //old IGV
                                "Șterge testimonial",
                                style: GoogleFonts.rubik(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
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
