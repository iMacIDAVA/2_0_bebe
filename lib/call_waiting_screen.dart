// import 'dart:async';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sos_bebe_app/apel_video_pacient_screen.dart';
// import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
// import 'package:sos_bebe_app/utils_api/api_config.dart';
// import 'package:sos_bebe_app/utils_api/classes.dart';
//
// import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;
// import 'package:sos_bebe_app/vezi_toti_medicii_screen.dart';
//
// class WaitingForDoctorScreen extends StatefulWidget {
//   final String pret;
//   final int tipServiciu;
//   final ContClientMobile contClientMobile;
//   final MedicMobile medicDetalii;
//
//   const WaitingForDoctorScreen({
//     Key? key,
//     required this.pret,
//     required this.tipServiciu,
//     required this.contClientMobile,
//     required this.medicDetalii,
//   }) : super(key: key);
//
//   @override
//   State<WaitingForDoctorScreen> createState() => _WaitingForDoctorScreenState();
// }
//
// class _WaitingForDoctorScreenState extends State<WaitingForDoctorScreen> {
//   int remainingTime = 180;
//   Timer? countdownTimer;
//   ApiCallFunctions apiCallFunctions = ApiCallFunctions();
//
//   List<MedicMobile> listaMedici = [];
//   ContClientMobile? resGetCont;
//
//   ValueNotifier<int> remainingTimeNotifier = ValueNotifier(180);
//
//   Future<void> getContUser() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String user = prefs.getString('user') ?? '';
//     String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
//
//     if (user.isEmpty || userPassMD5.isEmpty) {
//       throw Exception("Missing user credentials");
//     }
//
//     resGetCont = await apiCallFunctions.getContClient(
//       pUser: user,
//       pParola: userPassMD5,
//       pDeviceToken: prefs.getString('oneSignalId') ?? "",
//       pTipDispozitiv: Platform.isAndroid ? '1' : '2',
//       pModelDispozitiv: await apiCallFunctions.getDeviceInfo(),
//       pTokenVoip: '',
//     );
//
//     if (resGetCont == null) {
//       throw Exception("Failed to fetch account data");
//     }
//   }
//
//   Future<void> getListaMedici() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String user = prefs.getString('user') ?? '';
//     String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
//
//     listaMedici = await apiCallFunctions.getListaMedici(
//       pUser: user,
//       pParola: userPassMD5,
//     ) ??
//         [];
//   }
//
//   Future<void> fetchDataBeforeNavigation() async {
//     try {
//       // ✅ Fetch account details if not already loaded
//       if (resGetCont == null) {
//         await getContUser();
//       }
//
//       // ✅ Fetch list of doctors
//       await getListaMedici();
//
//       // ✅ Ensure at least 1 doctor is in the list
//       while (listaMedici.isEmpty) {
//         print("🔄 Waiting for doctors list...");
//         await Future.delayed(const Duration(seconds: 1));
//         await getListaMedici();
//       }
//
//     } catch (e) {
//       print("❌ Error loading data before navigation: $e");
//     }
//   }
//
//
//   void startTimer() {
//     countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }
//
//       if (remainingTimeNotifier.value > 0) {
//         remainingTimeNotifier.value--;
//       } else {
//         timer.cancel();
//
//         await sendExitNotificationToDoctor();
//
//         // ✅ Load required data before navigating
//         await fetchDataBeforeNavigation();
//
//         // ✅ Optional: Add a delay to ensure UI loads properly
//         await Future.delayed(const Duration(seconds: 2));
//
//         if (mounted && resGetCont != null) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => VeziTotiMediciiScreen(
//                 listaMedici: listaMedici,
//                 contClientMobile: resGetCont!,
//               ),
//             ),
//           );
//         }
//       }
//     });
//   }
//
//
//
//   Future<void> sendExitNotificationToDoctor() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     String pCheie = keyAppPacienti; // App key for patients
//     int pIdMedic = widget.medicDetalii.id; // Doctor ID
//     String pTip = widget.tipServiciu.toString();
//
//     String patientId = prefs.getString(pref_keys.userId) ?? '';
//     String patientNume = prefs.getString(pref_keys.userNume) ?? '';
//     String patientPrenume = prefs.getString(pref_keys.userPrenume) ?? '';
//
//     String pObservatii = '$patientId\$#\$$patientPrenume $patientNume';
//
//     // Exit message
//     String pMesaj = "Pacientul a părăsit sesiunea după 3 minute de inactivitate.";
//
//     await apiCallFunctions.trimitePushPrinOneSignalCatreMedic(
//       pCheie: pCheie,
//       pIdMedic: pIdMedic,
//       pTip: pTip,
//       pMesaj: pMesaj,
//       pObservatii: pObservatii,
//     );
//
//     print("📢 Exit notification sent to doctor!");
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     startTimer();
//     initNotificationListener();
//   }
//
//
//
//   void initNotificationListener() {
//     OneSignal.Notifications.addForegroundWillDisplayListener((event) {
//       handleNotification(event.notification);
//     });
//
//     OneSignal.Notifications.addClickListener((event) {
//       handleNotification(event.notification);
//     });
//   }
//
//   void handleNotification(OSNotification notification) {
//     String? alertMessage = notification.body;
//     if (alertMessage != null && alertMessage.toLowerCase().contains('apelul a început')) {
//       navigateToVideoCall();
//     }
//   }
//
//   void navigateToVideoCall() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ApelVideoPacientScreen(
//           medic: widget.medicDetalii,
//           contClientMobile: widget.contClientMobile,
//         ),
//       ),
//     );
//   }
//
//   Future<void> navigateToHome() async {
//     await sendExitNotificationToDoctor();
//
//     // ✅ Load required data before navigating
//     await fetchDataBeforeNavigation();
//
//     // ✅ Optional: Add a delay to ensure UI loads properly
//     await Future.delayed(const Duration(seconds: 2));
//
//     if (mounted && resGetCont != null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => VeziTotiMediciiScreen(
//             listaMedici: listaMedici,
//             contClientMobile: resGetCont!,
//           ),
//         ),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     countdownTimer?.cancel();
//     remainingTimeNotifier.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Vă rugăm să așteptați ca medicul să înceapă apelul.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
//               ),
//               const SizedBox(height: 20),
//               Padding(
//                 padding: const EdgeInsets.only(left: 128.0, right: 128.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.red.withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       AnimatedContainer(
//                         duration: const Duration(milliseconds: 500),
//                         width: 10,
//                         height: 10,
//                         decoration: const BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.red,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       ValueListenableBuilder<int>(
//                         valueListenable: remainingTimeNotifier,
//                         builder: (context, remainingTime, _) {
//                           return Text(
//                             "${remainingTime ~/ 60}:${(remainingTime % 60).toString().padLeft(2, '0')}",
//                             style: const TextStyle(
//                               color: Colors.red,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(width: 8),
//                       const Icon(
//                         Icons.timer,
//                         color: Colors.red,
//                         size: 20,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
