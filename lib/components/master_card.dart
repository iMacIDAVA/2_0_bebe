import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import 'package:sos_bebe_app/localizations/1_localizations.dart';

Card buildCreditCard({
  required Color color,
  required String cardNumber,
  required String cardHolder,
  required String cardExpiration,
  required BuildContext context,

}) {

  
  LocalizationsApp l = LocalizationsApp.of(context)!;

  return Card(
    elevation: 4.0,
    color: color,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    child: Container(
      height: 230,
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                //'Introduceți datele cardului',
                l.adaugaMetodaPlataIntroducetiDateleCardului,
                style: GoogleFonts.rubik(color:const Color.fromRGBO(103, 114, 148, 1), fontWeight: FontWeight.w500, fontSize: 18),
              ),
              Image.asset(
                "assets/images/mastercard.png",
                height: 60,
                width: 60,
              ),
            ],
          ),
          Row(
            children: [
              Image.asset(
                "assets/images/chip.png",
                height: 50,
                width: 60,
              ),
              const SizedBox(width: 8),
              Image.asset(
                "assets/icons/contact_less.png",
                height: 30,
                width: 30,
              ),
            ],
          ),
          Text(
            cardNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              letterSpacing: 4,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              buildDetailsBlock(
                //label: 'CARDHOLDER',
                label: l.adaugaMetodaPlataCardHolderTitle,
                value: cardHolder,
              ),
              buildDetailsBlock(
                //label: 'VALID THRU',
                label: l.adaugaMetodaPlataValidThruTitle,
                value: cardExpiration),
            ],
          ),
        ],
      ),
    ),
  );
}

Column buildDetailsBlock({required String label, required String value}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: const TextStyle(
            color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: .5,
        ),
      )
    ],
  );
}
