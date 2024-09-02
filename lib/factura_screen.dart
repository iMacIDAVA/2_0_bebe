import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';

import 'package:path/path.dart' as p;

import 'package:open_filex/open_filex.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:sos_bebe_app/testimonial_chat/testimonial_chat.dart';

import 'package:sos_bebe_app/testimonial_screen.dart';

import 'package:sos_bebe_app/questionare_screen.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';
import 'package:sos_bebe_app/utils_api/functions.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;
import 'package:sos_bebe_app/localizations/1_localizations.dart';

import 'package:sos_bebe_app/utils_api/api_call_functions.dart';

ApiCallFunctions apiCallFunctions = ApiCallFunctions();

class FacturaScreen extends StatefulWidget {
  static const String routeName = '/home';

  final FacturaClientMobile facturaDetalii;
  final String user;
  final bool isFromChat;
  /*
  final String tipPlata;
  final String emailAddressPlata;
  final String phoneNumberPlata;
  final String textNumeSubiect;
  final String tutorId;
  final String emailSubiect;
  final String phoneNumberSubiect;
  final String dataPlatii;
  final String dataPlatiiProcesata;
  final String detaliiFacturaNume;
  final String detaliiFacturaServicii;
  final String detaliiFacturaNumar;


  const FacturaScreen({super.key, required this.tipPlata, required this.emailAddressPlata, required this.phoneNumberPlata, required this.textNumeSubiect,
    required this.tutorId, required this.emailSubiect, required this.phoneNumberSubiect, required this.dataPlatii, required this.dataPlatiiProcesata,
     required this.detaliiFacturaNume, required this.detaliiFacturaServicii, required this.detaliiFacturaNumar,
     });
  */

  const FacturaScreen({
    super.key,
    required this.facturaDetalii,
    required this.user,
    required this.isFromChat,
  });

  @override
  State<FacturaScreen> createState() => _FacturaScreenState();
}

class _FacturaScreenState extends State<FacturaScreen> {
//class FacturaScreen extends StatelessWidget {

  String dataEmitereRo = '';

  String dataPlataRo = '';

  Future<String?> getSirBitiFacturaContClient() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    String? data = await apiCallFunctions.getSirBitiFacturaContClient(
      pUser: user,
      pParola: userPassMD5,
      pIdFactura: widget.facturaDetalii.id.toString(),
    );
    print(data);

    if (data == null) {
      return null;
    }
    try {
      print('getSirBitiFacturaContClient data $data');

      //base64Decode(widget.base64String.replaceAll('\n', ''));
      // Uint8List image = base64Decode(data);
      // print('getSirBitiFacturaContClient image $image');

      return data;
    } catch (e) {
      print('Aici');
      return null;
    }
  }

  Future<String?> descarca() async {
    Random random = Random();
    int min = 1000; // Minimum ID value
    int max = 9999; // Maximum ID value
    String? sirBitiFile = await getSirBitiFacturaContClient();
    Directory? dir;
    debugPrint(sirBitiFile.toString());

    try {
      if (Platform.isAndroid) {
        dir = await DownloadsPath.downloadsDirectory();
      } else if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory();
      }
      File? filePdf;
      String finalString = sirBitiFile!.replaceAll('"', '');
      Uint8List bytes = base64Decode(finalString);

      filePdf = File(dir!.path +
          "/sosbebeapp-pdf-file${min + random.nextInt(max - min)}.pdf");
      await filePdf.writeAsBytes(bytes, flush: true);
      OpenFilex.open(filePdf.path);
      debugPrint(sirBitiFile.toString());
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();

    LocalizationsApp l = LocalizationsApp.of(context)!;

    //String dataEmitereRo = DateFormat("MMM dd. yyyy", "ro").format(widget.facturaDetalii.dataEmitere).capitalizeFirst();
    String dataEmitereRo = DateFormat(l.facturaDateFormat, l.facturaLimba)
        .format(widget.facturaDetalii.dataEmitere)
        .capitalizeFirst();

    //String dataPlataRo = DateFormat("MMM dd. yyyy", "ro").format(widget.facturaDetalii.dataPlata).capitalizeFirst();
    String dataPlataRo = DateFormat(l.facturaDateFormat, l.facturaLimba)
        .format(widget.facturaDetalii.dataPlata)
        .capitalizeFirst();

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      Text(
                        //'Factură', //old IGV
                        l.facturaFacturaTitlu,
                        style: GoogleFonts.rubik(
                          color: const Color.fromRGBO(103, 114, 148, 1),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromRGBO(14, 190, 127, 1),
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            //'Plată - SOS Bebe',  //old IGV
                            l.facturaNumeFactura,
                            style: GoogleFonts.rubik(
                                color: const Color.fromRGBO(103, 114, 148, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.w300),
                          ),
                          if (widget.facturaDetalii.emailEmitent.isNotEmpty)
                            Text(
                              //'Email : ${widget.facturaDetalii.emailEmitent}', //old IGV
                              '${l.facturaEmailEmitent} ${widget.facturaDetalii.emailEmitent}',
                              style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300),
                            ),
                          if (widget.facturaDetalii.telefonEmitent.isNotEmpty)
                            Text(
                              //'Telefon : ${widget.facturaDetalii.telefonEmitent}', //old IGV
                              '${l.facturaTelefonEmitent} ${widget.facturaDetalii.telefonEmitent}',
                              style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            //'Factură pentru:', //old IGV
                            l.facturaTitluPentruBeneficiar,
                            style: GoogleFonts.rubik(
                                color: const Color.fromRGBO(103, 114, 148, 1),
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            widget.facturaDetalii.denumireBeneficiar,
                            style: GoogleFonts.rubik(
                                color: const Color.fromRGBO(103, 114, 148, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            //'User Id: ${widget.user}',  //old IGV
                            '${l.facturaUserId} ${widget.user}',
                            style: GoogleFonts.rubik(
                                color: const Color.fromRGBO(103, 114, 148, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            //'Email: ${widget.facturaDetalii.emailBeneficiar}', //old IGV
                            '${l.facturaEmailBeneficiar} ${widget.facturaDetalii.emailBeneficiar}',
                            style: GoogleFonts.rubik(
                                color: const Color.fromRGBO(103, 114, 148, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            //'Telefon: ${widget.facturaDetalii.telefonBeneficiar}',  //old IGV
                            '${l.facturaTelefonBeneficiar} ${widget.facturaDetalii.telefonBeneficiar}',
                            style: GoogleFonts.rubik(
                                color: const Color.fromRGBO(103, 114, 148, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            //'Data plății', //old IGV
                            l.facturaDataPlatiiTitlu,
                            style: GoogleFonts.rubik(
                                color: const Color.fromRGBO(103, 114, 148, 1),
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                //'Data plății', //old IGV
                                l.facturaDataPlatiiNume,
                                style: GoogleFonts.rubik(
                                    color:
                                        const Color.fromRGBO(103, 114, 148, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300),
                              ),
                              Text(
                                dataPlataRo,
                                style: GoogleFonts.rubik(
                                    color:
                                        const Color.fromRGBO(103, 114, 148, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                //'Procesată',  //old IGV
                                l.facturaProcesata,
                                style: GoogleFonts.rubik(
                                    color:
                                        const Color.fromRGBO(103, 114, 148, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300),
                              ),
                              Text(
                                dataEmitereRo,
                                style: GoogleFonts.rubik(
                                    color:
                                        const Color.fromRGBO(103, 114, 148, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            //'Detalii factură', //old IGV
                            l.facturaDetaliiFactura,
                            style: GoogleFonts.rubik(
                                color: const Color.fromRGBO(103, 114, 148, 1),
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            widget.facturaDetalii.denumireMedic,
                            style: GoogleFonts.rubik(
                                color: const Color.fromRGBO(103, 114, 148, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            //'Servicii: ${widget.facturaDetalii.serviciiFactura}', //old IGV
                            '${l.facturaServicii} ${widget.facturaDetalii.serviciiFactura}',
                            style: GoogleFonts.rubik(
                                color: const Color.fromRGBO(103, 114, 148, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          //'Număr: ${widget.facturaDetalii.numar}', //old IGV
                          '${l.facturaNumar} ${widget.facturaDetalii.numar}',
                          style: GoogleFonts.rubik(
                              color: const Color.fromRGBO(103, 114, 148, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w300),
                        ),
                        Text(
                          //'Serie: ${widget.facturaDetalii.serie}', //old IGV
                          '${l.facturaSerie} ${widget.facturaDetalii.serie}',
                          style: GoogleFonts.rubik(
                              color: const Color.fromRGBO(103, 114, 148, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              //'Valoare cu TVA', //old IGV
                              l.facturaValoareCuTVA,
                              style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300),
                            ),
                            /*
                                Text(widget.dataPlatii, 
                                  style: GoogleFonts.rubik(color: const Color.fromRGBO(103, 114, 148, 1), fontSize: 14, fontWeight: FontWeight.w300),
                                ),
                                */
                            Text(
                              widget.facturaDetalii.valoareCuTVA.toString(),
                              style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              //'Valoare TVA', //old IGV
                              l.facturaValoareTVA,
                              style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300),
                            ),
                            Text(
                              widget.facturaDetalii.valoareTVA.toString(),
                              style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              //'Valoare fără TVA', //old IGV
                              l.facturaValoareFaraTVA,
                              style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300),
                            ),
                            /*
                                Text(widget.dataPlatiiProcesata, 
                                    style: GoogleFonts.rubik(color: const Color.fromRGBO(103, 114, 148, 1), fontSize: 14, fontWeight: FontWeight.w300),
                                ),
                                */
                            Text(
                              widget.facturaDetalii.valoareFaraTVA.toString(),
                              style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        await descarca();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(14, 190, 127, 1),
                          minimumSize: const Size.fromHeight(50), // NEW
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('./assets/images/download_icon.png'),
                          const SizedBox(width: 10),
                          Text(
                              //'Download PDF',
                              l.facturaButonDownloadPdf,
                              style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),

                  //IGV către ecran testimonial
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.isFromChat
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TestimonialPentruChat(
                                    idMedic: widget.facturaDetalii.idMedic,
                                    idFactura: widget.facturaDetalii.id,
                                    factura: widget.facturaDetalii,
                                  ), //old IGV
                                ))
                            : Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TestimonialScreen(
                                    idMedic: widget.facturaDetalii.idMedic,
                                    idFactura: widget.facturaDetalii.id,
                                    factura: widget.facturaDetalii,
                                  ), //old IGV
                                ));
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(14, 190, 127, 1),
                          minimumSize: const Size.fromHeight(50), // NEW
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /*
                            Image.asset('./assets/images/download_icon.png'),
                            const SizedBox(
                              width:10
                            ),
                            */
                          Text(
                              //'TRIMITE TESTIMONIAL',
                              l.facturaTrimiteTestimonial,
                              style: GoogleFonts.rubik(
                                  color: const Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
