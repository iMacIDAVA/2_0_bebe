import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../datefacturare/date_facturare_completare_rapida.dart';
import '../services/consultation_service.dart';
import 'package:intl/intl.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;

import 'package:http/http.dart' as http;

class QuestionnaireScreen extends StatefulWidget {
  final String numePacient;
  final String dataNasterii;
  final String greutate;

  QuestionnaireScreen({
    required this.numePacient,
    required this.dataNasterii,
    required this.greutate,
  });

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeReprezentantController = TextEditingController();
  final _medicamentController = TextEditingController();
  bool _alergicLaMedicament = false;
  bool _alergicLaParacetamol = false;
  Map<String, bool> _symptoms = {
    'Febră': false,
    'Tuse': false,
    'Dificultăți respiratorii': false,
    'Astenie': false,
    'Cefalee': false,
    'Dureri în gât': false,
    'Greturi/Varsaturi': false,
    'Diaree/Constipație': false,
    'Refuzul alimentației': false,
    'Irjaț la piele': false,
    'Nas înfundat': false,
    'Rinoree': false,
  };

  @override
  void dispose() {
    _numeReprezentantController.dispose();
    _medicamentController.dispose();
    super.dispose();
  }

  String _formatDate(String date) {
    final parts = date.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
    }
    return date; // Fallback if format is invalid
  }

  double _parseGreutate(String greutate) {
    return double.tryParse(greutate.replaceAll(' kg', '')) ?? 0.0;
  }

  Future<void> submitTheForm() async {
    if (_formKey.currentState!.validate()) {
      final _consultationService = ConsultationService();
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String patientId = prefs.getString(pref_keys.userId) ?? '';
        final consultation = await _consultationService.getCurrentConsultation(patientId: int.parse(patientId));
        final sessionId = consultation['data']['id'];
        final questionnaireData = {
          'nume_si_prenume_reprezentant_legal': _numeReprezentantController.text,
          'nume_si_prenume': widget.numePacient,
          "data_nastere": widget.dataNasterii,
          'greutate': _parseGreutate(widget.greutate),
          'alergic_la_vreun_medicament': _alergicLaMedicament,
          'la_ce_medicament_este_alergic': _alergicLaMedicament ? _medicamentController.text : null,
          'febra': _symptoms['Febră']!,
          'tuse': _symptoms['Tuse']!,
          'dificultati_respiratorii': _symptoms['Dificultăți respiratorii']!,
          'astenie': _symptoms['Astenie']!,
          'cefalee': _symptoms['Cefalee']!,
          'dureri_in_gat': _symptoms['Dureri în gât']!,
          'greturi_varsaturi': _symptoms['Greturi/Varsaturi']!,
          'diaree_constipatie': _symptoms['Diaree/Constipație']!,
          'refuzul_alimentatie': _symptoms['Refuzul alimentației']!,
          'iritatii_piele': _symptoms['Irjaț la piele']!,
          'nas_infundat': _symptoms['Nas înfundat']!,
          'rinoree': _symptoms['Rinoree']!,
        };

        final result = await _consultationService.submitQuestionnaire(sessionId, questionnaireData);

        if (result['status'] == 'success') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Questionnaire submitted successfully')),
            );
            Navigator.pop(context, true);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errorxxx: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Chestionar',
          style: GoogleFonts.rubik(fontSize: 20, color: Colors.grey[700]),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reprezentant legal al copilului',
                style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nume și Prenume',
                    style: GoogleFonts.rubik(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(
                    width: 150,
                    child: TextFormField(
                      controller: _numeReprezentantController,
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Introduceți numele',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vă rugăm să introduceți numele și prenumele reprezentantului';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Divider(),
              Text(
                'Nume și Prenume Pacient',
                style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nume și Prenume',
                    style: GoogleFonts.rubik(fontSize: 16, color: Colors.grey[700]),
                  ),
                  Text(
                    widget.numePacient,
                    style: GoogleFonts.rubik(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vârsta',
                    style: GoogleFonts.rubik(fontSize: 16, color: Colors.grey[700]),
                  ),
                  Text(
                    '1 an și 8 luni',
                    style: GoogleFonts.rubik(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Greutate',
                    style: GoogleFonts.rubik(fontSize: 16, color: Colors.grey[700]),
                  ),
                  Text(
                    '${widget.greutate} kg',
                    style: GoogleFonts.rubik(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
              Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                title: Text(
                  'Alergic la vreun medicament?',
                  style: GoogleFonts.rubik(fontSize: 16, color: Colors.grey[700]),
                ),
                value: _alergicLaMedicament,
                activeColor: Color(0xFF0EBE7F),
                onChanged: (bool value) {
                  setState(() {
                    _alergicLaMedicament = value;
                    if (!value) _medicamentController.clear();
                  });
                },
                secondary: _alergicLaMedicament
                    ? SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _medicamentController,
                    decoration: InputDecoration(
                      hintText: 'La ce medicament este alergie?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                )
                    : null,
              ),
              Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                title: Text(
                  'Alergic la Paracetamol',
                  style: GoogleFonts.rubik(fontSize: 16, color: Colors.grey[700]),
                ),
                value: _alergicLaParacetamol,
                activeColor: Color(0xFF0EBE7F),
                onChanged: (bool value) {
                  setState(() {
                    _alergicLaParacetamol = value;
                  });
                },
              ),
              Divider(),
              Text(
                'Simptome Pacient',
                style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              ..._symptoms.keys.map((String key) {
                return Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      title: Text(
                        key,
                        style: GoogleFonts.rubik(fontSize: 16, color: Colors.grey[700]),
                      ),
                      value: _symptoms[key]!,
                      activeColor: Color(0xFF0EBE7F),
                      onChanged: (bool value) {
                        setState(() {
                          _symptoms[key] = value;
                        });
                      },
                    ),
                    Divider(),
                  ],
                );
              }).toList(),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitTheForm,
                  child: Text(
                    'TRIMITE CHESTIONARUL',
                    style: GoogleFonts.rubik(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0EBE7F),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> getChestionarClientMobileRaw({
    required String pUser,
    required String pParola,
    required String pIdChestionar,
  }) async {
    final Map<String, String> params = {
      'pUser': pUser,
      'pParolaMD5': pParola,
      'pIdChestionar': pIdChestionar,
    };

    http.Response? response = await apiCallFunctions.getApelFunctie(params, 'GetUltimulChestionarCompletatByContClient');
    if (response != null && response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }
}
// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../datefacturare/date_facturare_completare_rapida.dart';
// import '../services/consultation_service.dart';
// import 'package:intl/intl.dart';
// import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;
// import 'package:http/http.dart' as http;
//
// class QuestionnaireScreen extends StatefulWidget {
//   final String numePacient;
//   final String dataNasterii;
//   final String greutate;
//
//   QuestionnaireScreen({
//     required this.numePacient,
//     required this.dataNasterii,
//     required this.greutate,
//   });
//
//   @override
//   _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
// }
//
// class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _numeReprezentantController = TextEditingController();
//   final _medicamentController = TextEditingController();
//   bool _alergicLaMedicament = false;
//   bool _alergicLaParacetamol = false;
//   Map<String, bool> _symptoms = {
//     'Febră': false,
//     'Tuse': false,
//     'Dificultăți respiratorii': false,
//     'Astenie': false,
//     'Cefalee': false,
//     'Dureri în gât': false,
//     'Greturi/Varsaturi': false,
//     'Diaree/Constipație': false,
//     'Refuzul alimentației': false,
//     'Irjaț la piele': false,
//     'Nas înfundat': false,
//     'Rinoree': false,
//   };
//
//   @override
//   void dispose() {
//     _numeReprezentantController.dispose();
//     _medicamentController.dispose();
//     super.dispose();
//   }
//
//   String _formatDate(String date) {
//     final parts = date.split('/');
//     if (parts.length == 3) {
//       return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
//     }
//     return date; // Fallback if format is invalid
//   }
//
//   double _parseGreutate(String greutate) {
//     return double.tryParse(greutate.replaceAll(' kg', '')) ?? 0.0;
//   }
//
//   Future<void> submitTheForm() async {
//     if (_formKey.currentState!.validate()) {
//       final _consultationService = ConsultationService();
//       try {
//
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         String patientId = prefs.getString(pref_keys.userId) ?? '';
//         //int currentPatientId = 29;
//         // Get current consultation
//         final consultation = await _consultationService.getCurrentConsultation(patientId:int.parse(patientId) );
//         print("Debug submit the from ");
//         final sessionId = consultation['data']['id'];
//         final questionnaireData = {
//           'nume_si_prenume_reprezentant_legal': _numeReprezentantController.text,
//           'nume_si_prenume': widget.numePacient,
//           "data_nastere": widget.dataNasterii,
//           'greutate': _parseGreutate(widget.greutate),
//           'alergic_la_vreun_medicament': _alergicLaMedicament,
//           'la_ce_medicament_este_alergic': _alergicLaMedicament ?  _medicamentController.text : null,
//           'febra': _symptoms['Febră']!,
//           'tuse': _symptoms['Tuse']!,
//           'dificultati_respiratorii': _symptoms['Dificultăți respiratorii']!,
//           'astenie': _symptoms['Astenie']!,
//           'cefalee': _symptoms['Cefalee']!,
//           'dureri_in_gat': _symptoms['Dureri în gât']!,
//           'greturi_varsaturi': _symptoms['Greturi/Varsaturi']!,
//           'diaree_constipatie': _symptoms['Diaree/Constipație']!,
//           'refuzul_alimentatie': _symptoms['Refuzul alimentației']!,
//           'iritatii_piele': _symptoms['Irjaț la piele']!,
//           'nas_infundat': _symptoms['Nas înfundat']!,
//           'rinoree': _symptoms['Rinoree']!,
//         };
//
//
//         // Submit questionnaire
//         final result = await _consultationService.submitQuestionnaire(
//           sessionId,
//           questionnaireData,
//         );
//
//         if (result['status'] == 'success') {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Questionnaire submitted successfully')),
//             );
//             // Navigate to next screen
//             Navigator.pop(context, true);
//           }
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Errorxxx: ${e.toString()}')),
//           );
//         }
//       }
//     }
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar:AppBar(
//         backgroundColor: Colors.white,
//         title: Text('Chestionar'),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Patient Details Section (Non-Editable)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Nume și Prenume Pacient',
//                     style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//                   ),
//                   Text(
//                     widget.numePacient,
//                     style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//                   ),
//                 ],
//               ),
//               Divider(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//
//
//                   Text(
//                     'Data nașterii',
//                     style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//                   ),
//                   Text(
//                     widget.dataNasterii,
//                     style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//                   ),
//                 ],
//               ),
//               Divider(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Greutate',
//                     style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//                   ),
//                   Text(
//                     '${widget.greutate} kg',
//                     style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//                   ),
//                 ],
//               ),
//               Divider(),
//               // Allergy Section
//               SwitchListTile(
//                 contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
//                 title: Text(
//                   'Alergic la vreun medicament?',
//                   style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//                 ),
//                 value: _alergicLaMedicament,
//                 activeColor: Color(0xFF60D69C),
//                 onChanged: (bool value) {
//                   setState(() {
//                     _alergicLaMedicament = value;
//                     if (!value) _medicamentController.clear();
//                   });
//                 },
//                 secondary: _alergicLaMedicament
//                     ? SizedBox(
//                   width: 200,
//                   child: TextFormField(
//                     controller: _medicamentController,
//                     decoration: InputDecoration(
//                       hintText: 'La ce medicament este alergie?',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 )
//                     : null,
//               ),
//               Divider(),
//               SwitchListTile(
//                 contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
//                 title: Text(
//                   'Alergic la Paracetamol',
//                   style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//                 ),
//                 value: _alergicLaParacetamol,
//                 activeColor: Color(0xFF60D69C),
//                 onChanged: (bool value) {
//                   setState(() {
//                     _alergicLaParacetamol = value;
//                   });
//                 },
//               ),
//               Divider(),
//               // Symptoms Section
//               Text(
//                 'Simptome Pacient',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey[700],
//                 ),
//               ),
//               ..._symptoms.keys.map((String key) {
//                 return Column(
//                   children: [
//                     SwitchListTile(
//                       contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
//                       title: Text(
//                         key,
//                         style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//                       ),
//                       value: _symptoms[key]!,
//                       activeColor: Color(0xFF60D69C),
//                       onChanged: (bool value) {
//                         setState(() {
//                           _symptoms[key] = value;
//                         });
//                       },
//                     ),
//                     Divider(),
//                   ],
//                 );
//               }).toList(),
//               SizedBox(height: 20),
//               // Legal Representative Section
//               Text(
//                 'Reprezentant legal al copilului',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey[700],
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Nume și Prenume',
//                     style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//                   ),
//                   SizedBox(
//                     width: 150,
//                     child: TextFormField(
//                       controller: _numeReprezentantController,
//                       textAlign: TextAlign.end,
//                       decoration: InputDecoration(
//                         border: InputBorder.none,
//                         hintText: 'Introduceți numele',
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Vă rugăm să introduceți numele și prenumele reprezentantului';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               Divider(),
//               SizedBox(height: 20),
//               // Continue Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: submitTheForm,
//                   child: Text(
//                     'CONTINUA',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFF60D69C),
//                     foregroundColor: Colors.white,
//                     padding: EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<Map<String, dynamic>?> getChestionarClientMobileRaw({
//     required String pUser,
//     required String pParola,
//     required String pIdChestionar,
//   }) async {
//     final Map<String, String> params = {
//       'pUser': pUser,
//       'pParolaMD5': pParola,
//       'pIdChestionar': pIdChestionar,
//     };
//
//     // Use your actual method name here, e.g. 'GetChestionarClientMobile'
//     http.Response? response = await apiCallFunctions.getApelFunctie(params, 'GetUltimulChestionarCompletatByContClient');
//     if (response != null && response.statusCode == 200) {
//       return jsonDecode(response.body) as Map<String, dynamic>;
//     }
//     return null;
//   }
// }
//
