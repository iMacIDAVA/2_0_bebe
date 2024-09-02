import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sos_bebe_app/profil_pacient_screen.dart';
import 'package:sos_bebe_app/utils/utils_widgets.dart';

import 'package:sos_bebe_app/reset_password_pacient_screen.dart';

import 'package:sos_bebe_app/utils_api/classes.dart';
import 'package:sos_bebe_app/utils_api/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;
import 'package:http/http.dart' as http;
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';

import 'package:sos_bebe_app/localizations/1_localizations.dart';

ApiCallFunctions apiCallFunctions = ApiCallFunctions();

class EditareContScreen extends StatefulWidget {
//final MedicMobile medicDetalii;

  final ContClientMobile? contInfo;

  const EditareContScreen({super.key, required this.contInfo});

  @override
  State<EditareContScreen> createState() => EditareContScreenState();
}

class EditareContScreenState extends State<EditareContScreen> {
  final registerKey = GlobalKey<FormState>();
  bool isHidden = true;
  final controllerEmail = TextEditingController();
  final controllerTelefon = TextEditingController();
  final controllerUser = TextEditingController();
  final controllerNumeComplet = TextEditingController();
  final controllerResetareParola = TextEditingController();

  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodeTelefon = FocusNode();
  final FocusNode focusNodeUser = FocusNode();
  final FocusNode focusNodeNumeComplet = FocusNode();
  final FocusNode focusNodeResetareParola = FocusNode();

  bool editareContCorecta = false;
  bool showButonSalvare = true;

  void passVisibiltyToggle() {
    setState(() {
      isHidden = !isHidden;
    });
  }

  Future<http.Response?> updateDateClient() async {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    String textMessage = '';
    Color backgroundColor = Colors.red;
    Color textColor = Colors.black;

    http.Response? resUpdateDateClient = await apiCallFunctions.updateDateClient(
      pUser: user,
      pParola: userPassMD5,
      pNumeleComplet: controllerNumeComplet.text.isNotEmpty
          ? controllerNumeComplet.text
          : (widget.contInfo!.nume.isNotEmpty || widget.contInfo!.prenume.isNotEmpty)
              ? '${widget.contInfo!.nume} ${widget.contInfo!.prenume}'
              : '',
      pTelefonNou: controllerTelefon.text.isNotEmpty ? controllerTelefon.text : widget.contInfo!.telefon,
      pAdresaEmailNoua: controllerEmail.text.isNotEmpty ? controllerEmail.text : widget.contInfo!.email,
      pUserNou: controllerUser.text.isNotEmpty ? controllerUser.text : widget.contInfo!.user,
    );

    if (int.parse(resUpdateDateClient!.body) == 200) {
      setState(() {
        editareContCorecta = true;
        showButonSalvare = false;
      });

      //SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(pref_keys.userNumeComplet, controllerNumeComplet.text);
      prefs.setString(pref_keys.userEmail, controllerEmail.text);
      prefs.setString(pref_keys.userTelefon, controllerTelefon.text);
      prefs.setString(pref_keys.user, controllerUser.text);
      //prefs.setString(pref_keys.userPassMD5, controllerEmail.text);

      //prefs.setString(pref_keys.userPassMD5, apiCallFunctions.generateMd5(controllerResetareParola.text)); //old IGV

      //textMessage = 'Actualizare date finalizată cu succes!';  //old IGV
      textMessage = l.editareContActualizareFinalizataCuSucces;

      backgroundColor = const Color.fromARGB(255, 14, 190, 127);
      textColor = Colors.white;
    } else if (int.parse(resUpdateDateClient.body) == 400) {
      setState(() {
        editareContCorecta = false;
        showButonSalvare = true;
      });

      //textMessage = 'Apel invalid!'; //old IGV
      textMessage = l.editareContApelInvalid;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resUpdateDateClient.body) == 401) {
      prefs.setString(pref_keys.userEmail, controllerEmail.text);
      prefs.setString(pref_keys.userPassMD5, apiCallFunctions.generateMd5(controllerResetareParola.text));

      setState(() {
        editareContCorecta = false;
        showButonSalvare = true;
      });

      //textMessage = 'Datele nu au putut fi actualizate!'; //old IGV
      textMessage = l.editareContDateleNuAuPututFiActualizate;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resUpdateDateClient.body) == 405) {
      setState(() {
        editareContCorecta = false;
        showButonSalvare = true;
      });

      //textMessage = 'Informații insuficiente!'; //old IGV
      textMessage = l.editareContInformatiiInsuficiente;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resUpdateDateClient.body) == 500) {
      setState(() {
        editareContCorecta = false;
        showButonSalvare = true;
      });

      //textMessage = 'A apărut o eroare la execuția metodei!'; //old IGV
      textMessage = l.editareContEroareLaExecutiaMetodei;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    }

    if (context.mounted) {
      showSnackbar(context, textMessage, backgroundColor, textColor);

      return resUpdateDateClient;
    }

    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controllerEmail.text = widget.contInfo!.email;
    controllerTelefon.text = widget.contInfo!.telefon;
    controllerUser.text = widget.contInfo!.user;
    controllerNumeComplet.text = '${widget.contInfo!.nume} ${widget.contInfo!.prenume}';
  }

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromRGBO(30, 214, 158, 1),
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: const Color.fromRGBO(30, 214, 158, 1),
        foregroundColor: Colors.white,
        leading: const BackButton(
          color: Colors.white,
        ),
        title: Text(
          //'Profilul meu',
          l.editareContProfilulMeuTitlu,
          style: GoogleFonts.rubik(
              color: const Color.fromRGBO(255, 255, 255, 1), fontSize: 16, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /*
            const IconDateProfil(iconPathPacient: './assets/images/user_profil_icon.png', textNume: 'Cristina Mihalache', textAdresaEmail: 'cristina.24@gmail.com',
              textNumarTelefon: '+40 0770 545 224',),
            */
            IconDateProfil(
              iconPathPacient: widget.contInfo!.linkPozaProfil ?? '',
              textNume: '${widget.contInfo!.prenume} ${widget.contInfo!.nume}',
              textAdresaEmail: widget.contInfo!.email,
              textNumarTelefon: widget.contInfo!.telefon,
            ),
            const SizedBox(
              height: 35,
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Form(
                    key: registerKey,
                    child: GestureDetector(
                      onTap: () {
                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.only(top: 40, left: 30, right: 30),
                        child: Column(
                          children: [
                            TextFormField(
                              onFieldSubmitted: (String s) {
                                focusNodeTelefon.requestFocus();
                              },
                              controller: controllerEmail,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                prefixIcon: Image.asset(
                                  'assets/images/mail_icon.png',
                                  width: 15,
                                  height: 15, //fit: BoxFit.fill,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                  ),
                                ),
                                border: InputBorder.none,

                                filled: true,
                                fillColor: Colors.white,
                                //hintText: "Email", //old IGV
                                hintText: l.editareContEmailHint,
                                hintStyle: const TextStyle(
                                    color: Color.fromRGBO(59, 86, 110, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400), //added by George Valentin Iordache
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
                                //String phonePattern = r'(^(?:[+0]4)?[0-9]{10}$)';
                                //RegExp phoneRegExp = RegExp(phonePattern);
                                //String namePattern = r"^\s*([A-Za-z]{1,}([\.,] |[-']| ))+[A-Za-z]+\.?\s*$";
                                //String namePattern = r'^[a-z A-Z,.\-]+$';
                                //String userNamePattern = r'^(?=[a-zA-Z][a-zA-Z0-9._]{7,29}$)(?!.*[_.]{2})[^_.].*[^_.]$';
                                //RegExp nameRegExp = RegExp(userNamePattern);
                                if (value!.isEmpty || !(emailRegExp.hasMatch(value)))
                                // || phoneRegExp.hasMatch(value) || nameRegExp.hasMatch(value)))
                                {
                                  //return "Introduceți un email valid!"; //old IGV
                                  return l.editareContIntroducetiEmailValid;
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            customDividerProfil(),
                            const SizedBox(height: 10),
                            TextFormField(
                              onFieldSubmitted: (String s) {
                                focusNodeUser.requestFocus();
                              },
                              controller: controllerTelefon,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: Color.fromRGBO(30, 214, 158, 1),
                                  size: 15,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                  ),
                                ),
                                border: InputBorder.none,
                                /*
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                    width: 1.0,
                                  ),
                                ),
                                */
                                filled: true,
                                fillColor: Colors.white,
                                //hintText: "Telefon", //old IGV
                                hintText: l.editareContTelefonHint,
                                hintStyle: const TextStyle(
                                    color: Color.fromRGBO(59, 86, 110, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400), //added by George Valentin Iordache
                              ),
                              validator: (value) {
                                //String emailPattern = r'.+@.+\.+';
                                //RegExp emailRegExp = RegExp(emailPattern);
                                String phonePattern = r'(^(?:[+0]4)?[0-9]{10}$)';
                                RegExp phoneRegExp = RegExp(phonePattern);
                                //String namePattern = r"^\s*([A-Za-z]{1,}([\.,] |[-']| ))+[A-Za-z]+\.?\s*$";
                                //String namePattern = r'^[a-z A-Z,.\-]+$';
                                //String userNamePattern = r'^(?=[a-zA-Z][a-zA-Z0-9._]{7,29}$)(?!.*[_.]{2})[^_.].*[^_.]$';
                                //RegExp nameRegExp = RegExp(userNamePattern);
                                //if (value!.isEmpty || !(emailRegExp.hasMatch(value)))
                                // || phoneRegExp.hasMatch(value) || nameRegExp.hasMatch(value)))
                                if (value!.isEmpty || !(phoneRegExp.hasMatch(value))) {
                                  //return "Introduceți un număr de telefon valid!";
                                  return l.editareContIntroducetiTelefonValid;
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            customDividerProfil(),
                            const SizedBox(height: 10),
                            TextFormField(
                              onFieldSubmitted: (String s) {
                                focusNodeResetareParola.requestFocus();
                              },
                              controller: controllerUser,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                prefixIcon: Image.asset(
                                  'assets/images/user_icon.png',
                                  width: 15,
                                  height: 15, //fit: BoxFit.fill,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                  ),
                                ),
                                border: InputBorder.none,
                                /*
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                    width: 1.0,
                                  ),
                                ),
                                */
                                filled: true,
                                fillColor: Colors.white,
                                //hintText: "User", //old IGV
                                hintText: l.editareContUserHint,
                                hintStyle: const TextStyle(
                                    color: Color.fromRGBO(59, 86, 110, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400), //added by George Valentin Iordache
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  controllerUser.value = TextEditingValue(
                                    text: value[0].toUpperCase() + value.substring(1),
                                    selection: controllerUser.selection,
                                  );
                                }
                              },
                              validator: (value) {
                                //String emailPattern = r'.+@.+\.+';
                                //RegExp emailRegExp = RegExp(emailPattern);
                                //String phonePattern = r'(^(?:[+0]4)?[0-9]{10}$)';
                                //RegExp phoneRegExp = RegExp(phonePattern);
                                //String namePattern = r"^\s*([A-Za-z]{1,}([\.,] |[-']| ))+[A-Za-z]+\.?\s*$";
                                //String namePattern = r'^[a-z A-Z,.\-]+$';
                                //String userNamePattern = r'^(?=[a-zA-Z][a-zA-Z0-9._]{7,29}$)(?!.*[_.]{2})[^_.].*[^_.]$';
                                //RegExp nameRegExp = RegExp(userNamePattern);
                                if (value!.isEmpty)
                                // || phoneRegExp.hasMatch(value) || nameRegExp.hasMatch(value)))
                                {
                                  //return "Introduceți un utilizator!";
                                  return l.editareContIntroducetiUtilizator;
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            customDividerProfil(),
                            const SizedBox(height: 10),
                            TextFormField(
                              onFieldSubmitted: (String s) {
                                focusNodeResetareParola.requestFocus();
                              },
                              textCapitalization: TextCapitalization.sentences,
                              controller: controllerNumeComplet,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.account_circle,
                                  color: Color.fromRGBO(30, 214, 158, 1),
                                  size: 15,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                  ),
                                ),
                                border: InputBorder.none,
                                /*
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                    width: 1.0,
                                  ),
                                ),
                                */
                                filled: true,
                                fillColor: Colors.white,
                                //hintText: "Numele complet", //old IGV
                                hintText: l.editareContNumeleCompletHint,
                                hintStyle: const TextStyle(
                                    color: Color.fromRGBO(59, 86, 110, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400), //added by George Valentin Iordache
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
                                //String emailPattern = r'.+@.+\.+';
                                //RegExp emailRegExp = RegExp(emailPattern);
                                //String phonePattern = r'(^(?:[+0]4)?[0-9]{10}$)';
                                //RegExp phoneRegExp = RegExp(phonePattern);
                                //String namePattern = r"^\s*([A-Za-z]{1,}([\.,] |[-']| ))+[A-Za-z]+\.?\s*$";
                                //String namePattern = r'^[a-z A-Z,.\-]+$';
                                //String userNamePattern = r'^(?=[a-zA-Z][a-zA-Z0-9._]{7,29}$)(?!.*[_.]{2})[^_.].*[^_.]$';
                                //RegExp nameRegExp = RegExp(userNamePattern);
                                if (value!.isEmpty)
                                // || phoneRegExp.hasMatch(value) || nameRegExp.hasMatch(value)))
                                {
                                  //return "Introduceți numele complet!"; //old IGV
                                  return l.editareContIntroducetiNumeleComplet;
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            customDividerProfil(),
                            const SizedBox(height: 20),
                            /*
                            TextFormField(
                              focusNode: focusNodeResetareParola,
                              controller: controllerResetareParola,
                              obscureText: isHidden,
                              decoration: InputDecoration(
                                prefixIcon: Image.asset(
                                  'assets/images/resetare_parola_icon.png',
                                  width: 15,
                                  height: 15,    //fit: BoxFit.fill,
                                ),
                                suffixIcon: IconButton(
                                    onPressed: passVisibiltyToggle,
                                    icon: isHidden ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off)),
                                //hintText: "Parola noua", old
                                //hintText: "Resetare parolă", //old IGV
                                hintText: l.editareContResetareParolaHint,
                                hintStyle: const TextStyle(color: Color.fromRGBO(103, 114, 148, 1), fontSize: 14, fontWeight: FontWeight.w400), //added by George Valentin Iordache
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                  ),
                                ),
                                //enabledBorder: OutlineInputBorder(
                                //  borderRadius: BorderRadius.circular(5),
                                //  borderSide: const BorderSide(
                                //    color: Color.fromRGBO(205, 211, 223, 1),
                                //    width: 1.0,
                                //  ),
                                //),

                                border: InputBorder.none,
                                filled: true,
                                fillColor: Colors.white),
                              validator: (value) {
                                if (value!.isEmpty) {

                                  //return "Vă rugăm introduceți o parolă!"; //old IGV
                                  return l.editareContVaRugamIntroducetiParola;

                                } else if (value.length < 6) {
                                  //return "Parola trebuie să aibă cel puțin 6 caractere!"; //old IGV
                                  return l.editareContParolaTrebuieSaContina;
                                } else {
                                  return null;
                                }
                              },
                            ),
                            */
                            ExpandTapWidget(
                              tapPadding: const EdgeInsets.all(10.0),
                              child: Row(children: [
                                const SizedBox(width: 18),
                                Image.asset(
                                  'assets/images/resetare_parola_icon.png',
                                  width: 15,
                                  height: 15, //fit: BoxFit.fill,
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  l.editareContResetareParola,
                                  style: const TextStyle(
                                      color: Color.fromRGBO(103, 114, 148, 1),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                              ]),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return const ResetPasswordPacientScreen();
                                    //return const PlataEsuataScreen();
                                  },
                                ));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  customDividerProfil(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 284,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            final isValidForm = registerKey.currentState!.validate();
                            if (isValidForm) {
                              setState(() {
                                editareContCorecta = false;
                                showButonSalvare = false;
                              });

                              http.Response? resUpdateDateClient;

                              resUpdateDateClient = await updateDateClient();

                              if (context.mounted) {
                                if (int.parse(resUpdateDateClient!.body) == 200) {
                                  ContClientMobile? contInfo;

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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfilulMeuPacientScreen(
                                        contInfo: contInfo!,
                                      ),
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    editareContCorecta = false;
                                    showButonSalvare = true;
                                  });
                                }
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
                              //'Salvare date', //old IGV
                              l.editareContSalvareDate,
                              style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.09),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IconDateProfil extends StatefulWidget {
  final String iconPathPacient;
  final String textNume;
  final String textAdresaEmail;
  final String textNumarTelefon;

  const IconDateProfil({
    super.key,
    required this.iconPathPacient,
    required this.textNume,
    required this.textAdresaEmail,
    required this.textNumarTelefon,
  });

  @override
  State<IconDateProfil> createState() => _IconDateProfilState();
}

class _IconDateProfilState extends State<IconDateProfil> {
  Uint8List? _profileImage;
  final ImagePicker _picker = ImagePicker();
  File _selectedImage = File('');
  bool pozaStearsa = false;

  @override
  void initState() {
    super.initState();
    _loadAndDecodeImage();
  }

  Future<void> _loadAndDecodeImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? base64Image = prefs.getString(pref_keys.profileImageUrl);
    if (base64Image != null && base64Image.isNotEmpty) {
      setState(() {
        _profileImage = base64Decode(base64Image);
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // const SizedBox(width: 30),
        Stack(
          children: [
            if (_selectedImage.path == '')
              ClipOval(
                child: SizedBox(
                  height: 65,
                  width: 65,
                  child: _selectedImage.path.isEmpty
                      ? (_profileImage != null
                          ? Image.memory(
                              _profileImage!,
                              width: 65,
                              height: 65,
                              fit: BoxFit.cover,
                            )
                          : pozaStearsa
                              ? Image.asset(
                                  './assets/images/user_fara_poza.png',
                                  width: 65,
                                  height: 65,
                                  fit: BoxFit.cover,
                                )
                              : widget.iconPathPacient.isEmpty
                                  ? Image.asset(
                                      './assets/images/user_fara_poza.png',
                                      width: 65,
                                      height: 65,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      widget.iconPathPacient,
                                      width: 65,
                                      height: 65,
                                      fit: BoxFit.cover,
                                    ))
                      : Image.file(
                          _selectedImage,
                          width: 65,
                          height: 65,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            if (_selectedImage.path != "")
              ClipOval(
                child: SizedBox(
                  height: 65,
                  width: 65,
                  child: Image.file(_selectedImage, fit: BoxFit.cover),
                ),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  _updatePhotoDialog();
                },
                child: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromRGBO(30, 214, 158, 1),
                      border: Border.all(width: 1, color: Colors.white),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 15,
                      ),
                    )),
              ),
            )
          ],
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.textNume,
              style:
                  const TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 24, fontWeight: FontWeight.w400),
            ),
            Text(
              widget.textAdresaEmail,
              style:
                  const TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 12, fontWeight: FontWeight.w400),
            ),
            Text(
              widget.textNumarTelefon,
              style:
                  const TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _takePhoto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Uint8List? selectedImageBytes;

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      setState(() {
        pozaStearsa = false;
        selectedImageBytes = Uint8List.fromList(bytes);
        _selectedImage = File(photo.path);

        String base64Image = base64Encode(selectedImageBytes!);
        prefs.setString(pref_keys.profileImageUrl, base64Image);

        apiCallFunctions.uploadPicture(
          pExtensie: '.jpg',
          pUser: user,
          pParola: userPassMD5,
          pSirBitiDocument: selectedImageBytes.toString(),
        );
      });
    } else {}
  }

  Future<void> _chooseFromGallery() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Uint8List? selectedImageBytes;

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      setState(() {
        pozaStearsa = false;
        selectedImageBytes = Uint8List.fromList(bytes);
        _selectedImage = File(photo.path);

        // Save the image to SharedPreferences
        String base64Image = base64Encode(selectedImageBytes!);
        prefs.setString(pref_keys.profileImageUrl, base64Image);

        // Print the saved image

        // Upload picture as before
        apiCallFunctions.uploadPicture(
          pExtensie: '.jpg',
          pUser: user,
          pParola: userPassMD5,
          pSirBitiDocument: selectedImageBytes.toString(),
        );
      });
    } else {}
  }

  _updatePhotoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Schimba poza de profil"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.camera),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galerie'),
                  onTap: () {
                    Navigator.pop(context);
                    _chooseFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Sterge poza curenta'),
                  onTap: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();

                    // Set the flags and variables to indicate the image is deleted
                    pozaStearsa = true;
                    _selectedImage = File(""); // Reset the file
                    _profileImage = null; // Clear the loaded image from SharedPreferences

                    // Remove the image from SharedPreferences
                    await prefs.remove(pref_keys.profileImageUrl);

                    // Also, remove the image from the API
                    String user = prefs.getString('user') ?? '';
                    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
                    await apiCallFunctions.deletePicture(pUser: user, pParola: userPassMD5);

                    // Close the dialog and update the UI
                    Navigator.pop(context);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
