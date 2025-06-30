import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/fixing/chat.dart';
import 'package:sos_bebe_app/fixing/screens/questionaireScreen.dart';
import 'package:sos_bebe_app/fixing/screens/rev.dart';
import 'package:sos_bebe_app/fixing/screens/videoCallScreen.dart';
import '../../intro_screen.dart';
import '../CountdownWrapper.dart';
import '../services/consultation_service.dart';
import '../services/video_call_service.dart';
import 'payment_screen.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;
import 'package:http/http.dart' as http;


class ConsultationScreen extends StatefulWidget {
  final int patientId;
  final int doctorId ;
  const ConsultationScreen({Key? key, required this.patientId , required this.doctorId}) : super(key: key);

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
  final _videoCallService = VideoCallService();


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
    // Only start countdown if status is 'Requested'
    if (_currentConsultation?['status'] != 'Requested') {
      _countdownTimer?.cancel();
      return;
    }

    _countdownTimer?.cancel();
    _remainingTimeNotifier.value = 180; // Reset to 3 minutes
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTimeNotifier.value > 0) {
        _remainingTimeNotifier.value--;
      } else {
        timer.cancel();
        // Only cancel if still in Requested status
        if (_currentConsultation?['status'] == 'Requested') {
          _cancelConsultation();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Scaffold(body: Center(child: Text("i got tyhe bug !!!!"),),),
            ),
          );
        }
      }
    });
  }

  Future<void> _loadCurrentConsultation() async {
    try {
      print("_loadCurrentConsultation id  ${widget.patientId }");

      final response = await _consultationService.getCurrentConsultation(patientId: widget.patientId);
      print("responsexxx");
      print(response);
      if (response['has_active_session']) {
        final newStatus = response['data']['status'];
        final oldStatus = _currentConsultation?['status'];

        setState(() {
          _currentConsultation = response['data'];
          _isLoading = false;
        });

        // Only start countdown if status is Requested
        if (newStatus == 'Requested') {
          _startCountdown();
        } else {
          // Cancel countdown for any other status
          _countdownTimer?.cancel();
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

  // Future<void> _requestConsultation({required int doctorId,required String sessionType ,required double amount}) async {
  //   try {
  //     final response = await _consultationService.requestConsultation(
  //       patientId: widget.patientId,
  //       doctorId: doctorId,
  //       sessionType: sessionType,
  //       amount: amount
  //     );
  //
  //     setState(() {
  //       _currentConsultation = response['data'];
  //       _isLoading = false;
  //     });
  //     _startCountdown();
  //   } catch (e) {
  //     setState(() {
  //       _error = e.toString();
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<Map<String, dynamic>?> getChestionarClientMobileRaw({
    required String pUser,
    required String pParola,
    required int pIdChestionar,
  }) async {
    final Map<String, String> params = {
      'pUser': pUser,
      'pParolaMD5': pParola,
      'pIdChestionar': pIdChestionar.toString(),
    };

    // Use your actual method name here, e.g. 'GetChestionarClientMobile'
    http.Response? response = await apiCallFunctions.getApelFunctie(params, 'GetUltimulChestionarCompletatByContClient');
    if (response != null && response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
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
    return CountdownWrapper(
      onTimeout: () async{
          await _consultationService.updateConsultationStatus(
            _currentConsultation!['id'],
            'reject',
          );
          _loadCurrentConsultation();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const IntroScreen(),
            ),
          );


      },
      child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                'Aşteptağı râspunsul medicului',
                style: GoogleFonts.rubik(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF677195),
                ),
              ),


            ],
          ),),
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
            color: Color(0xFF0EBE7F),
          ),
          const SizedBox(height: 24),
          Text(
            'Medicul ți-a acceptat cererea',
            style: GoogleFonts.rubik(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0EBE7F),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Te rugăm să finalizezi plata pentru a continua consultația',
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
                        currentConsultation :  _currentConsultation!['id'],



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
              backgroundColor: const Color(0xFF0EBE7F),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Continuă cu plata',
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




  Widget _buildNoConsultationScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.medical_services,
            size: 80,
            color: Color(0xFF0EBE7F),
          ),
          const SizedBox(height: 24),
          Text(
            'No Active Consultation',
            style: GoogleFonts.rubik(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0EBE7F),
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
             // _requestConsultation(doctorId: widget.doctorId, sessionType: 'Call', amount: widget.);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => IntroScreen()
                ),(Route<dynamic> route) => false,
              );
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_error',
              style: const TextStyle(color: Color(0xFFE53935)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadCurrentConsultation();

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Refresh',
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
    // if (_error != null) {
    //   return Center(
    //     child: Text(
    //       'Error: $_error',
    //       style: const TextStyle(color: Color(0xFFE53935)),
    //     ),
    //   );
    // }


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

      case 'PaymentCompleted' || 'FormPending' :
        return _buildQuestionnaireScreen();

      case  'FormSubmitted' :
        return fromSubmittedScreen();

      case 'CallReady' || 'CallStarted':
        return _buildSessionScreen();

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
      body: _buildContent(),
    );
  }

  /// Navigate to Chat screen
  Widget _buildChatScreen() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          '',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF0EBE7F),
        elevation: 0,
        centerTitle: true,

      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'În atenția dumneavoastră',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '• Vă rugăm să adresați medicului o singură întrebare.',
                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '• Textul poate avea maxim 400 de caractere.',
                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '• Butonul TRIMITE ÎNTREBAREA se utilizează o singură dată după finalizarea scrierii mesajului.',
                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '• Vă informăm că după 10 minute fereastra se închide automat!',
                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Vă mulțumim!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0EBE7F),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Scrie text',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          recommendation: _currentConsultation!['session_type'] == 'Recommendation',
                          isDoctor: false,
                          doctorId: _currentConsultation!['doctor_id'].toString(),
                          patientId: _currentConsultation!['patient_id'].toString(),
                          doctorName: _currentConsultation!['doctor_name'],
                          patientName: _currentConsultation!['patient_name'],
                          chatRoomId: _currentConsultation!['channel_name'],
                          amount: double.tryParse(_currentConsultation!['amount'] ?? "0.0") ?? 0.0 ,
                        ),
                      ),
                          (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0EBE7F),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'TRIMITE ÎNTREBAREA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  /// Navigate to Chat screen
  // Widget _buildChatScreen() {
  //   // Dummy screen for Chat
  //   return   Scaffold(
  //
  //     appBar: AppBar(
  //       automaticallyImplyLeading: false,
  //       title: const Text(
  //         'În atenția dumneavoastră',
  //         style: TextStyle(
  //           fontSize: 22,
  //           fontWeight: FontWeight.w600,
  //           color: Colors.white,
  //         ),
  //       ),
  //       backgroundColor: Colors.red[900],
  //       elevation: 0,
  //       centerTitle: true,
  //     ),
  //     body: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: [Colors.blueGrey[50]!, Colors.white],
  //           begin: Alignment.topCenter,
  //           end: Alignment.bottomCenter,
  //         ),
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Card(
  //             color: Color(0xFF0EBE7F),
  //             elevation: 4,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: Padding(
  //               padding: const EdgeInsets.all(20),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: const [
  //                   Text(
  //                     '• Vă rugăm să adresați medicului o singură întrebare.',
  //                     style: TextStyle(fontSize: 16, height: 1.5 ,color: Colors.white , fontWeight: FontWeight.bold),
  //                   ),
  //                   SizedBox(height: 10),
  //                   Text(
  //                     '• Textul poate avea maxim 400 de caractere.',
  //                     style: TextStyle(fontSize: 16, height: 1.5,color: Colors.white , fontWeight: FontWeight.bold),
  //                   ),
  //                   SizedBox(height: 10),
  //                   Text(
  //                     '• Butonul **TRIMITE ÎNTREBAREA** se utilizează o singură dată după finalizarea scrierii mesajului.',
  //                     style: TextStyle(fontSize: 16, height: 1.5,color: Colors.white , fontWeight: FontWeight.bold),
  //                   ),
  //                   SizedBox(height: 10),
  //                   Text(
  //                     '• Vă informăm că după 10 minute fereastra se închide automat!',
  //                     style: TextStyle(fontSize: 16, height: 1.5,color: Colors.white , fontWeight: FontWeight.bold),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 30),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.pushAndRemoveUntil(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => ChatScreen(
  //                     recommendation : _currentConsultation!['session_type'] =='Recommendation' ,
  //                     isDoctor: false,
  //                     doctorId: _currentConsultation!['doctor_id'].toString(),
  //                     patientId: _currentConsultation!['patient_id'].toString(),
  //                     doctorName: _currentConsultation!['doctor_name'],
  //                     patientName: _currentConsultation!['patient_name'],
  //                     chatRoomId: _currentConsultation!['channel_name'],
  //                   ),
  //
  //                 ),(Route<dynamic> route) => false,
  //               );
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.red[900],
  //               padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //               elevation: 2,
  //             ),
  //             child: const Text(
  //               'Am înțeles',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.white,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }


  /// Navigate to the video call screen
  Widget _buildCallReadyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 80,
            color: Color(0xFF0EBE7F),
          ),
          const SizedBox(height: 24),
          Text(
            'Gata să te alături',
            style: GoogleFonts.rubik(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0EBE7F),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Medicul este gata să înceapă consultația',
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              print('_currentConsultation!');
              print(_currentConsultation);

// Navigate to call screen and clear all previous routes
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => VideoCallScreeen(
                    isDoctor: false,
                    channelName: _currentConsultation!['channel_name'],
                    sessionId: _currentConsultation!['id'],
                    drId: _currentConsultation!['doctor_id'],
                  ),
                ),
                    (route) => false,
              ).then((value) async {
                try {
                  // End the call
                  await _videoCallService.endCall(_currentConsultation!['id']);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Call ended successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    print('Error ending call: ${e.toString()}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error ending call: ${e.toString()}')),
                    );
                  }
                }

                // Navigate to testimonial screen after call ends
                if (mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TestimonialScreenSimple(
                        idMedic: _currentConsultation!['doctor_id'],
                      ),
                    ),
                  );
                }
              });

              // print('_currentConsultation!');
              // print(_currentConsultation);
              // // Navigate to call screen
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (context) => VideoCallScreeen(isDoctor: false  , channelName: _currentConsultation!['channel_name'],
              //     sessionId:  _currentConsultation!['id'] ,
              //     drId: _currentConsultation!['doctor_id']
              //   )),
              // ).then((value) async {
              //   try {
              //     // This is the specific line that ends the call
              //     await _videoCallService.endCall(_currentConsultation!['id']);
              //     if (mounted) {
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         const SnackBar(content: Text('Call ended successfully')),
              //       );
              //       Navigator.pop(context);
              //     }
              //   } catch (e) {
              //     if (mounted) {
              //       print('Error ending call: ${e.toString()}');
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         SnackBar(content: Text('Error ending call: ${e.toString()}')),
              //       );
              //     }
              //   }
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => TestimonialScreenSimple(
              //         idMedic: _currentConsultation!['doctor_id'], // Replace with actual doctor ID
              //       ),
              //     ),
              //   );
              // });


            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0EBE7F),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(

              'Intră în sesiune,',
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

  /// Swich screen
  Widget _buildSessionScreen() {
    switch (_currentConsultation!['session_type']) {
      case 'Call':
        return _buildCallReadyScreen();
      case 'Chat' || 'Recommendation' :
        return _buildChatScreen();

      default:
        return const Center(child: Text('Unknown Status'));
    }
  }

  Widget _buildAcceptedScreen() {
    return CountdownWrapper(
      onTimeout: () async {
        await _consultationService.updateConsultationStatus(
          _currentConsultation!['id'],
          'callEnded',
        );
        _loadCurrentConsultation();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const IntroScreen(),
          ),
        );
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Card(
            surfaceTintColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Doctorul ${_currentConsultation!['doctorName'] ?? 'Daniela Preoteasa'} a confirmat',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rubik(
                      fontSize: 18,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await _consultationService.updateConsultationStatus(
                          _currentConsultation!['id'],
                          'payment_pending',
                        );

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                              amount: double.parse(_currentConsultation!['amount'] ?? '0.0'),
                              currentConsultation: _currentConsultation!['id'],

                            ),
                          ),
                        );

                        if (result == true) {
                          await _consultationService.updateConsultationStatus(
                            _currentConsultation!['id'],
                            'payment_completed',
                          );
                          _loadCurrentConsultation();
                        }
                      } catch (e) {
                        setState(() {
                          _error = e.toString();
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0FBE7F),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'EFECTUAȚI PLATA',
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
        ),
      ),
    );
  }
  // Widget _buildAcceptedScreen() {
  //   return CountdownWrapper(
  //     onTimeout: () async {
  //       await _consultationService.updateConsultationStatus(
  //         _currentConsultation!['id'],
  //         'callEnded',
  //       );
  //       _loadCurrentConsultation();
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const IntroScreen(),
  //         ),
  //       );
  //     },
  //     child: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           const Icon(
  //             Icons.check_circle,
  //             size: 80,
  //             color: Color(0xFF0EBE7F),
  //           ),
  //           const SizedBox(height: 24),
  //           Text(
  //             'Medicul ți-a acceptat cererea',
  //             style: GoogleFonts.rubik(
  //               fontSize: 24,
  //               fontWeight: FontWeight.w500,
  //               color: const Color(0xFF0EBE7F),
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //           Text(
  //             'Te rugăm să continui cu plata pentru a putea continua consultația',
  //             textAlign: TextAlign.center,
  //             style: GoogleFonts.rubik(
  //               fontSize: 16,
  //               color: Colors.black87,
  //             ),
  //           ),
  //           const SizedBox(height: 32),
  //           ElevatedButton(
  //             onPressed: () async {
  //               try {
  //                 await _consultationService.updateConsultationStatus(
  //                   _currentConsultation!['id'],
  //                   'payment_pending',
  //                 );
  //
  //
  //                 final result = await Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (context) => PaymentScreen(
  //                       amount: double.parse(_currentConsultation!['amount'] ?? 0.0), currentConsultation: _currentConsultation!['id'] ,
  //                       serviceType: '1',
  //                       doctorId: 7,
  //                       ///HERE
  //
  //                     ),
  //                   ),
  //                 );
  //
  //                 if (result == true) {
  //                   await _consultationService.updateConsultationStatus(
  //                     _currentConsultation!['id'],
  //                     'payment_completed',
  //                   );
  //                   _loadCurrentConsultation();
  //                 }
  //               } catch (e) {
  //                 setState(() {
  //                   _error = e.toString();
  //                 });
  //               }
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: const Color(0xFF0EBE7F),
  //               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //             ),
  //             child: Text(
  //               'Continuă cu plata',
  //               style: GoogleFonts.rubik(
  //                 fontSize: 16,
  //                 color: Colors.white,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     )
  //   );
  // }



  Widget _buildQuestionnaireScreen() {
    return

      CountdownWrapper(
      child: Center(child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assignment,
            size: 80,
            color: Color(0xFF0EBE7F),
          ),
          const SizedBox(height: 24),
          Text(
            'Chestionar medical',
            style: GoogleFonts.rubik(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0EBE7F),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Te rugăm să completezi chestionarul medical pentru a continua',
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
                SharedPreferences prefss = await SharedPreferences.getInstance();
                String user = prefss.getString('user') ?? 'Test@t.com';
                String userPassMD5 = prefss.getString(pref_keys.userPassMD5) ?? '123456789';
                final map = await getChestionarClientMobileRaw(
                  pUser: user,
                  pParola:userPassMD5 ,
                  pIdChestionar:widget.patientId ,
                );

                final data= map ;

                final firstName = data!['PrenumeCompletat'] ?? '';
                final lastName = data['NumeCompletat'] ?? '';
                final fullName = '$firstName $lastName'.trim();
                final weight = data['GreutateCompletata'];
                final birthDate = data['DataNastereCompletata'].split('T').first;



                // First update status to FormPending
                await _consultationService.updateConsultationStatus(
                  _currentConsultation!['id'],
                  'form_pending',
                );

                // Navigate to questionnaire screen
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        QuestionnaireScreen(numePacient: fullName, dataNasterii: birthDate, greutate: weight,

                    ),
                  ),
                );

                if (result == true) {
                  // Questionnaire submitted successfully
                  await _consultationService.updateConsultationStatus(
                    _currentConsultation!['id'],
                    'FormSubmitted',
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
              backgroundColor: const Color(0xFF0EBE7F),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Completează chestionarul',
              style: GoogleFonts.rubik(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      )),
      onTimeout: () async {
      await _consultationService.updateConsultationStatus(
        _currentConsultation!['id'],
        'callEnded',
      );
      _loadCurrentConsultation();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const IntroScreen(),
        ),
      );
    },

    )  ;

  }
}

class fromSubmittedScreen extends StatelessWidget {
  const fromSubmittedScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(0xFF0EBE7F),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Formularul a fost trimis, așteptăm revizuirea medicului',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0EBE7F),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

}
