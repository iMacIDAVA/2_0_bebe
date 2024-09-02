import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/chat_screen.dart/chat_screen.dart';
import 'package:sos_bebe_app/factura_screen.dart';
import 'package:sos_bebe_app/questionare_screen.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;

import 'package:sos_bebe_app/localizations/1_localizations.dart';
import 'package:sos_bebe_app/raspunde_intrebare_doar_chat_screen.dart';
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
  State<PlataRealizataCuSuccesScreen> createState() =>
      _PlataRealizataCuSuccesScreenState();
}

class _PlataRealizataCuSuccesScreenState
    extends State<PlataRealizataCuSuccesScreen> {
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
    print(widget.medicDetalii.numeleComplet);
    notificaDoctor();
    Timer(const Duration(seconds: 5), () {
      if (widget.tipServiciu == 1) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => QuestionaireScreen(
                      tipServiciu: widget.tipServiciu,
                      contClientMobile: widget.contClientMobile,
                      medicDetalii: widget.medicDetalii,
                    )));
      } else {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return ChatScreenPage(
              medic: widget.medicDetalii,
              contClientMobile: widget.contClientMobile,
              pret: widget.pret,
              tipServiciu: widget.tipServiciu,
              chatOnly: widget.tipServiciu == 3 ? true : false,
            );
          },
        ));
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            //'Înapoi' //old IGV
            l.universalInapoi,
          ),
          backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
          foregroundColor: Colors.white,
          leading: const BackButton(
            color: Colors.white,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 55),
                Container(
                  margin: const EdgeInsets.only(left: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        //'Plată realizată cu succes', //old IGV
                        l.plataSuccesTitlu,
                        style: GoogleFonts.rubik(
                            color: const Color.fromRGBO(103, 114, 148, 1),
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.all(10),
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
                const SizedBox(height: 90),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      //'Vă mulțumim! ', //old IGV
                      l.plataSuccesVaMultumimSimplu,
                      style: GoogleFonts.rubik(
                          color: const Color.fromRGBO(14, 190, 127, 1),
                          fontSize: 26,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                const SizedBox(height: 115),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      //'Vei fi redirectionat ...', //old IGV
                      l.plataSuccesVeiFiRedirectionat,
                      style: GoogleFonts.rubik(
                          color: const Color.fromRGBO(103, 114, 148, 1),
                          fontSize: 18,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
