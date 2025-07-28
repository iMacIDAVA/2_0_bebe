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
import 'package:uuid/uuid.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  ApiCallFunctions apiCallFunctions = ApiCallFunctions();
  List<MedicMobile> listaMedici = [];
  ContClientMobile? resGetCont;
  String? userApp;
  String oneSignalId = '';

  @override
  void initState() {
    super.initState();
    initOneSignal();
    manuallyFetchOneSignalId();
  }

  Future<void> initOneSignal() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    await OneSignal.Notifications.requestPermission(true);
    await getPlayerId();
    await checkUserLoginState();
  }

 Future<void> getPlayerId() async {
    final String? id = OneSignal.User.pushSubscription.id;

    if (id != null) {
      oneSignalId = id;
    } else {
      oneSignalId = '';
      await initOneSignal();
    }
    if (id != null) {
      await SharedPreferences.getInstance().then((value) {
        value.setString('oneSignalId', id);
      });
    }
    setState(() {});
  }


Future<void> manuallyFetchOneSignalId() async {
  print("📢 Manually Fetching OneSignal Player ID...");

  String? playerId = OneSignal.User.pushSubscription.id;

  if (playerId != null && playerId.isNotEmpty) {
    print("✅ OneSignal Player ID Retrieved: $playerId");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('oneSignalId', playerId);
    print("🔹 OneSignal Player ID saved in SharedPreferences.");
  } else {
    print("❌ OneSignal Player ID is still NULL.");
  }
}



  Future<void> checkUserLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    if (user.isNotEmpty && userPassMD5.isNotEmpty) {
      try {
        await getContUser();
        if (resGetCont != null) {
          await getListaMedici();
        }
      } catch (e) {
        navigateToLoginScreen();
      }
    }
  }

  Future<void> getListaMedici() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    listaMedici = await apiCallFunctions.getListaMedici(
          pUser: user,
          pParola: userPassMD5,
        ) ??
        [];
  }

  Future<void> getContUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    if (user.isEmpty || userPassMD5.isEmpty) {
      throw Exception("Missing user credentials");
    }

    print('pUser : ${user}');
        print('pParola : ${userPassMD5}');
            print('pDeviceToken : ${prefs.getString('oneSignalId') ?? ""}');
                print('pTipDispozitiv : ${Platform.isAndroid ? '1' : '2'}');
                    print('pModelDispozitiv : ${await apiCallFunctions.getDeviceInfo()}');
                        print('pTokenVoip : ${''}');

    resGetCont = await apiCallFunctions.getContClient(
      pUser: user,
      pParola: userPassMD5,
      pDeviceToken: prefs.getString('oneSignalId') ?? "",
      pTipDispozitiv: Platform.isAndroid ? '1' : '2',
      pModelDispozitiv: await apiCallFunctions.getDeviceInfo(),
      pTokenVoip: '',
    );

    if (resGetCont == null) {
      throw Exception("Failed to fetch account data");
    }
  }

  void navigateToLoginScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
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
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [

                    Row(
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(150),
                            image: DecorationImage(
                              image: AssetImage('./assets/images/12n.png'),
                              fit: BoxFit.cover,

                            ),

                          ),

                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(l.introGasesteDoctorPediatru,
                              style: GoogleFonts.rubik(
                                color: const Color.fromRGBO(14, 190, 127, 1),
                                fontSize: 37,
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
                              text:'Pentru cei mici, suntem mereu aici.' , // l.introGasitiMediciSpecialisti,
                              style: GoogleFonts.rubik(
                                color: Colors.black,
                                fontSize: 17,
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
                              if (resGetCont != null && listaMedici.isNotEmpty) {
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
                                navigateToLoginScreen();
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
                                  style:
                                      GoogleFonts.rubik(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 22),
                                ),
                                const ImageIcon(
                                  AssetImage("./assets/images/babyhead.png"),
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
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
