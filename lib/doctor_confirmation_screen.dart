import 'dart:async';

import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/doctor_confirmation_reject_screen.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';

import 'doctor_confirmation_accepted_screen.dart';
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:sos_bebe_app/utils_api/api_config.dart';

import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;

class NotificationDisplayScreen extends StatefulWidget {
  final String pret;
  final int tipServiciu;
  final ContClientMobile contClientMobile;
  final MedicMobile medicDetalii;

  const NotificationDisplayScreen({
    Key? key,
    required this.pret,
    required this.tipServiciu,
    required this.contClientMobile,
    required this.medicDetalii,
  }) : super(key: key);

  @override
  State<NotificationDisplayScreen> createState() => _NotificationDisplayScreenState();
}

class _NotificationDisplayScreenState extends State<NotificationDisplayScreen> {
  int remainingTime = 180;
  Timer? countdownTimer;
  final ApiCallFunctions apiCallFunctions = ApiCallFunctions();

  ValueNotifier<int> remainingTimeNotifier = ValueNotifier(180);

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTimeNotifier.value > 0) {
        remainingTimeNotifier.value--;
      } else {
        timer.cancel();
        navigateToRejectScreen("Ne para rău, timpul a expirat. \nMedicul nu a răspuns");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initNotificationListener();
    startTimer();
  }

  void initNotificationListener() {
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      saveNotificationData(event.notification);
    });

    OneSignal.Notifications.addClickListener((event) {
      saveNotificationData(event.notification);
    });
  }

  Future<void> saveNotificationData(OSNotification notification) async {
    remainingTimeNotifier.dispose();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(pref_keys.notificationTitle, notification.title ?? 'Fără Titlu');
    await prefs.setString(pref_keys.notificationBody, notification.body ?? 'Fără corp');
    await prefs.setString(pref_keys.notificationData, notification.additionalData?.toString() ?? 'Fără date');

    handleNotification(notification);
  }

  @override
  void dispose() {
    remainingTimeNotifier.dispose();
    super.dispose();
  }

  void handleNotification(OSNotification notification) async {
    String? alertMessage = notification.body;
    if (alertMessage != null) {
      if (alertMessage.toLowerCase().contains('confirmare')) {
        navigateToConfirmScreen(notification.body);
      }else if (alertMessage.toLowerCase().contains('respingere')) {
        navigateToRejectScreen('Ne pare rău, medicul nu este disponibil.');
      }
      else {}
    } else {}
  }

  Future<void> notificaDoctor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
    apiCallFunctions.anuntaMedicDeServiciuTerminat(
        pUser: user,
        pParola: userPassMD5,
        pIdMedic: widget.medicDetalii.id.toString(),
        tipPlata: widget.tipServiciu.toString());
  }

  void navigateToConfirmScreen(String? body) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationContentScreen(
          body: body ?? "Fără conținut",
          pret: widget.pret,
          tipServiciu: widget.tipServiciu,
          contClientMobile: widget.contClientMobile,
          medicDetalii: widget.medicDetalii,
        ),
      ),
    );
  }

  Future<void> navigateToRejectScreen(String? body) async {

    await notificaDoctor();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorConfirmationReject(
          medicDetalii: widget.medicDetalii,
          body: body ?? "Fără conținut",
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text(
        //     'Raspunde doctorul',
        //     style: TextStyle(
        //       fontSize: 20,
        //       fontWeight: FontWeight.w600,
        //     ),
        //   ),
        //   backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
        //   foregroundColor: Colors.white,
        //   centerTitle: true,
        //   automaticallyImplyLeading: false,
        // ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Așteptați răspunsul medicului',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 128.0, right: 128.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ValueListenableBuilder<int>(
                        valueListenable: remainingTimeNotifier,
                        builder: (context, remainingTime, _) {
                          return Text(
                            "${remainingTime ~/ 60}:${(remainingTime % 60).toString().padLeft(2, '0')}", // Format as MM:SS
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.timer,
                        color: Colors.red,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
