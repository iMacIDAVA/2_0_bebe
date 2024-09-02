import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/login_screen.dart';
import 'package:sos_bebe_app/profil_doctor_disponibilitate_servicii_screen.dart';
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';
import 'package:sos_bebe_app/vezi_toti_medicii_screen.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  ApiCallFunctions apiCallFunctions = ApiCallFunctions();
  List<MedicMobile> listaMedici = [];
  ContClientMobile? resGetCont;
  bool userHasData = false;

  Stream<String> getUserData() async* {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? "";
    if (user != '') {
      await getContUser();
      await getListaMedici();
    }
    yield user;
  }

  getListaMedici() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    listaMedici = await apiCallFunctions.getListaMedici(
          pUser: user,
          pParola: userPassMD5,
        ) ??
        [];
  }

  getContUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
    resGetCont = await apiCallFunctions.getContClient(
      pUser: user,
      pParola: userPassMD5,

      //pDeviceToken: '', //old IGV
      pDeviceToken: prefs.getString('oneSignalId') ?? "",
      pTipDispozitiv: Platform.isAndroid ? '1' : '2',
      pModelDispozitiv: await apiCallFunctions.getDeviceInfo(),
      pTokenVoip: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != "") {
              return VeziTotiMediciiScreen(
                listaMedici: listaMedici,
                contClientMobile: resGetCont!,
              );
            } else {
              return const LoginScreen();
            }
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
