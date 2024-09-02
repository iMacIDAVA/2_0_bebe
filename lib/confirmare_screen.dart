import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:sos_bebe_app/register.dart';
import 'package:sos_bebe_app/utils/utils_widgets.dart';

import 'package:sos_bebe_app/localizations/1_localizations.dart';

class ConfirmareScreen extends StatefulWidget {
  final bool correctCard;

  const ConfirmareScreen({super.key, required this.correctCard});

  @override
  State<ConfirmareScreen> createState() => _ConfirmareScreenState();
}

class _ConfirmareScreenState extends State<ConfirmareScreen> {
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userNume');
    });
  }

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        appBar: AppBar(
          //title: const Text('Înapoi'), //IGV
          title: Text(l.universalInapoi),
          backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
          foregroundColor: Colors.white,
          leading: const BackButton(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 55),
                Row(
                  children: [
                    const SizedBox(width: 15),
                    Text(
                      //'Confirmare', //old IGV
                      l.confirmareTitlu,
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 15),
                    SizedBox(
                      width: 270,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //Text('Master Card', style: GoogleFonts.rubik(color:const Color.fromRGBO(103, 114, 148, 1), fontWeight: FontWeight.w400, fontSize: 15,),), //old IGV
                          Text(
                            l.confirmareMasterCard,
                            style: GoogleFonts.rubik(
                              color: const Color.fromRGBO(103, 114, 148, 1),
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                            ),
                          ),

                          Text(
                            //'● ● ● ●  ● ● ● ●  ● ● ● ● 4455', //old IGV
                            l.confirmareCardNumber,
                            style: GoogleFonts.rubik(
                              color: const Color.fromRGBO(205, 211, 223, 1),
                              fontWeight: FontWeight.w400,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 25),
                    widget.correctCard
                        ? Image.asset(
                            "assets/images/correct.png",
                            //height: 18,
                            //width: 18,
                          )
                        : const SizedBox(),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 15),
                    SizedBox(
                      width: 270,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //Text('Paypal', style: GoogleFonts.rubik(color:const Color.fromRGBO(103, 114, 148, 1), fontWeight: FontWeight.w400, fontSize: 15,),),
                          Text(
                            //'Paypal', //old IGV
                            l.confirmareTipPlata,
                            style: GoogleFonts.rubik(
                              color: const Color.fromRGBO(103, 114, 148, 1),
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                            ),
                          ),

                          Text(
                            userName ?? '',
                            style: GoogleFonts.rubik(
                              color: const Color.fromRGBO(205, 211, 223, 1),
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 15),
                    SizedBox(
                      width: 270,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            //'Bank', //old IGV
                            l.confirmareBanca,
                            style: GoogleFonts.rubik(
                              color: const Color.fromRGBO(103, 114, 148, 1),
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            //'Stripe', //old IGV
                            l.confirmareStripe,
                            style: GoogleFonts.rubik(
                              color: const Color.fromRGBO(205, 211, 223, 1),
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    const SizedBox(width: 15),
                    customDividerConfirmareScreen(),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 15),
                    IconButton(
                      icon: Image.asset('assets/images/adauga.png'),
                      //iconSize: 50, maybe modifiy the size
                      onPressed: () {},
                    ),
                    const SizedBox(width: 15),
                    Text(
                      //'ADAUGĂ METODĂ DE PLATĂ', //old IGV
                      l.confirmareAdaugaMetodaDePlata,
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  height: 135.0,
                  width: 299.0,
                  margin: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(border: Border.all(color: const Color.fromRGBO(112, 112, 112, 1))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
