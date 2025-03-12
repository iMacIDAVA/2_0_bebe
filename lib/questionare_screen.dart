import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sos_bebe_app/apel_video_pacient_screen.dart';
import 'package:sos_bebe_app/chat_screen.dart/chat_screen.dart';
import 'package:sos_bebe_app/utils/utils_widgets.dart';
import 'package:sos_bebe_app/utils_api/api_config.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';

import 'package:sos_bebe_app/raspunde_intrebare_doar_chat_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;
import 'package:http/http.dart' as http;
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:sos_bebe_app/utils_api/functions.dart';
import 'package:intl/intl.dart';

import 'package:sos_bebe_app/localizations/1_localizations.dart';
import 'package:sos_bebe_app/vezi_toti_medicii_screen.dart';

ApiCallFunctions apiCallFunctions = ApiCallFunctions();

ChestionarClientMobile? chestionarInitial;

class QuestionaireScreen extends StatefulWidget {
  final int tipServiciu;
  final String pret;

  final ContClientMobile contClientMobile;

  final MedicMobile medicDetalii;

  final bool chatOnly;


  const QuestionaireScreen({
    super.key,
    required this.tipServiciu,
    required this.contClientMobile,
    required this.medicDetalii, required this.pret, required this.chatOnly,
  });

  @override
  State<QuestionaireScreen> createState() => _QuestionaireScreenState();
}

class _QuestionaireScreenState extends State<QuestionaireScreen> {

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

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (remainingTimeNotifier.value > 0) {
        remainingTimeNotifier.value--;
      } else {
        timer.cancel();

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

  void callbackVisible(bool newIsVisible) {
    setState(() {
      isVisible = newIsVisible;
    });
  }

  void callbackVisibleAlergicLaMedicament(bool newIsVisibleAlergicLaMedicament) {
    setState(() {
      isVisibleAlergicLaMedicament = newIsVisibleAlergicLaMedicament;
    });
  }

  void callbackFebra(bool newIsToggledFebra) {
    setState(() {
      isToggledFebra = newIsToggledFebra;
    });
  }

  void callbackTuse(bool newIsToggledTuse) {
    setState(() {
      isToggledTuse = newIsToggledTuse;
    });
  }

  void callbackDificultatiRespiratorii(bool newIsToggledDificultatiRespiratorii) {
    setState(() {
      isToggledDificultatiRespiratorii = newIsToggledDificultatiRespiratorii;
    });
  }

  void callbackAstenie(bool newIsToggledAstenie) {
    setState(() {
      isToggledAstenie = newIsToggledAstenie;
    });
  }

  void callbackCefalee(bool newIsToggledCefalee) {
    setState(() {
      isToggledCefalee = newIsToggledCefalee;
    });
  }

  void callbackDureriInGat(bool newIsToggledDureriInGat) {
    setState(() {
      isToggledDureriInGat = newIsToggledDureriInGat;
    });
  }

  void callbackGreturiVarsaturi(bool newIsToggledGreturiVarsaturi) {
    setState(() {
      isToggledGreturiVarsaturi = newIsToggledGreturiVarsaturi;
    });
  }

  void callbackDiareeConstipatie(bool newIsToggledDiareeConstipatie) {
    setState(() {
      isToggledDiareeConstipatie = newIsToggledDiareeConstipatie;
    });
  }

  void callbackRefuzulAlimentatie(bool newIsToggledRefuzulAlimentatie) {
    setState(() {
      isToggledRefuzulAlimentatie = newIsToggledRefuzulAlimentatie;
    });
  }

  void callbackIritatiiPiele(bool newIsToggledIritatiiPiele) {
    setState(() {
      isToggledIritatiiPiele = newIsToggledIritatiiPiele;
    });
  }

  void callbackNasInfundat(bool newIsToggledNasInfundat) {
    setState(() {
      isToggledNasInfundat = newIsToggledNasInfundat;
    });
  }

  void callbackRinoree(bool newIsToggledRinoree) {
    setState(() {
      isToggledRinoree = newIsToggledRinoree;
    });
  }

  //old IGV
  /*
  void callbackAlergicLaMedicament(String newAlergicLaMedicament) {
    setState(() {
      alergicLaMedicament = newAlergicLaMedicament;
    });
  }
  */

  bool isToggled = false;
  bool isVisible = false;
  bool isVisibleAlergicLaMedicament = false;
  String alergicLaMedicament = '';

  bool isToggledAlergicLaMedicament = false;
  bool isToggledFebra = false;
  bool isToggledTuse = false;
  bool isToggledDificultatiRespiratorii = false;
  bool isToggledAstenie = false;
  bool isToggledCefalee = false;
  bool isToggledDureriInGat = false;
  bool isToggledGreturiVarsaturi = false;
  bool isToggledDiareeConstipatie = false;
  bool isToggledRefuzulAlimentatie = false;
  bool isToggledIritatiiPiele = false;
  bool isToggledNasInfundat = false;
  bool isToggledRinoree = false;

  DateTime dataNastere = DateTime.now();

  bool dateChosen = true;
  String hintDataNastere = '';

  String dataDeNastereVeche = '';

  final questionaireKey = GlobalKey<FormState>();

  final controllerAlergicLaMedicamentText = TextEditingController();

  TextEditingController controllerNumeComplet = TextEditingController();
  TextEditingController controllerDataNastere = TextEditingController();
  TextEditingController controllerGreutate = TextEditingController();

  TextEditingController controllerNumePrenumeComplet = TextEditingController();

  final FocusNode focusNodeNumeComplet = FocusNode();
  final FocusNode focusNodeDataNastere = FocusNode();
  final FocusNode focusNodeGreutate = FocusNode();

  final FocusNode focusNodePrenumeComplet = FocusNode();

  bool chestionarTrimis = false;
  bool showButonTrimite = true;

  @override
  void initState() {
    super.initState();
    loadQuestionnaireData();
       startTimer();
  }

  Future<void> loadQuestionnaireData() async {
    await getUltimulChestionarCompletatByContClient();

    if (chestionarInitial != null) {
      setState(() {
        if (chestionarInitial!.numeCompletat.isNotEmpty) {
          controllerNumeComplet.text = chestionarInitial!.numeCompletat;
        }

        if (chestionarInitial!.numeCompletat.isNotEmpty) {
          controllerNumePrenumeComplet.text = chestionarInitial!.numeCompletat + chestionarInitial!.prenumeCompletat;
        }

        if (chestionarInitial!.dataNastereCompletata.toString().isNotEmpty) {
          controllerDataNastere.text =
              DateFormat("dd.MM.yyyy").format(chestionarInitial!.dataNastereCompletata).toString();
        }

        if (chestionarInitial!.greutateCompletata.isNotEmpty) {
          controllerGreutate.text = chestionarInitial!.greutateCompletata;
        }

        // Set the toggle switches and visibility based on the previously entered data
        isVisibleAlergicLaMedicament = (chestionarInitial!.listaRaspunsuri[0].raspunsIntrebare == '1');

        if (isVisibleAlergicLaMedicament && chestionarInitial!.listaRaspunsuri[0].informatiiComplementare.isNotEmpty) {
          alergicLaMedicament = chestionarInitial!.listaRaspunsuri[0].informatiiComplementare;
          controllerAlergicLaMedicamentText.text = alergicLaMedicament;
        }

        isToggledFebra = (chestionarInitial!.listaRaspunsuri[1].raspunsIntrebare == '1');
        isToggledTuse = (chestionarInitial!.listaRaspunsuri[2].raspunsIntrebare == '1');
        isToggledDificultatiRespiratorii = (chestionarInitial!.listaRaspunsuri[3].raspunsIntrebare == '1');
        isToggledAstenie = (chestionarInitial!.listaRaspunsuri[4].raspunsIntrebare == '1');
        isToggledCefalee = (chestionarInitial!.listaRaspunsuri[5].raspunsIntrebare == '1');
        isToggledDureriInGat = (chestionarInitial!.listaRaspunsuri[6].raspunsIntrebare == '1');
        isToggledGreturiVarsaturi = (chestionarInitial!.listaRaspunsuri[7].raspunsIntrebare == '1');
        isToggledDiareeConstipatie = (chestionarInitial!.listaRaspunsuri[8].raspunsIntrebare == '1');
        isToggledRefuzulAlimentatie = (chestionarInitial!.listaRaspunsuri[9].raspunsIntrebare == '1');
        isToggledIritatiiPiele = (chestionarInitial!.listaRaspunsuri[10].raspunsIntrebare == '1');
        isToggledNasInfundat = (chestionarInitial!.listaRaspunsuri[11].raspunsIntrebare == '1');
        isToggledRinoree = (chestionarInitial!.listaRaspunsuri[12].raspunsIntrebare == '1');
      });
    }
  }

  Future<ChestionarClientMobile?> getUltimulChestionarCompletatByContClient() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    chestionarInitial = await apiCallFunctions.getUltimulChestionarCompletatByContClient(
      pUser: user,
      pParola: userPassMD5,
    );

    if (chestionarInitial != null) {
      // Debug each field of chestionarInitial individually

      // Loop through the listaRaspunsuri to inspect each answer
    } else {}

    return chestionarInitial;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.

    controllerAlergicLaMedicamentText.dispose();

     countdownTimer?.cancel(); // ✅ Cancel timer
    remainingTimeNotifier.dispose();

    super.dispose();
  }

  Future<http.Response?> updateChestionarDinContClient() async {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    String textMessage = '';
    Color backgroundColor = Colors.red;
    Color textColor = Colors.black;

    /*
    http.Response? res = await apiCallFunctions.getContClient(
      pUser: controllerEmail.text,
      pParola: controllerPass.text,
    );
    */

    String pNumeleComplet = controllerNumeComplet.text;

    String pNumelePrenumeComplet = controllerNumePrenumeComplet.text;

    DateFormat dateFormat = DateFormat('dd.MM.yyyy');
    DateTime parsedDate = dateFormat.parse(controllerDataNastere.text);
    String pDataNastereDDMMYYYY = DateFormat('ddMMyyyy').format(parsedDate).toString();

    String pGreutate = controllerGreutate.text;

    String pListaRaspunsuri = '';

    pListaRaspunsuri =
        '${pListaRaspunsuri}1\$-\$${(isVisibleAlergicLaMedicament ? '1' : '2')}\$-\$${(isVisibleAlergicLaMedicament ? controllerAlergicLaMedicamentText.text : '')}*\$*';
    pListaRaspunsuri = '${pListaRaspunsuri}2\$-\$${(isToggledFebra ? '1' : '2')}\$-\$\$-\$*\$*';
    pListaRaspunsuri = '${pListaRaspunsuri}3\$-\$${(isToggledTuse ? '1' : '2')}\$-\$\$-\$*\$*';
    pListaRaspunsuri = '${pListaRaspunsuri}4\$-\$${(isToggledDificultatiRespiratorii ? '1' : '2')}\$-\$\$-\$*\$*';
    pListaRaspunsuri = '${pListaRaspunsuri}5\$-\$${(isToggledAstenie ? '1' : '2')}\$-\$\$-\$*\$*';
    pListaRaspunsuri = '${pListaRaspunsuri}6\$-\$${(isToggledCefalee ? '1' : '2')}\$-\$\$-\$*\$*';
    pListaRaspunsuri = '${pListaRaspunsuri}7\$-\$${(isToggledDureriInGat ? '1' : '2')}\$-\$\$-\$*\$*';
    pListaRaspunsuri = '${pListaRaspunsuri}8\$-\$${(isToggledGreturiVarsaturi ? '1' : '2')}\$-\$\$-\$*\$*';
    pListaRaspunsuri = '${pListaRaspunsuri}9\$-\$${(isToggledDiareeConstipatie ? '1' : '2')}\$-\$\$-\$*\$*';
    pListaRaspunsuri = '${pListaRaspunsuri}10\$-\$${(isToggledRefuzulAlimentatie ? '1' : '2')}\$-\$\$-\$*\$*';
    pListaRaspunsuri = '${pListaRaspunsuri}11\$-\$${(isToggledIritatiiPiele ? '1' : '2')}\$-\$\$-\$*\$*';
    pListaRaspunsuri = '${pListaRaspunsuri}12\$-\$${(isToggledNasInfundat ? '1' : '2')}\$-\$\$-\$*\$*';
    pListaRaspunsuri = '${pListaRaspunsuri}13\$-\$${(isToggledRinoree ? '1' : '2')}\$-\$\$-\$*\$*';

    http.Response? resUpdateChestionarDinContClient = await apiCallFunctions.updateChestionarDinContClient(
      pUser: user,
      pParola: userPassMD5,
      pNumeleComplet: pNumeleComplet,
      pDataNastereDDMMYYYY: pDataNastereDDMMYYYY,
      pGreutate: pGreutate,
      pListaRaspunsuri: pListaRaspunsuri,
    );

    if (int.parse(resUpdateChestionarDinContClient!.body) == 200) {
      setState(() {
        chestionarTrimis = true;
        showButonTrimite = false;
      });

      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //prefs.setString(pref_keys.userPassMD5, controllerEmail.text);

      //textMessage = 'Date chestionar trimise cu succes!'; //old IGV
      textMessage = l.questionareDateChestionarTrimiseCuSucces;
      backgroundColor = const Color.fromARGB(255, 14, 190, 127);
      textColor = Colors.white;
    } else if (int.parse(resUpdateChestionarDinContClient.body) == 400) {
      setState(() {
        chestionarTrimis = false;
        showButonTrimite = true;
      });

      //textMessage = 'Apel invalid!'; //old IGV

      textMessage = l.questionareApelInvalid;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resUpdateChestionarDinContClient.body) == 401) {
      /*prefs.setString(pref_keys.userEmail, controllerEmail.text);
      prefs.setString(pref_keys.userPassMD5, apiCallFunctions.generateMd5(controllerResetareParola.text));
      */

      setState(() {
        chestionarTrimis = false;
        showButonTrimite = true;
      });

      //textMessage = 'Datele nu au putut fi trimise!'; //old IGV
      textMessage = l.questionareDateleNuAuPututFiTrimise;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resUpdateChestionarDinContClient.body) == 405) {
      setState(() {
        chestionarTrimis = false;
        showButonTrimite = true;
      });

      //textMessage = 'Informații insuficiente!'; //old IGV
      textMessage = l.questionareInformatiiInsuficiente;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resUpdateChestionarDinContClient.body) == 500) {
      setState(() {
        chestionarTrimis = false;
        showButonTrimite = true;
      });

      //textMessage = 'A apărut o eroare la execuția metodei!'; //old IGV
      textMessage = l.questionareAAparutOEroare;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    }

    if (context.mounted) {
      showSnackbar(context, textMessage, backgroundColor, textColor);

      return resUpdateChestionarDinContClient;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    return WillPopScope(
      onWillPop: () async => false,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: Scaffold(
          body: SingleChildScrollView(
              child: Column(
            children: [
              const SizedBox(height: 20),
              // Row(
              //   children: [
              //     IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_outlined))
              //   ],
              // ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Form(
                  key: questionaireKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Text(
                                //'Chestionar', //old IGV
                                l.questionareChestionar,
                                style: GoogleFonts.rubik(
                                    color: const Color.fromRGBO(103, 114, 148, 1),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),










                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Text('Varsta', style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w400)), old
                          //Text('1 an si 8 luni', style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w400)) old

                          //adăugat de George Valentin Iordache
                          Text(
                            //'Data naștere',  //old IGV
                              'Reprezentant legal al copilului\nNume și Prenume',
                              style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800)),
                          //Text('1 an si 8 luni', style: GoogleFonts.rubik(color: const Color.fromRGBO(103, 114, 148, 1), fontSize: 12, fontWeight: FontWeight.w300)),
                          SizedBox(
                            width: 150.0,
                            child: TextFormField(
                                onTap: () async {
                                  DateTime? date = await showDatePicker(
                                    context: context,
                                    locale: const Locale("ro", "RO"),
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1960),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          splashColor: const Color.fromARGB(255, 200, 200, 200), //Colors.red,
                                          colorScheme: const ColorScheme.light(
                                            surface: Colors.white,
                                            primary: Color.fromARGB(255, 14, 190, 127), // // <-- SEE HERE
                                            //onSurface: Colors.white, // <-- SEE HERE
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.black, // button text color
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  // setState(() {
                                  //   //controllerDataNastere.text = DateFormat('ddMMyyyy').format(date!).toString(); //old IGV
                                  //   controllerDataNastere.text =
                                  //       DateFormat(l.questionareDateFormat).format(date!).toString();
                                  //   dataNastere = date;
                                  //   dateChosen = true;
                                  //   hintDataNastere = controllerDataNastere.text;
                                  // });
                                },
                                controller: controllerNumeComplet,
                                focusNode: focusNodePrenumeComplet,
                                style: GoogleFonts.rubik(
                                    color: const Color.fromRGBO(103, 114, 148, 1),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300),
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  //hintText: 'Număr ani și număr luni', //old IGV
                                  //hintText: 'Data naștere', //old IGV
                                  hintText: l.questionareDataNastereHint,
                                ),
                                // validator: (value) {
                                //   value = controllerNumePrenumeComplet.text;
                                //   if ((dataDeNastereVeche.isEmpty) && value.isEmpty) {
                                //     //return "Enter a valid Email Address or Password"; //old Andrei Bădescu
                                //
                                //     //return "Introduceți o dată de naștere!"; //old IGV
                                //     return l.questionareIntroducetiDataNastere;
                                //   }
                                //   return null;
                                // }
                                ),
                          ),
                        ],
                      ),









                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Text(
                                  //'Nume și prenume pacient', //old IGV
                                  l.questionareNumePrenumePacient,
                                  style: GoogleFonts.rubik(
                                      color: const Color.fromRGBO(103, 114, 148, 1),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400)),
                            ),
                          ),
                          Flexible(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: TextFormField(
                                textCapitalization: TextCapitalization.sentences,
                                controller: controllerNumeComplet,
                                focusNode: focusNodeNumeComplet,
                                autocorrect: false,
                                readOnly: false,
                                style: GoogleFonts.rubik(
                                    color: const Color.fromRGBO(103, 114, 148, 1),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300),
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  //hintText: 'Nume copil', //old IGV
                                  hintText: l.questionareNumeCopilHint,
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
                                    //return 'Introduceti numele și prenumele pacientului!'; //old IGV
                                    return l.questionareIntroducetiNumePrenumePacient;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          //Text('Laura Popescu', style: GoogleFonts.rubik(color: const Color.fromRGBO(103, 114, 148, 1), fontSize: 12, fontWeight: FontWeight.w300)),
                        ],
                      ),
                      customDivider(),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Text('Varsta', style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w400)), old
                          //Text('1 an si 8 luni', style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w400)) old

                          //adăugat de George Valentin Iordache
                          Text(
                              //'Data naștere',  //old IGV
                              l.questionareDataNastere,
                              style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400)),
                          //Text('1 an si 8 luni', style: GoogleFonts.rubik(color: const Color.fromRGBO(103, 114, 148, 1), fontSize: 12, fontWeight: FontWeight.w300)),
                          SizedBox(
                            width: 150.0,
                            child: TextFormField(
                                onTap: () async {
                                  DateTime? date = await showDatePicker(
                                    context: context,
                                    locale: const Locale("ro", "RO"),
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1960),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          splashColor: const Color.fromARGB(255, 200, 200, 200), //Colors.red,
                                          colorScheme: const ColorScheme.light(
                                            surface: Colors.white,
                                            primary: Color.fromARGB(255, 14, 190, 127), // // <-- SEE HERE
                                            //onSurface: Colors.white, // <-- SEE HERE
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.black, // button text color
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  setState(() {
                                    //controllerDataNastere.text = DateFormat('ddMMyyyy').format(date!).toString(); //old IGV
                                    controllerDataNastere.text =
                                        DateFormat(l.questionareDateFormat).format(date!).toString();
                                    dataNastere = date;
                                    dateChosen = true;
                                    hintDataNastere = controllerDataNastere.text;
                                  });
                                },
                                controller: controllerDataNastere,
                                focusNode: focusNodeDataNastere,
                                style: GoogleFonts.rubik(
                                    color: const Color.fromRGBO(103, 114, 148, 1),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300),
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  //hintText: 'Număr ani și număr luni', //old IGV
                                  //hintText: 'Data naștere', //old IGV
                                  hintText: l.questionareDataNastereHint,
                                ),
                                validator: (value) {
                                  value = controllerDataNastere.text;
                                  if ((dataDeNastereVeche.isEmpty) && value.isEmpty) {
                                    //return "Enter a valid Email Address or Password"; //old Andrei Bădescu

                                    //return "Introduceți o dată de naștere!"; //old IGV
                                    return l.questionareIntroducetiDataNastere;
                                  }
                                  return null;
                                }),
                          ),
                        ],
                      ),
                      customDivider(),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Text('Greutate', style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w400)),
                          // Text('10 kg', style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w400))

                          //adăugat de George Valentin Iordache
                          Text(
                              //'Greutate', //IGV
                              l.questionareGreutate,
                              style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400)),
                          //Text('10 kg', style: GoogleFonts.rubik(color: const Color.fromRGBO(103, 114, 148, 1), fontSize: 12, fontWeight: FontWeight.w300))
                          SizedBox(
                            width: 150.0,
                            child: TextFormField(
                              controller: controllerGreutate,
                              style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300),
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                //hintText: 'Număr kilograme', //old IGV
                                hintText: l.questionareNumarKilograme,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  if (value[value.length - 1] == ' ') {
                                    controllerGreutate.value = TextEditingValue(
                                      text: value,
                                      selection: controllerGreutate.selection,
                                    );
                                  } else {
                                    List<String> words = value.split(' ');
                                    for (int i = 0; i < words.length; i++) {
                                      if (words[i].isNotEmpty) {
                                        words[i] = words[i][0].toUpperCase() + words[i].substring(1);
                                      }
                                    }
                                    String updatedValue = words.join(' ');

                                    controllerGreutate.value = TextEditingValue(
                                      text: updatedValue,
                                      selection: controllerGreutate.selection,
                                    );
                                  }
                                }
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  //return 'Introduceti numărul de kilograme';
                                  return l.questionareIntroducetiNumarKilograme;
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    customDivider(),
                    const SizedBox(height: 10),
                    //TextAndSwitchWidget(isToggled: isVisibleAlergicLaMedicament, disease: "Alergic la vreun medicament?", callback: callbackVisibleAlergicLaMedicament), //old IGV
                    TextAndSwitchWidget(
                        isToggled: isVisibleAlergicLaMedicament,
                        disease: l.questionareAlergicLaMedicament,
                        callback: callbackVisibleAlergicLaMedicament),

                    Visibility(
                      //visible: isVisible, //old IGV
                      visible: isVisibleAlergicLaMedicament,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                  //'La ce medicament este alergic?', //old IGV
                                  l.questionareLaCeMedicamentEsteAlergic,

                                  //style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w400)), old

                                  //adăugat de George Valentin Iordache
                                  style: GoogleFonts.rubik(
                                      color: const Color.fromRGBO(103, 114, 148, 1),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromARGB(255, 242, 239, 239),
                            ),
                            height: 70,
                            child: TextField(
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              controller: controllerAlergicLaMedicamentText,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                //hintText: 'Alergic la paracetamol...', //old IGV
                                hintText: l.questionareAlergicLaParacetamol,
                                //added by George Valentin Iordache
                                hintStyle: const TextStyle(
                                    color: Color.fromRGBO(103, 114, 148, 1), fontSize: 12, fontWeight: FontWeight.w300),
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(children: [
                      //Text('Simptome pacient', style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w500)) old

                      //adăugat de George Valentin Iordache
                      Text(
                          //'Simptome pacient', //old IGV
                          l.questionareSimptomePacient,
                          style: GoogleFonts.rubik(
                              color: const Color.fromRGBO(103, 114, 148, 1), fontSize: 12, fontWeight: FontWeight.w500)),
                    ]),
                    const SizedBox(height: 15),

                    //TextAndSwitchWidget(isToggled: isToggledFebra, disease: "Febră", callback: callbackFebra,), //old IGV
                    TextAndSwitchWidget(
                      isToggled: isToggledFebra,
                      disease: l.questionareFebra,
                      callback: callbackFebra,
                    ),

                    //TextAndSwitchWidget(isToggled: isToggledTuse, disease: "Tuse", callback: callbackTuse,), //old IGV
                    TextAndSwitchWidget(
                      isToggled: isToggledTuse,
                      disease: l.questionareTuse,
                      callback: callbackTuse,
                    ),

                    //TextAndSwitchWidget(isToggled: isToggledDificultatiRespiratorii, disease: "Dificultăți respiratorii",callback: callbackDificultatiRespiratorii,), //old IGV
                    TextAndSwitchWidget(
                      isToggled: isToggledDificultatiRespiratorii,
                      disease: l.questionareDificultatiRespiratorii,
                      callback: callbackDificultatiRespiratorii,
                    ),

                    //TextAndSwitchWidget(isToggled: isToggledAstenie, disease: "Astenie", callback: callbackAstenie), //old IGV
                    TextAndSwitchWidget(
                        isToggled: isToggledAstenie, disease: l.questionareAstenie, callback: callbackAstenie),

                    //TextAndSwitchWidget(isToggled: isToggledCefalee, disease: "Cefalee", callback: callbackCefalee),
                    TextAndSwitchWidget(
                        isToggled: isToggledCefalee, disease: l.questionareCefalee, callback: callbackCefalee),

                    //TextAndSwitchWidget(isToggled: isToggledDureriInGat, disease: "Dureri în gât", callback: callbackDureriInGat), //old IGV
                    TextAndSwitchWidget(
                        isToggled: isToggledDureriInGat,
                        disease: l.questionareDureriInGat,
                        callback: callbackDureriInGat),

                    //TextAndSwitchWidget(isToggled: isToggledGreturiVarsaturi, disease: "Grețuri/Vărsături", callback: callbackGreturiVarsaturi), //old IGV
                    TextAndSwitchWidget(
                        isToggled: isToggledGreturiVarsaturi,
                        disease: l.questionareGreturiVarsaturi,
                        callback: callbackGreturiVarsaturi),

                    //TextAndSwitchWidget(isToggled: isToggledDiareeConstipatie, disease: "Diaree/Constipație", callback: callbackDiareeConstipatie), //old IGV
                    TextAndSwitchWidget(
                        isToggled: isToggledDiareeConstipatie,
                        disease: l.questionareDiareeConstipatie,
                        callback: callbackDiareeConstipatie),

                    //TextAndSwitchWidget(isToggled: isToggledRefuzulAlimentatie, disease: "Refuzul alimentație", callback: callbackRefuzulAlimentatie), //old IGV
                    TextAndSwitchWidget(
                        isToggled: isToggledRefuzulAlimentatie,
                        disease: l.questionareRefuzulAlimentatie,
                        callback: callbackRefuzulAlimentatie),

                    //TextAndSwitchWidget(isToggled: isToggledIritatiiPiele, disease: "Iritații piele", callback: callbackIritatiiPiele), //old IGV
                    TextAndSwitchWidget(
                        isToggled: isToggledIritatiiPiele,
                        disease: l.questionareIritatiiPiele,
                        callback: callbackIritatiiPiele),

                    //TextAndSwitchWidget(isToggled: isToggledNasInfundat, disease: "Nas înfundat", callback: callbackNasInfundat), //old IGV
                    TextAndSwitchWidget(
                        isToggled: isToggledNasInfundat,
                        disease: l.questionareNasInfundat,
                        callback: callbackNasInfundat),

                    //TextAndSwitchWidget(isToggled: isToggledRinoree, disease: "Rinoree", callback: callbackRinoree), //old IGV
                    TextAndSwitchWidget(
                        isToggled: isToggledRinoree, disease: l.questionareRinoree, callback: callbackRinoree),
                  ],
                ),
              ),
              const SizedBox(height: 15),
                     Padding(
                padding: const EdgeInsets.only(left: 128.0, right: 128.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                   const SizedBox(height: 15),
              GestureDetector(
                onTap: () async {
                  final isValidForm = questionaireKey.currentState!.validate();
                  if (isValidForm) {
                    setState(() {
                      chestionarTrimis = false;
                      showButonTrimite = false;
                    });

                    http.Response? resUpdateChestionarDinContClient;

                    resUpdateChestionarDinContClient = await updateChestionarDinContClient();

                    if (context.mounted) {
                      if (int.parse(resUpdateChestionarDinContClient!.body) == 200) {

                        SharedPreferences prefs = await SharedPreferences.getInstance();
          String patientId = prefs.getString(pref_keys.userId) ?? '';
          String patientNume = prefs.getString(pref_keys.userNume) ?? '';
          String patientPrenume = prefs.getString(pref_keys.userPrenume) ?? '';

          String pObservatii = '$patientId\$#\$$patientPrenume $patientNume';
          String pCheie = keyAppPacienti;
          int pIdMedic = widget.medicDetalii.id;

          // Message to send to doctor
          String pMesaj = "Pacientul a terminat întrebările";

          await apiCallFunctions.trimitePushPrinOneSignalCatreMedic(
            pCheie: pCheie,
            pIdMedic: pIdMedic,
            pTip: widget.tipServiciu.toString(),
            pMesaj: pMesaj,
            pObservatii: pObservatii,
          );

                      } else {
                        setState(() {
                          chestionarTrimis = false;
                          showButonTrimite = true;
                        });
                      }
                    }
                  }

                  if (context.mounted) {
                    if (questionaireKey.currentState!.validate()) {
                      if (widget.tipServiciu == 1) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return  ApelVideoPacientScreen(
                            medic: widget.medicDetalii,
                            contClientMobile: widget.contClientMobile,
                          );
                        }));
                      } else if (widget.tipServiciu == 2) {
                      } else if (widget.tipServiciu == 3) {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            //return const PaymentScreen();
                            return ChatScreenPage(
                              medic: widget.medicDetalii,
                              contClientMobile: widget.contClientMobile,
                              pret: widget.pret, chatOnly: widget.chatOnly,
                              tipServiciu: widget.tipServiciu,
                            );
                          },
                        ));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Completați toate datele necesare')),
                      );
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(25, 0, 25, 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    //color: Colors.green,

                    color: const Color.fromRGBO(14, 190, 127, 1), //adăugat de George Valentin Iordache
                  ),
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        //'TRIMITE CHESTIONARUL', //old IGV
                        l.questionareTrimiteChestionarul,
                        style: GoogleFonts.rubik(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              //SizedBox(height: 15), old
              const SizedBox(height: 15),
            ],
          )),
        ),
      ),
    );
  }

  Divider customDivider() => const Divider(color: Colors.black12, height: 2, thickness: 1);
}

// ignore: must_be_immutable
class TextAndSwitchWidget extends StatefulWidget {
  bool isToggled;
  final Function(bool)? callback;
  final String disease;
  TextAndSwitchWidget({super.key, required this.isToggled, required this.disease, this.callback});

  @override
  State<TextAndSwitchWidget> createState() => _TextAndSwitchWidgetState();
}

class _TextAndSwitchWidgetState extends State<TextAndSwitchWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //Text(widget.disease, style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w400)), old

            Text(widget.disease,
                style: GoogleFonts.rubik(
                    color: const Color.fromRGBO(103, 114, 148, 1), fontSize: 12, fontWeight: FontWeight.w400)),

            FlutterSwitch(
              value: widget.isToggled,
              height: 25,
              width: 60,

              //activeColor: const Color.fromARGB(255, 103, 197, 108),

              //added by George Valentin Iordache
              activeColor: const Color.fromRGBO(14, 190, 127, 1),

              inactiveColor: Colors.grey[200]!,
              onToggle: (value) {
                if (widget.callback != null) {
                  setState(() {
                    widget.callback!(value);
                  });
                } else {
                  setState(() {
                    widget.isToggled = value;
                    // ignore: avoid_print
                    print(widget.isToggled);
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 5),
        customDivider(),
        const SizedBox(height: 5),
      ],
    );
  }
}
