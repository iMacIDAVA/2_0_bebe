import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _numePacientController = TextEditingController(); // <-- Add this line
  final _numeReprezentantController = TextEditingController();
  final _medicamentController = TextEditingController();
  final _varstaController = TextEditingController(); // Add controller for age
  final _greutateController = TextEditingController(); // Add controller for weight
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
  void initState() {
    super.initState();
    //_numePacientController.text = widget.numePacient; // Pre-fill if available
    // _greutateController.text = widget.greutate; // Pre-fill if available
    // Optionally, pre-fill _varstaController if you have age data
  }

  @override
  void dispose() {
    _numePacientController.dispose(); // <-- Dispose controller
    _numeReprezentantController.dispose();
    _medicamentController.dispose();
    _varstaController.dispose(); // Dispose age controller
    _greutateController.dispose(); // Dispose weight controller
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
          'nume_si_prenume': _numePacientController.text, // <-- Use controller value
          'varsta': _varstaController.text, // Add age to data
          "data_nastere":_varstaController.text, /// here
          'greutate': double.tryParse(_greutateController.text) ?? 0.0, // Use controller value
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
              const SnackBar(content: Text('Răspunsul tău a fost trimis cu succes')
              ),
            );
            Navigator.pop(context, true);
          }
        }
      } catch (e) {
        print('Error ${e.toString()}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error 221 : ${e.toString()}')),
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

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  ),
                  if (_alergicLaMedicament)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextFormField(
                          controller: _medicamentController,
                          decoration: InputDecoration(
                            hintText: 'La ce medicament este alergie?',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                ],
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
                        hintStyle: TextStyle(color: Color(0xFFB0B0B0)),

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
                  SizedBox(
                    width: 150,
                    child: TextFormField(
                      controller: _numePacientController,
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Introduceți numele ',
                        hintStyle: TextStyle(color: Color(0xFFB0B0B0)),

                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vă rugăm să introduceți numele și prenumele pacientului';
                        }
                        return null;
                      },
                    ),
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
                  SizedBox(
                    width: 150,
                    child: TextFormField(
                      controller: _varstaController,
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText:  'Ex: 3 ani',
                        hintStyle: TextStyle(color: Color(0xFFB0B0B0)),

                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vă rugăm să introduceți vârsta';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Greutate',
                    style: GoogleFonts.rubik(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: TextFormField(
                      controller: _greutateController,
                      textAlign: TextAlign.end,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Ex: 2 kg',
                        hintStyle: TextStyle(color: Color(0xFFB0B0B0)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vă rugăm să introduceți greutatea';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Divider(),
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

