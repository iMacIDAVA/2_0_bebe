import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sos_bebe_app/fixing/screens/questionaireScreen.dart';
import '../services/consultation_service.dart';
import 'payment_screen.dart';

class ConsultationScreen extends StatefulWidget {
  final int patientId;
  const ConsultationScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  _ConsultationScreenState createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final ConsultationService _consultationService = ConsultationService();
  Map<String, dynamic>? _currentConsultation;
  bool _isLoading = true;
  String? _error;
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  final ValueNotifier<int> _remainingTimeNotifier = ValueNotifier(180); // 3 minutes timeout

  @override
  void initState() {
    super.initState();
    _loadCurrentConsultation();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    _remainingTimeNotifier.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentConsultation != null) {
        _loadCurrentConsultation();
      }
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _remainingTimeNotifier.value = 180; // Reset to 3 minutes
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTimeNotifier.value > 0) {
        _remainingTimeNotifier.value--;
      } else {
        timer.cancel();
        _cancelConsultation();
      }
    });
  }

  Future<void> _loadCurrentConsultation() async {
    try {
      final response = await _consultationService.getCurrentConsultation(widget.patientId);
      if (response['has_active_session']) {
        final newStatus = response['data']['status'];
        final oldStatus = _currentConsultation?['status'];

        setState(() {
          _currentConsultation = response['data'];
          _isLoading = false;
        });

        if (newStatus == 'Requested' && oldStatus != 'Requested') {
          _startCountdown();
        }
      } else {
        setState(() {
          _currentConsultation = null;
          _isLoading = false;
        });
        _countdownTimer?.cancel();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _requestConsultation(int doctorId, String sessionType) async {
    try {
      final response = await _consultationService.requestConsultation(
        patientId: widget.patientId,
        doctorId: doctorId,
        sessionType: sessionType,
      );

      setState(() {
        _currentConsultation = response['data'];
        _isLoading = false;
      });
      _startCountdown();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelConsultation() async {
    if (_currentConsultation == null) return;
    try {
      await _consultationService.updateConsultationStatus(
        _currentConsultation!['id'],
        'reject',
      );
      setState(() {
        _currentConsultation = null;
      });
      _countdownTimer?.cancel();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Widget _buildRequestedScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.hourglass_empty,
            size: 80,
            color: Color(0xFF2196F3),
          ),
          const SizedBox(height: 24),
          Text(
            'Waiting for Doctor',
            style: GoogleFonts.rubik(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<int>(
            valueListenable: _remainingTimeNotifier,
            builder: (context, remainingSeconds, child) {
              final minutes = remainingSeconds ~/ 60;
              final seconds = remainingSeconds % 60;
              return Text(
                'Time remaining: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: GoogleFonts.rubik(
                  fontSize: 16,
                  color: const Color(0xFF2196F3),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _cancelConsultation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Cancel Request',
              style: GoogleFonts.rubik(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPendingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.payment,
            size: 80,
            color: Color(0xFF2196F3),
          ),
          const SizedBox(height: 24),
          Text(
            'Doctor Accepted Your Request',
            style: GoogleFonts.rubik(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please complete the payment to proceed with the consultation',
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              try {
                // First, update status to PaymentPending
                await _consultationService.updateConsultationStatus(
                  _currentConsultation!['id'],
                  'payment_pending',
                );
                // print("_currentConsultation");
                // print(_currentConsultation!['amount'].toDouble);
                // print(_currentConsultation!['amount'].runtimeType);

                // Navigate to payment screen
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      amount:double.parse(_currentConsultation!['amount'] ?? 0.0),
                    ),
                  ),
                );

                if (result == true) {
                  // Payment successful, update status to payment_completed
                  await _consultationService.updateConsultationStatus(
                    _currentConsultation!['id'],
                    'payment_completed',
                  );

                  // Reload consultation to show next state
                  _loadCurrentConsultation();
                }
              } catch (e) {
                setState(() {
                  _error = e.toString();
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Proceed to Payment',
              style: GoogleFonts.rubik(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPendingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assignment,
            size: 80,
            color: Color(0xFF2196F3),
          ),
          const SizedBox(height: 24),
          Text(
            'Medical Form Required',
            style: GoogleFonts.rubik(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please fill out the medical questionnaire to proceed',
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Navigate to form screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Fill Form',
              style: GoogleFonts.rubik(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallReadyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.video_call,
            size: 80,
            color: Color(0xFF2196F3),
          ),
          const SizedBox(height: 24),
          Text(
            'Ready to Join',
            style: GoogleFonts.rubik(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'The doctor is ready to start the consultation',
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Navigate to call screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Join Session',
              style: GoogleFonts.rubik(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoConsultationScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.medical_services,
            size: 80,
            color: Color(0xFF2196F3),
          ),
          const SizedBox(height: 24),
          Text(
            'No Active Consultation',
            style: GoogleFonts.rubik(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Request a consultation with a doctor',
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // showDialog(
              //   context: context,
              //   builder: (context) => ConsultationRequestDialog(
              //     onRequest: (doctorId, sessionType) {
              //       _requestConsultation(doctorId, sessionType);
              //     },
              //   ),
              // );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Request Consultation',
              style: GoogleFonts.rubik(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2196F3),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          'Error: $_error',
          style: const TextStyle(color: Color(0xFFE53935)),
        ),
      );
    }

    if (_currentConsultation == null) {
      return _buildNoConsultationScreen();
    }

    switch (_currentConsultation!['status']) {
      case 'Requested':
        return _buildRequestedScreen();

        case 'Accepted':
        return _buildAcceptedScreen();

      case 'PaymentPending' :
        return _buildPaymentPendingScreen();

      case 'PaymentCompleted':
        return _buildQuestionnaireScreen();

      case 'FormPending':
        return _buildFormPendingScreen();

      case 'CallReady':
        return _buildCallReadyScreen();

      default:
        print( 'Unknown status: ${_currentConsultation!['status']}',) ;
        return Center(
          child: Text(
            'Unknown status: ${_currentConsultation!['status']}',
            style: GoogleFonts.rubik(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Consultation',
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
      body: _buildContent(),
    );
  }
  Widget _buildAcceptedScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 80,
            color: Color(0xFF2196F3),
          ),
          const SizedBox(height: 24),
          Text(
            'Doctor Accepted Your Request',
            style: GoogleFonts.rubik(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please proceed to payment to continue with the consultation',
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              try {
                // Update status to payment_pending
                await _consultationService.updateConsultationStatus(
                  _currentConsultation!['id'],
                  'payment_pending',
                );

                // Navigate to payment screen
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      amount:double.parse(_currentConsultation!['amount'] ?? 0.0),                    ),
                  ),
                );

                if (result == true) {
                  // Payment successful, update status to payment_completed
                  await _consultationService.updateConsultationStatus(
                    _currentConsultation!['id'],
                    'payment_completed',
                  );

                  // Reload consultation to show next state
                  _loadCurrentConsultation();
                }
              } catch (e) {
                setState(() {
                  _error = e.toString();
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Proceed to Payment',
              style: GoogleFonts.rubik(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildQuestionnaireScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assignment,
            size: 80,
            color: Color(0xFF2196F3),
          ),
          const SizedBox(height: 24),
          Text(
            'Medical Questionnaire',
            style: GoogleFonts.rubik(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please fill out the medical questionnaire to proceed',
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              try {
               // First update status to FormPending
                await _consultationService.updateConsultationStatus(
                  _currentConsultation!['id'],
                  'form_pending',
                );

                // Navigate to questionnaire screen
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionnaireScreen(

                      consultationId: _currentConsultation!['id'],
                    ),
                  ),
                );

                if (result == true) {
                  // Questionnaire submitted successfully
                  await _consultationService.updateConsultationStatus(
                    _currentConsultation!['id'],
                    'call_ready',
                  );

                  // Reload consultation to show next state
                  _loadCurrentConsultation();
                }
              } catch (e) {
                setState(() {
                  _error = e.toString();
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Fill Questionnaire',
              style: GoogleFonts.rubik(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
