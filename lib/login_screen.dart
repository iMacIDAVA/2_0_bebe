import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:sos_bebe_app/register_screen.dart';
import 'package:sos_bebe_app/reset_password_pacient_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';
import 'package:sos_bebe_app/utils_api/functions.dart';
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;
import 'package:http/http.dart' as http;
import 'package:sos_bebe_app/localizations/1_localizations.dart';
import 'package:sos_bebe_app/vezi_medici_disponibili_intro_screen.dart';

ApiCallFunctions apiCallFunctions = ApiCallFunctions();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginKey = GlobalKey<FormState>();
  bool isHidden = true;

  final controllerEmailTelefonUser = TextEditingController();
  final controllerPass = TextEditingController();

  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodePassword = FocusNode();

  bool requireConsent = false;
  String oneSignalToken = '';

  ContClientMobile? contClientMobile;

  onLocaleChange(Locale l) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    loadLocale();
  }

  loadLocale() async {
    //String? lang = prefs.getString(prefKeys.preferredLanguage); //old Adrian Murgu

    String lang = 'ro';
    // lang = 'en';
    switch (lang) {
      case 'ro':
        break;
      case 'it':
        break;
      case 'fr':
        break;
      case 'en':
        break;
      default:
    }

    if (mounted) {
      setState(() {});
    }
  }

  void passVisibiltyToggle() {
    setState(() {
      isHidden = !isHidden;
    });
  }

  // Future<void> checkLoginWithFacebook() async {
  //   Map<String, dynamic> userData;
  //   final LoginResult result = await FacebookAuth.instance.login();
  //
  //   if (result.status == LoginStatus.success) {
  //     final user = await FacebookAuth.instance.getUserData();
  //     userData = user;
  //
  //     ContClientMobile? resGetCont2 = await loginGoogleFunction(
  //       context,
  //       userData['email'],
  //       userData['id'],
  //     );
  //
  //     if (resGetCont2 != null) {
  //       Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => VeziMediciDisponibiliIntroScreen(
  //               contClientMobile: contClientMobile!,
  //             ), //LoginScreen(),
  //           ));
  //     }
  //   }
  // }

  Future<void> checkLoginWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);
      print('bbbbbbbbbb : $result'); // Debugging

      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();
        final email = userData['email'];
        final facebookUserId = userData['id'];

        // Use the consolidated function for Facebook login
        ContClientMobile? resGetCont2 = await loginWithSocialMedia(context, email, facebookUserId);

        if (resGetCont2 != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VeziMediciDisponibiliIntroScreen(
                contClientMobile: contClientMobile!,
              ),
            ),
          );
        }
      } else if (result.status == LoginStatus.cancelled) {
        showSnackbar(context, 'Login cancelled by user', Colors.red, Colors.white);
      } else if (result.status == LoginStatus.failed) {
        showSnackbar(context, 'Login failed: ${result.message}', Colors.red, Colors.white);
      }
    } catch (e) {
      showSnackbar(context, 'An error occurred: $e', Colors.red, Colors.white);
      print('aaaaaaaaa : $e'); // Debugging
    }
  }


  Future<User?> loginWithGoogle() async {
    try {
      final googleAccount = await GoogleSignIn().signIn();
      if (googleAccount == null) return null; // User cancelled login

      final googleAuth = await googleAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      await FirebaseAuth.instance.signOut(); // Optional: Sign out after getting user data

      final user = userCredential.user;
      if (user != null) {
        ContClientMobile? resGetCont2 = await loginWithSocialMedia(context, user.email!, user.uid);
        if (resGetCont2 != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VeziMediciDisponibiliIntroScreen(
                contClientMobile: contClientMobile!,
              ),
            ),
          );
        }
      }

      return user;
    } catch (e) {
      showSnackbar(context, 'Google login error: $e', Colors.red, Colors.white);
      return null;
    }
  }

  // loginGoogleFunction(BuildContext context, String user, String parola) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   LocalizationsApp l = LocalizationsApp.of(context)!;
  //
  //   String textMesaj = '';
  //   Color backgroundColor = Colors.red;
  //   Color textColor = Colors.black;
  //
  //   String userPassMD5 = apiCallFunctions.generateMd5(parola);
  //
  //   try {
  //     ContClientMobile? resGetCont = await apiCallFunctions.getContClient(
  //       pUser: user,
  //       pParola: userPassMD5,
  //
  //       //pDeviceToken: '', //old IGV
  //       pDeviceToken: prefs.getString('oneSignalId') ?? "",
  //       pTipDispozitiv: Platform.isAndroid ? '1' : '2',
  //       pModelDispozitiv: await apiCallFunctions.getDeviceInfo(),
  //       pTokenVoip: '',
  //     );
  //
  //     if (resGetCont != null) {
  //       contClientMobile = resGetCont;
  //       //textMesaj = 'Login realizat cu succes!'; //old IGV
  //       textMesaj = l.loginLoginCuSucces;
  //
  //       backgroundColor = const Color.fromARGB(255, 14, 190, 127);
  //       textColor = Colors.white;
  //
  //       SharedPreferences prefs = await SharedPreferences.getInstance();
  //       prefs.setString(pref_keys.userId, resGetCont.id.toString());
  //       prefs.setString(pref_keys.userEmail, resGetCont.email);
  //       prefs.setString(pref_keys.userTelefon, resGetCont.telefon);
  //       prefs.setString(pref_keys.user, resGetCont.user);
  //       //prefs.setString(pref_keys.userPassMD5, controllerEmail.text);
  //       prefs.setString(pref_keys.userPassMD5, userPassMD5);
  //       prefs.setString(pref_keys.userNume, resGetCont.nume);
  //       prefs.setString(pref_keys.userPrenume, resGetCont.prenume);
  //     } else {
  //       //textMesaj = 'Eroare! Reintroduceți user-ul și parola!'; //old IGV
  //       textMesaj = l.loginEroareReintroducetiUserParola;
  //       backgroundColor = Colors.red;
  //       textColor = Colors.black;
  //     }
  //     if (context.mounted) {
  //       showSnackbar(
  //         context,
  //         textMesaj,
  //         backgroundColor,
  //         textColor,
  //       );
  //     }
  //
  //     return resGetCont;
  //   } catch (e) {
  //     showSnackbar(
  //       context,
  //       e.toString(),
  //       backgroundColor,
  //       textColor,
  //     );
  //   }
  // }

  loginWithSocialMedia(BuildContext context, String user, String parola) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    LocalizationsApp l = LocalizationsApp.of(context)!;

    try {
      // Prepare MD5 encrypted password
      String userPassMD5 = apiCallFunctions.generateMd5(parola);

      ContClientMobile? resGetCont = await apiCallFunctions.getContClient(
        pUser: user,
        pParola: userPassMD5,
        pDeviceToken: prefs.getString('oneSignalId') ?? "",
        pTipDispozitiv: Platform.isAndroid ? '1' : '2',
        pModelDispozitiv: await apiCallFunctions.getDeviceInfo(),
        pTokenVoip: '',
      );

      if (resGetCont != null) {
        contClientMobile = resGetCont;

        // Save the user data in shared preferences
        await prefs.setString(pref_keys.userId, resGetCont.id.toString());
        await prefs.setString(pref_keys.userEmail, resGetCont.email);
        await prefs.setString(pref_keys.userTelefon, resGetCont.telefon);
        await prefs.setString(pref_keys.user, resGetCont.user);
        await prefs.setString(pref_keys.userPassMD5, userPassMD5);
        await prefs.setString(pref_keys.userNume, resGetCont.nume);
        await prefs.setString(pref_keys.userPrenume, resGetCont.prenume);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VeziMediciDisponibiliIntroScreen(
              contClientMobile: contClientMobile!,
            ),
          ),
        );
      } else {
        showSnackbar(context, l.loginEroareReintroducetiUserParola, Colors.red, Colors.black);
      }

      return resGetCont;
    } catch (e) {
      showSnackbar(context, e.toString(), Colors.red, Colors.white);
    }
  }

  login(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    LocalizationsApp l = LocalizationsApp.of(context)!;

    String textMesaj = '';
    Color backgroundColor = Colors.red;
    Color textColor = Colors.black;

    String mailTelefonUser = controllerEmailTelefonUser.text;
    String pass = controllerPass.text;

    String userPassMD5 = apiCallFunctions.generateMd5(pass);

    try {
      ContClientMobile? resGetCont = await apiCallFunctions.getContClient(
        pUser: mailTelefonUser,
        pParola: userPassMD5,

        //pDeviceToken: '', //old IGV
        pDeviceToken: prefs.getString('oneSignalId') ?? "",
        pTipDispozitiv: Platform.isAndroid ? '1' : '2',
        pModelDispozitiv: await apiCallFunctions.getDeviceInfo(),
        pTokenVoip: '',
      );

      if (resGetCont != null) {
        contClientMobile = resGetCont;
        //textMesaj = 'Login realizat cu succes!'; //old IGV
        textMesaj = l.loginLoginCuSucces;

        backgroundColor = const Color.fromARGB(255, 14, 190, 127);
        textColor = Colors.white;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(pref_keys.userId, resGetCont.id.toString());
        prefs.setString(pref_keys.userEmail, resGetCont.email);
        prefs.setString(pref_keys.userTelefon, resGetCont.telefon);
        prefs.setString(pref_keys.user, resGetCont.user);
        //prefs.setString(pref_keys.userPassMD5, controllerEmail.text);
        prefs.setString(pref_keys.userPassMD5, userPassMD5);
        prefs.setString(pref_keys.userNume, resGetCont.nume);
        prefs.setString(pref_keys.userPrenume, resGetCont.prenume);
      } else {
        //textMesaj = 'Eroare! Reintroduceți user-ul și parola!'; //old IGV
        textMesaj = l.loginEroareReintroducetiUserParola;
        backgroundColor = Colors.red;
        textColor = Colors.black;
      }
      if (context.mounted) {
        showSnackbar(
          context,
          textMesaj,
          backgroundColor,
          textColor,
        );
      }

      return resGetCont;
    } catch (e) {
      print(e.toString());
      showSnackbar(
        context,
        e.toString(),
        backgroundColor,
        textColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        //begin added by George Valentin Iordache
        /*
        appBar: AppBar(
          title: Text(
            //'Înapoi'
            l.universalInapoi,
          ),
          backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
          foregroundColor: Colors.white,
          leading: const BackButton(
            color: Colors.white,
          ),
        ),
        */
        //end added by George Valentin Iordache
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              children: [
                //added by George Iordache
                /*Row(
                    children:[
                      IconButton(
                        onPressed: (){
                        Navigator.pop(context);
                        //sau Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                        icon: const Icon(Icons.arrow_back),
                        //replace with our own icon data.
                      ),
                      const Text("Back"),
                    ]
                ),
                */
                // end added by George Valentin Iordache
                const SizedBox(height: 10),
                Center(child: Image.asset('./assets/images/12n.png', height: 200)),
                const SizedBox(height: 25),
                Form(
                  key: loginKey,
                  child: Column(
                    children: [
                      TextFormField(
                        onFieldSubmitted: (String s) {
                          focusNodePassword.requestFocus();
                        },
                        focusNode: focusNodeEmail,
                        controller: controllerEmailTelefonUser,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(205, 211, 223, 1),
                              //color: Color.fromARGB(255, 14, 190, 127), old
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(205, 211, 223, 1),
                              //color: Color.fromARGB(255, 14, 190, 127), old
                              width: 1.0,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          //hintText: "Telefon, e-mail sau utilizator", //old IGV
                          hintText: l.loginTelefonEmailUtilizatorHint,
                          hintStyle: const TextStyle(
                              color: Color.fromRGBO(103, 114, 148, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w300), //added by George Valentin Iordache
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            controllerEmailTelefonUser.value = TextEditingValue(
                              text: value[0].toUpperCase() + value.substring(1),
                              selection: controllerEmailTelefonUser.selection,
                            );
                          }
                        },
                        validator: (value) {
                          String emailPattern = r'.+@.+\.+';
                          RegExp emailRegExp = RegExp(emailPattern);
                          String phonePattern = r'(^(?:[+0]4)?[0-9]{10}$)';
                          RegExp phoneRegExp = RegExp(phonePattern);
                          //String namePattern = r"^\s*([A-Za-z]{1,}([\.,] |[-']| ))+[A-Za-z]+\.?\s*$";
                          //String namePattern = r'^[a-z A-Z,.\-]+$';

                          String userNamePattern = r'^(?=[a-zA-Z0-9._]{8,20}$)(?!.*[_.]{2})[^_.].*[^_.]$';
                          RegExp nameRegExp = RegExp(userNamePattern);
                          //RegExp nameRegExp = RegExp(namePattern);
                          if (value!.isEmpty ||
                              !(emailRegExp.hasMatch(value) ||
                                  phoneRegExp.hasMatch(value) ||
                                  nameRegExp.hasMatch(value))) {
                            //return "Introduceți un utilizator/email/numar de telefon valabil!"; //old IGV
                            return l.loginMesajIntroducetiUtilizatorEmailTelefon;
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        focusNode: focusNodePassword,
                        controller: controllerPass,
                        obscureText: isHidden,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: passVisibiltyToggle,
                                icon: isHidden ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off)),
                            //hintText: "Parolă", //old IGV
                            hintText: l.loginParola,
                            hintStyle: const TextStyle(
                                color: Color.fromRGBO(103, 114, 148, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.w300), //added by George Valentin Iordache

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                //color: Color.fromARGB(255, 14, 190, 127), old
                                color: Color.fromRGBO(205, 211, 223, 1),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                //color: Color.fromARGB(255, 14, 190, 127), old
                                color: Color.fromRGBO(205, 211, 223, 1),
                                width: 1.0,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return l.loginIntroducetiParola;
                          } else if (value.length < 6) {
                            return l.loginMesajParolaCelPutin;
                          } else {
                            return null;
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return const ResetPasswordPacientScreen();
                              //return const PlataEsuataScreen();
                            },
                          ));
                        },
                        child: Text(
                            //'Ai uitat parola?', //old IGV
                            l.loginAiUitatParola,
                            style:
                                const TextStyle(color: Color.fromRGBO(103, 114, 148, 1), fontWeight: FontWeight.w300))),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  /*
                  onPressed: () async
                  {

                    await trimitePushPrinOneSignal();

                  },
                  */
                  //corect IGV
                  onPressed: () async {
                    final isValidForm = loginKey.currentState!.validate();
                    if (isValidForm) {
                      ContClientMobile? resGetCont = await login(context);
                      if (resGetCont != null) {
                        if (context.mounted) {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) =>
                          //           IntroScreen(contClientMobile: resGetCont),
                          //     ));
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VeziMediciDisponibiliIntroScreen(
                                  contClientMobile: contClientMobile!,
                                ), //LoginScreen(),
                              ));
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
                      //const Color.fromARGB(255, 14, 190, 127), old
                      minimumSize: const Size.fromHeight(50), // NEW
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                  child: Text(
                      //'CONECTARE', //old IGV
                      l.loginConectare,
                      //style: GoogleFonts.rubik(color: Colors.white, fontWeight: FontWeight.w300, fontSize: 20)), old
                      style: GoogleFonts.rubik(
                          color: Colors.white, fontWeight: FontWeight.w300, fontSize: 18)), //George Valentin Iordache
                ),
                const SizedBox(height: 100),
                // Text("OR", style: GoogleFonts.rubik(color: Colors.black45, fontWeight: FontWeight.w500)), old
                Text(
                    //"OR", //old IGV
                    l.loginOr,
                    style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1), fontWeight: FontWeight.w400, fontSize: 14)),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () async {
                    await checkLoginWithFacebook();
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50), // NEW
                    side: const BorderSide(color: Colors.blue, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          './assets/images/facebook_icon.png',
                          width: 25,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          l.loginConectareCuFacebook,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rubik(color: Colors.blue, fontWeight: FontWeight.w400, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () async {
                    //! todo: connect with google
                    try {
                      final user = await loginWithGoogle();
                      if (user != null && mounted) {}
                    } on FirebaseAuthException catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.message ?? "Something went wrong")));
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50), // NEW
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          './assets/images/google_icon.png',
                          width: 25,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          //"CONECTARE CU GOOGLE", //old IGV
                          l.loginConectareCuGoogle,
                          style: GoogleFonts.rubik(color: Colors.red, fontWeight: FontWeight.w400, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ));
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50), // NEW
                    side: const BorderSide(color: Color.fromRGBO(14, 190, 127, 1), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          //"NU AI CONT?", //old IGV
                          l.loginNuAiCont,
                          style: GoogleFonts.rubik(
                            color: const Color.fromRGBO(14, 190, 127, 1),
                            fontWeight: FontWeight.w300,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2), // Slight space between the texts
                      Text(
                        //" INSCRIE-TE!", //old IGV
                        l.loginInscrieTe,
                        style: GoogleFonts.rubik(
                          color: const Color.fromRGBO(14, 190, 127, 1),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }

//metodă de testat

  Future<http.Response?> trimitePushPrinOneSignal() async {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    String textMessage = '';
    Color backgroundColor = Colors.red;
    Color textColor = Colors.black;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('userEmail');
    String? userPassMD5 = prefs.getString('userPassMD5');

    if (userEmail == null || userPassMD5 == null) {
      return null;
    }

    http.Response? resTrimitePushPrinOneSignal = await apiCallFunctions.trimitePushPrinOneSignal(
      pUser: userEmail,
      pParola: userPassMD5,
      pTipNotificare: '1',
    );

    if (int.parse(resTrimitePushPrinOneSignal!.body) == 200) {
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //prefs.setString(pref_keys.userEmail, controllerEmail.text);

      //prefs.setString(pref_keys.userPassMD5, apiCallFunctions.generateMd5(controllerPass.text));

      textMessage = 'Notificare trimisă cu succes!'; //old IGV
      //textMessage = l.resetPasswordPacientCodTrimisCuSucces;

      backgroundColor = const Color.fromARGB(255, 14, 190, 127);
      textColor = Colors.white;
    } else if (int.parse(resTrimitePushPrinOneSignal.body) == 400) {
      textMessage = 'Apel invalid!'; //old IGV
      //textMessage = l.resetPasswordPacientApelInvalid;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resTrimitePushPrinOneSignal.body) == 401) {
      //prefs.setString(pref_keys.userEmail, controllerEmail.text);
      //prefs.setString(pref_keys.userPassMD5, apiCallFunctions.generateMd5(controllerPass.text));

      textMessage = 'Nu s-a trimis notificarea!'; //old IGV

      //textMessage = l.resetPasswordPacientContInexistent;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resTrimitePushPrinOneSignal.body) == 405) {
      textMessage = 'Informații insuficiente!'; //old IGV

      //textMessage = l.resetPasswordPacientContExistentFaraDate; //old IGV

      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resTrimitePushPrinOneSignal.body) == 500) {
      //textMessage = 'A apărut o eroare la execuția metodei!'; //old IGV

      textMessage = l.resetPasswordPacientAAparutOEroare;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    }

    if (context.mounted) {
      showSnackbar(context, textMessage, backgroundColor, textColor);

      return resTrimitePushPrinOneSignal;
    }

    return null;
  }
}
