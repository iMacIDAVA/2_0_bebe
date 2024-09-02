import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:sos_bebe_app/verifica_codul_pacient_screen.dart';
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:http/http.dart' as http;
import 'package:sos_bebe_app/utils_api/classes.dart';
import 'package:sos_bebe_app/utils_api/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;

import 'package:sos_bebe_app/localizations/1_localizations.dart';

ApiCallFunctions apiCallFunctions = ApiCallFunctions();

class ResetPasswordPacientScreen extends StatefulWidget {
  const ResetPasswordPacientScreen({super.key});

  @override
  State<ResetPasswordPacientScreen> createState() => _ResetPasswordPacientScreenState();
}

class _ResetPasswordPacientScreenState extends State<ResetPasswordPacientScreen> {
  final resetPasswordKey = GlobalKey<FormState>();
  bool isHidden = true;
  final controllerPhoneEmailUser = TextEditingController();
  //final controllerPass = TextEditingController();
  //final controllerNumeComplet = TextEditingController();

  final FocusNode focusNodePhone = FocusNode();
  //final FocusNode focusNodePassword = FocusNode();
  //final FocusNode focusNodeNumeComplet = FocusNode();

  void passVisibiltyToggle() {
    setState(() {
      isHidden = !isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 125),
                  Center(
                    child: Text(
                      //'Resetează parola', //old IGV
                      l.resetPasswordPacientReseteazaParolaTitlu,
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(14, 190, 127, 1),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 70),
                  Form(
                    key: resetPasswordKey,
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
                                  //text: 'Introdu numărul de telefon pentru a-ți schimba parola contului' //old IGV
                                  text: l.resetPasswordPacientReseteazaParolaTextMijloc,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 35),
                        TextFormField(
                          onFieldSubmitted: (String s) {
                            //focusNodePassword.requestFocus();
                          },
                          controller: controllerPhoneEmailUser,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(103, 114, 148, 1),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(103, 114, 148, 1),
                                width: 1.0,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            //hintText: "Telefon, e-mail sau utilizator", //old IGV
                            hintText: l.resetPasswordPacientTelefonEmailUtilizatorHint,
                            hintStyle: const TextStyle(
                                color: Color.fromRGBO(103, 114, 148, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.w300), //added by George Valentin Iordache
                            /*
                            prefixIcon: const Padding(
                              padding: EdgeInsets.all(0.0),
                              child: ImageIcon(
                                AssetImage('assets/images/icon_telefon_reseteaza_parola.png'),
                              ), // icon is 48px widget.
                            ),
                            */ //IGV
                          ),
                          validator: (value) {
                            String emailPattern = r'.+@.+\.+';
                            RegExp emailRegExp = RegExp(emailPattern);
                            String phonePattern = r'(^(?:[+0]4)?[0-9]{10}$)';
                            RegExp phoneRegExp = RegExp(phonePattern);
                            //String namePattern = r"^\s*([A-Za-z]{1,}([\.,] |[-']| ))+[A-Za-z]+\.?\s*$";
                            //String namePattern = r'^[a-z A-Z,.\-]+$';
                            String userNamePattern = r'^(?=[a-zA-Z][a-zA-Z0-9._]{7,29}$)(?!.*[_.]{2})[^_.].*[^_.]$';
                            RegExp nameRegExp = RegExp(userNamePattern);
                            if (value!.isEmpty ||
                                !(emailRegExp.hasMatch(value) ||
                                    phoneRegExp.hasMatch(value) ||
                                    nameRegExp.hasMatch(value))) {
                              //return "Introduceți un utilizator/email/numar de telefon valid!"; //old IGV
                              return l.resetPasswordPacientIntroducetiUtilizatorEmailTelefon;
                            } else {
                              return null;
                            }
                          },
                        ),
                        //const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 175),
                  SizedBox(
                    width: 160,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () async {
                        final isValidForm = resetPasswordKey.currentState!.validate();
                        if (isValidForm) {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          //prefs.setString(pref_keys.userPassMD5, controllerEmail.text);

                          prefs.setString(pref_keys.userPassMD5, apiCallFunctions.generateMd5('123456'));

                          //String? userPassMD5 = prefs.getString(pref_keys.userPassMD5);

                          String? userPassMD5 = apiCallFunctions.generateMd5('123456');
                          ContClientMobile? resGetCont;
                          try {
                            resGetCont = await apiCallFunctions.getContClient(
                              pUser: controllerPhoneEmailUser.text,
                              pParola: userPassMD5,
                              pDeviceToken: prefs.getString('oneSignalId') ?? "",
                              pTipDispozitiv: Platform.isAndroid ? '1' : '2',
                              pModelDispozitiv: await apiCallFunctions.getDeviceInfo(),
                              pTokenVoip: '',
                            );
                          } catch (e) {
                            showSnackbar(context, e.toString(), Colors.red, Colors.black);
                          }

                          if (resGetCont?.id == 0) {
                            //print('reset_password_screen getContClient id : ${resGetCont!.id} nume : ${resGetCont.nume} prenume : ${resGetCont.prenume} email: ${resGetCont.email} telefon: ${resGetCont.telefon}  user: ${resGetCont.user}');

                            //if (resGetCont.telefon.isEmpty && resGetCont.email.isEmpty)
                            {
                              if (context.mounted) {
                                //showSnackbar(context, "Contul dumneavoastră nu conține informațiile de contact pentru a reseta parola, vă rugăm să contactați un reprezentant SOS Bebe", Colors.red, Colors.black);
                                showSnackbar(
                                    context, l.resetPasswordPacientContulDumneavoastra, Colors.red, Colors.black);
                              }
                              //return;
                            }
                          } else {
                            http.Response? resTrimitePin;

                            resTrimitePin = await trimitePinPentruResetareParolaClient();

                            if (context.mounted) {
                              if (int.parse(resTrimitePin!.body) == 200) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        VerificaCodulPacientScreen(user: controllerPhoneEmailUser.text),
                                    //builder: (context) => const ServiceSelectScreen(),
                                  ),
                                );
                              }
                            }

                            /*
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                //builder: (context) => const ServiceSelectScreen(),
                                builder: (context) => const VerificaCodulPacientScreen(),
                              ),
                            );
                            */
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
                          minimumSize: const Size.fromHeight(50), // NEW
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          )),
                      child: Text(
                          //'Trimite cod', //old IGV
                          l.resetPasswordPacientSendCode,
                          style: GoogleFonts.rubik(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w300)),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<http.Response?> trimitePinPentruResetareParolaClient() async {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    String textMessage = '';
    Color backgroundColor = Colors.red;
    Color textColor = Colors.black;

    http.Response? resTrimitePin = await apiCallFunctions.trimitePinPentruResetareParolaClient(
      pUser: controllerPhoneEmailUser.text,
    );

    if (int.parse(resTrimitePin!.body) == 200) {
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //prefs.setString(pref_keys.userEmail, controllerEmail.text);

      //prefs.setString(pref_keys.userPassMD5, apiCallFunctions.generateMd5(controllerPass.text));

      //textMessage = 'Cod trimis cu succes!'; //old IGV
      textMessage = l.resetPasswordPacientCodTrimisCuSucces;

      backgroundColor = const Color.fromARGB(255, 14, 190, 127);
      textColor = Colors.white;
    } else if (int.parse(resTrimitePin.body) == 400) {
      //textMessage = 'Apel invalid!'; //old IGV
      textMessage = l.resetPasswordPacientApelInvalid;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resTrimitePin.body) == 401) {
      //prefs.setString(pref_keys.userEmail, controllerEmail.text);
      //prefs.setString(pref_keys.userPassMD5, apiCallFunctions.generateMd5(controllerPass.text));

      //textMessage = 'Cont inexistent!'; //old IGV

      textMessage = l.resetPasswordPacientContInexistent;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resTrimitePin.body) == 405) {
      //textMessage = 'Cont existent dar clientul nu are date de contact!'; //old IGV

      textMessage = l.resetPasswordPacientContExistentFaraDate; //old IGV

      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resTrimitePin.body) == 500) {
      //textMessage = 'A apărut o eroare la execuția metodei!'; //old IGV

      textMessage = l.resetPasswordPacientAAparutOEroare;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    }

    if (context.mounted) {
      showSnackbar(context, textMessage, backgroundColor, textColor);

      return resTrimitePin;
    }

    return null;
  }
}
