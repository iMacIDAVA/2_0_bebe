import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/datefacturare/date_facturare_completare_rapida.dart';
import 'package:sos_bebe_app/profil_doctor_disponibilitate_servicii_screen.dart';
import 'package:sos_bebe_app/utils/utils_widgets.dart';
import 'package:sos_bebe_app/adauga_metoda_plata_screen.dart';
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:sos_bebe_app/utils_api/api_config.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';

import 'package:sos_bebe_app/localizations/1_localizations.dart';
import 'package:sos_bebe_app/vezi_toti_medicii_screen.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;


class ConfirmareServiciiScreen extends StatefulWidget {
  final String pret;
  final int tipServiciu;
  final ContClientMobile contClientMobile;
  final MedicMobile medicDetalii;

  const ConfirmareServiciiScreen({
    super.key,
    required this.pret,
    required this.tipServiciu,
    required this.contClientMobile,
    required this.medicDetalii,
  });

  @override
  State<ConfirmareServiciiScreen> createState() => _ConfirmareServiciiScreenState();
}

class _ConfirmareServiciiScreenState extends State<ConfirmareServiciiScreen> {

  int remainingTime = 180;
  Timer? countdownTimer;
  ApiCallFunctions apiCallFunctions = ApiCallFunctions();

  List<MedicMobile> listaMedici = [];
  ContClientMobile? resGetCont;

  ValueNotifier<int> remainingTimeNotifier = ValueNotifier(180);

  bool _isNavigating = false;

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


  int persoanaFizica = 0;
  bool isDateFacturareComplete = true;
  @override
  void initState() {
    super.initState();

    startTimer();

    persoanaFizica = widget.contClientMobile.tipPersoana;
    if (persoanaFizica == 0) {
      isDateFacturareComplete = false;
    } else if (persoanaFizica == 1) {
      if (widget.contClientMobile.cnp.isEmpty ||
          widget.contClientMobile.seriecAct.isEmpty ||
          widget.contClientMobile.numarAct.isEmpty ||
          widget.contClientMobile.adresa1.isEmpty ||
          widget.contClientMobile.denumireJudet.isEmpty ||
          widget.contClientMobile.denumireLocalitate.isEmpty) {
        isDateFacturareComplete = false;
      }
    } else if (persoanaFizica == 2) {
      if (widget.contClientMobile.codFiscal.isEmpty ||
          widget.contClientMobile.denumireFirma.isEmpty ||
          widget.contClientMobile.adresa1.isEmpty ||
          widget.contClientMobile.denumireJudet.isEmpty ||
          widget.contClientMobile.denumireLocalitate.isEmpty) {
        isDateFacturareComplete = false;
      }
    }
  }

  @override
  void dispose() {
    remainingTimeNotifier.dispose();
    super.dispose();
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
          // appBar: AppBar(
          //   backgroundColor: Colors.transparent,
          //   foregroundColor: Colors.black,
          //   leading: GestureDetector(
          //     onTap: () {
          //       Navigator.push(context, MaterialPageRoute(builder: (context) {
          //         return ProfilDoctorDisponibilitateServiciiScreen(
          //           medicDetalii: widget.medicDetalii,
          //           contClientMobileInfo: widget.contClientMobile,
          //           ecranTotiMedicii: true,
          //           statusMedic: widget.medicDetalii.status,
          //         );
          //       }));
          //     },
          //     child: const Icon(Icons.arrow_back),
          //   ),
          // ),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 55),
                  Text(
                    l.confirmareServiciiTitlu,
                    style: GoogleFonts.rubik(
                      color: const Color.fromRGBO(103, 114, 148, 1),
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              './assets/images/servicii_pediatrie_dreptunghi.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              './assets/images/servicii_pediatrie_adauga_efect_1.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              './assets/images/servicii_pediatrie_adauga_efect_2.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l.confirmareServiciiServiciiPediatrie,
                                      style: GoogleFonts.rubik(
                                        color: const Color.fromRGBO(255, 255, 255, 1),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      child: Text(
                                        widget.tipServiciu == 1
                                            ? "Consultație video"
                                            : widget.tipServiciu == 2
                                                ? "Interpretare analize"
                                                : widget.tipServiciu == 3
                                                    ? "Consultație chat"
                                                    : "",
                                        maxLines: 2,
                                        style: GoogleFonts.rubik(
                                          color: const Color.fromRGBO(255, 255, 255, 1),
                                          fontWeight: FontWeight.w300,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 18.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      widget.pret,
                                      style: GoogleFonts.rubik(
                                        color: const Color.fromRGBO(255, 255, 255, 1),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 32,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 18.0),
                                      child: Text(
                                        l.confirmareServiciiRON,
                                        style: GoogleFonts.rubik(
                                          color: const Color.fromRGBO(255, 255, 255, 1),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          l.confirmareServiciiSubtotal,
                          style: GoogleFonts.rubik(
                            color: const Color.fromRGBO(103, 114, 148, 1),
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${widget.pret} ${l.confirmareServiciiRON}',
                          style: GoogleFonts.rubik(
                            color: const Color.fromRGBO(103, 114, 148, 1),
                            fontWeight: FontWeight.w300,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  customDividerConfirmareServicii(),


                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          l.confirmareServiciiTotal,
                          style: GoogleFonts.rubik(
                            color: const Color.fromRGBO(103, 114, 148, 1),
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${widget.pret} ${l.confirmareServiciiRON}',
                          style: GoogleFonts.rubik(
                            color: const Color.fromRGBO(103, 114, 148, 1),
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 60,
                  ),
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
                  const Spacer(),
                  if (!isDateFacturareComplete)
                    const Text(
                      "Va rugăm să completați datele de facturare înainte de continua",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.red),
                    ),
                  isDateFacturareComplete
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentScreen(
                                    tipServiciu: widget.tipServiciu,
                                    contClientMobile: widget.contClientMobile,
                                    medicDetalii: widget.medicDetalii,
                                    pret: widget.pret,
                                    currency: 'RON',
                                  ),
                                ),
                              );

                              Future.delayed(Duration(milliseconds: 500), () {
                                _isNavigating = false;
                              });

                            },

                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
                                minimumSize: const Size.fromHeight(50), // NEW
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            child: Text(l.confirmareServiciiConfirmaPlataButon,
                                style: GoogleFonts.rubik(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                )),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return DateFacturareCompletareRapida(
                                  contClientMobile: widget.contClientMobile,
                                  pret: widget.pret,
                                  tipServiciu: widget.tipServiciu,
                                  medicDetalii: widget.medicDetalii,
                                );
                              }));
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            child: Text("Completeaza date facturare",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.rubik(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                )),
                          ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
