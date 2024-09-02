import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:sos_bebe_app/localizations/1_localizations.dart';

class PlataEsuataScreen extends StatelessWidget {
  const PlataEsuataScreen({super.key});

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
                  //children: [Text('Vă mulțumim!', style: GoogleFonts.rubik(color: Colors.black87, fontSize: 28))], old
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        //'Plată eșuată', //old IGV
                        l.plataEsuataTitlu,
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
                    Container(
                      width: 325,
                      margin: const EdgeInsets.only(left: 25),
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
                              //text: 'S-ar putea să nu aveți suficiente fonduri în cont pentru a plăti. Verificați soldul contului sau contactați-vă banca. Card de credit sau de debit neeligibil.' //old IGV
                              text: l.plataEsuataFonduriInsuficiente,
                            ),
                          ],
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
                Image.asset('./assets/images/plata_esuata_image.png'),
                const SizedBox(height: 175),
                InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return const PlataEsuataScreen();
                    },
                  )),
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
                          //'CONTINUĂ', //old IGV
                          l.plataEsuataContinua,
                          style: GoogleFonts.rubik(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16),
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
    );
  }
}
