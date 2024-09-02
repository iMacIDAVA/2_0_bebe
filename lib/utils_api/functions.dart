import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './shared_pref_keys.dart' as pref_keys;

extension StringExtension on String {
  String capitalizeFirst() {
    //return "${this[0].toUpperCase()}${substring(1).toLowerCase()}"; //old Andrei Bădescu
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

Future<List<String>> getUserName() async {
  List<String> user = [];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var nume = prefs.getString(pref_keys.userNume);
  var prenume = prefs.getString(pref_keys.userPrenume);
  user.add(nume ?? "asd");
  user.add(prenume ?? " asd");
  // print(user);
  return user;
}

void showSnackbar(BuildContext context, String text, Color bckColor, Color textColor) {
  final snackBar = SnackBar(
    
    //content: Text(text, textAlign: TextAlign.center, style: TextStyle(color: Colors.black,),), //old IGV

    content: Text(text, textAlign: TextAlign.center, style: TextStyle(color: textColor,),),
    
    //backgroundColor: const Color.fromARGB(255,200,200,200), //old IGV
    backgroundColor: bckColor,
    duration: const Duration(seconds: 2),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
