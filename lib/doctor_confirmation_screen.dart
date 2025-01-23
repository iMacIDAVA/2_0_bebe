import 'dart:async';

import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/doctor_confirmation_reject_screen.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';

import 'doctor_confirmation_accepted_screen.dart';

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
  State<NotificationDisplayScreen> createState() =>
      _NotificationDisplayScreenState();
}

class _NotificationDisplayScreenState extends State<NotificationDisplayScreen> {

  Timer? _timer;
  
@override
void initState() {
  super.initState();
  initNotificationListener();
  startTimeout();
}

void startTimeout() {
  _timer = Timer(const Duration(seconds: 30), () {
    if (mounted) {
      navigateToRejectScreen("Timpul a expirat. Medicul nu a răspuns.");
    }
  });
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
    _timer?.cancel(); 
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(pref_keys.notificationTitle, notification.title ?? 'Fără Titlu');
    await prefs.setString(pref_keys.notificationBody, notification.body ?? 'Fără corp');
    await prefs.setString(pref_keys.notificationData, notification.additionalData?.toString() ?? 'Fără date');

    handleNotification(notification);
  }

  @override
void dispose() {
  _timer?.cancel();
  super.dispose();
}


  void handleNotification(OSNotification notification) async {
    String? alertMessage = notification.body;
    if (alertMessage != null) {
      if (alertMessage.toLowerCase().contains('confirmare')) {
        navigateToConfirmScreen(notification.body);
      } else if (alertMessage.toLowerCase().contains('respingere')) {
        navigateToRejectScreen(notification.body);
      } else {

      }
    } else {

    }
  }

  void navigateToConfirmScreen(String? body) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NotificationContentScreen(
              body: body ?? "Fără conținut",
              pret: widget.pret,
              tipServiciu: widget.tipServiciu,
              contClientMobile: widget.contClientMobile,
              medicDetalii: widget.medicDetalii,
            ),
      ),
    );
  }

  void navigateToRejectScreen(String? body) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DoctorConfirmationReject(
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
        appBar: AppBar(
          title: const Text(
            'Raspunde doctorul',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
          foregroundColor: Colors.white,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: Text(
            'Astept raspunsul medicului...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}