import 'package:flutter/material.dart';

Divider customDivider() {
  return Divider(color: Colors.black12, height: 2, thickness: 1);
}

Padding customDividerConfirmareServicii() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 0),
    child: Container(
        height: 1.0,
        //color:Colors.black12,
        color: const Color.fromRGBO(6, 39, 55, 0.1)),
  );
}

Padding customDividerConfirmareScreen() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 1.0),
    child: Container(
        height: 1.0,
        width: 312.0,
        //color:Colors.black12,
        color: const Color.fromRGBO(6, 39, 55, 0.1)),
  );
}

Padding customDividerProfil() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 1.0),
    child: Container(
        height: 1.0,
        width: 339.0,
        //color:Colors.black12,
        color: const Color.fromRGBO(6, 39, 55, 0.1)),
  );
}

Container customDividerProfilDoctor() {
  return Container(
    height: 0.7,
    width: 370.0,
    //color:Colors.black12,
    color: const Color.fromRGBO(205, 211, 223, 1),
  );
}
