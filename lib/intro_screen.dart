import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/login_screen.dart';
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;
import 'package:sos_bebe_app/localizations/1_localizations.dart';
import 'package:sos_bebe_app/vezi_toti_medicii_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({
    super.key,
  });

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  ApiCallFunctions apiCallFunctions = ApiCallFunctions();
  List<MedicMobile> listaMedici = [];
  ContClientMobile? resGetCont;
  bool userHasData = false;
  String? userApp;
  String oneSignalId = '';

  Future<void> initOneSignal() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    await OneSignal.Notifications.requestPermission(true);
    await getPlayerId();
    await getUserData();
  }

  Future<void> getPlayerId() async {
    final id = OneSignal.User.pushSubscription.id;
    if (id != null) {
      oneSignalId = id;
    } else {
      oneSignalId = '';
    }
    if (id != null) {
      SharedPreferences.getInstance().then((value) {
        value.setString('oneSignalId', id);
      });
    }
    setState(() {});

  }

  Future<String> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? "";
    if (user != '') {
      await getContUser();
      await getListaMedici();
    }
    userApp = user;
    return user;
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
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String user = prefs.getString('user') ?? '';
      String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
      resGetCont = await apiCallFunctions.getContClient(
        pUser: user,
        pParola: userPassMD5,
        pDeviceToken: prefs.getString('oneSignalId') ?? "",
        pTipDispozitiv: Platform.isAndroid ? '1' : '2',
        pModelDispozitiv: await apiCallFunctions.getDeviceInfo(),
        pTokenVoip: '',
      );

      if (resGetCont == null) {
        throw Exception('Failed to fetch account data');
      }
    } catch (e) {
      // Handle the error gracefully
      print('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    initOneSignal();
  }

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.white, Colors.transparent],
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                    height: MediaQuery.of(context).size.height * 0.7,
                    width: MediaQuery.of(context).size.width,
                    './assets/images/splash_background_image.png'),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(width: 100, height: 136, './assets/images/Sosbebe.png'),
                    ),
                    const Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(l.introGasesteDoctorPediatru,
                              style: GoogleFonts.rubik(
                                color: const Color.fromRGBO(14, 190, 127, 1),
                                fontSize: 28,
                                fontWeight: FontWeight.w400,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            child: AutoSizeText.rich(
                              TextSpan(
                                  text: l.introGasitiMediciSpecialisti,
                                  style: GoogleFonts.rubik(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w300,
                                  )),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                            )),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        SizedBox(
                          height: 60,
                          width: 224,
                          child: ElevatedButton(
                              onPressed: () async {
                                await getPlayerId();
                                if (userApp != '') {
                                  // Ensure getContUser has completed
                                  await getContUser();
                                  if (resGetCont != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return VeziTotiMediciiScreen(
                                            listaMedici: listaMedici,
                                            contClientMobile: resGetCont!,
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    // Handle the case where resGetCont is null
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Failed to fetch account data. Please try again."))
                                    );
                                  }
                                } else {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return const LoginScreen();
                                    },
                                  ));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(60),
                                  backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  shadowColor: const Color.fromRGBO(14, 190, 127, 1),
                                  elevation: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l.introContinua,
                                    style: GoogleFonts.rubik(
                                        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 22),
                                  ),
                                  const ImageIcon(
                                    AssetImage("./assets/images/babyhead.png"),
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
