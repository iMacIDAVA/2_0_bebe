// ignore_for_file: avoid_print
//import 'package:dental_care_app/screens/programari.dart';
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:flutter/material.dart';
//import '../main.dart';
import './shared_pref_keys.dart' as pref_keys;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveTokenToDB(String token) async {
  ApiCallFunctions apiCallFunctions = ApiCallFunctions();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(pref_keys.fcmToken, token);
  /*
  String? res = await apiCallFunctions.updateDeviceID(
    pAdresaEmail: prefs.getString(pref_keys.userEmail) ?? "User has not registered yet!",
    pFirebaseGoogleDeviceID: prefs.getString(pref_keys.fcmToken)!,
    pParolaMD5: prefs.getString(pref_keys.userPassMD5) ?? "User has not registered yet!",
    pPrimesteNotificari: prefs.getString(pref_keys.pPrimesteNotificari) ?? "0",
  );
  if (res == null) {
    print("Error: Could not save token!");
    return;
  } else if (res.startsWith('66')) {
    print("Error: Could not save token!");
    return;
  } else if (res.startsWith('13')) {
    print("Succes, token saved!");
    return;
  } else {
    print("Unkown error saving token!");
    return;
  }
  */
}


Future<void> handleBackgroundMessage(RemoteMessage? message) async {
  if (message == null) return;
  if (message.data['tip'] == '0') {
    /*
    navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) {
      //return ProgramariScreen(); //old Andrei Bădescu 
      return ProgramariScreen(fromLocatiiPage: false, fromOtherPage: true, currentIndex: 0, isSelectedTrecute: true, isSelectedViitoare: false,);
    }));
    */
  } 
  else 
  {
    
    print('alo?');

  }
}


class FirebaseApi {
  late Stream<String> _tokenStream;
  final firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    NotificationSettings settings = await firebaseMessaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      prefs.setString(pref_keys.pPrimesteNotificari, '1');
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      prefs.setString(pref_keys.pPrimesteNotificari, '0');

      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
      prefs.setString(pref_keys.pPrimesteNotificari, '0');
    }
    final fcmToken = await firebaseMessaging.getToken() ?? "Error: Could not retrieve token!";
    saveTokenToDB(fcmToken);
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen(saveTokenToDB);
    print('Token: $fcmToken');
    initPushNotifications();
  }

  Future initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleBackgroundMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}

// void _handleMessage(NotificationData notificationData) {
//   if (notificationData.tip == '0') {
//     navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) {
//       return ProgramariScreen();
//     }));
//   }
// }

// void handleMssg(RemoteMessage message) {
//   if (message.data['tip'] == '0') {
//     navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) {
//       return ProgramariScreen();
//     }));
//   } else
//     print('sui');
// }

// Updates the User's FCM Token in the DB



// Tried extracing data from notification, but it was not necessary, you can access them directly from message.data

// class NotificationData {
//   final String idDoctor;
//   final String idProgramare;
//   final String tip;
//   NotificationData({required this.idDoctor, required this.idProgramare, required this.tip});
// }

// // NotificationData extractNotificationData(RemoteMessage message) {
// //   NotificationData notificationData = NotificationData(
// //     idDoctor: message.data['idElementAsociat2'] ?? '',
// //     idProgramare: message.data['idElementAsociat'] ?? '',
// //     tip: message.data['tip'] ?? '',
// //   );
//   // print('idDoctor: ${notificationData.idDoctor}');
//   return notificationData;
//   // String notificationString = message.data.toString();
//   // // Regular expressions to match numbers after idElementAsociat and idElementAsociat2
//   // RegExp idElementAsociatRegExp = RegExp(r'idElementAsociat: (\d+)');
//   // RegExp idElementAsociat2RegExp = RegExp(r'idElementAsociat2: (\d+)');
//   // RegExp tipRegExp = RegExp(r'tip: (\d+)');
//   // // Extracting numbers using regular expressions
//   // String idElementAsociatMatch = idElementAsociatRegExp.firstMatch(notificationString)?.group(1) ?? '';
//   // String idElementAsociat2Match = idElementAsociat2RegExp.firstMatch(notificationString)?.group(1) ?? '';
//   // String tipRegExpMatch = tipRegExp.firstMatch(notificationString)?.group(1) ?? '';
//   // // Converting extracted strings to integers
//   // // int idElementAsociat = int.tryParse(idElementAsociatMatch) ?? 0;
//   // // int idElementAsociat2 = int.tryParse(idElementAsociat2Match) ?? 0;
//   // // Printing the extracted numbers
//   // print('idElementAsociat: $idElementAsociatMatch');
//   // print('idElementAsociat2: $idElementAsociat2Match');
//   // print('tip: $tipRegExpMatch');
// }



    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Got a message whilst in the foreground!');
    //   print('Message data: ${message.data}');
    //   if (message.notification != null) {
    //     print('Message also contained a notification: ${message.notification}');
    //   }
    // });


    // Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   print('Title: ${message.notification?.title}');
//   print('Body: ${message.notification?.body}');
//   print('Data: ${message.data}');
//   NotificationData notificationData = extractNotificationData(message);
//   _handleMessage(notificationData);
// }
