import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:list_picker/list_picker.dart';
import 'package:sos_bebe_app/custom_picker/sos_bebe_picker.dart';
import 'package:sos_bebe_app/login_screen.dart';
//import 'package:sos_bebe_app/select_service_screen_old_dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:http/http.dart' as http;
import 'package:sos_bebe_app/utils_api/classes.dart';
import 'package:sos_bebe_app/utils_api/functions.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;

import 'package:sos_bebe_app/localizations/1_localizations.dart';

//import 'package:sos_bebe_app/testimonial_screen.dart';

ApiCallFunctions apiCallFunctions = ApiCallFunctions();

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final registerKey = GlobalKey<FormState>();
  bool isHidden = true;
  final controllerEmail = TextEditingController();
  final controllerPass = TextEditingController();
  final controllerNumeComplet = TextEditingController();
  //persoana fizica
  final controllerSerieAct = TextEditingController();
  final controllerNumarAct = TextEditingController();
  final controllerCNP = TextEditingController();
  final controllerAdresa = TextEditingController();
  final controllerJudet = TextEditingController();
  final controllerLocalitate = TextEditingController();
  //persoana juridica - cod fiscal - denumire firma - nr reg com - adresa sediu ca sus^
  final controllercodFiscal = TextEditingController();
  final controllerDenumireFirma = TextEditingController();
  final controllerNrRegCom = TextEditingController();
  late DateFirma dateFirma;

  String tara = '';
  String judet = '';
  String localitate = '';

  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodePassword = FocusNode();
  final FocusNode focusNodeNumeComplet = FocusNode();

  final FocusNode focusNodeSerieAct = FocusNode();
  final FocusNode focusNodeNumarAct = FocusNode();
  final FocusNode focusNodeCNP = FocusNode();

  final FocusNode focusCodFiscal = FocusNode();
  final FocusNode focusDenumireFirma = FocusNode();
  final FocusNode focusNrRegCom = FocusNode();

// date noi logare
  bool persoanaFizica = true;
  bool persoanaJuridica = false;
//===========
  bool registerCorect = false;
  bool showInainteButton = true;
//Lista judete
  String idjudet = '';
  String idLocalitate = '';

  List<Judet> listaJudete = [];
  List<String> listaJudeteString = [];
  List<Localitate> listaLocalitate = [];
  List<String> listaLocalitateString = [];
  void passVisibiltyToggle() {
    setState(() {
      isHidden = !isHidden;
    });
  }

  void getListajudete() async {
    listaJudete = await apiCallFunctions.getListajudete();
    for (var element in listaJudete) {
      listaJudeteString.add(element.denumire);
    }
  }

  late ListPickerField judetPickerField;

  Future<http.Response?> adaugaContClient() async {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String textMessage = '';
    Color backgroundColor = Colors.red;
    Color textColor = Colors.black;

    http.Response? resAdaugaCont = await apiCallFunctions.adaugaContClient(
        pNumeComplet: controllerNumeComplet.text,
        pUser: controllerEmail.text,
        pParola: controllerPass.text,
        pDeviceToken: prefs.getString('oneSignalId') ?? "",
        pTipDispozitiv: Platform.isAndroid ? '1' : '2',
        pTipPersoana: persoanaFizica
            ? "1"
            : persoanaJuridica
                ? "2"
                : "1",
        pCodFiscal: controllercodFiscal.text,
        pDenumireFirma: controllerDenumireFirma.text,
        pNrRegCom: controllerNrRegCom.text,
        pSerieAct: controllerSerieAct.text,
        pNumarAct: controllerNumarAct.text,
        pCNP: controllerCNP.text,
        pAdresaLinie1: controllerAdresa.text,
        pIdJudet: idjudet,
        pIdLocalitate: idLocalitate);

    if (int.parse(resAdaugaCont!.body) == 200) {
      setState(() {
        registerCorect = true;
        showInainteButton = false;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(pref_keys.userEmail, controllerEmail.text);
      //prefs.setString(pref_keys.userPassMD5, controllerEmail.text);

      prefs.setString(pref_keys.userPassMD5, apiCallFunctions.generateMd5(controllerPass.text));

      //textMessage = 'Înregistrare finalizată cu succes!'; //old IGV
      textMessage = l.registerInregistrareCuSucces;

      backgroundColor = const Color.fromARGB(255, 14, 190, 127);
      textColor = Colors.white;
      /*
      if (context.mounted)
      {

        showSnackbar(context, "Înregistrare finalizată cu succes!",const Color.fromARGB(255, 14, 190, 127), Colors.white);

      }

      return resAdaugaCont;
      */
    } else if (int.parse(resAdaugaCont.body) == 400) {
      setState(() {
        registerCorect = false;
        showInainteButton = true;
      });

      /*
      if (context.mounted)
      {

        showSnackbar(context, "Apel invalid!", Colors.red, Colors.black);

      }

      return resAdaugaCont;
      */

      //textMessage = 'Apel invalid!'; //old IGV

      textMessage = l.registerApelInvalid;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resAdaugaCont.body) == 401) {
      prefs.setString(pref_keys.userEmail, controllerEmail.text);
      prefs.setString(pref_keys.userPassMD5, apiCallFunctions.generateMd5(controllerPass.text));

      setState(() {
        registerCorect = false;
        showInainteButton = true;
      });

      /*
      if (context.mounted)
      {

        showSnackbar(context, "Cont deja existent!", Colors.red, Colors.black);

      }

      return resAdaugaCont;
      */

      //textMessage = 'Cont deja existent!'; //old IGV

      textMessage = l.registerContDejaExistent;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resAdaugaCont.body) == 405) {
      setState(() {
        registerCorect = false;
        showInainteButton = true;
      });

      /*
      if (context.mounted)
      {

        showSnackbar(context, "Informații insuficiente!", Colors.red, Colors.black);

      }

      return resAdaugaCont;
      */

      //textMessage = 'Informații insuficiente!'; //old IGV
      textMessage = l.registerInformatiiInsuficiente;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resAdaugaCont.body) == 500) {
      setState(() {
        registerCorect = false;
        showInainteButton = true;
      });

      //textMessage = 'A apărut o eroare la execuția metodei!'; //old IGV

      textMessage = l.registerAAparutEroare; //old IGV

      backgroundColor = Colors.red;
      textColor = Colors.black;
      /*
      if (context.mounted)
      {

        showSnackbar(context, "A apărut o eroare la execuția metodei!", Colors.red, Colors.black);

      }

      return resAdaugaCont;
      */
    }

    if (context.mounted) {
      showSnackbar(context, textMessage, backgroundColor, textColor);

      return resAdaugaCont;
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    getListajudete();
    judetPickerField = ListPickerField(
      label: "Judet",
      items: listaJudeteString,
      controller: controllerJudet,
    );
  }

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);

              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Center(child: Image.asset('./assets/images/Sosbebe.png', height: 102, width: 81)),
                    const SizedBox(height: 50),
                    Form(
                      key: registerKey,
                      child: Column(
                        children: [
                          TextFormField(
                            onFieldSubmitted: (String s) {
                              focusNodePassword.requestFocus();
                            },
                            controller: controllerEmail,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(205, 211, 223, 1),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(205, 211, 223, 1),
                                  width: 1.0,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              //hintText: "Telefon, e-mail sau utilizator", //old IGV
                              hintText: l.registerTelefonEmailUtilizatorHint,
                              hintStyle: const TextStyle(
                                  color: Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300), //added by George Valentin Iordache
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                controllerEmail.value = TextEditingValue(
                                  text: value[0].toUpperCase() + value.substring(1),
                                  selection: controllerEmail.selection,
                                );
                              }
                            },
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
                                return l.registerIntroducetiUtilizatorEmailTelefonValid;
                              } else {
                                return null;
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            onFieldSubmitted: (String s) {
                              focusNodePassword.requestFocus();
                            },
                            textCapitalization: TextCapitalization.sentences,
                            controller: controllerNumeComplet,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(205, 211, 223, 1),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(205, 211, 223, 1),
                                  width: 1.0,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              //hintText: "Nume Complet", //old IGV
                              hintText: l.registerNumeCompletHint,
                              hintStyle: const TextStyle(
                                  color: Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300), //added by George Valentin Iordache
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                if (value[value.length - 1] == ' ') {
                                  controllerNumeComplet.value = TextEditingValue(
                                    text: value,
                                    selection: controllerNumeComplet.selection,
                                  );
                                } else {
                                  List<String> words = value.split(' ');
                                  for (int i = 0; i < words.length; i++) {
                                    if (words[i].isNotEmpty) {
                                      words[i] = words[i][0].toUpperCase() + words[i].substring(1);
                                    }
                                  }
                                  String updatedValue = words.join(' ');

                                  controllerNumeComplet.value = TextEditingValue(
                                    text: updatedValue,
                                    selection: controllerNumeComplet.selection,
                                  );
                                }
                              }
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                //return "Vă rugăm introduceți numele complet!"; //old IGV
                                return l.registerIntroducetiNumeleComplet;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            focusNode: focusNodePassword,
                            controller: controllerPass,
                            obscureText: isHidden,
                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    onPressed: passVisibiltyToggle,
                                    icon: isHidden ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off)),
                                //hintText: "Parola noua", old
                                //hintText: "Parolă", //old IGV
                                hintText: l.registerParola,
                                hintStyle: const TextStyle(
                                    color: Color.fromRGBO(103, 114, 148, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300), //added by George Valentin Iordache
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                    width: 1.0,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white),
                            validator: (value) {
                              if (value!.isEmpty) {
                                //return "Vă rugăm introduceți o parolă!";
                                return l.registerIntroducetiParola;
                              } else if (value.length < 6) {
                                //return "Parola trebuie să aibă cel puțin 6 caractere!"; //old IGV
                                return l.registerParolaCelPutin;
                              } else {
                                return null;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        persoanaFizica = !persoanaFizica;
                        persoanaJuridica = !persoanaJuridica;
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Checkbox(
                            value: persoanaFizica,
                            onChanged: (value) {
                              persoanaFizica = value!;
                              persoanaJuridica = !value;
                              setState(() {});
                            },
                            activeColor: const Color.fromARGB(255, 14, 190, 127),
                          ),
                          const Text('Persoană Fizică')
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        persoanaFizica = !persoanaFizica;
                        persoanaJuridica = !persoanaJuridica;
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Checkbox(
                            value: persoanaJuridica,
                            onChanged: (value) {
                              persoanaJuridica = value!;
                              persoanaFizica = !value;
                              setState(() {});
                            },
                            activeColor: const Color.fromARGB(255, 14, 190, 127),
                          ),
                          const Text('Persoană Juridică')
                        ],
                      ),
                    ),
                    if (persoanaFizica)
                      Column(
                        children: [
                          TextFormField(
                            focusNode: focusNodeSerieAct,
                            controller: controllerSerieAct,
                            onFieldSubmitted: (String s) {
                              focusNodeNumarAct.requestFocus();
                            },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(2),
                            ],
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                hintText: 'Serie Act',
                                hintStyle: const TextStyle(
                                    color: Color.fromRGBO(103, 114, 148, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300), //added by George Valentin Iordache
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                    width: 1.0,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                controllerSerieAct.value = TextEditingValue(
                                  text: value[0].toUpperCase() + value.substring(1),
                                  selection: controllerSerieAct.selection,
                                );
                              }
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            focusNode: focusNodeNumarAct,
                            controller: controllerNumarAct,
                            onFieldSubmitted: (String s) {
                              focusNodeCNP.requestFocus();
                            },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(6),
                            ],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintText: 'Număr Act',
                                hintStyle: const TextStyle(
                                    color: Color.fromRGBO(103, 114, 148, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300), //added by George Valentin Iordache
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                    width: 1.0,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            focusNode: focusNodeCNP,
                            controller: controllerCNP,
                            // onFieldSubmitted: (String s) {
                            //   focusNodeCNP.requestFocus();
                            // },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(13),
                            ],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintText: 'CNP',
                                hintStyle: const TextStyle(
                                    color: Color.fromRGBO(103, 114, 148, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300), //added by George Valentin Iordache
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                    width: 1.0,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white),
                          ),
                        ],
                      ),
                    if (persoanaJuridica)
                      Column(
                        children: [
                          TextFormField(
                            controller: controllercodFiscal,
                            onFieldSubmitted: (String s) {
                              focusDenumireFirma.requestFocus();
                            },
                            onEditingComplete: () async {
                              dateFirma = await apiCallFunctions.getDateFirma(pCodFiscal: controllercodFiscal.text);
                              controllerDenumireFirma.text = dateFirma.denumireFirma;
                              controllerNrRegCom.text = dateFirma.nrRegCom;
                              controllerJudet.text = dateFirma.denumireJudet;
                              controllerLocalitate.text = dateFirma.denumireLocalitate;
                              controllerAdresa.text = dateFirma.adresaLinie1;
                              listaLocalitate =
                                  await apiCallFunctions.getListaLocalitati(pIdJudet: dateFirma.idJudet.toString());
                              for (var element in listaLocalitate) {
                                listaLocalitateString.add(element.denumire);
                              }
                              setState(() {});
                            },
                            decoration: InputDecoration(
                                hintText: 'Cod Fiscal',
                                hintStyle: const TextStyle(
                                    color: Color.fromRGBO(103, 114, 148, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300), //added by George Valentin Iordache
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                    width: 1.0,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            focusNode: focusDenumireFirma,
                            controller: controllerDenumireFirma,
                            onFieldSubmitted: (String s) {
                              focusNrRegCom.requestFocus();
                            },
                            decoration: InputDecoration(
                                hintText: 'Denumire Firmă',
                                hintStyle: const TextStyle(
                                    color: Color.fromRGBO(103, 114, 148, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300), //added by George Valentin Iordache
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                    width: 1.0,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            focusNode: focusNrRegCom,
                            controller: controllerNrRegCom,
                            decoration: InputDecoration(
                                hintText: 'Nr Reg Con',
                                hintStyle: const TextStyle(
                                    color: Color.fromRGBO(103, 114, 148, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300), //added by George Valentin Iordache
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                    width: 1.0,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white),
                          ),
                        ],
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        listaLocalitateString.clear();
                        String id = "";
                        String? judet = await showPickerSOSBebeDialog(
                          context: context,
                          label: "județul",
                          items: listaJudeteString,
                        );
                        if (judet != null) {
                          controllerJudet.text = judet;
                          for (var item in listaJudete) {
                            if (item.denumire == controllerJudet.text) {
                              id = item.id;
                              idjudet = id;
                              controllerLocalitate.clear();

                              listaLocalitate = await apiCallFunctions.getListaLocalitati(pIdJudet: id);
                              for (var element in listaLocalitate) {
                                listaLocalitateString.add(element.denumire);
                              }
                              break;
                            }
                          }
                        }
                        setState(() {});
                      },
                      child: AbsorbPointer(
                        absorbing: true,
                        child: TextFormField(
                          controller: controllerJudet,
                          enableInteractiveSelection: false,
                          readOnly: true,
                          decoration: InputDecoration(
                              hintText: 'Județ',
                              hintStyle: const TextStyle(
                                  color: Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300), //added by George Valentin Iordache
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(205, 211, 223, 1),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(205, 211, 223, 1),
                                  width: 1.0,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        String id = "";
                        String? judet = await showPickerSOSBebeDialog(
                          context: context,
                          label: "localitatea",
                          items: listaLocalitateString,
                        );
                        if (judet != null) {
                          controllerLocalitate.text = judet;
                          for (var item in listaLocalitate) {
                            if (item.denumire == judet) {
                              id = item.id;
                              idLocalitate = id;
                              break;
                            }
                          }
                        }
                        setState(() {});
                      },
                      child: AbsorbPointer(
                        absorbing: true,
                        child: TextFormField(
                          controller: controllerLocalitate,
                          enableInteractiveSelection: false,
                          readOnly: true,
                          decoration: InputDecoration(
                              hintText: 'Localitate',
                              hintStyle: const TextStyle(
                                  color: Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300), //added by George Valentin Iordache
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(205, 211, 223, 1),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(205, 211, 223, 1),
                                  width: 1.0,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: controllerAdresa,
                      decoration: InputDecoration(
                          hintText: 'Adresă',
                          hintStyle: const TextStyle(
                              color: Color.fromRGBO(103, 114, 148, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w300), //added by George Valentin Iordache
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(205, 211, 223, 1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(205, 211, 223, 1),
                              width: 1.0,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (value[value.length - 1] == ' ') {
                            controllerAdresa.value = TextEditingValue(
                              text: value,
                              selection: controllerAdresa.selection,
                            );
                          } else {
                            List<String> words = value.split(' ');
                            for (int i = 0; i < words.length; i++) {
                              if (words[i].isNotEmpty) {
                                words[i] = words[i][0].toUpperCase() + words[i].substring(1);
                              }
                            }
                            String updatedValue = words.join(' ');

                            controllerAdresa.value = TextEditingValue(
                              text: updatedValue,
                              selection: controllerAdresa.selection,
                            );
                          }
                        }
                      },
                    ),

                    const SizedBox(height: 20),
                    (!showInainteButton)
                        ? Text(
                            //'Se încearcă înregistrarea',//old IGV
                            l.registerSeIncearcaInregistrarea,
                            //style: GoogleFonts.rubik(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20)), old
                            style: GoogleFonts.rubik(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 18))
                        : ElevatedButton(
                            onPressed: () async {
                              final isValidForm = registerKey.currentState!.validate();
                              if (isValidForm) {
                                setState(() {
                                  registerCorect = false;
                                  showInainteButton = false;
                                });

                                http.Response? resAdaugaCont;

                                resAdaugaCont = await adaugaContClient();

                                if (context.mounted) {
                                  if (int.parse(resAdaugaCont!.body) == 200) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginScreen(),
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      registerCorect = false;
                                      showInainteButton = true;
                                    });
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 14, 190, 127),
                                minimumSize: const Size.fromHeight(50), // NEW
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                )),
                            child: Text(
                                // 'ÎNAINTE', //old IGV
                                l.registerInainte,
                                //style: GoogleFonts.rubik(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20)), old
                                style:
                                    GoogleFonts.rubik(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18)),
                          ),
                    //const SizedBox(height: 20), old
                    const SizedBox(height: 35),
                    //  child:
                    AutoSizeText.rich(
                      // old value RichText(
                      TextSpan(
                        style: GoogleFonts.rubik(
                          color: const Color.fromRGBO(103, 114, 148, 1),
                          fontSize: 12,
                        ),
                        children: <TextSpan>[
                          //TextSpan(text: 'Dacă te înscrii, îți exprimi acordul cu '), //old IGV
                          TextSpan(text: l.registerDacaTeInscrii),
                          //TextSpan(text: 'Condițiile de utilizare.', style: TextStyle(fontWeight: FontWeight.bold)), //old IGV
                          TextSpan(
                              text: l.registerConditiiUtilizare,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  /*
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateAccount()),

                                ),
                                */
                                }),
                          //TextSpan(text: 'Din '), //old IGV
                          TextSpan(text: l.registerDin),
                          //TextSpan(text: 'Politica de confidențialitate', style: TextStyle(fontWeight: FontWeight.bold)), //old IGV
                          TextSpan(
                            text: l.registerPoliticaDeConfidentialitate,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                /*
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateAccount()),

                                ),
                                */
                              },
                          ),
                          //TextSpan(text: ' poți afla cum colectăm, folosim și distribuim datele tale, iar din '), //old IGV
                          TextSpan(text: l.registerPotiAflaCumColectam),
                          //TextSpan(text: 'Politica de utilizare a modulelor cookie', style: TextStyle(fontWeight: FontWeight.bold)), //old IGV
                          TextSpan(
                            text: l.registerPoliticaDeUtilizare,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                /*
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateAccount()),

                                ),
                                */
                              },
                          ),
                          //TextSpan(text: ' poți afla cum utilizăm modulele cookie și tehnologii similare. '), //old IGV
                          TextSpan(text: l.registerPotiAflaCumUtilizam),
                        ],
                      ),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                    //George Valentin Iordache
                    //const SizedBox(height: 20),
                    const SizedBox(height: 60),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              //builder: (context) => const ServiceSelectScreen(),
                              builder: (context) => const LoginScreen(),
                            ));
                      },
                      style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50), // NEW
                          side: const BorderSide(color: Color.fromRGBO(205, 211, 223, 1), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          )),
                      /* old
                      child: Text(
                        "Ai un cont? Conectează-te",
                        style: GoogleFonts.rubik(color:const Color.fromRGBO(103, 114, 148, 1), fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                      */
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                              //"Ai un cont? ", //old IGV
                              l.registerAiUnCont,
                              style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(103, 114, 148, 1),
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14)),
                          Text(
                              //"Conectează-te", //old IGV
                              l.registerConecteazaTe,
                              style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(103, 114, 148, 1),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
