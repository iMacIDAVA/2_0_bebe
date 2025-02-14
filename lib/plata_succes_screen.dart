import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/chat_screen.dart/chat_screen.dart';
import 'package:sos_bebe_app/questionare_screen.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;

import 'package:sos_bebe_app/localizations/1_localizations.dart';
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';

class PlataRealizataCuSuccesScreen extends StatefulWidget {
  final int tipServiciu;

  final ContClientMobile contClientMobile;

  final MedicMobile medicDetalii;
  final String pret;

  const PlataRealizataCuSuccesScreen(
      {super.key,
      required this.tipServiciu,
      required this.contClientMobile,
      required this.medicDetalii,
      required this.pret});

  @override
  State<PlataRealizataCuSuccesScreen> createState() => _PlataRealizataCuSuccesScreenState();
}

class _PlataRealizataCuSuccesScreenState extends State<PlataRealizataCuSuccesScreen> {
  ApiCallFunctions apiCallFunctions = ApiCallFunctions();

  Future<void> notificaDoctor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
    apiCallFunctions.anuntaMedicDePlataEfectuata(
        pUser: user,
        pParola: userPassMD5,
        pIdMedic: widget.medicDetalii.id.toString(),
        tipPlata: widget.tipServiciu.toString());
  }

  @override
  void initState() {
    super.initState();

    print('aaaaaa : ${widget.tipServiciu}');

    // Log the doctor's name for debugging
    print(widget.medicDetalii.numeleComplet);

    // Notify the doctor of the successful payment
    notificaDoctor();

    // Schedule navigation based on the type of service
    Timer(const Duration(seconds: 5), () {
      if (widget.tipServiciu == 1 || widget.tipServiciu == 3) {
        // Navigate to the QuestionaireScreen for specific service type
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => QuestionaireScreen(
              tipServiciu: widget.tipServiciu,
              contClientMobile: widget.contClientMobile,
              medicDetalii: widget.medicDetalii, pret: widget.pret, chatOnly: widget.tipServiciu == 3 ? true : false,
            ),
          ),
        );
      } else {
        // Navigate to ChatScreenPage for chat or consultation services
        if (widget.medicDetalii != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ChatScreenPage(
                medic: widget.medicDetalii,
                contClientMobile: widget.contClientMobile,
                pret: widget.pret,
                tipServiciu: widget.tipServiciu,
                chatOnly: widget.tipServiciu == 3 ? true : false,
              ),

            ),
          );
        } else {
          // Show an error message if medicDetalii is null
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error: Invalid doctor details. Please try again."),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    return WillPopScope(
      onWillPop: () async => false,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: Scaffold(
          // appBar: AppBar(
          //   // title: Text(
          //   //   //'Înapoi' //old IGV
          //   //   l.universalInapoi,
          //   // ),
          //   backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
          //   foregroundColor: Colors.white,
          //   leading: const SizedBox(),
          // ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 70),
                  Container(
                    margin: const EdgeInsets.only(left: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          //'Plată realizată cu succes', //old IGV
                          l.plataSuccesTitlu,
                          style: GoogleFonts.rubik(
                              color: const Color.fromRGBO(103, 114, 148, 1), fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.all(30),
                          child: AutoSizeText.rich(
                            // old value RichText(
                            TextSpan(
                              style: GoogleFonts.rubik(
                                color: const Color.fromRGBO(103, 114, 148, 1),
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  //text: 'Vă mulțumim! Detaliile dvs. de plată vor fi trimise la adresa dvs. de e-mail.'
                                  text: l.plataSuccesVaMultumimDetalii,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 210),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        //'Vă mulțumim! ', //old IGV
                        l.plataSuccesVaMultumimSimplu,
                        style: GoogleFonts.rubik(
                            color: const Color.fromRGBO(14, 190, 127, 1), fontSize: 26, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        //'Vei fi redirectionat ...', //old IGV
                        'Vei fi redirecționat ...',
                        style: GoogleFonts.rubik(
                            color: const Color.fromRGBO(103, 114, 148, 1), fontSize: 18, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
