import 'dart:convert';

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as s;
import 'package:google_fonts/google_fonts.dart';
import 'package:sos_bebe_app/plata_succes_screen.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';
import '../components/card_input_formatter.dart';
import '../components/card_month_input_formatter.dart';
import '../components/master_card.dart';
import '../components/my_painter.dart';
import 'package:http/http.dart' as http;

import 'package:sos_bebe_app/localizations/1_localizations.dart';
//import '../constants.dart';

class AdaugaMetodaPlataScreen extends StatefulWidget {
  final int tipServiciu;
  final ContClientMobile contClientMobile;
  final MedicMobile medicDetalii;
  final String pret;

  const AdaugaMetodaPlataScreen(
      {Key? key,
        required this.tipServiciu,
        required this.contClientMobile,
        required this.medicDetalii,
        required this.pret})
      : super(key: key);

  @override
  State<AdaugaMetodaPlataScreen> createState() => _AdaugaMetodaPlataScreenState();
}

class _AdaugaMetodaPlataScreenState extends State<AdaugaMetodaPlataScreen> {








  final cardKey = GlobalKey<FormState>();

  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardHolderNameController = TextEditingController();
  final TextEditingController cardExpiryDateController = TextEditingController();
  final TextEditingController cardCvvController = TextEditingController();

  final FlipCardController flipCardController = FlipCardController();

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    //print('Test adauga metoda ${LocalizationsApp.of(context)}');

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        appBar: AppBar(
          //title: const Text('Înapoi'), //old IGV
          title: Text(l.universalInapoi),
          backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
          foregroundColor: Colors.white,
          leading: const BackButton(
            color: Colors.white,
          ),
        ),
        //end added by George Valentin Iordache
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: cardKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  FlipCard(
                      fill: Fill.fillFront,
                      direction: FlipDirection.HORIZONTAL,
                      controller: flipCardController,
                      onFlip: () {},
                      flipOnTouch: true,
                      onFlipDone: (isFront) {},
                      front: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: buildCreditCard(
                          context: context,
                          //color: kDarkBlue,
                          color: const Color.fromRGBO(14, 190, 127, 1),
                          cardExpiration: cardExpiryDateController.text.isEmpty
                          //? "08/2022" //old IGV
                              ? l.adaugaMetodaPlataExpiryDate
                              : cardExpiryDateController.text,
                          cardHolder: cardHolderNameController.text.isEmpty
                          //? "Card Holder"
                              ? l.adaugaMetodaPlataCardHolderHint
                              : cardHolderNameController.text.toUpperCase(),
                          cardNumber: cardNumberController.text.isEmpty
                          //? "XXXX XXXX XXXX XXXX"
                              ? l.adaugaMetodaPlataCardNumberHint
                              : cardNumberController.text,
                        ),
                      ),
                      back: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Card(
                          elevation: 4.0,
                          //color: kDarkBlue,
                          color: const Color.fromRGBO(14, 190, 127, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Container(
                            height: 230,
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 22.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(height: 0),
                                Text(
                                  //'https://www.paypal.com', //old IGV
                                  l.adaugaMetodaPlataAdresaWeb,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                                Container(
                                  height: 45,
                                  width: MediaQuery.of(context).size.width / 1.2,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                CustomPaint(
                                  painter: MyPainter(),
                                  child: SizedBox(
                                    height: 35,
                                    width: MediaQuery.of(context).size.width / 1.2,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          cardCvvController.text.isEmpty
                                          //? "322" //old IGV
                                              ? l.adaugaMetodaPlataCVV
                                              : cardCvvController.text,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 21,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  '',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      const SizedBox(
                        width: 30,
                      ),
                      Text(
                        //'Card Number', //old IGV
                        l.adaugaMetodaPlataCardNumberTitle,
                        style: GoogleFonts.rubik(
                          color: const Color.fromRGBO(103, 114, 148, 1),
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width / 1.12,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromRGBO(14, 190, 127, 1), width: 1.0, style: BorderStyle.solid),
                      //color: Colors.grey[200],
                      //borderRadius: BorderRadius.circular(15),
                      color: const Color.fromRGBO(255, 255, 255, 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                        controller: cardNumberController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          /*border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:  const BorderSide(color: Color.fromRGBO(14, 190, 127, 1), ),

                        ),
                        */
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          //hintText: '1453 2436 1198 4452', //old IGV
                          hintText: l.adaugaMetodaPlataCardNumberHint,
                          hintStyle: const TextStyle(
                            color: Color.fromRGBO(206, 209, 229, 1),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.credit_card,
                            color: Colors.grey,
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                          CardInputFormatter(),
                        ],
                        onChanged: (value) {
                          var text = value.replaceAll(RegExp(r'\s+\b|\b\s'), ' ');
                          setState(() {
                            cardNumberController.value = cardNumberController.value.copyWith(
                                text: text,
                                selection: TextSelection.collapsed(offset: text.length),
                                composing: TextRange.empty);
                          });
                        },
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            //return 'Necompletat'; //old IGV
                            return l.adaugaMetodaPlataNecompletat;
                          } else if ((value?.length ?? 16) < 16) {
                            //return 'Incorect'; //old IGV
                            return l.adaugaMetodaPlataIncorect;
                          }
                          return null;
                        }),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const SizedBox(
                        width: 30,
                      ),
                      Text(
                        //'Nume', //old IGV
                        l.adaugaMetodaPlataNume,
                        style: GoogleFonts.rubik(
                          color: const Color.fromRGBO(103, 114, 148, 1),
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width / 1.12,
                    decoration: BoxDecoration(
                      //color: Colors.grey[200],
                      //borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: const Color.fromRGBO(14, 190, 127, 1), width: 1.0, style: BorderStyle.solid),
                      //color: Colors.grey[200],
                      color: const Color.fromRGBO(255, 255, 255, 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: cardHolderNameController,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        hintText: l.adaugaMetodaPlataCardHolderNameHint,
                        hintStyle: const TextStyle(
                          color: Color.fromRGBO(206, 209, 229, 1),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          List<String> words = value.split(' ');
                          for (int i = 0; i < words.length; i++) {
                            if (words[i].isNotEmpty) {
                              words[i] = words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
                            }
                          }
                          String updatedValue = words.join(' ');

                          setState(() {
                            cardHolderNameController.value = TextEditingValue(
                              text: updatedValue,
                              selection: TextSelection.collapsed(offset: updatedValue.length),
                            );
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                //'CVV', //old IGV
                                l.adaugaMetodaPlataCVVTitle,
                                style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(103, 114, 148, 1),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 55,
                            width: MediaQuery.of(context).size.width / 2.4,
                            decoration: BoxDecoration(
                              //color: Colors.grey[200],
                              //borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  color: const Color.fromRGBO(14, 190, 127, 1), width: 1.0, style: BorderStyle.solid),
                              //color: Colors.grey[200],
                              color: const Color.fromRGBO(255, 255, 255, 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                                controller: cardCvvController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                  // hintText: '● ● ●', //old IGV
                                  hintText: l.adaugaMetodaPlataCardCVV,
                                  hintStyle: const TextStyle(
                                    color: Color.fromRGBO(206, 209, 229, 1),
                                    fontSize: 16,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: Colors.grey,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                onTap: () {
                                  setState(() {
                                    Future.delayed(const Duration(milliseconds: 300), () {
                                      flipCardController.toggleCard();
                                    });
                                  });
                                },
                                onChanged: (value) {
                                  setState(() {
                                    int length = value.length;
                                    if (length == 4 || length == 9 || length == 14) {
                                      cardNumberController.text = '$value ';
                                      cardNumberController.selection =
                                          TextSelection.fromPosition(TextPosition(offset: value.length + 1));
                                    }
                                  });
                                },
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    //return 'Necompletat'; //old IGV
                                    return l.adaugaMetodaPlataNecompletat;
                                  } else if ((value?.length ?? 3) < 3) {
                                    //return 'Incorect'; //old IGV
                                    return l.adaugaMetodaPlataIncorect;
                                  }
                                  return null;
                                }),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 5),
                              Text(
                                //'Expired Date', //old IGV
                                l.adaugaMetodaPlataExpiredDate,
                                style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(103, 114, 148, 1),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 55,
                            width: MediaQuery.of(context).size.width / 2.4,
                            decoration: BoxDecoration(
                              //color: Colors.grey[200],
                              //borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  color: const Color.fromRGBO(14, 190, 127, 1), width: 1.0, style: BorderStyle.solid),
                              //color: Colors.grey[200],
                              color: const Color.fromRGBO(255, 255, 255, 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                                controller: cardExpiryDateController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                  //hintText: '08/29', //old IGV
                                  hintText: l.adaugaMetodaPlataExpiryDateHint,
                                  hintStyle: const TextStyle(
                                    color: Color.fromRGBO(206, 209, 229, 1),
                                    fontSize: 16,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.calendar_today,
                                    color: Colors.grey,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                  CardDateInputFormatter(),
                                ],
                                onChanged: (value) {
                                  var text = value.replaceAll(RegExp(r'\s+\b|\b\s'), ' ');
                                  setState(() {
                                    cardExpiryDateController.value = cardExpiryDateController.value.copyWith(
                                        text: text,
                                        selection: TextSelection.collapsed(offset: text.length),
                                        composing: TextRange.empty);
                                  });
                                },
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    //return "Necompletată"; //old IGV
                                    return l.adaugaMetodaPlataNecompletata;
                                  }
                                  final DateTime now = DateTime.now();
                                  final List<String> date = value!.split(RegExp(r'/'));

                                  final int month = int.parse(date.first);
                                  final int year = int.parse('20${date.last}');

                                  final int lastDayOfMonth =
                                  month < 12 ? DateTime(year, month + 1, 0).day : DateTime(year + 1, 1, 0).day;

                                  final DateTime cardDate = DateTime(year, month, lastDayOfMonth, 23, 59, 59, 999);

                                  if (cardDate.isBefore(now) || month > 12 || month == 0) {
                                    //return "Incorectă"; //old IGV
                                    return l.adaugaMetodaPlataIncorecta;
                                  }

                                  return null;
                                }),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20 * 3),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(MediaQuery.of(context).size.width / 1.12, 55),
                    ),
                    onPressed: () {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        final isValidForm = cardKey.currentState!.validate();
                        if (isValidForm) {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return PlataRealizataCuSuccesScreen(
                                  tipServiciu: widget.tipServiciu,
                                  contClientMobile: widget.contClientMobile,
                                  medicDetalii: widget.medicDetalii,
                                  pret: widget.pret);
                              //return const PlataEsuataScreen();
                            },
                          ));
                        }
                      });
                    },
                    child: Text(
                      //'PLATĂ / ADAUGĂ', //IGV
                      l.adaugaMetodaPlataPlataAdauga,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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
