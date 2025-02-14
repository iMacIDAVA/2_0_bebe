import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
//import 'package:agora_uikit/agora_uikit.dart';
//import 'package:auto_size_text/auto_size_text.dart';
//import 'package:sos_bebe_profil_bebe_doctor/raspunde_intrebare_screen.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'package:device_info_plus/device_info_plus.dart';
import 'package:sos_bebe_app/raspunde_intrebare_medic_screen.dart';
import 'package:agora_token_service/agora_token_service.dart';

import 'package:sos_bebe_app/localizations/1_localizations.dart';
import 'package:sos_bebe_app/testimonial_screen.dart';
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';
import 'package:sos_bebe_app/vezi_toti_medicii_screen.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;

import 'package:path/path.dart' as path;

import 'package:http/http.dart' as http;

const appId = "da37c68ec4f64cd1af4093c758f20869";
//appId: 'a6810f83c0c549aab473207134b69489',
const appCertificate = '69b34ac5d15044a7906063342cc15471';
//const channelName =  "TestIGV_1";
const channelName = "TestChannelIGV_1";

const role = RtcRole.subscriber;

const expirationInSeconds = 86400;

final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
final expireTimestamp = currentTimestamp + expirationInSeconds;

//const token = '007eJxTYNjEWLn2xZZnXDv2ON9yF7NNF5oRcX7WwSVmC2fZ127pVu1XYEhJNDZPNrNITTZJMzNJTjFMTDMxsDRONje1SDMysDCzdF1xJLUhkJEhWVCBgREKQXxOhpDU4hJP97B4QwYGAAa3IGo=';

/*      username: "4",
      uid: 4,
*/
//const username = "pacient1";
//const uid = 10;

/*
const role = RtcRole.publisher;

const expirationInSeconds = 1000000;

final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
final expireTimestamp = currentTimestamp + expirationInSeconds;

final token = RtcTokenBuilder.build(
        appId: appId,
        channelName: channel,
        appCertificate: appCertificate,
        uid: 'doctor1',
        role: role,
        expireTimestamp: expireTimestamp,

);
*/

class ApelVideoPacientScreen extends StatefulWidget {
  final MedicMobile medic;
  final ContClientMobile contClientMobile;

  const ApelVideoPacientScreen(
      {Key? key, required this.medic, required this.contClientMobile})
      : super(key: key);

  @override
  State<ApelVideoPacientScreen> createState() => _ApelVideoPacientScreenState();
}

class _ApelVideoPacientScreenState extends State<ApelVideoPacientScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  RtcEngine? _engine;

  String token = '';

  final Stopwatch _stopwatch = Stopwatch();

  final ApiCallFunctions apiCallFunctions = ApiCallFunctions();

  bool isVideoEnabled = true;
  bool isMicEnabled = true;

  late Timer _timer;
  String _result = '15:00';

  int remainingTime = 180;
  Timer? countdownTimer;

  ValueNotifier<int> remainingTimeNotifier = ValueNotifier(900);

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (remainingTimeNotifier.value > 0) {
        remainingTimeNotifier.value--;
      } else {
        timer.cancel();
        _stopTimer();
        if (_engine != null) {
          await _engine!.leaveChannel();
          await _engine!.release();
        }
        // Add your shared preferences and logic
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Call the `notificaDoctor` method
        await notificaDoctor();

        // Navigate to the `VeziTotiMediciiScreen`
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => VeziTotiMediciiScreen(
        //       listaMedici: listaMedici,
        //       contClientMobile: resGetCont!,
        //     ),
        //   ),
        // );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TestimonialScreen(
              factura: facturaSelectata!,
              idFactura: facturaSelectata?.id ?? 0,
              idMedic: facturaSelectata?.idMedic ?? 0,
            ),
          ),
        );

        dispose(); // Close the connection
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        int remainingSeconds = (15 * 60) - _stopwatch.elapsed.inSeconds;

        if (remainingSeconds >= 0) {
          // ✅ Ensure it reaches 00:00
          int minutes = remainingSeconds ~/ 60;
          int seconds = remainingSeconds % 60;
          _result =
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        } else {
          _result = "00:00";
          _stopTimer();
        }
      });
    });

    _stopwatch.start();
  }

  void _stopTimer() {
    _timer.cancel();
    _stopwatch.stop();
  }

  Timer? _messageUpdateTimer; // ✅ Declare this at the top

  int minute = 15;
  int secunde = 0;

  void _start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        int remainingSeconds = (15 * 60) - _stopwatch.elapsed.inSeconds;

        if (remainingSeconds > 0) {
          int minutes = remainingSeconds ~/ 60;
          int seconds = remainingSeconds % 60;
          _result =
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        } else {
          _result = "00:00";
          _stop(); // Stop the timer when it reaches zero
        }
      });
    });

    _stopwatch.start();
  }

  void _stop() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    _stopwatch.stop();
  }

  List<String> receivedFiles = [];
  int receivedFilesCount = 0;

  @override
  void initState() {
    super.initState();
    getUser();

    startTimer();

    isVideoEnabled = true;
    isMicEnabled = true;

    token = RtcTokenBuilder.build(
      appId: appId,
      channelName: channelName,
      appCertificate: appCertificate,
      uid: '0',
      role: role,
      expireTimestamp: expireTimestamp,
    );

    _fetchMessages(); // Fetch messages immediately when the screen loads

    // 🔴 Add this to check for new messages every 5 seconds
    _messageUpdateTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => _fetchMessages(),
    );

    initAgora();
  }

  Future<void> notificaDoctor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
    apiCallFunctions.anuntaMedicDeServiciuTerminat(
        pUser: user,
        pParola: userPassMD5,
        pIdMedic: widget.medic.id.toString(),
        tipPlata: '2');
  }

  Future<void> initAgora() async {
    String token = RtcTokenBuilder.build(
      appId: appId,
      channelName: channelName,
      appCertificate: appCertificate,
      uid: '1',
      role: role,
      expireTimestamp: expireTimestamp,
    );
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine?.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine?.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) async {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });

          SharedPreferences prefs = await SharedPreferences.getInstance();
          String user = prefs.getString('user') ?? '';
          String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

          // Call the `notificaDoctor` method
          await notificaDoctor();

          // Navigate to the `VeziTotiMediciiScreen`
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => VeziTotiMediciiScreen(
          //       listaMedici: listaMedici,
          //       contClientMobile: resGetCont!,
          //     ),
          //   ),
          // );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TestimonialScreen(
                factura: facturaSelectata!,
                idFactura: facturaSelectata?.id ?? 0,
                idMedic: facturaSelectata?.idMedic ?? 0,
              ),
            ),
          );
        },
        onTokenPrivilegeWillExpire:
            (RtcConnection connection, String token) async {
          try {
            token = RtcTokenBuilder.build(
              appId: appId,
              channelName: channelName,
              appCertificate: appCertificate,
              uid: 'pacient1',
              role: role,
              expireTimestamp: expireTimestamp,
            );
            await _engine?.renewToken(token);
          } catch (e) {
            debugPrint("Token renewal failed: $e");

            // Add your shared preferences and logic
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String user = prefs.getString('user') ?? '';
            String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

            // Call the `notificaDoctor` method
            await notificaDoctor();

            // Navigate to the `VeziTotiMediciiScreen`
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => VeziTotiMediciiScreen(
            //       listaMedici: listaMedici,
            //       contClientMobile: resGetCont!,
            //     ),
            //   ),
            // );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TestimonialScreen(
                  factura: facturaSelectata!,
                  idFactura: facturaSelectata?.id ?? 0,
                  idMedic: facturaSelectata?.idMedic ?? 0,
                ),
              ),
            );
          }
        },
      ),
    );

    await _engine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine?.enableVideo();
    await _engine?.startPreview();

    await _engine?.joinChannel(
      token: token,
      channelId: channelName,
      uid: 1,
      options: const ChannelMediaOptions(),
    );
  }

  List<MedicMobile> listaMedici = [];
  ContClientMobile? resGetCont;

  @override
  void dispose() {
    _stop();
    _stopTimer();
    remainingTimeNotifier.dispose();
    _messageUpdateTimer?.cancel();

    super.dispose();

    _dispose();
  }

  Future<void> _dispose() async {
    if (_engine != null) {
      await _engine!.leaveChannel();
      await _engine!.release();
    }
  }

  void _downloadAndOpenFile(String url) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(url);
    final filePath = path.join(directory.path, fileName);

    if (await File(filePath).exists()) {
      OpenFilex.open(
          filePath); // ✅ Open existing file instead of re-downloading
      return;
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      OpenFilex.open(filePath);
    } else {
      print("❌ Download failed: ${response.statusCode}");
    }
  }

  void _showReceivedFiles() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text("Fișiere primite",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: receivedFiles.length,
                  itemBuilder: (context, index) {
                    final fileUrl = receivedFiles[index];
                    return GestureDetector(
                      onTap: () => _downloadAndOpenFile(fileUrl),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Center(
                          child: fileUrl.endsWith('.jpg') ||
                                  fileUrl.endsWith('.png')
                              ? Image.network(fileUrl, fit: BoxFit.cover)
                              : const Icon(Icons.insert_drive_file,
                                  size: 40, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _fetchMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    try {
      final newMessages = await apiCallFunctions.getListaMesajePeConversatie(
            pUser: user,
            pParola: userPassMD5,
            pIdConversatie: widget.medic.id.toString(),
          ) ??
          [];

      List<String> newFiles = [];

      for (var message in newMessages) {
        String text = message.comentariu.trim();
        if (text.startsWith("http") && !receivedFiles.contains(text)) {
          newFiles.add(text);
        }
      }

      if (mounted && newFiles.isNotEmpty) {
        setState(() {
          receivedFiles.addAll(newFiles);
          receivedFilesCount = receivedFiles.length;
        });
      }
    } catch (error) {
      print("Error fetching messages: $error");
    }
  }

  FacturaClientMobile? facturaSelectata;

  Future<FacturaClientMobile?> getDetaliiFactura(int idFactura) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    facturaSelectata = await apiCallFunctions.getDetaliiFactura(
      pUser: user,
      pParola: userPassMD5,
      pIdFactura: idFactura.toString(),
    );

    return facturaSelectata;
  }

  String user = '';
  void getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    user = prefs.getString('user') ?? '';
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
            //title: const Text('Agora Video Call'),
            ),
        body: Stack(
          children: [
            Center(
              child: _remoteVideo(),
              // child: Text('ss'),
            ),
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 100,
                height: 150,
                child: Center(
                  child: _localUserJoined
                      ? _engine != null
                          ? AgoraVideoView(
                              controller: VideoViewController(
                                rtcEngine: _engine!,
                                canvas: const VideoCanvas(uid: 0),
                              ),
                            )
                          : const CircularProgressIndicator()
                      : const CircularProgressIndicator(),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 480),
                Container(
                  width: 130,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        width: 25,
                        height: 17,
                        "./assets/images/cerc_apel_video.png",
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 2),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Video On/Off Button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isVideoEnabled = !isVideoEnabled;
                          if (_engine != null) {
                            if (isVideoEnabled) {
                              _engine!.enableVideo();
                            } else {
                              _engine!.disableVideo();
                            }
                          }
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        child: Icon(
                          isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    // Microphone On/Off Button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isMicEnabled = !isMicEnabled;
                          if (_engine != null) {
                            if (isMicEnabled) {
                              _engine!.enableLocalAudio(true);
                            } else {
                              _engine!.enableLocalAudio(false);
                            }
                          }
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        child: Icon(
                          isMicEnabled ? Icons.mic : Icons.mic_off,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    // End Call Button
                    GestureDetector(
                      onTap: () async {
                        _stopTimer();
                        if (_engine != null) {
                          await _engine!.leaveChannel();
                          await _engine!.release();
                        }
                        // Add your shared preferences and logic
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                        // Call the `notificaDoctor` method
                        await notificaDoctor();

                        // Navigate to the `VeziTotiMediciiScreen`
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => VeziTotiMediciiScreen(
                        //       listaMedici: listaMedici,
                        //       contClientMobile: resGetCont!,
                        //     ),
                        //   ),
                        // );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestimonialScreen(
                              factura: facturaSelectata!,
                              idFactura: facturaSelectata?.id ?? 0,
                              idMedic: facturaSelectata?.idMedic ?? 0,
                            ),
                          ),
                        );

                        dispose(); // Close the connection
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Center(
                          child: Image.asset(
                            './assets/images/inchide_apel_icon.png',
                            width: 80,
                            height: 80,
                          ),
                        ),
                      ),
                    ),
                    // Switch Camera Button
                    GestureDetector(
                      onTap: () async {
                        await _engine?.switchCamera();
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        child: const Icon(
                          Icons.cameraswitch,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    // Chat Button
                    GestureDetector(
                      onTap: () => _showReceivedFiles(),
                      child: Stack(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            child: const Icon(
                              Icons.chat,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          if (receivedFilesCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "$receivedFilesCount",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Glisați în sus pentru a afișa chatul',
                  style: TextStyle(color: Colors.grey),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     IconButton(
                //       onPressed: () async {
                //         // Add your shared preferences and logic
                //         SharedPreferences prefs =
                //             await SharedPreferences.getInstance();
                //         String user = prefs.getString('user') ?? '';
                //         String userPassMD5 =
                //             prefs.getString(pref_keys.userPassMD5) ?? '';
                //
                //         // Call the `notificaDoctor` method
                //         // await notificaDoctor();
                //
                //         // Navigate to the `VeziTotiMediciiScreen`
                //         Navigator.pushReplacement(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => VeziTotiMediciiScreen(
                //               listaMedici: listaMedici,
                //               contClientMobile: resGetCont!,
                //             ),
                //           ),
                //         );
                //
                //         dispose(); // Close the connection
                //       },
                //       icon: Image.asset(
                //           width: 80,
                //           height: 80,
                //           './assets/images/inchide_apel_icon.png'),
                //     ),
                //     IconButton(
                //       onPressed: () async {
                //         await _engine?.switchCamera();
                //       },
                //       icon: Image.asset(
                //           width: 50,
                //           height: 50,
                //           './assets/images/switch_camera_icon.png'),
                //     ),
                //   ],
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    if (_remoteUid != null) {
      _start();
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: channelName),
        ),
      );
    } else {
      return Text(
        //'Vă rugăm așteptați după doctor să intre!', //old IGV
        l.apelVideoPacientVaRugamAsteptati,
        textAlign: TextAlign.center,
      );
    }
  }
}
