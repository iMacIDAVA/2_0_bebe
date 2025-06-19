import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sos_bebe_app/profil_pacient_screen.dart';
import 'package:sos_bebe_app/utils_api/doctor_busy_service.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';
import 'package:sos_bebe_app/utils_api/functions.dart';
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:sos_bebe_app/profil_doctor_disponibilitate_servicii_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;
import 'package:sos_bebe_app/localizations/1_localizations.dart';
import 'package:http/http.dart' as http;

ApiCallFunctions apiCallFunctions = ApiCallFunctions();



List<MedicMobile> listaMediciInitiala = [];

MedicMobile? medicSelectat;

List<RecenzieMobile>? listaRecenziiMedicSelectat = [];

class VeziTotiMediciiScreen extends StatefulWidget {
  final List<MedicMobile> listaMedici;

  final ContClientMobile contClientMobile;

  const VeziTotiMediciiScreen({super.key, required this.listaMedici, required this.contClientMobile});

  @override
  State<VeziTotiMediciiScreen> createState() => _VeziTotiMediciiScreenState();
}

class _VeziTotiMediciiScreenState extends State<VeziTotiMediciiScreen> {
  ContClientMobile? contInfo;

  List<MedicMobile> listaFiltrata = [];

  Map<int, bool> doctorBusyStatus = {};

  bool showSearchField = false;

  bool scrieOintrebareLista = false;
  bool consultatieVideoLista = false;
  bool interpretareAnalizeLista = false;
  bool totiMediciiList = true;
  bool mediciOnlineList = false;

  TextEditingController searchController = TextEditingController();
  List<MedicMobile> listaCautata = [];

  void filterDoctors(String query) {
    setState(() {
      if (query.isEmpty) {
        listaCautata = List.from(listaFiltrata);
      } else {
        listaCautata = listaFiltrata.where((doctor) {
          return doctor.numeleComplet.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  List<Widget> allMedics = [];
  List<Widget> intrebariMedics = [];
  List<Widget> consultatieMedics = [];
  List<Widget> interpretareMedics = [];
  List<Widget> mediciOnline = [];
  bool isDoneLoading = false;

  Uint8List? _profileImage;

  bool isLoading = false ;
  List<MedicMobile> listaMediciInitiala = [];

  //StreamSubscription<List<MedicMobile>>? _streamSubscription;

  // CHANGE: Added StreamController and StreamSubscription for manual stream
  StreamController<List<MedicMobile>>? _streamController;
  StreamSubscription<List<MedicMobile>>? _streamSubscription;

  @override
  void initState() {
    super.initState();

    _loadAndDecodeImage();
    getContDetalii();

    getListaMedici();

    aa();
  }

  aa() async {
       SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? '';
   var a =  prefs.getString('oneSignalId') ?? "";
   // print('aaaa : ${a}');
  }

  // CHANGE: Use StreamController to skip polling when mediciOnlineList is true
  Future<void> getListaMedici() async {
    setState(() {
      isLoading = true;
    });

    _streamController = StreamController<List<MedicMobile>>.broadcast();

    // CHANGE: Initial fetch to populate data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString('userPassMD5') ?? '';
    final initialData = await apiCallFunctions.getListaMedici(
      pUser: user,
      pParola: userPassMD5,
    ) ??
        <MedicMobile>[];
    _streamController!.add(initialData);

    // CHANGE: Periodic polling with flag check
    Timer.periodic(const Duration(seconds:5), (timer) async {
      if (mediciOnlineList) {
        print('Polling skipped: mediciOnlineList is true');
        return; // Skip polling
      }

      print('Polling: Fetching doctor list');
      final data = await apiCallFunctions.getListaMedici(
        pUser: user,
        pParola: userPassMD5,
      ) ??
          <MedicMobile>[];
      _streamController!.add(data);

    });

    _streamSubscription = _streamController!.stream.listen((List<MedicMobile> listaMediciInitiala) {

      setState(() {
        this.listaMediciInitiala = listaMediciInitiala;

        // Reapply active filter
        if (scrieOintrebareLista) {
          listaFiltrata = listaMediciInitiala.where((doctor) => doctor.primesteIntrebari).toList();
        } else if (consultatieVideoLista) {
          listaFiltrata = listaMediciInitiala.where((doctor) => doctor.consultatieVideo).toList();
        } else if (interpretareAnalizeLista) {
          listaFiltrata = listaMediciInitiala.where((doctor) => doctor.interpreteazaAnalize).toList();
        } else if (mediciOnlineList) {
          listaFiltrata = listaMediciInitiala.where((doctor) => doctor.status == 1 || doctor.status == 3).toList();
        } else if (searchController.text.isNotEmpty) {
          listaFiltrata = listaMediciInitiala
              .where((doctor) => doctor.numeleComplet.toLowerCase().contains(searchController.text.toLowerCase()))
              .toList();
        } else {
          listaFiltrata = List.from(listaMediciInitiala);
        }
        listaCautata = List.from(listaFiltrata);

        allMedics.clear();
        mediciOnline.clear();

        for (var element in listaMediciInitiala) {
          allMedics.add(
            IconStatusNumeRatingSpitalLikesMedic(
              medicItem: element,
              contClientMobile: widget.contClientMobile,
            ),
          );

          if (element.status == 1 || element.status == 2 || element.status == 3) {
            mediciOnline.add(
              IconStatusNumeRatingSpitalLikesMedic(
                medicItem: element,
                contClientMobile: widget.contClientMobile,
              ),
            );
          }
        }

        isLoading = false;
        isDoneLoading = true;
      });
    }, onError: (error) {

      setState(() {
        isLoading = false;
        isDoneLoading = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching doctors: $error')),
      );
    });
  }

  // Future<void> getListaMedici() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String user = prefs.getString('user') ?? '';
  //   String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
  //
  //   listaMediciInitiala = await apiCallFunctions.getListaMedici(
  //         pUser: user,
  //         pParola: userPassMD5,
  //       ) ??
  //       [];
  //
  //   setState(() {
  //     listaFiltrata = List.from(listaMediciInitiala);
  //     allMedics.clear();
  //     mediciOnline.clear();
  //
  //     for (var element in listaMediciInitiala) {
  //       allMedics.add(
  //         IconStatusNumeRatingSpitalLikesMedic(
  //           medicItem: element,
  //           contClientMobile: widget.contClientMobile,
  //         ),
  //       );
  //
  //       if (element.status == 1 || element.status == 2 || element.status == 3) {
  //         mediciOnline.add(
  //           IconStatusNumeRatingSpitalLikesMedic(
  //             medicItem: element,
  //             contClientMobile: widget.contClientMobile,
  //           ),
  //         );
  //       }
  //     }
  //
  //     isDoneLoading = true;
  //   });
  // }

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

    final fetchedContInfo = await apiCallFunctions.getContClient(
      pUser: user,
      pParola: userPassMD5,
      pDeviceToken: prefs.getString('oneSignalId') ?? "",
      pTipDispozitiv: Platform.isAndroid ? '1' : '2',
      pModelDispozitiv: await apiCallFunctions.getDeviceInfo(),
      pTokenVoip: '',
    );

    if (fetchedContInfo != null && mounted) {
      setState(() {
        contInfo = fetchedContInfo;
        isDoneLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    LocalizationsApp l = LocalizationsApp.of(context)!;

    if (widget.listaMedici.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: getListaMedici,
                child: const Text("reîncercați"),
              ),
            ],
          ),
        ),
      );
    }

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: isDoneLoading
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (isDoneLoading) {}
                                  if (contInfo != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfilulMeuPacientScreen(contInfo: contInfo!),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("User data not loaded yet. Try again.")),
                                    );
                                  }
                                },
                                child: (isDoneLoading && contInfo?.linkPozaProfil != null)
                                    ? Image.network(contInfo!.linkPozaProfil!, width: 60, height: 60)
                                    : (_profileImage != null)
                                        ? Image.memory(_profileImage!, width: 60, height: 60)
                                        : Image.asset('./assets/images/user_fara_poza.png', width: 60, height: 60),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    totiMediciiList = false;
                                    scrieOintrebareLista = false;
                                    consultatieVideoLista = false;
                                    interpretareAnalizeLista = false;
                                    mediciOnlineList = true;

                                    // Properly update mediciOnline list, which is used in the UI
                                    mediciOnline.clear();
                                    for (var doctor in listaMediciInitiala) {
                                      bool isOnline = doctor.status == 1 || doctor.status == 3;
                                      print("Checking Doctor: ${doctor.numeleComplet} - Status: ${doctor.status} - Is Online: $isOnline");

                                      if (isOnline) {
                                        mediciOnline.add(
                                          IconStatusNumeRatingSpitalLikesMedic(
                                            medicItem: doctor,
                                            contClientMobile: widget.contClientMobile,
                                          ),
                                        );
                                      }
                                    }
                                  });

                                },
                                style: const ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(Color.fromRGBO(236, 251, 247, 1)),
                                ),
                                child: Text(l.veziTotiMediciiMediciOnline,
                                    style: GoogleFonts.rubik(
                                        color: const Color.fromRGBO(30, 214, 158, 1),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300)),
                              ),
                              TextButton(
                                onPressed: () {
                                  totiMediciiList = true;
                                  scrieOintrebareLista = false;
                                  consultatieVideoLista = false;
                                  interpretareAnalizeLista = false;
                                  mediciOnlineList = false;
                                  setState(() {});
                                },
                                style: const ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(Color.fromRGBO(241, 248, 251, 1)),
                                ),
                                child: Text(l.veziTotiMediciiTotiMedicii,
                                    style: GoogleFonts.rubik(
                                        color: const Color.fromRGBO(30, 166, 219, 1),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300)),
                              ),
                              showSearchField
                                  ? Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: TextField(
                                          controller: searchController,
                                          decoration: InputDecoration(
                                            hintText: "Caută doctor...",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide(color: Colors.grey.shade300),
                                            ),
                                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                            suffixIcon: IconButton(
                                              icon: const Icon(Icons.clear, color: Colors.grey),
                                              onPressed: () {
                                                searchController.clear();
                                                filterDoctors('');
                                                setState(() {
                                                  showSearchField = false;
                                                });
                                              },
                                            ),
                                          ),
                                          onChanged: filterDoctors,
                                        ),
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.search, color: Colors.grey),
                                      onPressed: () {
                                        setState(() {
                                          showSearchField = true;
                                        });
                                      },
                                    ),
                              const SizedBox(
                                width: 2,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  totiMediciiList = false;
                                  scrieOintrebareLista = true;
                                  consultatieVideoLista = false;
                                  interpretareAnalizeLista = false;
                                  mediciOnlineList = false;

                                  // Filter doctors who accept questions
                                  listaFiltrata = listaMediciInitiala.where((doctor) {
                                    bool acceptsQuestions = doctor.primesteIntrebari;
                                    print("Checking Doctor: ${doctor.numeleComplet} - Accepts Questions: $acceptsQuestions");
                                    return acceptsQuestions;
                                  }).toList();

                                  // Debugging output
                                  print("Filtered Chat Doctors (${listaFiltrata.length}): ${listaFiltrata.map((d) => d.numeleComplet).toList()}");
                                });
                              },
                              child: ButtonSelectareOptiuni(
                                colorBackground: const Color.fromRGBO(241, 248, 251, 1),
                                colorScris: const Color.fromRGBO(30, 166, 219, 1),
                                iconLocation: './assets/images/intrebare_icon.png',
                                textServiciu: l.veziTotiMediciiScrieOIntrebare,
                                widthScris: 60,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  totiMediciiList = false;
                                  scrieOintrebareLista = false;
                                  consultatieVideoLista = true;
                                  interpretareAnalizeLista = false;
                                  mediciOnlineList = false;

                                  // Filter doctors who offer video consultations
                                  listaFiltrata = listaMediciInitiala.where((doctor) {
                                    bool offersVideo = doctor.consultatieVideo;
                                    print("Checking Doctor: ${doctor.numeleComplet} - Offers Video: $offersVideo");
                                    return offersVideo;
                                  }).toList();

                                  // Debugging output
                                  print("Filtered Video Consultation Doctors (${listaFiltrata.length}): ${listaFiltrata.map((d) => d.numeleComplet).toList()}");
                                });
                              },

                              child: ButtonSelectareOptiuni(
                                colorBackground: const Color.fromRGBO(236, 251, 247, 1),
                                colorScris: const Color.fromRGBO(30, 214, 158, 1),
                                iconLocation: './assets/images/phone-call_apel_video.png',
                                textServiciu: l.veziTotiMediciiConsultatieVideo,
                                widthScris: 70,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  totiMediciiList = false;
                                  scrieOintrebareLista = false;
                                  consultatieVideoLista = false;
                                  interpretareAnalizeLista = true;
                                  mediciOnlineList = false;

                                  // Filter doctors who interpret analyses
                                  listaFiltrata = listaMediciInitiala.where((doctor) {
                                    bool interpretsAnalyses = doctor.interpreteazaAnalize;
                                    print("Checking Doctor: ${doctor.numeleComplet} - Interprets Analyses: $interpretsAnalyses");
                                    return interpretsAnalyses;
                                  }).toList();

                                  // Debugging output
                                  print("Filtered Analysis Interpretation Doctors (${listaFiltrata.length}): ${listaFiltrata.map((d) => d.numeleComplet).toList()}");
                                });
                              },

                              child: ButtonSelectareOptiuni(
                                colorBackground: const Color.fromRGBO(253, 250, 234, 1),
                                colorScris: const Color.fromRGBO(241, 201, 0, 1),
                                iconLocation: './assets/images/analize_icon.png',
                                textServiciu: l.veziTotiMediciiInterpretareAnalize,
                                widthScris: 73,
                              ),
                            ),
                          ],
                        ),
                        isLoading?  Padding(padding: EdgeInsetsDirectional.only(top: 200) , child: CircularProgressIndicator( color: Color.fromRGBO(30, 214, 158, 1),) ,):

                        Center(
                          //here
                          child: Column(
                            children: totiMediciiList
                                ? allMedics
                                : mediciOnlineList
                                ? mediciOnline
                                : (scrieOintrebareLista || consultatieVideoLista || interpretareAnalizeLista)
                                ? listaFiltrata.map((doctor) =>
                                IconStatusNumeRatingSpitalLikesMedic(
                              medicItem: doctor,
                              contClientMobile: widget.contClientMobile,
                            )).toList()
                                : allMedics,
                          ),
                        ),
                        // const SizedBox(height: 25),
                        // Center(
                        //   child: Column(
                        //     children: totiMediciiList
                        //         ? allMedics
                        //         : mediciOnlineList
                        //         ? mediciOnline
                        //         : (scrieOintrebareLista || consultatieVideoLista || interpretareAnalizeLista)
                        //         ? listaFiltrata.map((doctor) => IconStatusNumeRatingSpitalLikesMedic(
                        //       medicItem: doctor,
                        //       contClientMobile: widget.contClientMobile,
                        //     )).toList()
                        //         : allMedics,
                        //   ),
                        // ),


                      ],
                    ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 15),
                        Text(
                          "Se încarcă lista de medici...",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey),
                        ),
                      ],
                    ),
                  )),
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
      decoration: BoxDecoration(
          border: Border.all(
            color: colorBackground,
          ),
          borderRadius: BorderRadius.circular(15.0),
          color: colorBackground),
      child: Row(
        children: [
          const SizedBox(width: 5),
          Image.asset(iconLocation),
          const SizedBox(width: 5),
          SizedBox(
            width: widthScris,
            height: 35,
            child: Text(
              textServiciu,
              style: GoogleFonts.rubik(color: colorScris, fontSize: 11, fontWeight: FontWeight.w400),
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
      onTap: widget.medicItem.status == inConsultatie.value
          ? null
          : () async {
              medicSelectat = await getDetaliiMedic(widget.medicItem.id);
              listaRecenziiMedicSelectat = await getListaRecenziiByIdMedic(widget.medicItem.id);

              if (mounted) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilDoctorDisponibilitateServiciiScreen(
                        medicDetalii: medicSelectat!,
                        statusMedic: widget.medicItem.status,
                        listaRecenzii: listaRecenziiMedicSelectat,
                        ecranTotiMedicii: true,
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
                          const SizedBox(
                            width: 2,
                          ),
                          widget.medicItem.medieReviewuri != 0.0 ?
                          RatingBar(
                            ignoreGestures: true,
                            initialRating: widget.medicItem.medieReviewuri ?? 0.0, // Use actual rating
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
                                  : widget.medicItem.status == activ.value
                                  ? const Icon(Icons.star_half, color: Color.fromRGBO(252, 220, 85, 1))
                                  : const Icon(Icons.star_half, color: Color.fromRGBO(103, 114, 148, 1)),

                              empty: widget.medicItem.status == inConsultatie.value
                                  ? const Icon(Icons.star_outline, color: Color.fromRGBO(252, 220, 85, 1))
                                  : widget.medicItem.status == activ.value
                                  ? const Icon(Icons.star_outline, color: Color.fromRGBO(252, 220, 85, 1))
                                  : const Icon(Icons.star_outline, color: Color.fromRGBO(103, 114, 148, 1)),
                            ),
                            onRatingUpdate: (value) {
                              setState(() {
                                //_ratingValue = value;
                              });
                            },
                          ) : const SizedBox(),
                          widget.medicItem.medieReviewuri != 0.0 ?
                          SizedBox(
                            width: 50,
                            child: Text(
                              widget.medicItem.medieReviewuri.toStringAsFixed(1),
                              style: GoogleFonts.rubik(
                                color: widget.medicItem.status == inConsultatie.value
                                    ? const Color.fromRGBO(252, 220, 85, 1)
                                    : widget.medicItem.status == activ.value
                                    ? const Color.fromRGBO(252, 220, 85, 1)
                                    : const Color.fromRGBO(103, 114, 148, 1),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ) : const SizedBox()
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
