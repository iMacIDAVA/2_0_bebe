import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sos_bebe_app/login_screen.dart';
import 'package:sos_bebe_app/utils_api/functions.dart';
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:http/http.dart' as http;
import 'package:sos_bebe_app/localizations/1_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;

ApiCallFunctions apiCallFunctions = ApiCallFunctions();

class VerificaPinStergeContScreen extends StatefulWidget {
  final String user;
  final String userPassMD5;
  const VerificaPinStergeContScreen(
      {super.key, required this.user, required this.userPassMD5});

  @override
  State<VerificaPinStergeContScreen> createState() =>
      _VerificaPinStergeContScreenState();
}

class _VerificaPinStergeContScreenState
    extends State<VerificaPinStergeContScreen> {
  final verificaCodulKey = GlobalKey<FormState>();

  String? currentPIN;
  bool isHidden = true;
  final controllerCode = TextEditingController();

  bool showButonVerificaSterge = true;
  bool verificareReusita = false;
  bool stergereReusita = false;

  final FocusNode focusNodePhone = FocusNode();

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 125),
                Center(
                  child: Text(
                    //'Verifică codul și șterge contul', //old IGV
                    l.verificaPinStergeContVerificaCodulStergeContTitlu,
                    style: GoogleFonts.rubik(
                      color: const Color.fromRGBO(14, 190, 127, 1),
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 70),
                Form(
                  key: verificaCodulKey,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 250,
                        child: AutoSizeText.rich(
                          // old value RichText(
                          TextSpan(
                            style: GoogleFonts.rubik(
                              color: const Color.fromRGBO(103, 114, 148, 1),
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                //text: 'Introdu codul primit prin SMS' //old IGV
                                text: l.verificaPinStergeContTextMijloc,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 35),
                      SizedBox(
                        height: 80,
                        width: 270,
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 1,
                                color: const Color.fromRGBO(205, 211, 223, 1)),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 200,
                              height: 80,
                              child: PinCodeTextField(
                                length: 4,
                                //obscureText: false,
                                textStyle: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.number,
                                //animationType: AnimationType.fade,
                                appContext: context,
                                pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.circle,
                                  borderRadius: BorderRadius.zero,
                                  fieldHeight: 40,
                                  fieldWidth: 40,
                                  activeFillColor:
                                      const Color.fromRGBO(14, 190, 127, 1),
                                  inactiveColor:
                                      const Color.fromRGBO(103, 114, 148, 1),
                                  inactiveFillColor:
                                      const Color.fromRGBO(103, 114, 148, 1),
                                  selectedFillColor:
                                      const Color.fromRGBO(103, 114, 148, 1),
                                  selectedColor:
                                      const Color.fromRGBO(103, 114, 148, 1),
                                  activeColor:
                                      const Color.fromRGBO(103, 114, 148, 1),
                                ),
                                animationDuration:
                                    const Duration(milliseconds: 300),
                                //cursorColor: const Color.fromRGBO(103, 114, 148, 1),
                                backgroundColor: Colors.transparent,
                                enableActiveFill: true,
                                //errorAnimationController: errorController,
                                //controller: textEditingController,
                                onCompleted: (v) {
                                  print("Completed");
                                },
                                onChanged: (value) {
                                  setState(() {
                                    currentPIN = value;
                                  });

                                  print(
                                      'pinValue: $value currentPIN: $currentPIN');
                                },
                                beforeTextPaste: (text) {
                                  print("Allowing to paste $text");
                                  //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                  //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                  return true;
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 45),
                      SizedBox(
                        width: 250,
                        child: GestureDetector(
                          onTap: () async {
                            http.Response?
                                resTrimitePinPentruStergereContClient;

                            resTrimitePinPentruStergereContClient =
                                await trimitePinPentruStergereContClient();
                          },
                          child: Center(
                              child: Text(
                                  //'Trimite din nou codul', //old IGV
                                  l.verificaPinStergeContTrimiteDinNouCodul,
                                  style: GoogleFonts.rubik(
                                      color:
                                          const Color.fromRGBO(14, 190, 127, 1),
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14))),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 115),

                //(showButonVerificaSterge && !verificareReusita && !stergereReusita)?
                (!showButonVerificaSterge && !verificareReusita)
                    ? SizedBox(
                        width: 160,
                        height: 44,
                        child: Center(
                            child: Text(
                                //'Se verifică codul trimis', //old IGV
                                l.verificaPinStergeContSeVerificaCodulTrimis,
                                style: GoogleFonts.rubik(
                                    color:
                                        const Color.fromRGBO(14, 190, 127, 1),
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14))),
                      )
                    : (!showButonVerificaSterge &&
                            verificareReusita &&
                            !stergereReusita)
                        ? SizedBox(
                            width: 160,
                            height: 44,
                            child: Center(
                                child: Text(
                                    //'Se sterge contul', //old IGV
                                    l.verificaPinStergeContSeStergeContul,
                                    style: GoogleFonts.rubik(
                                        color: const Color.fromRGBO(
                                            14, 190, 127, 1),
                                        fontWeight: FontWeight.w300,
                                        fontSize: 14))),
                          )
                        : SizedBox(
                            width: 230,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () async {
                                final isValidForm =
                                    verificaCodulKey.currentState!.validate();
                                if (isValidForm) {
                                  setState(() {
                                    verificareReusita = false;
                                    stergereReusita = false;
                                    showButonVerificaSterge = true;
                                  });

                                  http.Response? resVerificaPinStergeCont;

                                  resVerificaPinStergeCont =
                                      await verificaCodPinClient();

                                  if (int.parse(
                                          resVerificaPinStergeCont!.body) ==
                                      200) {
                                    http.Response? resStergeContClient;
                                    resStergeContClient =
                                        await stergeContClient();

                                    if (int.parse(resStergeContClient!.body) ==
                                        200) {
                                      if (context.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            //builder: (context) => const ServiceSelectScreen(),
                                            builder: (context) =>
                                                const LoginScreen(),
                                          ),
                                        );
                                      }
                                    } else {
                                      setState(() {
                                        verificareReusita = true;
                                        stergereReusita = false;
                                        showButonVerificaSterge = true;
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      verificareReusita = false;
                                      stergereReusita = false;
                                      showButonVerificaSterge = true;
                                    });
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(14, 190, 127, 1),
                                  minimumSize: const Size.fromHeight(50), // NEW
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  )),
                              child: Text(
                                  //'Verifică pin și șterge cont', //old IGV
                                  l
                                      .verificaPinStergeContVerificaPinStergeContButon,
                                  style: GoogleFonts.rubik(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300)),
                            ),
                          ),
                //const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<http.Response?> verificaCodPinClient() async {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    String textMessage = '';
    Color backgroundColor = Colors.red;
    Color textColor = Colors.black;

    http.Response? resVerificaCodPin =
        await apiCallFunctions.verificaCodPinClient(
      pUser: widget.user,
      pCodPIN: currentPIN ?? '1234',
    );

    if (int.parse(resVerificaCodPin!.body) == 200) {
      setState(() {
        verificareReusita = true;
        showButonVerificaSterge = false;
      });

      textMessage = l.verificaPinStergeContCodVerificatCuSucces;

      backgroundColor = const Color.fromARGB(255, 14, 190, 127);
      textColor = Colors.white;
      //showSnackbar(context, "Cod verificat cu succes!",const Color.fromARGB(255, 14, 190, 127), Colors.white);

      //}

      //return resVerificaCodPin;
    } else if (int.parse(resVerificaCodPin.body) == 400) {
      setState(() {
        verificareReusita = false;
        showButonVerificaSterge = true;
      });
      textMessage = l.verificaPinStergeContApelInvalid;

      backgroundColor = Colors.red;
      textColor = Colors.black;
      //showSnackbar(context, "Apel invalid!", Colors.red, Colors.black);

      //}

      //return resVerificaCodPin;
    } else if (int.parse(resVerificaCodPin.body) == 401) {
      setState(() {
        verificareReusita = false;
        showButonVerificaSterge = true;
      });

      textMessage = l.verificaPinStergeContEroareCodNeverificat;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resVerificaCodPin.body) == 405) {
      setState(() {
        verificareReusita = false;
        showButonVerificaSterge = true;
      });

      textMessage = l.verificaPinStergeContInformatiiInsuficiente;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resVerificaCodPin.body) == 500) {
      setState(() {
        verificareReusita = false;
        showButonVerificaSterge = true;
      });

      textMessage = l.verificaPinStergeContAAparutOEroare;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    }

    if (context.mounted) {
      showSnackbar(context, textMessage, backgroundColor, textColor);
      return resVerificaCodPin;
    }
    return null;
  }

  Future<http.Response?> stergeContClient() async {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    String textMessage = '';
    Color backgroundColor = Colors.red;
    Color textColor = Colors.black;

    http.Response? resStegeContClient = await apiCallFunctions.stergeContClient(
      pUser: widget.user,
      pParola: widget.userPassMD5,
    );

    if (int.parse(resStegeContClient!.body) == 200) {
      setState(() {
        verificareReusita = true;
        stergereReusita = true;
        showButonVerificaSterge = false;
      });

      textMessage = l.verificaPinStergeContContStersCuSucces;

      backgroundColor = const Color.fromARGB(255, 14, 190, 127);
      textColor = Colors.white;
    } else if (int.parse(resStegeContClient.body) == 400) {
      setState(() {
        verificareReusita = true;
        stergereReusita = false;
        showButonVerificaSterge = true;
      });

      //textMessage = 'Apel invalid!'; //old IGV
      textMessage = l.verificaPinStergeContApelInvalidStergeCont;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resStegeContClient.body) == 401) {
      setState(() {
        verificareReusita = true;
        stergereReusita = false;
        showButonVerificaSterge = true;
      });

      textMessage = l.verificaPinStergeContEroareContNesters;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resStegeContClient.body) == 405) {
      setState(() {
        verificareReusita = true;
        stergereReusita = false;
        showButonVerificaSterge = true;
      });
      textMessage = l.verificaPinStergeContInformatiiInsuficienteStergeCont;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resStegeContClient.body) == 500) {
      setState(() {
        verificareReusita = true;
        stergereReusita = false;
        showButonVerificaSterge = true;
      });
      textMessage = l.verificaPinStergeContAAparutOEroareStergeCont;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    }

    if (context.mounted) {
      showSnackbar(context, textMessage, backgroundColor, textColor);
      return resStegeContClient;
    }
    return null;
  }

  Future<http.Response?> trimitePinPentruStergereContClient() async {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    String textMessage = '';
    Color backgroundColor = Colors.red;
    Color textColor = Colors.black;

    http.Response? resTrimitePinPentruStergere =
        await apiCallFunctions.trimitePinPentruStergereContClient(
      pUser: user,
      pParola: userPassMD5,
    );

    if (int.parse(resTrimitePinPentruStergere!.body) == 200) {
      textMessage = l.profilPacientCodTrimisCuSucces;

      backgroundColor = const Color.fromARGB(255, 14, 190, 127);
      textColor = Colors.white;
    } else if (int.parse(resTrimitePinPentruStergere.body) == 400) {
      print('Apel invalid');

      //textMessage = 'Apel invalid!'; //old IGV
      textMessage = l.profilPacientApelInvalid;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resTrimitePinPentruStergere.body) == 401) {
      textMessage = l.profilPacientContInexistent;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resTrimitePinPentruStergere.body) == 405) {
      textMessage = l.profilPacientContExistentFaraDateContact;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resTrimitePinPentruStergere.body) == 500) {
      textMessage = l.profilPacientAAparutOEroare;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    }

    if (context.mounted) {
      showSnackbar(context, textMessage, backgroundColor, textColor);

      return resTrimitePinPentruStergere;
    }

    return null;
  }
}
