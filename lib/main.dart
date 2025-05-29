import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sos_bebe_app/firebase_options.dart';
import 'package:sos_bebe_app/fixing/chat.dart';
import 'package:sos_bebe_app/fixing/screens/consultation_screnn.dart';
import 'package:sos_bebe_app/intro_screen.dart';
import 'package:sos_bebe_app/localizations/1_localizations.dart';
import 'package:sos_bebe_app/utils/consts.dart';

import 'fixing/TestVideoCallScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init(
        (options) {
      options.dsn = 'https://f678d0ec64eaef6a2fdae1243cb3f676@o4509014972366848.ingest.de.sentry.io/4509015011885136';
      options.tracesSampleRate = 1.0;
      options.debug = true;
      options.sendDefaultPii = true;
    },
    appRunner: () async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize("bf049046-edaf-41f1-bb07-e2ac883af161");
      OneSignal.Notifications.requestPermission(true);

      Future<void> setupStripe() async {
        Stripe.publishableKey = stripePublishableKey;
      }

      await setupStripe();

      runApp(const MyApp());
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'SOS Bebe',
      locale: const Locale('ro', 'RO'),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        LocalizationsApp.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ro', 'RO'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //home: const IntroScreen(), //
      home:ConsultationScreen(patientId:1) // const IntroScreen(), //
    );
  }
}

//
// import 'package:flutter/material.dart';
// import 'package:agora_rtm/agora_rtm.dart';
//
// import 'fixing/chat.dart';
//
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: ChatHomeScreen(),
//     );
//   }
// }
//
// class ChatHomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chat Test'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>  ChatScreen(isDoctor: true),
//                   ),
//                 );
//               },
//               child: const Text('Join Chat as Doctor'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>  ChatScreen(isDoctor: false),
//                   ),
//                 );
//               },
//               child: const Text('Join Chat as Patient'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

