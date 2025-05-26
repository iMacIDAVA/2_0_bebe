/// test for vido call between dr and paient

import 'package:agora_token_service/agora_token_service.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TestVideoCallHome(),
    );
  }
}

class TestVideoCallHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call Testccc'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                print("Doctor button pressed");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TestVideoCallScreen(isDoctor: true),
                  ),
                );
              },
              child: const Text('Start Test Call (Doctor)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print("Patient button pressed");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TestVideoCallScreen(isDoctor: false),
                  ),
                );
              },
              child: const Text('Start Test Call (Patient)'),
            ),
            const SizedBox(height: 30,) ,
            // In your TestVideoCallScreen




          ],
        ),
      ),
    );
  }
}

class TestVideoCallScreen extends StatefulWidget {
  final bool isDoctor;

  const TestVideoCallScreen({Key? key, required this.isDoctor}) : super(key: key);

  @override
  State<TestVideoCallScreen> createState() => _TestVideoCallScreenState();
}

class _TestVideoCallScreenState extends State<TestVideoCallScreen> {
  RtcEngine? _engine;
  int? _remoteUid;
  bool _localUserJoined = false;
  String _statusMessage = "Initializing...";
  bool isVideoEnabled = true;
  bool isMicEnabled = true;
  List<String> receivedFiles = [];
  int receivedFilesCount = 0;
  ValueNotifier<int> remainingTimeNotifier = ValueNotifier(900); // 15 minutes

  // Static values for testing
  static const appId = "da37c68ec4f64cd1af4093c758f20869";
  static const channelName = "test_room_123";
  static const appCertificate = '69b34ac5d15044a7906063342cc15471';

  @override
  void initState() {
    super.initState();
    print("TestVideoCallScreen initialized");
    initAgora();
  }

  Future<void> initAgora() async {
    try {
      print("Requesting permissions...");
      final status = await [Permission.microphone, Permission.camera].request();
      print("Permission status: $status");

      print("Creating Agora engine...");
      _engine = createAgoraRtcEngine();

      print("Initializing Agora engine...");
      await _engine?.initialize(const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      print("Setting up event handlers...");
      _engine?.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print("Local user joined successfully");
            setState(() {
              _localUserJoined = true;
              _statusMessage = "Connected to channel";
            });
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            print("Remote user joined: $remoteUid");
            setState(() {
              _remoteUid = remoteUid;
              _statusMessage = "Remote user connected";
            });
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            print("Remote user left: $remoteUid");
            setState(() {
              _remoteUid = null;
              _statusMessage = "Remote user disconnected";
            });
          },
          onError: (ErrorCodeType err, String msg) {
            print("Agora error: $err, $msg");
            setState(() {
              _statusMessage = "Error: $msg";
            });
          },
        ),
      );

      print("Enabling video...");
      await _engine?.enableVideo();
      await _engine?.startPreview();
      await _engine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      print("Generating token...");
      String token = RtcTokenBuilder.build(
        appId: appId,
        channelName: channelName,
        appCertificate: appCertificate,
        uid: widget.isDoctor ? '2' : '1',
        role: RtcRole.subscriber,
        expireTimestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
      );

      print("Joining channel...");
      await _engine?.joinChannel(
        token: token,
        channelId: channelName,
        uid: widget.isDoctor ? 2 : 1,
        options: const ChannelMediaOptions(),
      );
    } catch (e) {
      print("Error in initAgora: $e");
      setState(() {
        _statusMessage = "Error: $e";
      });
    }
  }

  @override
  void dispose() {
    remainingTimeNotifier.dispose();
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: _remoteVideo(),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 18.0, top: 48.0),
              child: Align(
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
                      Padding(
                        padding: const EdgeInsets.all(5),
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
                                    "${remainingTime ~/ 60}:${(remainingTime % 60).toString().padLeft(2, '0')}",
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
                      onTap: () {
                        _engine?.leaveChannel();
                        _engine?.release();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: const Icon(
                          Icons.call_end,
                          color: Colors.white,
                          size: 30,
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
                      onTap: () {
                        // Implement chat functionality
                      },
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: channelName),
        ),
      );
    } else {
      return const Text(
        'Vă rugăm așteptați după doctor să intre!',
        textAlign: TextAlign.center,
      );
    }
  }
}