import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:sos_bebe_app/localizations/1_localizations.dart';

class TermeniSiConditiiScreen extends StatelessWidget {
  const TermeniSiConditiiScreen({super.key});

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
                      //'Termeni și condiții', //old IGV
                      l.termeniSiConditiiTitlu,
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(242, 63, 87, 1),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 70),
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
                            //text: 'Termeni și condiții text' //old IGV
                            text: l.termeniSiConditiiText,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 250),
                  SizedBox(
                    width: 160,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        //Navigator.push(
                        //context,
                        //MaterialPageRoute(
                        //builder: (context) => const ServiceSelectScreen(),
                        //builder: (context) => const TestimonialScreen(),
                        //));
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(255, 255, 255, 1),
                          minimumSize: const Size.fromHeight(50), // NEW
                          side: const BorderSide(
                            width: 1.0,
                            color: Color.fromRGBO(14, 190, 127, 1),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          )),
                      child: Text(
                          //'Go home', //old IGV
                          l.termeniSiConditiiGoHome,
                          style: GoogleFonts.rubik(
                              color: const Color.fromRGBO(14, 190, 127, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w300)),
                    ),
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
