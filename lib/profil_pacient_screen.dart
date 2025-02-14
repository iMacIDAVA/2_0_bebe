import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sos_bebe_app/datefacturare/date_facturare_screen.dart';
import 'package:sos_bebe_app/gdpr/gdpr_page.dart';
import 'package:sos_bebe_app/intro_screen.dart';
import 'package:sos_bebe_app/istoric_consultatii/istoric_consultatii.dart';
import 'package:sos_bebe_app/plati_screen.dart';
import 'package:sos_bebe_app/termeni_conditii/termeni_conditii_page.dart';
import 'package:sos_bebe_app/termeni_si_conditii_screen.dart';
import 'package:sos_bebe_app/utils/utils_widgets.dart';
//import  'package:sos_bebe_app/register_screen.dart';

//import  'package:sos_bebe_app/factura_screen.dart';

import 'package:sos_bebe_app/editare_cont_screen.dart';
import 'package:sos_bebe_app/login_screen.dart';

import 'package:sos_bebe_app/vezi_medici_salvati_screen.dart';

import 'package:sos_bebe_app/verifica_pin_sterge_cont_screen.dart';

import 'package:sos_bebe_app/utils_api/classes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';

import 'package:sos_bebe_app/utils_api/functions.dart';
import 'package:http/http.dart' as http;

import 'package:sos_bebe_app/localizations/1_localizations.dart';
import 'package:sos_bebe_app/vezi_toti_medicii_screen.dart';

ApiCallFunctions apiCallFunctions = ApiCallFunctions();

List<MedicMobile> listaMedici = [];

  ContClientMobile? resGetCont;

class ProfilulMeuPacientScreen extends StatefulWidget {
  final ContClientMobile? contInfo;

  const ProfilulMeuPacientScreen({
    super.key,
    required this.contInfo,
  });

  @override
  State<ProfilulMeuPacientScreen> createState() => ProfilulMeuPacientScreenState();
}

class ProfilulMeuPacientScreenState extends State<ProfilulMeuPacientScreen> {
  List<FacturaClientMobile> listaFacturi = [];

  bool deconectareActivat = false;

  void callbackDeconectare(bool newDeconectareActivat) {
    setState(() {
      deconectareActivat = newDeconectareActivat;
    });
  }

  getListaFacturi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    listaFacturi = await apiCallFunctions.getListaFacturi(
          pUser: user,
          pParola: userPassMD5,
        ) ??
        [];
  }

  void logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return const IntroScreen();
      },
    ));
    setState(() {});
  }

  Future<http.Response?> trimitePinPentruStergereContClient() async {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    /*
    http.Response? res = await apiCallFunctions.getContClient(
      pUser: controllerEmail.text,
      pParola: controllerPass.text,
    );
    */

    String textMessage = '';
    Color backgroundColor = Colors.red;
    Color textColor = Colors.black;

    http.Response? resTrimitePinPentruStergere = await apiCallFunctions.trimitePinPentruStergereContClient(
      pUser: user,
      pParola: userPassMD5,
    );

    if (int.parse(resTrimitePinPentruStergere!.body) == 200) {
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //prefs.setString(pref_keys.userEmail, controllerEmail.text);

      //prefs.setString(pref_keys.userPassMD5, apiCallFunctions.generateMd5(controllerPass.text));

      //textMessage = 'Cod trimis cu succes!';// old IGV
      textMessage = l.profilPacientCodTrimisCuSucces;

      backgroundColor = const Color.fromARGB(255, 14, 190, 127);
      textColor = Colors.white;
    } else if (int.parse(resTrimitePinPentruStergere.body) == 400) {
      //textMessage = 'Apel invalid!'; //old IGV
      textMessage = l.profilPacientApelInvalid;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resTrimitePinPentruStergere.body) == 401) {
      //prefs.setString(pref_keys.userEmail, controllerEmail.text);
      //prefs.setString(pref_keys.userPassMD5, apiCallFunctions.generateMd5(controllerPass.text));

      //textMessage = 'Cont inexistent!'; //old IGV
      textMessage = l.profilPacientContInexistent;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resTrimitePinPentruStergere.body) == 405) {
      //textMessage = 'Cont existent dar clientul nu are date de contact!'; //old IGV

      textMessage = l.profilPacientContExistentFaraDateContact;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resTrimitePinPentruStergere.body) == 500) {
      //textMessage = 'A apărut o eroare la execuția metodei!'; //old IGV
      textMessage = l.profilPacientAAparutOEroare;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    }

    if (context.mounted) {
      showSnackbar(context, textMessage, backgroundColor, textColor);

      return resTrimitePinPentruStergere;
    }

    return null;
  }

  List<MedicMobile> listaMediciFavoriti = [];

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

  Future<void> getListaMediciFavoriti() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    listaMediciFavoriti = await apiCallFunctions.getListaMedicFavorit(
          pUser: user,
          pParola: userPassMD5,
        ) ??
        [];
  }

  ContClientMobile? contInfo;

  Future<void> getContDetalii() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
    contInfo = await apiCallFunctions.getContClient(
      pUser: user,
      pParola: userPassMD5,
      pDeviceToken: prefs.getString('oneSignalId') ?? "",
      pTipDispozitiv: Platform.isAndroid ? '1' : '2',
      pModelDispozitiv: await apiCallFunctions.getDeviceInfo(),
      pTokenVoip: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    return WillPopScope(
      onWillPop: () async {
        await getContDetalii();
        await getListaMedici();
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return VeziTotiMediciiScreen(listaMedici: listaMedici, contClientMobile: contInfo!);
        }));
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color.fromRGBO(30, 214, 158, 1),
        appBar: AppBar(
          toolbarHeight: 90,
          backgroundColor: const Color.fromRGBO(30, 214, 158, 1),
          foregroundColor: Colors.white,
          leading: BackButton(
            color: Colors.white,
            onPressed: () async {
              await getContDetalii();
              await getListaMedici();
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return VeziTotiMediciiScreen(listaMedici: listaMedici, contClientMobile: contInfo!);
              }));
            },
          ),
          title: Text(
            //'Profilul meu',
            l.profilPacientProfilulMeuTitlu,
            style: GoogleFonts.rubik(
                color: const Color.fromRGBO(255, 255, 255, 1), fontSize: 16, fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              IconDateProfil(
                iconPathPacient: widget.contInfo!.linkPozaProfil ?? '',
                textNume: '${widget.contInfo!.prenume} ${widget.contInfo!.nume}',
                textAdresaEmail: widget.contInfo!.email,
                textNumarTelefon: widget.contInfo!.telefon,
              ),
              const SizedBox(
                height: 35,
              ),
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    ExpandTapWidget(
                      tapPadding: const EdgeInsets.all(10.0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => EditareContScreen(
                                    contInfo: widget.contInfo,
                                  )),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              'assets/images/user_icon.png',
                              scale: 0.8,
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 150),
                              child: Text(
                                //'Editare cont', //old IGV
                                l.profilPacientEditareCont,
                                style: GoogleFonts.rubik(
                                    color: const Color.fromRGBO(18, 25, 36, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            Image.asset('./assets/images/arrow_right_verde_icon.png'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    customDividerProfil(),
                    const SizedBox(height: 20),
                    ExpandTapWidget(
                      tapPadding: const EdgeInsets.all(10.0),
                      onTap: () async {
                        await getListaMediciFavoriti();

                        if (context.mounted) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VeziMediciSalvatiScreen(
                                    listaMedici: listaMediciFavoriti, contInfo: widget.contInfo),
                              ));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              './assets/images/doctori_salvati_icon.png',
                              scale: 1.2,
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 150),
                              child: Text(
                                //'Editare cont', //old IGV
                                'Doctori Salvați',
                                style: GoogleFonts.rubik(
                                    color: const Color.fromRGBO(18, 25, 36, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            Image.asset('./assets/images/arrow_right_verde_icon.png'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    customDividerProfil(),
                    const SizedBox(height: 20),
                    ExpandTapWidget(
                      tapPadding: const EdgeInsets.all(10.0),
                      onTap: () async {
                        await getListaFacturi();

                        if (context.mounted) {
                          if (listaFacturi.isNotEmpty) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlatiScreen(
                                    listaFacturi: listaFacturi,
                                  ),
                                ));
                          } else {
                            //showSnackbar(context, 'Nu există facturi de afișat!', Colors.red, Colors.black,);
                            showSnackbar(
                              context,
                              l.profilPacientNuExistaFacturiDeAfisat,
                              Colors.red,
                              Colors.black,
                            );
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              'assets/images/incasari_meniu.png',
                              color: const Color.fromRGBO(30, 214, 158, 1),
                              scale: 0.8,
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 150),
                              child: Text(
                                //'Editare cont', //old IGV
                                'Vezi plțăi',
                                style: GoogleFonts.rubik(
                                    color: const Color.fromRGBO(18, 25, 36, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            Image.asset('./assets/images/arrow_right_verde_icon.png'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    customDividerProfil(),
                    const SizedBox(height: 20),
                    ExpandTapWidget(
                      tapPadding: const EdgeInsets.all(10.0),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return const IstoricConsultatii();
                        }));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              './assets/images/termeni_si_conditii_icon.png',
                              color: const Color.fromRGBO(30, 214, 158, 1),
                              scale: 0.8,
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 150),
                              child: Text(
                                //'Editare cont', //old IGV
                                "Istoric consultații",
                                style: GoogleFonts.rubik(
                                    color: const Color.fromRGBO(18, 25, 36, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            Image.asset('./assets/images/arrow_right_verde_icon.png'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    customDividerProfil(),
                    const SizedBox(height: 20),
                    ExpandTapWidget(
                      tapPadding: const EdgeInsets.all(10.0),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return DateFacturareScreen(
                            contClientMobile: widget.contInfo!,
                          );
                        }));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              'assets/images/incasari_meniu.png',
                              color: const Color.fromRGBO(30, 214, 158, 1),
                              scale: 0.8,
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 150),
                              child: Text(
                                //'Editare cont', //old IGV
                                'Date de facturare',
                                style: GoogleFonts.rubik(
                                    color: const Color.fromRGBO(18, 25, 36, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            Image.asset('./assets/images/arrow_right_verde_icon.png'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    customDividerProfil(),
                    const SizedBox(height: 20),
                    ExpandTapWidget(
                      tapPadding: const EdgeInsets.all(10.0),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return const GDPRPage();
                        }));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              './assets/images/termeni_si_conditii_icon.png',
                              scale: 0.8,
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 150),
                              child: Text(
                                //'Editare cont', //old IGV
                                l.profilPacientGDPR,
                                style: GoogleFonts.rubik(
                                    color: const Color.fromRGBO(18, 25, 36, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            Image.asset('./assets/images/arrow_right_verde_icon.png'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    customDividerProfil(),
                    const SizedBox(height: 20),
                    ExpandTapWidget(
                      tapPadding: const EdgeInsets.all(10.0),
                      onTap: () {
                        dezactivareDialog();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              'assets/images/user_icon.png',
                              scale: 0.8,
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 150),
                              child: Text(
                                //'Editare cont', //old IGV
                                l.profilPacientDezactivareCont,
                                style: GoogleFonts.rubik(
                                    color: const Color.fromRGBO(18, 25, 36, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            Image.asset('./assets/images/arrow_right_verde_icon.png'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    customDividerProfil(),
                    const SizedBox(height: 20),
                    // IconTextAndSwitchWidget(
                    //     iconPath: './assets/images/deconectare_icon.png',
                    //     text: l.profilPacientDeconectare,
                    //     callback: callbackDeconectare,
                    //     isToggled: deconectareActivat),
                    ExpandTapWidget(
                      tapPadding: const EdgeInsets.all(10.0),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (contexxt) {
                          return const TermeniSiConditii();
                        }));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              './assets/images/termeni_si_conditii_icon.png',
                              scale: 0.8,
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 150),
                              child: Text(
                                //'Editare cont', //old IGV
                                'Termeni și condiții',
                                style: GoogleFonts.rubik(
                                    color: const Color.fromRGBO(18, 25, 36, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            Image.asset('./assets/images/arrow_right_verde_icon.png'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    customDividerProfil(),
                    const SizedBox(height: 20),
                    ExpandTapWidget(
                      tapPadding: const EdgeInsets.all(10.0),
                      onTap: () {
                        logOut();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              './assets/images/deconectare_icon.png',
                              scale: 0.8,
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 150),
                              child: Text(
                                //'Editare cont', //old IGV
                                l.profilPacientDeconectare,
                                style: GoogleFonts.rubik(
                                    color: const Color.fromRGBO(18, 25, 36, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    customDividerProfil(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  dezactivareDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Dezactivare cont'),
            content: const Text('Ești sigur că vrei să îți dezactivezi contul?'),
            actions: <Widget>[
              GestureDetector(
                child: const Text('Anulează'),
                onTap: () {
                  Navigator.of(context).pop(false); // Return false when cancelled
                },
              ),
              GestureDetector(
                child: const Text(
                  'Dezactivează',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  try {
                    http.Response? resTrimitePinPentruStergereContClient;

                    resTrimitePinPentruStergereContClient = await trimitePinPentruStergereContClient();
                    if (resTrimitePinPentruStergereContClient!.body == "200") {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String user = prefs.getString('user') ?? '';
                      String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VerificaPinStergeContScreen(user: user, userPassMD5: userPassMD5),
                        ),
                      );
                    }
                  } catch (e) {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        });
  }
}

//ignore: must_be_immutable
class IconTextAndSwitchWidget extends StatefulWidget {
  final String text;
  final String iconPath;
  bool isToggled;

  final Function(bool)? callback;
  IconTextAndSwitchWidget(
      {super.key, required this.text, required this.iconPath, required this.isToggled, this.callback});

  @override
  State<IconTextAndSwitchWidget> createState() => _IconTextAndSwitchWidgetState();
}

class _IconTextAndSwitchWidgetState extends State<IconTextAndSwitchWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,

      //Text(widget.disease, style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w400)), old

      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.09,
        ),
        IconButton(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();

            prefs.setString(pref_keys.userId, '-1');
            prefs.setString(pref_keys.userEmail, '');
            prefs.setString(pref_keys.userTelefon, '');
            prefs.setString(pref_keys.user, '');
            prefs.setString(pref_keys.userPassMD5, '');

            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            }
          },
          icon: Image.asset(widget.iconPath),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.05),
        GestureDetector(
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();

            prefs.setString(pref_keys.userId, '-1');
            prefs.setString(pref_keys.userEmail, '');
            prefs.setString(pref_keys.userTelefon, '');
            prefs.setString(pref_keys.user, '');
            prefs.setString(pref_keys.userPassMD5, '');

            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            }
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Text(widget.text,
                style: GoogleFonts.rubik(
                    color: const Color.fromRGBO(18, 25, 36, 1), fontSize: 14, fontWeight: FontWeight.w400)),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
        ),
        /*
        FlutterSwitch(
          value: widget.isToggled,
          height: 20,
          width: 40,

          //activeColor: const Color.fromARGB(255, 103, 197, 108),

          //added by George Valentin Iordache
          activeColor: const Color.fromRGBO(30, 214, 158, 1),

          inactiveColor: Colors.grey[200]!,
          onToggle: (value) {
            if (widget.callback != null)
            {
              setState(() {
                widget.callback!(value);
              });
            } else
            {
              setState(() {
                widget.isToggled = value;
                // ignore: avoid_print
                print(widget.isToggled);
              });
            }
          },
        ),
        */
      ],
    );
  }
}

class IconAndText extends StatelessWidget {
  final String iconPath;
  final String termeniSiConditii;

  const IconAndText({
    super.key,
    required this.iconPath,
    required this.termeniSiConditii,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,

      //Text(widget.disease, style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w400)), old

      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.08,
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermeniSiConditiiScreen(),
                ));
          },
          icon: Image.asset(iconPath),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.0007),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermeniSiConditiiScreen(),
                  ));
            },
            child: Text(
              termeniSiConditii,
              style: GoogleFonts.rubik(
                  color: const Color.fromRGBO(18, 25, 36, 1), fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
        ),
      ],
    );
  }
}

class IconDateProfil extends StatefulWidget {
  final String iconPathPacient;
  final String textNume;
  final String textAdresaEmail;
  final String textNumarTelefon;

  const IconDateProfil({
    super.key,
    required this.iconPathPacient,
    required this.textNume,
    required this.textAdresaEmail,
    required this.textNumarTelefon,
  });

  @override
  State<IconDateProfil> createState() => _IconDateProfilState();
}

class _IconDateProfilState extends State<IconDateProfil> {
  Uint8List? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadAndDecodeImage();
  }

  Future<void> _loadAndDecodeImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? base64Image = prefs.getString(pref_keys.profileImageUrl);
    if (base64Image != null && base64Image.isNotEmpty) {
      setState(() {
        _profileImage = base64Decode(base64Image);
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
              onPressed: () {},
              icon: _profileImage == null && widget.iconPathPacient.isEmpty
                  ? Image.asset('./assets/images/user_fara_poza.png', width: 75, height: 75)
                  : _profileImage != null
                      ? Image.memory(_profileImage!, width: 75, height: 75)
                      : widget.iconPathPacient.isNotEmpty
                          ? Image.network(widget.iconPathPacient, width: 75, height: 75)
                          : Image.asset('./assets/images/user_fara_poza.png', width: 75, height: 75)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.textNume,
                  style: const TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.clip,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.textAdresaEmail,
                  style: const TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.clip,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.textNumarTelefon,
                  style: const TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
