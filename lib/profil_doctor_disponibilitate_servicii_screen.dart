import 'package:intl/intl.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sos_bebe_app/doctor_confirmation_screen.dart';

import 'package:sos_bebe_app/utils/utils_widgets.dart';
import 'package:sos_bebe_app/utils_api/doctor_busy_service.dart';
import 'package:sos_bebe_app/utils_api/api_config.dart';

import 'package:sos_bebe_app/utils_api/classes.dart';
import 'package:sos_bebe_app/utils_api/functions.dart';

import 'package:sos_bebe_app/utils_api/api_call_functions.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;

import 'package:http/http.dart' as http;

import 'package:sos_bebe_app/localizations/1_localizations.dart';
import 'package:sos_bebe_app/vezi_medici_salvati_screen.dart';
import 'package:sos_bebe_app/vezi_toti_medicii_screen.dart';

ApiCallFunctions apiCallFunctions = ApiCallFunctions();

List<MedicMobile> listaMedici = [];

class ProfilDoctorDisponibilitateServiciiScreen extends StatefulWidget {
  final MedicMobile medicDetalii;
  final ContClientMobile contClientMobileInfo;
  final List<RecenzieMobile>? listaRecenzii;
  final bool ecranTotiMedicii;
  final int statusMedic;

  const ProfilDoctorDisponibilitateServiciiScreen(
      {super.key,
      required this.medicDetalii,
      required this.contClientMobileInfo,
      this.listaRecenzii,
      required this.ecranTotiMedicii,
      required this.statusMedic});

  @override
  State<ProfilDoctorDisponibilitateServiciiScreen> createState() => _ProfilDoctorDisponibilitateServiciiScreenState();
}

class _ProfilDoctorDisponibilitateServiciiScreenState extends State<ProfilDoctorDisponibilitateServiciiScreen> {
  static const ron = EnumTipMoneda.lei;
  static const euro = EnumTipMoneda.euro;

  static const consultVideo = EnumTipConsultatie.consultVideo;
  static const interpretareAnalize = EnumTipConsultatie.interpretareAnalize;
  static const intrebare = EnumTipConsultatie.intrebare;

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

  getListaMediciFavoriti() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    listaMedici = await apiCallFunctions.getListaMedicFavorit(
          pUser: user,
          pParola: userPassMD5,
        ) ??
        [];
  }

  MedicMobile? medicMobile;

  @override
  void initState() {
    super.initState();

    medicMobile = widget.medicDetalii;
  }

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    List<Widget> mywidgets = [];

    List<RecenzieMobile> listaFiltrata = widget.listaRecenzii ?? [];

    initializeDateFormatting();

    for (int index = 0; index < listaFiltrata.length; index++) {
      var item = listaFiltrata[index];

      String dataRo =
          DateFormat(l.profilDoctorDisponibilitateServiciiDateFormat, l.profilDoctorDisponibilitateServiciiLimba)
              .format(item.dataRecenzie);

      String dataRoLuna = dataRo.substring(0, 3) + dataRo.substring(3, 4).toUpperCase() + dataRo.substring(4);

      if (index < listaFiltrata.length - 1) {
        mywidgets.add(
          RecenzieWidget(
            textNume: item.identitateClient,
            textData: dataRoLuna,
            rating: item.rating,
          ),
        );
        mywidgets.add(
          const SizedBox(height: 5),
        );
        mywidgets.add(
          customDividerProfilDoctor(),
        );
      } else if (index == listaFiltrata.length - 1) {
        mywidgets.add(
          RecenzieWidget(
            textNume: item.identitateClient,
            textData: dataRoLuna,
            rating: item.rating,
          ),
        );
        mywidgets.add(
          const SizedBox(height: 5),
        );
        mywidgets.add(
          customDividerProfilDoctor(),
        );
        mywidgets.add(
          const SizedBox(height: 25),
        );
      }
    }

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l.universalInapoi,
          ),
          backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
          foregroundColor: Colors.white,
          leading: BackButton(
            onPressed: () async {
              if (context.mounted) {
                if (widget.ecranTotiMedicii) {
                  await getListaMedici();

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VeziTotiMediciiScreen(
                          listaMedici: listaMedici,
                          contClientMobile: widget.contClientMobileInfo,
                        ),
                      ));
                } else {
                  await getListaMediciFavoriti();

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VeziMediciSalvatiScreen(
                          contInfo: widget.contClientMobileInfo,
                          listaMedici: listaMedici,
                        ),
                      ));
                }
              }
              // Navigator.pop(context);
            },
            color: Colors.white,
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
          onWillPop: () async {
            if (context.mounted) {
              if (widget.ecranTotiMedicii) {
                await getListaMedici();

                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VeziTotiMediciiScreen(
                        listaMedici: listaMedici,
                        contClientMobile: widget.contClientMobileInfo,
                      ),
                    ));
              } else {
                await getListaMediciFavoriti();

                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VeziMediciSalvatiScreen(
                        contInfo: widget.contClientMobileInfo,
                        listaMedici: listaMedici,
                      ),
                    ));
              }
            }
            // Navigator.pop(context);
            return false;
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                IconStatusNumeRatingSpitalLikesMedic(
                  medicMobile: widget.medicDetalii,
                  statusMedic: widget.statusMedic,
                ),
                if (widget.statusMedic == 1)
                  if (widget.medicDetalii.primesteIntrebari)
                    ButtonServiciiProfilDoctor(
                      pret: '${widget.medicDetalii.pretIntrebare} ',
                      moneda: widget.medicDetalii.monedaPreturi == ron.value
                          ? l.profilDoctorDisponibilitateServiciiMonedaRon
                          : widget.medicDetalii.monedaPreturi == euro.value
                              ? l.profilDoctorDisponibilitateServiciiMonedaEuro
                              : l.profilDoctorDisponibilitateServiciiMonedaRon,
                      textServiciu: l.profilDoctorDisponibilitateServiciiScrieIntrebare,
                      iconLocation: './assets/images/chat_profil_doctor_icon.png',
                      color: const Color.fromRGBO(30, 166, 219, 1),
                      tipConsultatieReteta: false,
                      tipServiciu: intrebare.value,
                      contClientMobile: widget.contClientMobileInfo,
                      medicDetalii: widget.medicDetalii,
                      statusMedic: widget.statusMedic,
                    ),
                if (widget.statusMedic == 1)
                  if (widget.medicDetalii.consultatieVideo)
                    ButtonServiciiProfilDoctor(
                      pret: '${widget.medicDetalii.pretConsultatieVideo} ',
                      moneda: widget.medicDetalii.monedaPreturi == ron.value
                          ? l.profilDoctorDisponibilitateServiciiMonedaRon
                          : widget.medicDetalii.monedaPreturi == euro.value
                              ? l.profilDoctorDisponibilitateServiciiMonedaEuro
                              : l.profilDoctorDisponibilitateServiciiMonedaRon,
                      textServiciu: l.profilDoctorDisponibilitateServiciiSunaAcum,
                      iconLocation: './assets/images/apel_video_profil_doctor_icon.png',
                      color: const Color.fromRGBO(14, 190, 127, 1),
                      tipConsultatieReteta: false,
                      tipServiciu: consultVideo.value,
                      contClientMobile: widget.contClientMobileInfo,
                      medicDetalii: widget.medicDetalii,
                      statusMedic: widget.statusMedic,
                    ),
                if (widget.statusMedic == 1)
                  if (widget.medicDetalii.interpreteazaAnalize)
                    ButtonServiciiProfilDoctor(
                      pret: '${widget.medicDetalii.pretInterpretareAnalize} ',
                      moneda: widget.medicDetalii.monedaPreturi == ron.value
                          ? l.profilDoctorDisponibilitateServiciiMonedaRon
                          : widget.medicDetalii.monedaPreturi == euro.value
                              ? l.profilDoctorDisponibilitateServiciiMonedaEuro
                              : l.profilDoctorDisponibilitateServiciiMonedaRon,
                      textServiciu: l.profilDoctorDisponibilitateServiciiPrimitiRecomandare,
                      iconLocation: './assets/images/reteta_profil_doctor_icon.png',
                      color: const Color.fromRGBO(241, 201, 0, 1),
                      tipConsultatieReteta: true,
                      tipServiciu: interpretareAnalize.value,
                      contClientMobile: widget.contClientMobileInfo,
                      medicDetalii: widget.medicDetalii,
                      statusMedic: widget.statusMedic,
                    ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20, top: widget.statusMedic == 1 ? 40 : 0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Text(
                      l.profilDoctorDisponibilitateServiciiSumarTitlu,
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 5),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(
                      //'Titlu profesional', //old IGV
                      l.profilDoctorDisponibilitateServiciiTitluProfestional,
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      widget.medicDetalii.functia,
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ]),
                ),
                customDividerProfilDoctor(),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(
                      l.profilDoctorDisponibilitateServiciiSpecializare,
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      widget.medicDetalii.specializarea,
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ]),
                ),
                customDividerProfilDoctor(),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(
                      l.profilDoctorDisponibilitateServiciiExperienta,
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      widget.medicDetalii.experienta,
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(
                      l.profilDoctorDisponibilitateServiciiLocDeMunca,
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Image.asset('./assets/images/spital_icon.png'),
                    const SizedBox(width: 5),
                    Text(
                      widget.medicDetalii.locDeMunca,
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ]),
                ),
                customDividerProfilDoctor(),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Image.asset('./assets/images/adresa_icon.png'),
                    const SizedBox(width: 5),
                    Text(
                      widget.medicDetalii.adresaLocDeMunca,
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ]),
                ),
                customDividerProfilDoctor(),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Text(
                      l.profilDoctorDisponibilitateServiciiActivitate,
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Image.asset('./assets/images/utilizatori_multumiti_icon.png'),
                    const SizedBox(width: 5),
                    Text(
                      l.profilDoctorDisponibilitateServiciiUtilizatoriMultumiti,
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      //old IGV
                      '${widget.medicDetalii.procentRating}%',
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ]),
                ),
                customDividerProfilDoctor(),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Image.asset('./assets/images/numar_pacienti_ajutati_icon.png'),
                    const SizedBox(width: 5),
                    Text(
                      //'Am ajutat', //old IGV
                      l.profilDoctorDisponibilitateServiciiAmAjutat,
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      ' ${widget.medicDetalii.totalClienti} ${l.profilDoctorDisponibilitateServiciiPacienti} ',
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      l.profilDoctorDisponibilitateServiciiAiAplicatiei,
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ]),
                ),
                customDividerProfilDoctor(),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Image.asset('./assets/images/testimoniale_icon.png'),
                    const SizedBox(width: 5),
                    Text(
                      '${widget.medicDetalii.totalTestimoniale} ',
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      l.profilDoctorDisponibilitateServiciiTestimoniale,
                      style: GoogleFonts.rubik(
                        color: const Color.fromRGBO(103, 114, 148, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 20),
                if (mywidgets.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
                    child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Text(
                        l.profilDoctorDisponibilitateServiciiRecenzii,
                        style: GoogleFonts.rubik(
                          color: const Color.fromRGBO(103, 114, 148, 1),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ]),
                  ),
                SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: mywidgets,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IconStatusNumeRatingSpitalLikesMedic extends StatefulWidget {
  final MedicMobile medicMobile;
  final int statusMedic;

  const IconStatusNumeRatingSpitalLikesMedic({super.key, required this.medicMobile, required this.statusMedic});

  @override
  State<IconStatusNumeRatingSpitalLikesMedic> createState() => _IconStatusNumeRatingSpitalLikesMedic();
}

class _IconStatusNumeRatingSpitalLikesMedic extends State<IconStatusNumeRatingSpitalLikesMedic> {
  final double _ratingValue = 4.9;

  bool medicAdaugatCuSucces = false;
  bool medicScosCuSucces = false;

  bool medicFavorit = false;

  @override
  void initState() {
    super.initState();
    medicFavorit = widget.medicMobile.esteFavorit;
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
      pIdMedic: widget.medicMobile.id.toString(),
    );

    print('adaugaMedicLaFavorit resAdaugaMedicLaFavorit.body ${resAdaugaMedicLaFavorit!.body}');

    if (int.parse(resAdaugaMedicLaFavorit.body) == 200) {
      setState(() {
        medicAdaugatCuSucces = true;
        medicScosCuSucces = false;

        medicFavorit = true;
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
      pIdMedic: widget.medicMobile.id.toString(),
    );

    print('scoateMedicDeLaFavorit resScoateMedicDeLaFavorit.body ${resScoateMedicDeLaFavorit!.body}');

    if (int.parse(resScoateMedicDeLaFavorit.body) == 200) {
      setState(() {
        medicAdaugatCuSucces = false;
        medicScosCuSucces = true;

        medicFavorit = false;
      });

      textMessage = l.profilDoctorDisponibilitateServiciiMedicScosCuSucces;

      backgroundColor = const Color.fromARGB(255, 14, 190, 127);
      textColor = Colors.white;
    } else if (int.parse(resScoateMedicDeLaFavorit.body) == 400) {
      setState(() {
        medicScosCuSucces = false;
      });

      textMessage = l.profilDoctorDisponibilitateServiciiMedicScosApelInvalid;
      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resScoateMedicDeLaFavorit.body) == 401) {
      setState(() {
        medicScosCuSucces = false;
      });

      textMessage = l.profilDoctorDisponibilitateServiciiMedicNescos;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resScoateMedicDeLaFavorit.body) == 405) {
      setState(() {
        medicScosCuSucces = false;
      });

      textMessage = l.profilDoctorDisponibilitateServiciiMedicScosInformatiiInsuficiente;

      backgroundColor = Colors.red;
      textColor = Colors.black;
    } else if (int.parse(resScoateMedicDeLaFavorit.body) == 500) {
      setState(() {
        medicScosCuSucces = false;
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

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 121,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromRGBO(255, 255, 255, 1),
          ),
          borderRadius: BorderRadius.circular(15.0),
          color: const Color.fromRGBO(255, 255, 255, 1),
        ),
        child: Row(
          children: [
            //photo here
            Stack(
              children: [
                widget.medicMobile.linkPozaProfil.isNotEmpty
                    ? Container(
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Image.network(widget.medicMobile.linkPozaProfil, width: 60, height: 60),
                      )
                    : Container(
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Image.asset('./assets/images/user_fara_poza.png', width: 60, height: 60),
                      ),
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: Image.asset(widget.statusMedic == EnumStatusMedicMobile.inConsultatie.value
                      ? './assets/images/on_call_icon.png'
                      : widget.statusMedic == EnumStatusMedicMobile.activ.value
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
                          widget.statusMedic == EnumStatusMedicMobile.inConsultatie.value
                              ? Container(
                                  width: 69,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color.fromRGBO(255, 0, 0, 1),
                                    ),
                                    borderRadius: BorderRadius.circular(3.0),
                                    color: const Color.fromRGBO(255, 0, 0, 1),
                                  ),
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
                                full: widget.statusMedic == EnumStatusMedicMobile.inConsultatie.value
                                    ? const Icon(Icons.star, color: Color.fromRGBO(252, 220, 85, 1))
                                    : widget.statusMedic == EnumStatusMedicMobile.activ.value
                                        ? const Icon(Icons.star, color: Color.fromRGBO(252, 220, 85, 1))
                                        : const Icon(Icons.star, color: Color.fromRGBO(103, 114, 148, 1)),

                                half: widget.statusMedic == EnumStatusMedicMobile.inConsultatie.value
                                    ? const Icon(Icons.star_half, color: Color.fromRGBO(252, 220, 85, 1))
                                    : // old IGV
                                    widget.statusMedic == EnumStatusMedicMobile.activ.value
                                        ? const Icon(Icons.star_half, color: Color.fromRGBO(252, 220, 85, 1))
                                        : const Icon(Icons.star_half,
                                            color: Color.fromRGBO(103, 114, 148, 1)), // old IGV

                                empty: widget.statusMedic == EnumStatusMedicMobile.inConsultatie.value
                                    ? const Icon(Icons.star_outline, color: Color.fromRGBO(252, 220, 85, 1))
                                    : widget.statusMedic == EnumStatusMedicMobile.activ.value
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
                              child: widget.statusMedic == EnumStatusMedicMobile.inConsultatie.value
                                  ? Text(_ratingValue.toString(),
                                      style: GoogleFonts.rubik(
                                          color: const Color.fromRGBO(252, 220, 85, 1),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500))
                                  : widget.statusMedic == EnumStatusMedicMobile.activ.value
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
                      widget.statusMedic == EnumStatusMedicMobile.inConsultatie.value
                          ? SizedBox(
                              width: 175,
                              height: 17,
                              child: Text('${widget.medicMobile.titulatura}. ${widget.medicMobile.numeleComplet}',
                                  style: GoogleFonts.rubik(
                                      color: const Color.fromRGBO(255, 0, 0, 1),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400)))
                          : SizedBox(
                              width: 175,
                              height: 17,
                              child: Text('${widget.medicMobile.titulatura}. ${widget.medicMobile.numeleComplet}',
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
                        child: Text(widget.medicMobile.locDeMunca,
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
                        child: Text('${widget.medicMobile.specializarea}, ${widget.medicMobile.functia}',
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
                        child: Text(widget.medicMobile.nrLikeuri.toString(),
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

class ButtonServiciiProfilDoctor extends StatefulWidget {
  final String textServiciu;
  final String pret;
  final String moneda;
  final String iconLocation;
  final Color color;
  final bool tipConsultatieReteta;
  final int tipServiciu;
  final ContClientMobile contClientMobile;
  final MedicMobile medicDetalii;
    final int statusMedic;

  const ButtonServiciiProfilDoctor({
    super.key,
    required this.textServiciu,
    required this.pret,
    required this.moneda,
    required this.iconLocation,
    required this.color,
    required this.tipConsultatieReteta,
    required this.tipServiciu,
    required this.contClientMobile,
    required this.medicDetalii,
    required this.statusMedic
  });

  @override
  State<ButtonServiciiProfilDoctor> createState() => _ButtonServiciiProfilDoctorState();
}

class _ButtonServiciiProfilDoctorState extends State<ButtonServiciiProfilDoctor> {
  String pretModificat = "";
  @override
  void initState() {
    super.initState();
    pretModificat = widget.pret.replaceAll(".", ",");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String patientId = prefs.getString(pref_keys.userId) ?? '';
          String patientNume = prefs.getString(pref_keys.userNume) ?? '';
          String patientPrenume = prefs.getString(pref_keys.userPrenume) ?? '';

          String pObservatii = '$patientId\$#\$$patientPrenume $patientNume';

          String pCheie = keyAppPacienti;
          int pIdMedic = widget.medicDetalii.id;
          String pTip = widget.tipServiciu.toString();

          String tipLabel;
          switch (widget.tipServiciu) {
            case 1:
              tipLabel = 'Apel';
              break;
            case 2:
              tipLabel = 'Recomandare';
              break;
            case 3:
              tipLabel = 'întrebare';
              break;
            default:
              tipLabel = 'Necunoscut';
          }

          String pMesaj = 'Ai o nouă cerere de la $patientPrenume $patientNume: $tipLabel';

          await apiCallFunctions.trimitePushPrinOneSignalCatreMedic(
            pCheie: pCheie,
            pIdMedic: pIdMedic,
            pTip: pTip,
            pMesaj: pMesaj,
            pObservatii: pObservatii,
          );

          doctorStatusService.doctorBusyStatus[pIdMedic] = true;

          setState(() {});

          await Future.delayed(const Duration(seconds: 1));

          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return NotificationDisplayScreen(
                pret: widget.pret,
                tipServiciu: widget.tipServiciu,
                contClientMobile: widget.contClientMobile,
                medicDetalii: widget.medicDetalii,
              );
            },
          ));
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          constraints: const BoxConstraints(minHeight: 53),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: widget.color,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Row(
                  children: [
                    Image.asset(
                      widget.iconLocation,
                      height: 17,
                      width: 17,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: Text(
                        widget.textServiciu,
                        style: GoogleFonts.rubik(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 10.5),
                        // maxLines: 3,
                        // overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    pretModificat,
                    style: GoogleFonts.rubik(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(widget.moneda,
                      style: GoogleFonts.rubik(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w300,
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecenzieWidget extends StatelessWidget {
  final String textNume;
  final String textData;
  final double rating;

  bool isInteger(num value) => (value % 1) == 0;

  const RecenzieWidget({
    super.key,
    required this.textNume,
    required this.textData,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    return Container(
      padding: const EdgeInsets.only(left: 25, top: 15, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                textNume,
                style: GoogleFonts.rubik(
                  color: const Color.fromRGBO(103, 114, 148, 1),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                textData,
                style: GoogleFonts.rubik(
                  color: const Color.fromRGBO(103, 114, 148, 1),
                  fontSize: 9,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Row(
                children: [
                  Image.asset('./assets/images/utilizatori_multumiti_icon.png'),
                  const SizedBox(width: 5),
                  isInteger(rating)
                      ? Text(
                          //'Rating ${rating.toInt()}/5', //old IGV
                          '${l.profilDoctorDisponibilitateServiciiRating} ${rating.toInt()}/5',
                          style: GoogleFonts.rubik(
                            color: const Color.fromRGBO(103, 114, 148, 1),
                            fontSize: 9,
                            fontWeight: FontWeight.w300,
                          ),
                        )
                      : Text(
                          //'Rating $rating/5', //old IGV
                          '${l.profilDoctorDisponibilitateServiciiRating} $rating/5',
                          style: GoogleFonts.rubik(
                            color: const Color.fromRGBO(103, 114, 148, 1),
                            fontSize: 9,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
