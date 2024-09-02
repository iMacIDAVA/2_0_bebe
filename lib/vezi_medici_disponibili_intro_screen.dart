import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:sos_bebe_app/intro_screen.dart';
import 'package:sos_bebe_app/vezi_toti_medicii_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:sos_bebe_app/localizations/1_localizations.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';

ApiCallFunctions apiCallFunctions = ApiCallFunctions();

List<MedicMobile> listaMedici = [];

class VeziMediciDisponibiliIntroScreen extends StatelessWidget {
  final ContClientMobile contClientMobile;

  const VeziMediciDisponibiliIntroScreen(
      {super.key, required this.contClientMobile});

  getListaMedici() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    listaMedici = await apiCallFunctions.getListaMedici(
          pUser: user,
          pParola: userPassMD5,
        ) ??
        [];

    print('listaMedici: $listaMedici');
  }

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    return Scaffold(
      //begin added by George Valentin Iordache
      appBar: AppBar(
          //title: const Text('Înapoi'), //old IGV
          title: Text(
            l.universalInapoi,
          ),
          backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
          foregroundColor: Colors.white,
          leading: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return IntroScreen();
                },
              ));
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          )),
      //end added by George Valentin Iordache
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('./assets/images/Sosbebe.png',
                    height: 102, width: 81),
                ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.white, Colors.transparent],
                    ).createShader(
                        Rect.fromLTRB(0, 0, rect.width, rect.height));
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                      width: 300,
                      './assets/images/medici_disponibili_intro_background_image.png'),
                  //Image.memory(poza, height: 190, width: 175, fit: BoxFit.cover)), Unident Andrei Bădescu
                ),
                ElevatedButton(
                  onPressed: () async {
                    await getListaMedici();
                    print('Email intro_screen ${contClientMobile.email}');

                    if (context.mounted) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VeziTotiMediciiScreen(
                              listaMedici: listaMedici,
                              contClientMobile: contClientMobile,
                            ),
                          ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
                      //const Color.fromARGB(255, 14, 190, 127), old
                      //minimumSize: const Size.fromHeight(50), // NEW
                      maximumSize: const Size(306, 53),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          //'Vezi medici disponibili', //old IGV
                          l.veziMediciDisponibiliIntroVeziMediciDisponibiliTitlu,
                          style: GoogleFonts.rubik(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            fontSize: 14,
                          )),
                      Image.asset(
                          './assets/images/medici_disponibili_buton_icon.png'),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                AutoSizeText.rich(
                  // old value RichText(
                  TextSpan(
                    style: GoogleFonts.rubik(
                      color: const Color.fromRGBO(103, 114, 148, 1),
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                          //text: 'Acesta aplicatie doreste sa vina in sprijinul parintilor oferind sfaturi medicale profesioniste, la orice ora din zi sau din noapte.'), //old IGV
                          //'Acestă aplicație dorește să vină în sprijinul părinților oferind sfaturi medicale profesioniste, la orice oră din zi sau din noapte.' //text cu diacritice IGV
                          text:
                              l.veziMediciDisponibiliIntroAceastaAplicatieText),
                    ],
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 25),
                AutoSizeText.rich(
                  // old value RichText(
                  TextSpan(
                    style: GoogleFonts.rubik(
                      color: const Color.fromRGBO(103, 114, 148, 1),
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                          //text: 'Medicii nostri acorda asistenta pediatrica de prima interventie cu scopul de a linisti temerile parintilor si a ameliora sintmomele copiilor pana la un consult in persoana cu medicul pediatru sau de familie.'), //old IGV
                          //'Medicii noștri acordă asistență pediatrică de prima intervenție cu scopul de a liniști temerile părinților și a ameliora simptome copiilor până la un consult în persoană cu medicul pediatru sau de familie.' //text cu diacritice IGV
                          text: l.veziMediciDisponibiliIntroMediciiNostriText),
                    ],
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 25),
                AutoSizeText.rich(
                  // old value RichText(
                  TextSpan(
                    style: GoogleFonts.rubik(
                      color: const Color.fromRGBO(103, 114, 148, 1),
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                    children: <TextSpan>[
                      //TextSpan(text: 'Atentie! In cazul in care viata copilului este in pericol, va rugam sa apelati numarul unic de urgente 112 sau sa va adresati Unitatilor de Primire Urgente.'), //old IGV
                      //'Atenție! În cazul în care viața copilului este în pericol, vă rugăm să apelați numărul unic de urgențe 112 sau să vă adresați Unităților de Primire Urgențe.' //text cu diacritice IGV
                      TextSpan(text: l.veziMediciDisponibiliIntroAtentieText),
                    ],
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
