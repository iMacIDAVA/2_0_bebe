import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sos_bebe_app/profil_pacient_screen.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:sos_bebe_app/profil_doctor_disponibilitate_servicii_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/utils_api/functions.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;
import 'package:http/http.dart' as http;

import 'package:sos_bebe_app/localizations/1_localizations.dart';

ApiCallFunctions apiCallFunctions = ApiCallFunctions();

List<MedicMobile> listaMediciSalvatiInitiala = [];

MedicMobile? medicSelectat;

List<RecenzieMobile>? listaRecenziiMedicSelectat = [];

class VeziMediciSalvatiScreen extends StatefulWidget {
  final List<MedicMobile> listaMedici;
  final ContClientMobile? contInfo;

  const VeziMediciSalvatiScreen({super.key, required this.listaMedici, required this.contInfo});

  @override
  State<VeziMediciSalvatiScreen> createState() => _VeziMediciSalvatiScreenState();
}

class _VeziMediciSalvatiScreenState extends State<VeziMediciSalvatiScreen> {
  //List<MedicMobile> listaFiltrata = [];

  ContClientMobile? contInfo;

  List<MedicMobile> listaFiltrata = [];

  bool scrieOintrebareLista = false;
  bool consultatieVideoLista = false;
  bool interpretareAnalizeLista = false;
  bool totiMediciiList = true;

  //
  List<Widget> allMedics = [];
  List<Widget> intrebariMedics = [];
  List<Widget> consultatieMedics = [];
  List<Widget> interpretareMedics = [];
  bool isDoneLoading = false;

  Uint8List? _profileImage;

  @override
  void initState() {
    // Do some other stuff
    super.initState();

    _loadAndDecodeImage();

    getContDetalii();
    listaFiltrata = widget.listaMedici;
    for (var element in listaFiltrata) {
      allMedics.add(
        IconStatusNumeRatingSpitalLikesMedic(
          medicItem: element,
          contClientMobile: widget.contInfo!,
        ),
      );
      if (element.consultatieVideo == true) {
        consultatieMedics.add(
          IconStatusNumeRatingSpitalLikesMedic(
            medicItem: element,
            contClientMobile: widget.contInfo!,
          ),
        );
      }
      if (element.interpreteazaAnalize == true) {
        interpretareMedics.add(IconStatusNumeRatingSpitalLikesMedic(
          medicItem: element,
          contClientMobile: widget.contInfo!,
        ));
      }
      if (element.primesteIntrebari == true) {
        intrebariMedics.add(IconStatusNumeRatingSpitalLikesMedic(
          medicItem: element,
          contClientMobile: widget.contInfo!,
        ));
      }
    }

    //listaFiltrata = listaMedici;
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
    setState(() {
      isDoneLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    //var length = listaMedici.length;
    //print('Size lista: $length');

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        appBar: AppBar(
          //title: const Text('Înapoi'), //old IGV
          title: Text(
            l.universalInapoi,
          ),

          backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
          foregroundColor: Colors.white,
          leading: GestureDetector(
            onTap: () {
              // Navigator.pop(context);
              if (isDoneLoading) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilulMeuPacientScreen(contInfo: contInfo),
                    ));
              }
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Column(
                  children: totiMediciiList
                      ? allMedics
                      : scrieOintrebareLista
                          ? intrebariMedics
                          : consultatieVideoLista
                              ? consultatieMedics
                              : interpretareAnalizeLista
                                  ? interpretareMedics
                                  : allMedics,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ButtonSelectareOptiuni extends StatelessWidget {
  Color colorBackground;
  String iconLocation;
  double widthScris;
  String textServiciu;
  Color colorScris;
  ButtonSelectareOptiuni(
      {super.key,
      required this.colorBackground,
      required this.colorScris,
      required this.iconLocation,
      required this.textServiciu,
      required this.widthScris});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      //color: const Color.fromRGBO(241, 248, 251, 1),
      decoration: BoxDecoration(
          border: Border.all(
            color: colorBackground,
          ),
          borderRadius: BorderRadius.circular(15.0),
          color: colorBackground //const Color.fromRGBO(241, 248, 251, 1),
          ),
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(width: 5),
          Image.asset(iconLocation),
          const SizedBox(width: 5),
          SizedBox(
            width: widthScris,
            height: 35,
            child: Text(
              textServiciu,
              style: GoogleFonts.rubik(
                  color: colorScris,
                  fontSize: 11,
                  fontWeight: FontWeight.w400), //const Color.fromRGBO(30, 166, 219, 1),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class IconStatusNumeRatingSpitalLikesMedic extends StatefulWidget {
  final MedicMobile medicItem;

  final ContClientMobile contClientMobile;

  const IconStatusNumeRatingSpitalLikesMedic({
    super.key,
    required this.medicItem,
    required this.contClientMobile,
  });

  @override
  State<IconStatusNumeRatingSpitalLikesMedic> createState() => _IconStatusNumeRatingSpitalLikesMedic();
}

class _IconStatusNumeRatingSpitalLikesMedic extends State<IconStatusNumeRatingSpitalLikesMedic> {
  final double _ratingValue = 4.9;

  static const activ = EnumStatusMedicMobile.activ;
  static const inConsultatie = EnumStatusMedicMobile.inConsultatie;

  bool medicAdaugatCuSucces = false;
  bool medicScosCuSucces = false;
  bool medicFavorit = false;
  Future<MedicMobile?> getDetaliiMedic(int idMedic) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    medicSelectat = await apiCallFunctions.getDetaliiMedic(
      pUser: user,
      pParola: userPassMD5,
      pIdMedic: idMedic.toString(),
    );
    return medicSelectat;
  }

  Future<http.Response?> adaugaMedicLaFavorit() async {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    String textMessage = '';
    Color backgroundColor = Colors.red;
    Color textColor = Colors.black;

    http.Response? resAdaugaMedicLaFavorit = await apiCallFunctions.adaugaMedicLaFavorit(
      pUser: user,
      pParola: userPassMD5,
      pIdMedic: widget.medicItem.id.toString(),
    );

    if (int.parse(resAdaugaMedicLaFavorit!.body) == 200) {
      setState(() {
        medicAdaugatCuSucces = true;
        medicScosCuSucces = false;

        medicFavorit = true;

        //showButonTrimiteTestimonial = false;
      });

      textMessage = l.profilDoctorDisponibilitateServiciiMedicAdaugatCuSucces;

      backgroundColor = const Color.fromARGB(255, 14, 190, 127);
      textColor = Colors.white;
    } else if (int.parse(resAdaugaMedicLaFavorit.body) == 400) {
      setState(() {
        medicAdaugatCuSucces = false;
      });

      textMessage = l.profilDoctorDisponibilitateServiciiMedicAdaugatApelInvalid;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resAdaugaMedicLaFavorit.body) == 401) {
      setState(() {
        medicAdaugatCuSucces = false;
      });

      textMessage = l.profilDoctorDisponibilitateServiciiMedicNeadaugat;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resAdaugaMedicLaFavorit.body) == 405) {
      setState(() {
        medicAdaugatCuSucces = false;
      });

      textMessage = l.profilDoctorDisponibilitateServiciiMedicAdaugatInformatiiInsuficiente;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resAdaugaMedicLaFavorit.body) == 500) {
      setState(() {
        medicAdaugatCuSucces = false;
      });

      textMessage = l.profilDoctorDisponibilitateServiciiMedicAdaugatAAparutOEroare;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    }

    if (context.mounted) {
      showSnackbar(context, textMessage, backgroundColor, textColor);

      return resAdaugaMedicLaFavorit;
    }

    return null;
  }

  Future<http.Response?> scoateMedicDeLaFavorit() async {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    String textMessage = '';
    Color backgroundColor = Colors.red;
    Color textColor = Colors.black;

    http.Response? resScoateMedicDeLaFavorit = await apiCallFunctions.scoateMedicDeLaFavorit(
      pUser: user,
      pParola: userPassMD5,
      pIdMedic: widget.medicItem.id.toString(),
    );

    if (int.parse(resScoateMedicDeLaFavorit!.body) == 200) {
      setState(() {
        medicAdaugatCuSucces = false;
        medicScosCuSucces = true;
        //showButonTrimiteTestimonial = false;

        medicFavorit = false;
      });

      textMessage = l.profilDoctorDisponibilitateServiciiMedicScosCuSucces;

      backgroundColor = const Color.fromARGB(255, 14, 190, 127);
      textColor = Colors.white;
    } else if (int.parse(resScoateMedicDeLaFavorit.body) == 400) {
      setState(() {
        medicScosCuSucces = false;
      });

      //textMessage = 'Apel invalid!'; //old IGV

      textMessage = l.profilDoctorDisponibilitateServiciiMedicScosApelInvalid;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resScoateMedicDeLaFavorit.body) == 401) {
      setState(() {
        //medicAdaugatCuSucces = false;
        medicScosCuSucces = false;
        //showButonTrimiteTestimonial = false;
      });

      //textMessage = 'Medicul nu a fost scos de la favorite!'; //old IGV
      textMessage = l.profilDoctorDisponibilitateServiciiMedicNescos;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resScoateMedicDeLaFavorit.body) == 405) {
      setState(() {
        //medicAdaugatCuSucces = false;
        medicScosCuSucces = false;
        //showButonTrimiteTestimonial = false;
      });

      textMessage = l.profilDoctorDisponibilitateServiciiMedicScosInformatiiInsuficiente;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resScoateMedicDeLaFavorit.body) == 500) {
      setState(() {
        //medicAdaugatCuSucces = false;
        medicScosCuSucces = false;
        //showButonTrimiteTestimonial = false;
      });

      textMessage = l.profilDoctorDisponibilitateServiciiMedicScosAAparutOEroare;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    }

    if (context.mounted) {
      showSnackbar(context, textMessage, backgroundColor, textColor);

      return resScoateMedicDeLaFavorit;
    }

    return null;
  }

  getListaRecenziiByIdMedic(int idMedic) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    listaRecenziiMedicSelectat = await apiCallFunctions.getListaRecenziiByIdMedic(
      pUser: user,
      pParola: userPassMD5,
      pIdMedic: idMedic.toString(),
      pNrMaxim: '10',
    );

    return listaRecenziiMedicSelectat;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    medicFavorit = widget.medicItem.esteFavorit;
  }

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    return GestureDetector(
      onTap: () async {
        medicSelectat = await getDetaliiMedic(widget.medicItem.id);
        listaRecenziiMedicSelectat = await getListaRecenziiByIdMedic(widget.medicItem.id);

        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilDoctorDisponibilitateServiciiScreen(
                  statusMedic: widget.medicItem.status,
                  medicDetalii: medicSelectat!,
                  listaRecenzii: listaRecenziiMedicSelectat,
                  ecranTotiMedicii: false,
                  contClientMobileInfo: widget.contClientMobile,
                ),
              ));
        }
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        height: 121,
        //color: const Color.fromRGBO(253, 250, 234, 1),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.medicItem.status == inConsultatie.value
                ? const Color.fromRGBO(214, 30, 42, 1)
                : widget.medicItem.status == activ.value
                    ? const Color.fromRGBO(30, 214, 158, 1)
                    : const Color.fromRGBO(205, 211, 223, 1),
          ),
          borderRadius: BorderRadius.circular(15.0),
          color: const Color.fromRGBO(255, 255, 255, 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //photo here
            Stack(
              children: [
                //Image.asset(widget.iconPath),
                widget.medicItem.linkPozaProfil.isNotEmpty
                    ? Container(
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Image.network(widget.medicItem.linkPozaProfil, width: 60, height: 60),
                      )
                    : Container(
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Image.asset('./assets/images/user_fara_poza.png', width: 60, height: 60),
                      ),
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  //child: Image.asset(widget.eInConsultatie? './assets/images/on_call_icon.png' : widget.eDisponibil? './assets/images/online_icon.png': './assets/images/offline_icon.png'),
                  child: Image.asset(widget.medicItem.status == inConsultatie.value
                      ? './assets/images/on_call_icon.png'
                      : widget.medicItem.status == activ.value
                          ? './assets/images/online_icon.png'
                          : './assets/images/offline_icon.png'),
                ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            //rows
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          widget.medicItem.status == inConsultatie.value
                              ? Container(
                                  width: 69,
                                  height: 16,
                                  //color: const Color.fromRGBO(255, 0, 0, 1),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color.fromRGBO(255, 0, 0, 1),
                                    ),
                                    borderRadius: BorderRadius.circular(3.0),
                                    color: const Color.fromRGBO(255, 0, 0, 1),
                                  ),
                                  //child: Text(' în consultație', style: GoogleFonts.rubik(color:const Color.fromRGBO(255, 255, 255, 1), fontSize: 9, fontWeight: FontWeight.w500)), //old IGV
                                  child: Text(l.veziTotiMediciiInConsultatie,
                                      style: GoogleFonts.rubik(
                                          color: const Color.fromRGBO(255, 255, 255, 1),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500)),
                                )
                              : const SizedBox(width: 0, height: 0),
                          RatingBar(
                              ignoreGestures: true,
                              initialRating: 4.9,
                              direction: Axis.horizontal,
                              itemCount: 5,
                              itemSize: 13,
                              itemPadding: const EdgeInsets.symmetric(horizontal: 0.5, vertical: 5.0),
                              ratingWidget: RatingWidget(
                                full: widget.medicItem.status == inConsultatie.value
                                    ? const Icon(Icons.star, color: Color.fromRGBO(252, 220, 85, 1))
                                    : widget.medicItem.status == activ.value
                                        ? const Icon(Icons.star, color: Color.fromRGBO(252, 220, 85, 1))
                                        : const Icon(Icons.star, color: Color.fromRGBO(103, 114, 148, 1)),

                                half: widget.medicItem.status == inConsultatie.value
                                    ? const Icon(Icons.star_half, color: Color.fromRGBO(252, 220, 85, 1))
                                    : // old IGV
                                    widget.medicItem.status == activ.value
                                        ? const Icon(Icons.star_half, color: Color.fromRGBO(252, 220, 85, 1))
                                        : const Icon(Icons.star_half,
                                            color: Color.fromRGBO(103, 114, 148, 1)), // old IGV

                                empty: widget.medicItem.status == inConsultatie.value
                                    ? const Icon(Icons.star_outline, color: Color.fromRGBO(252, 220, 85, 1))
                                    : widget.medicItem.status == activ.value
                                        ? const Icon(Icons.star_outline, color: Color.fromRGBO(252, 220, 85, 1))
                                        : const Icon(Icons.star_outline,
                                            color: Color.fromRGBO(103, 114, 148, 1)), //old IGV
                              ),
                              onRatingUpdate: (value) {
                                setState(() {
                                  //_ratingValue = value;
                                });
                              }),
                          SizedBox(
                              width: 50,
                              child: widget.medicItem.status == inConsultatie.value
                                  ? Text(_ratingValue.toString(),
                                      style: GoogleFonts.rubik(
                                          color: const Color.fromRGBO(252, 220, 85, 1),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500))
                                  : widget.medicItem.status == activ.value
                                      ? Text(_ratingValue.toString(),
                                          style: GoogleFonts.rubik(
                                              color: const Color.fromRGBO(252, 220, 85, 1),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500))
                                      : Text(_ratingValue.toString(),
                                          style: GoogleFonts.rubik(
                                              color: const Color.fromRGBO(103, 114, 148, 1),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500))),
                        ],
                      ),
                      GestureDetector(
                        child: medicFavorit
                            ? Image.asset('./assets/images/love_red.png')
                            : Image.asset('./assets/images/love_icon.png'),
                        onTap: () {
                          if (!medicFavorit) {
                            adaugaMedicLaFavorit();
                          } else {
                            scoateMedicDeLaFavorit();
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      widget.medicItem.status == inConsultatie.value
                          ? SizedBox(
                              width: 175,
                              height: 17,
                              child: Text('${widget.medicItem.titulatura}. ${widget.medicItem.numeleComplet}',
                                  style: GoogleFonts.rubik(
                                      color: const Color.fromRGBO(255, 0, 0, 1),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400)))
                          : SizedBox(
                              width: 175,
                              height: 17,
                              child: Text('${widget.medicItem.titulatura}. ${widget.medicItem.numeleComplet}',
                                  style: GoogleFonts.rubik(
                                      color: const Color.fromRGBO(64, 75, 109, 1),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400)),
                            ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 175,
                        height: 17,
                        //child: Text(widget.textSpital, style: GoogleFonts.rubik(color:const Color.fromRGBO(64, 75, 109, 1), fontSize: 12, fontWeight: FontWeight.w300)), //old IGV
                        child: Text(widget.medicItem.locDeMunca,
                            style: GoogleFonts.rubik(
                                color: const Color.fromRGBO(64, 75, 109, 1),
                                fontSize: 12,
                                fontWeight: FontWeight.w300)),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 175,
                        height: 17,
                        //child: Text(widget.textTipMedic, style: GoogleFonts.rubik(color:const Color.fromRGBO(64, 75, 109, 1), fontSize: 10, fontWeight: FontWeight.w300)),
                        child: Text('${widget.medicItem.specializarea}, ${widget.medicItem.functia}',
                            style: GoogleFonts.rubik(
                                color: const Color.fromRGBO(64, 75, 109, 1),
                                fontSize: 10,
                                fontWeight: FontWeight.w300)),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset('./assets/images/ok_mic_icon.png'),
                      const SizedBox(width: 5),
                      SizedBox(
                        width: 100,
                        height: 17,
                        //child: Text(widget.likes.toString(), style: GoogleFonts.rubik(color:const Color.fromRGBO(64, 75, 109, 1), fontSize: 10, fontWeight: FontWeight.w300)),//old IGV
                        child: Text(widget.medicItem.nrLikeuri.toString(),
                            style: GoogleFonts.rubik(
                                color: const Color.fromRGBO(64, 75, 109, 1),
                                fontSize: 10,
                                fontWeight: FontWeight.w300)),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
