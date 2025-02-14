import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/custom_picker/sos_bebe_picker.dart';
import 'package:sos_bebe_app/profil_pacient_screen.dart';
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;
import 'package:http/http.dart' as http;

ApiCallFunctions apiCallFunctions = ApiCallFunctions();

class DateFacturareScreen extends StatefulWidget {
  final ContClientMobile contClientMobile;
  const DateFacturareScreen({super.key, required this.contClientMobile});

  @override
  State<DateFacturareScreen> createState() => _DateFacturareScreenState();
}

class _DateFacturareScreenState extends State<DateFacturareScreen> {
  ContClientMobile? contClientMobile;
  ContClientMobile? contInfoUpdatat;

  final controllerSerieAct = TextEditingController();
  final controllerNumarAct = TextEditingController();
  final controllerCNP = TextEditingController();
  final controllerAdresa = TextEditingController();
  final controllerJudet = TextEditingController();
  final controllerLocalitate = TextEditingController();

  final controllercodFiscal = TextEditingController();
  final controllerDenumireFirma = TextEditingController();
  final controllerNrRegCom = TextEditingController();
  late DateFirma dateFirma;

  final FocusNode focusNodeSerieAct = FocusNode();
  final FocusNode focusNodeNumarAct = FocusNode();
  final FocusNode focusNodeCNP = FocusNode();

  final FocusNode focusCodFiscal = FocusNode();
  final FocusNode focusDenumireFirma = FocusNode();
  final FocusNode focusNrRegCom = FocusNode();

  bool persoanaFizica = false;
  bool persoanaJuridica = false;

  bool registerCorect = false;
  bool showInainteButton = true;

  String idjudet = '';
  String idLocalitate = '';

  List<Judet> listaJudete = [];
  List<String> listaJudeteString = [];
  List<Localitate> listaLocalitate = [];
  List<String> listaLocalitateString = [];

  @override
  void dispose() {
    controllerSerieAct.dispose();
    controllerNumarAct.dispose();
    controllerCNP.dispose();
    controllerAdresa.dispose();
    controllerJudet.dispose();
    controllerLocalitate.dispose();
    controllercodFiscal.dispose();
    controllerDenumireFirma.dispose();
    controllerNrRegCom.dispose();
    focusNodeSerieAct.dispose();
    focusNodeNumarAct.dispose();
    focusNodeCNP.dispose();
    focusCodFiscal.dispose();
    focusDenumireFirma.dispose();
    focusNrRegCom.dispose();
    super.dispose();
  }

  void getListajudete() async {
    listaJudete = await apiCallFunctions.getListajudete();
    for (var element in listaJudete) {
      listaJudeteString.add(element.denumire);
    }
  }

  Future<void> getContDetalii() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
    contInfoUpdatat = await apiCallFunctions.getContClient(
      pUser: user,
      pParola: userPassMD5,
      pDeviceToken: prefs.getString('oneSignalId') ?? "",
      pTipDispozitiv: Platform.isAndroid ? '1' : '2',
      pModelDispozitiv: await apiCallFunctions.getDeviceInfo(),
      pTokenVoip: '',
    );
  }

  Future<void> updateDetaliiFacturare() async {
    // print("Serie Act: ${controllerSerieAct.text}");
    // print("Numar Act: ${controllerNumarAct.text}");
    // print("CNP: ${controllerCNP.text}");
    // print("Adresa: ${controllerAdresa.text}");
    // print("Cod Fiscal: ${controllercodFiscal.text}");
    // print("Denumire Firma: ${controllerDenumireFirma.text}");
    // print("Nr Reg Com: ${controllerNrRegCom.text}");
    // print("Judet: ${controllerJudet.text}");
    // print("Localitate: ${controllerLocalitate.text}");

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    http.Response? statusResult = await apiCallFunctions.actualizeazaDateFiscalePentruClient(
      pUser: user,
      pParola: userPassMD5,
      pTipPersoana: persoanaFizica
          ? "1"
          : persoanaJuridica
              ? "2"
              : "1",
      pCodFiscal: controllercodFiscal.text,
      pDenumireFirma: controllerDenumireFirma.text,
      pNrRegCom: controllerNrRegCom.text,
      pSerieAct: controllerSerieAct.text,
      pNumarAct: controllerNumarAct.text,
      pCNP: controllerCNP.text,
      pAdresaLinie1: controllerAdresa.text,
      pIdJudet: idjudet,
      pIdLocalitate: idLocalitate,
    );

    if (statusResult!.body == '200') {
      Fluttertoast.showToast(msg: "Date actualizate cu succes !");
      await getContDetalii();
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ProfilulMeuPacientScreen(
          contInfo: contInfoUpdatat,
        );
      }));
    } else {
      Fluttertoast.showToast(msg: "Nu s-au putut actualiza datele!");
    }
  }

  bool isLoading = true;

  void getDetalii() async {
    setState(() {
      isLoading = true;
    });

    contClientMobile = widget.contClientMobile;
    contClientMobile!.tipPersoana == 1
        ? persoanaFizica = true
        : contClientMobile!.tipPersoana == 2
            ? persoanaJuridica = true
            : persoanaFizica = true;
    controllerSerieAct.text = contClientMobile!.seriecAct;
    controllerNumarAct.text = contClientMobile!.numarAct;
    controllerCNP.text = contClientMobile!.cnp;
    controllerAdresa.text = contClientMobile!.adresa1;
    controllercodFiscal.text = contClientMobile!.codFiscal;
    controllerDenumireFirma.text = contClientMobile!.denumireFirma;
    controllerNrRegCom.text = contClientMobile!.nregCom;
    idjudet = contClientMobile!.idJudet.toString();
    idLocalitate = contClientMobile!.idLocalitate.toString();
    controllerJudet.text = contClientMobile!.denumireJudet;
    controllerLocalitate.text = contClientMobile!.denumireLocalitate;

    listaLocalitate = await apiCallFunctions.getListaLocalitati(pIdJudet: contClientMobile!.idJudet.toString());
    for (var element in listaLocalitate) {
      listaLocalitateString.add(element.denumire);
    }

    if (persoanaJuridica && controllercodFiscal.text.isNotEmpty) {
      dateFirma = await apiCallFunctions.getDateFirma(pCodFiscal: controllercodFiscal.text);

      controllerDenumireFirma.text = dateFirma.denumireFirma;
      controllerNrRegCom.text = dateFirma.nrRegCom;
      controllerJudet.text = dateFirma.denumireJudet;
      controllerLocalitate.text = dateFirma.denumireLocalitate;
      controllerAdresa.text = dateFirma.adresaLinie1;

      listaLocalitateString.clear();
      listaLocalitate = await apiCallFunctions.getListaLocalitati(pIdJudet: dateFirma.idJudet.toString());
      for (var element in listaLocalitate) {
        listaLocalitateString.add(element.denumire);
      }
    }

    setState(() {
      isLoading = false;
    });

    // print("Serie Act: ${controllerSerieAct.text}");
    // print("Numar Act: ${controllerNumarAct.text}");
    // print("CNP: ${controllerCNP.text}");
    // print("Adresa: ${controllerAdresa.text}");
    // print("Cod Fiscal: ${controllercodFiscal.text}");
    // print("Denumire Firma: ${controllerDenumireFirma.text}");
    // print("Nr Reg Com: ${controllerNrRegCom.text}");
    // print("Judet: ${controllerJudet.text}");
    // print("Localitate: ${controllerLocalitate.text}");
  }

  @override
  void initState() {
    super.initState();
    getListajudete();
    getDetalii();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(30, 214, 158, 1),
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: const Color.fromRGBO(30, 214, 158, 1),
        foregroundColor: Colors.white,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Datele mele de facturare",
          style: GoogleFonts.rubik(
            color: const Color.fromRGBO(255, 255, 255, 1),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            persoanaFizica = !persoanaFizica;
                            persoanaJuridica = !persoanaJuridica;
                          });
                        },
                        child: Row(
                          children: [
                            Checkbox(
                              value: persoanaFizica,
                              onChanged: (value) {
                                setState(() {
                                  persoanaFizica = value!;
                                  persoanaJuridica = !value;
                                });
                              },
                              activeColor: const Color.fromARGB(255, 14, 190, 127),
                            ),
                            const Text('Persoană Fizică')
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            persoanaFizica = !persoanaFizica;
                            persoanaJuridica = !persoanaJuridica;
                          });
                        },
                        child: Row(
                          children: [
                            Checkbox(
                              value: persoanaJuridica,
                              onChanged: (value) {
                                setState(() {
                                  persoanaJuridica = value!;
                                  persoanaFizica = !value;
                                });
                              },
                              activeColor: const Color.fromARGB(255, 14, 190, 127),
                            ),
                            const Text('Persoană Juridică')
                          ],
                        ),
                      ),
                      if (persoanaFizica)
                        Column(
                          children: [
                            TextFormField(
                              focusNode: focusNodeSerieAct,
                              controller: controllerSerieAct,
                              onFieldSubmitted: (String s) {
                                focusNodeNumarAct.requestFocus();
                              },
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(2),
                              ],
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: 'Serie Act',
                                hintStyle: const TextStyle(
                                  color: Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                    width: 1.0,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  controllerSerieAct.value = TextEditingValue(
                                    text: value[0].toUpperCase() + value.substring(1),
                                    selection: controllerSerieAct.selection,
                                  );
                                }
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              focusNode: focusNodeNumarAct,
                              controller: controllerNumarAct,
                              onFieldSubmitted: (String s) {
                                focusNodeCNP.requestFocus();
                              },
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(6),
                              ],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Număr Act',
                                hintStyle: const TextStyle(
                                  color: Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                    width: 1.0,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              focusNode: focusNodeCNP,
                              controller: controllerCNP,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(13),
                              ],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'CNP',
                                hintStyle: const TextStyle(
                                  color: Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                    width: 1.0,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      if (persoanaJuridica)
                        Column(
                          children: [
                            TextFormField(
                              controller: controllercodFiscal,
                              onChanged: (value) async {
                                if (value.length >= 8 && persoanaJuridica) {
                                  setState(() {
                                    controllerDenumireFirma.clear();
                                    controllerNrRegCom.clear();
                                    controllerJudet.clear();
                                    controllerLocalitate.clear();
                                    controllerAdresa.clear();
                                  });

                                  dateFirma = await apiCallFunctions.getDateFirma(pCodFiscal: value);

                                  setState(() {
                                    controllerDenumireFirma.text = dateFirma.denumireFirma;
                                    controllerNrRegCom.text = dateFirma.nrRegCom;
                                    controllerJudet.text = dateFirma.denumireJudet;
                                    controllerLocalitate.text = dateFirma.denumireLocalitate;
                                    controllerAdresa.text = dateFirma.adresaLinie1;

                                    listaLocalitateString.clear();
                                    apiCallFunctions.getListaLocalitati(pIdJudet: dateFirma.idJudet.toString()).then(
                                      (localitati) {
                                        listaLocalitate = localitati;
                                        for (var element in listaLocalitate) {
                                          listaLocalitateString.add(element.denumire);
                                        }
                                        setState(() {});
                                      },
                                    );
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Cod Fiscal',
                                hintStyle: const TextStyle(
                                  color: Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                    width: 1.0,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              focusNode: focusDenumireFirma,
                              controller: controllerDenumireFirma,
                              onFieldSubmitted: (String s) {
                                focusNrRegCom.requestFocus();
                              },
                              decoration: InputDecoration(
                                hintText: 'Denumire Firmă',
                                hintStyle: const TextStyle(
                                  color: Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                    width: 1.0,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  controllerDenumireFirma.value = TextEditingValue(
                                    text: value[0].toUpperCase() + value.substring(1),
                                    selection: controllerDenumireFirma.selection,
                                  );
                                }
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              focusNode: focusNrRegCom,
                              controller: controllerNrRegCom,
                              decoration: InputDecoration(
                                hintText: 'Nr Reg Com',
                                hintStyle: const TextStyle(
                                  color: Color.fromRGBO(103, 114, 148, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(205, 211, 223, 1),
                                    width: 1.0,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  controllerNrRegCom.value = TextEditingValue(
                                    text: value[0].toUpperCase() + value.substring(1),
                                    selection: controllerNrRegCom.selection,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          listaLocalitateString.clear();
                          String id = "";
                          String? judet = await showPickerSOSBebeDialog(
                            context: context,
                            label: "județul",
                            items: listaJudeteString,
                          );
                          if (judet != null) {
                            setState(() {
                              controllerJudet.text = judet;
                            });
                            for (var item in listaJudete) {
                              if (item.denumire == controllerJudet.text) {
                                id = item.id;
                                idjudet = id;
                                controllerLocalitate.clear();

                                listaLocalitate = await apiCallFunctions.getListaLocalitati(pIdJudet: id);
                                for (var element in listaLocalitate) {
                                  listaLocalitateString.add(element.denumire);
                                }
                                break;
                              }
                            }
                          }
                          setState(() {});
                        },
                        child: AbsorbPointer(
                          absorbing: true,
                          child: TextFormField(
                            controller: controllerJudet,
                            enableInteractiveSelection: false,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'Județ',
                              hintStyle: const TextStyle(
                                color: Color.fromRGBO(103, 114, 148, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(205, 211, 223, 1),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(205, 211, 223, 1),
                                  width: 1.0,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          String id = "";
                          String? localitate = await showPickerSOSBebeDialog(
                            context: context,
                            label: "localitatea",
                            items: listaLocalitateString,
                          );
                          if (localitate != null) {
                            setState(() {
                              controllerLocalitate.text = localitate;
                            });
                            for (var item in listaLocalitate) {
                              if (item.denumire == localitate) {
                                id = item.id;
                                idLocalitate = id;
                                break;
                              }
                            }
                          }
                          setState(() {});
                        },
                        child: AbsorbPointer(
                          absorbing: true,
                          child: TextFormField(
                            controller: controllerLocalitate,
                            enableInteractiveSelection: false,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'Localitate',
                              hintStyle: const TextStyle(
                                color: Color.fromRGBO(103, 114, 148, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(205, 211, 223, 1),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(205, 211, 223, 1),
                                  width: 1.0,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: controllerAdresa,
                        decoration: InputDecoration(
                          hintText: 'Adresă',
                          hintStyle: const TextStyle(
                            color: Color.fromRGBO(103, 114, 148, 1),
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(205, 211, 223, 1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(205, 211, 223, 1),
                              width: 1.0,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            if (value[value.length - 1] == ' ') {
                              controllerAdresa.value = TextEditingValue(
                                text: value,
                                selection: controllerAdresa.selection,
                              );
                            } else {
                              List<String> words = value.split(' ');
                              for (int i = 0; i < words.length; i++) {
                                if (words[i].isNotEmpty) {
                                  words[i] = words[i][0].toUpperCase() + words[i].substring(1);
                                }
                              }
                              String updatedValue = words.join(' ');

                              controllerAdresa.value = TextEditingValue(
                                text: updatedValue,
                                selection: controllerAdresa.selection,
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            await updateDetaliiFacturare();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 14, 190, 127),
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                            child: Text(
                              "ACTUALIZEAZĂ DATE",
                              style: GoogleFonts.rubik(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
