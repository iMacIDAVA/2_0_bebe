import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sos_bebe_app/datefacturare/date_facturare_completare_rapida.dart';
import 'package:sos_bebe_app/profil_doctor_disponibilitate_servicii_screen.dart';
import 'package:sos_bebe_app/utils/utils_widgets.dart';
import 'package:sos_bebe_app/adauga_metoda_plata_screen.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';

import 'package:sos_bebe_app/localizations/1_localizations.dart';

class ConfirmareServiciiScreen extends StatefulWidget {
  final String pret;
  final int tipServiciu;
  final ContClientMobile contClientMobile;
  final MedicMobile medicDetalii;

  const ConfirmareServiciiScreen({
    super.key,
    required this.pret,
    required this.tipServiciu,
    required this.contClientMobile,
    required this.medicDetalii,
  });

  @override
  State<ConfirmareServiciiScreen> createState() => _ConfirmareServiciiScreenState();
}

class _ConfirmareServiciiScreenState extends State<ConfirmareServiciiScreen> {
  int persoanaFizica = 0;
  bool isDateFacturareComplete = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    persoanaFizica = widget.contClientMobile.tipPersoana;
    if (persoanaFizica == 0) {
      isDateFacturareComplete = false;
    } else if (persoanaFizica == 1) {
      if (widget.contClientMobile.cnp.isEmpty ||
          widget.contClientMobile.seriecAct.isEmpty ||
          widget.contClientMobile.numarAct.isEmpty ||
          widget.contClientMobile.adresa1.isEmpty ||
          widget.contClientMobile.denumireJudet.isEmpty ||
          widget.contClientMobile.denumireLocalitate.isEmpty) {
        isDateFacturareComplete = false;
      }
    } else if (persoanaFizica == 2) {
      if (widget.contClientMobile.codFiscal.isEmpty ||
          widget.contClientMobile.denumireFirma.isEmpty ||
          widget.contClientMobile.adresa1.isEmpty ||
          widget.contClientMobile.denumireJudet.isEmpty ||
          widget.contClientMobile.denumireLocalitate.isEmpty) {
        isDateFacturareComplete = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;
    //print('l.confirmareServiciiTitlu ${l.confirmareServiciiTitlu}');

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        //begin added by George Valentin Iordache
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          leading: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ProfilDoctorDisponibilitateServiciiScreen(
                  medicDetalii: widget.medicDetalii,
                  contClientMobileInfo: widget.contClientMobile,
                  ecranTotiMedicii: true,
                  statusMedic: widget.medicDetalii.status,
                );
              }));
            },
            child: const Icon(Icons.arrow_back),
          ),
        ),
        //end added by George Valentin Iordache
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 55),
                Text(
                  //'Confirmă plata', //old IGV
                  l.confirmareServiciiTitlu,

                  style: GoogleFonts.rubik(
                    color: const Color.fromRGBO(103, 114, 148, 1),
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      Container(
                        // constraints: BoxConstraints(minHeight: 100),
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20), // Adjust this value as needed
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20), // Match the borderRadius above
                          child: Image.asset(
                            './assets/images/servicii_pediatrie_dreptunghi.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        // constraints: BoxConstraints(minHeight: 100),
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20), // Adjust this value as needed
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20), // Match the borderRadius above
                          child: Image.asset(
                            './assets/images/servicii_pediatrie_adauga_efect_1.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        // constraints: BoxConstraints(minHeight: 100),
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20), // Adjust this value as needed
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20), // Match the borderRadius above
                          child: Image.asset(
                            './assets/images/servicii_pediatrie_adauga_efect_2.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    //'Servicii Pediatrie', //old IGV
                                    l.confirmareServiciiServiciiPediatrie,
                                    style: GoogleFonts.rubik(
                                      color: const Color.fromRGBO(255, 255, 255, 1),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    child: Text(
                                      //'Primiți o recomandare și rețetă medicală', //old IGV
                                      widget.tipServiciu == 1
                                          ? "Consultație video"
                                          : widget.tipServiciu == 2
                                              ? "Interpretare analize"
                                              : widget.tipServiciu == 3
                                                  ? "Consultație chat"
                                                  : "",
                                      maxLines: 2,
                                      style: GoogleFonts.rubik(
                                        color: const Color.fromRGBO(255, 255, 255, 1),
                                        fontWeight: FontWeight.w300,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  widget.pret,
                                  //'9.9',
                                  style: GoogleFonts.rubik(
                                    color: const Color.fromRGBO(255, 255, 255, 1),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 32,
                                  ),
                                ),
                                Text(
                                  //'RON', //old IGV
                                  l.confirmareServiciiRON,
                                  style: GoogleFonts.rubik(
                                    color: const Color.fromRGBO(255, 255, 255, 1),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        //'Subtotal', //old IGV
                        l.confirmareServiciiSubtotal,
                        style: GoogleFonts.rubik(
                          color: const Color.fromRGBO(103, 114, 148, 1),
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        //'$pret RON', //old IGV
                        '${widget.pret} ${l.confirmareServiciiRON}',
                        style: GoogleFonts.rubik(
                          color: const Color.fromRGBO(103, 114, 148, 1),
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                customDividerConfirmareServicii(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        //'Total',  //old IGV
                        l.confirmareServiciiTotal,
                        style: GoogleFonts.rubik(
                          color: const Color.fromRGBO(103, 114, 148, 1),
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        //'$pret RON', //old IGV
                        '${widget.pret} ${l.confirmareServiciiRON}',
                        style: GoogleFonts.rubik(
                          color: const Color.fromRGBO(103, 114, 148, 1),
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (!isDateFacturareComplete)
                  const Text(
                    "Va rugăm să completați datele de facturare înainte de continua",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.red),
                  ),
                isDateFacturareComplete
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdaugaMetodaPlataScreen(
                                    tipServiciu: widget.tipServiciu,
                                    contClientMobile: widget.contClientMobile,
                                    medicDetalii: widget.medicDetalii,
                                    pret: widget.pret,
                                  ),
                                ));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
                              //const Color.fromARGB(255, 14, 190, 127), old
                              minimumSize: const Size.fromHeight(50), // NEW
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                          child: Text(
                              //'CONFIRMĂ PLATA', //old IGV
                              l.confirmareServiciiConfirmaPlataButon,
                              style: GoogleFonts.rubik(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              )),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return DateFacturareCompletareRapida(
                                contClientMobile: widget.contClientMobile,
                                pret: widget.pret,
                                tipServiciu: widget.tipServiciu,
                                medicDetalii: widget.medicDetalii,
                              );
                            }));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
                              //const Color.fromARGB(255, 14, 190, 127), old
                              minimumSize: const Size.fromHeight(50), // NEW
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                          child: Text(
                              //'CONFIRMĂ PLATA', //old IGV
                              "Completeaza date facturare",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.rubik(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              )),
                        ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
