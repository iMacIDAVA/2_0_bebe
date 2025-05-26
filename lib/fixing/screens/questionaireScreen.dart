import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuestionnaireScreen extends StatefulWidget {
  final int consultationId;

  const QuestionnaireScreen({
    Key? key,
    required this.consultationId,
  }) : super(key: key);

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _error;

  // Form controllers
  final _representativeNameController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _weightController = TextEditingController();

  // Symptom toggles
  bool _isAllergicToMedication = false;
  bool _hasFever = false;
  bool _hasCough = false;
  bool _hasBreathingDifficulties = false;
  bool _hasFatigue = false;
  bool _hasHeadache = false;
  bool _hasSoreThroat = false;
  bool _hasNauseaVomiting = false;
  bool _hasDiarrheaConstipation = false;
  bool _hasRefusedFood = false;
  bool _hasSkinIrritation = false;
  bool _hasStuffyNose = false;
  bool _hasRunnyNose = false;

  Future<void> _submitQuestionnaire() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      // First submit the questionnaire
      final questionnaireResponse = await http.post(
        Uri.parse('http://localhost:8000/api/questionnaires/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nume_si_prenume_reprezentant_legal': _representativeNameController.text,
          'nume_si_prenume': _patientNameController.text,
          'data_nastere': _birthDateController.text,
          'greutate': double.parse(_weightController.text),
          'alergic_la_vreun_medicament': _isAllergicToMedication,
          'febra': _hasFever,
          'tuse': _hasCough,
          'dificultati_respiratorii': _hasBreathingDifficulties,
          'astenie': _hasFatigue,
          'cefalee': _hasHeadache,
          'dureri_in_gat': _hasSoreThroat,
          'greturi_varsaturi': _hasNauseaVomiting,
          'diaree_constipatie': _hasDiarrheaConstipation,
          'refuzul_alimentatie': _hasRefusedFood,
          'iritatii_piele': _hasSkinIrritation,
          'nas_infundat': _hasStuffyNose,
          'rinoree': _hasRunnyNose,
        }),
      );

      if (questionnaireResponse.statusCode == 200) {
        final questionnaireData = jsonDecode(questionnaireResponse.body);
        final questionnaireId = questionnaireData['id'];

        // Then submit the form
        final formResponse = await http.post(
          Uri.parse('http://localhost:8000/api/consultation/${widget.consultationId}/submit-form/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'questionnaire_id': questionnaireId,
          }),
        );

        if (formResponse.statusCode == 200) {
          Navigator.pop(context, true); // Return success
        } else {
          throw Exception('Failed to submit form');
        }
      } else {
        throw Exception('Failed to submit questionnaire');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Medical Questionnaire',
          style: GoogleFonts.rubik(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Representative Legal Name
              TextFormField(
                controller: _representativeNameController,
                decoration: const InputDecoration(
                  labelText: 'Legal Representative Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the legal representative name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Patient Name
              TextFormField(
                controller: _patientNameController,
                decoration: const InputDecoration(
                  labelText: 'Patient Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the patient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Birth Date
              TextFormField(
                controller: _birthDateController,
                decoration: const InputDecoration(
                  labelText: 'Birth Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the birth date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Weight
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Symptoms Section
              Text(
                'Symptoms',
                style: GoogleFonts.rubik(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(height: 16),

              // Symptom toggles
              _buildSymptomToggle('Allergic to any medication', _isAllergicToMedication, (value) {
                setState(() => _isAllergicToMedication = value);
              }),
              _buildSymptomToggle('Fever', _hasFever, (value) {
                setState(() => _hasFever = value);
              }),
              _buildSymptomToggle('Cough', _hasCough, (value) {
                setState(() => _hasCough = value);
              }),
              _buildSymptomToggle('Breathing difficulties', _hasBreathingDifficulties, (value) {
                setState(() => _hasBreathingDifficulties = value);
              }),
              _buildSymptomToggle('Fatigue', _hasFatigue, (value) {
                setState(() => _hasFatigue = value);
              }),
              _buildSymptomToggle('Headache', _hasHeadache, (value) {
                setState(() => _hasHeadache = value);
              }),
              _buildSymptomToggle('Sore throat', _hasSoreThroat, (value) {
                setState(() => _hasSoreThroat = value);
              }),
              _buildSymptomToggle('Nausea/Vomiting', _hasNauseaVomiting, (value) {
                setState(() => _hasNauseaVomiting = value);
              }),
              _buildSymptomToggle('Diarrhea/Constipation', _hasDiarrheaConstipation, (value) {
                setState(() => _hasDiarrheaConstipation = value);
              }),
              _buildSymptomToggle('Refused food', _hasRefusedFood, (value) {
                setState(() => _hasRefusedFood = value);
              }),
              _buildSymptomToggle('Skin irritation', _hasSkinIrritation, (value) {
                setState(() => _hasSkinIrritation = value);
              }),
              _buildSymptomToggle('Stuffy nose', _hasStuffyNose, (value) {
                setState(() => _hasStuffyNose = value);
              }),
              _buildSymptomToggle('Runny nose', _hasRunnyNose, (value) {
                setState(() => _hasRunnyNose = value);
              }),

              if (_error != null)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Color(0xFFE53935),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitQuestionnaire,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Submit Questionnaire',
                        style: GoogleFonts.rubik(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSymptomToggle(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _representativeNameController.dispose();
    _patientNameController.dispose();
    _birthDateController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}