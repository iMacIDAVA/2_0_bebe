import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/istoric_consultatii/istoric_deschis.dart';
import 'package:sos_bebe_app/raspunde_intrebare_doar_chat_screen.dart';
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;

class IstoricConsultatii extends StatefulWidget {
  const IstoricConsultatii({super.key});

  @override
  State<IstoricConsultatii> createState() => _IstoricConsultatiiState();
}

class _IstoricConsultatiiState extends State<IstoricConsultatii> {
  ApiCallFunctions apiCallFunctions = ApiCallFunctions();
  List<ConsultatiiMobile> consultatiiList = [];
  Future<void> getListaIstoricConsultatiiDinContClient() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
    consultatiiList =
        await apiCallFunctions.getListaIstoricConsultatiiDinContClient(
            pParola: userPassMD5, pUser: user);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getListaIstoricConsultatiiDinContClient();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(30, 214, 158, 1),
      appBar: AppBar(
        title: Text(
          "Istoric consultații",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(30, 214, 158, 1),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              consultatiiList.length == 0
                  ? Text("Nu aveti consultatii inregistrate.")
                  : Expanded(
                      child: ListView.builder(
                          itemCount: consultatiiList.length,
                          itemBuilder: (context, index) {
                            return consultatieCard(index);
                          }),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget consultatieCard(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          ContClientMobile? resGetCont;
          String user = prefs.getString('user') ?? '';
          String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
          resGetCont = await apiCallFunctions.getContClient(
            pUser: user,
            pParola: userPassMD5,

            //pDeviceToken: '', //old IGV
            pDeviceToken: prefs.getString('oneSignalId') ?? "",
            pTipDispozitiv: Platform.isAndroid ? '1' : '2',
            pModelDispozitiv: await apiCallFunctions.getDeviceInfo(),
            pTokenVoip: '',
          );
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return IstoricDeschis(
                contClientMobile: resGetCont!,
                medic: consultatiiList[index].idMedic);
          }));
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey[400]),
                    child: consultatiiList[index].linkPozaProfil.isEmpty
                        ? Image.asset('/assets/user_fara_poza.png')
                        : Image.network(consultatiiList[index].linkPozaProfil),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          consultatiiList[index].numeCompletClient,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff677294),
                          ),
                        ),
                        Text(
                          consultatiiList[index].adresa,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff677294),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                height: 1,
                color: Color.fromARGB(255, 217, 217, 217),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                '${DateFormat('hh:mm a').format(DateTime.parse(consultatiiList[index].dataInceput))} - ${DateFormat('hh:mm a').format(DateTime.parse(consultatiiList[index].dataSfarsit))} (${consultatiiList[index].etichetaDurata})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff677294),
                ),
              ),
              Text(
                DateTime(
                            DateTime.parse(consultatiiList[index].dataInceput)
                                .year,
                            DateTime.parse(consultatiiList[index].dataInceput)
                                .month,
                            DateTime.parse(consultatiiList[index].dataInceput)
                                .day) ==
                        DateTime(
                            DateTime.parse(consultatiiList[index].dataSfarsit)
                                .year,
                            DateTime.parse(consultatiiList[index].dataSfarsit)
                                .month,
                            DateTime.parse(consultatiiList[index].dataSfarsit)
                                .day)
                    ? DateFormat('dd.MM.yyyy').format(
                        DateTime.parse(consultatiiList[index].dataInceput))
                    : '${DateFormat('dd.MM.yyyy').format(DateTime.parse(consultatiiList[index].dataInceput))} - ${DateFormat('dd.MM.yyyy').format(DateTime.parse(consultatiiList[index].dataSfarsit))}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff677294),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: consultatiiList[index].tipConsultatie == 1
                      ? const Color(0xff0EBE7F)
                      : consultatiiList[index].tipConsultatie == 2
                          ? const Color.fromRGBO(241, 201, 0, 1)
                          : consultatiiList[index].tipConsultatie == 3
                              ? const Color.fromRGBO(30, 166, 219, 1)
                              : const Color(0xff0EBE7F),
                ),
                child: Text(
                  consultatiiList[index].tipConsultatie == 1
                      ? "Apel video"
                      : consultatiiList[index].tipConsultatie == 2
                          ? "Recomandare"
                          : consultatiiList[index].tipConsultatie == 3
                              ? "Întrebare"
                              : "",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
