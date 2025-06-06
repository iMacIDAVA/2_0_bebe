// import 'dart:async';
//
// import 'package:agora_token_service/agora_token_service.dart';
// import 'package:flutter/material.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class VideoCallScreeen extends StatefulWidget {
//   final bool isDoctor;
//   final String channelName; // <-- Added channelName parameter
//
//   const VideoCallScreeen({
//     Key? key,
//     required this.isDoctor,
//     required this.channelName, // <-- Required in constructor
//   }) : super(key: key);
//
//   @override
//   State<VideoCallScreeen> createState() => _VideoCallScreeenState();
// }
//
// class _VideoCallScreeenState extends State<VideoCallScreeen> {
//   RtcEngine? _engine;
//   int? _remoteUid;
//   bool _localUserJoined = false;
//   String _statusMessage = "Initializing...";
//   bool isVideoEnabled = true;
//   bool isMicEnabled = true;
//   List<String> receivedFiles = [];
//   int receivedFilesCount = 0;
//   ValueNotifier<int> remainingTimeNotifier = ValueNotifier(900); // 15 minutes
//
//   // Static values for testing (except channelName)
//   static const appId = "da37c68ec4f64cd1af4093c758f20869";
//   // static const channelName = "test_room_123"; // <-- Removed static channelName
//   static const appCertificate = '69b34ac5d15044a7906063342cc15471';
//
//   bool _isTimeUp = false; // Track if time is up
//   Timer? _timer; // Timer for countdown
//
//
//
//   @override
//   void initState() {
//     super.initState();
//     print("TestVideoCallScreen initialized for channel: ${widget.channelName}");
//     initAgora();
//     _startTimer(); // Start the countdown timer
//   }
//
//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (remainingTimeNotifier.value > 0) {
//         remainingTimeNotifier.value -= 1;
//       } else {
//         setState(() {
//           _isTimeUp = true; // Keep this to update UI to show "END"
//         });
//         timer.cancel(); // Stop the timer
//         _handleTimeUp(); // Call custom method for time-up actions
//       }
//     });
//   }
//
//   void _handleTimeUp() {
//     // Your custom actions here. Examples:
//
//     // 1. Show a dialog
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Call Ended"),
//         content: const Text("The 15-minute call duration has ended."),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close dialog
//               _engine?.leaveChannel();
//               Navigator.of(context).pop(); // Exit call screen
//             },
//             child: const Text("OK"),
//           ),
//         ],
//       ),
//     );
//
//     // 2. Log a message (example)
//     print("Time's up for channel: ${widget.channelName}");
//
//     // 3. Optionally send a notification or API call
//     // Example: Send a message via Agora's signaling or your backend
//     // _engine?.sendMessage(...); // Add your logic here
//
//     // 4. Update UI or state
//     setState(() {
//       _statusMessage = "Call ended due to time limit";
//     });
//
//     // Add any other custom actions here
//   }
//
//   Future<void> initAgora() async {
//     try {
//       print("Requesting permissions...");
//       final status = await [Permission.microphone, Permission.camera].request();
//       print("Permission status: $status");
//
//       print("Creating Agora engine...");
//       _engine = createAgoraRtcEngine();
//
//       print("Initializing Agora engine...");
//       await _engine?.initialize(const RtcEngineContext(
//         appId: appId,
//         channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
//       ));
//
//       print("Setting up event handlers...");
//       _engine?.registerEventHandler(
//         RtcEngineEventHandler(
//           onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//             print("Local user joined successfully on channel: ${connection.channelId}");
//             setState(() {
//               _localUserJoined = true;
//               _statusMessage = "Connected to channel";
//             });
//           },
//           onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//             print("Remote user joined: $remoteUid on channel: ${connection.channelId}");
//             setState(() {
//               _remoteUid = remoteUid;
//               _statusMessage = "Remote user connected";
//             });
//           },
//           onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
//             print("Remote user left: $remoteUid from channel: ${connection.channelId}");
//             setState(() {
//               _remoteUid = null;
//               _statusMessage = "Remote user disconnected";
//             });
//           },
//           onError: (ErrorCodeType err, String msg) {
//             print("Agora error: $err, $msg");
//             setState(() {
//               _statusMessage = "Error: $msg";
//             });
//           },
//         ),
//       );
//
//       print("Enabling video...");
//       await _engine?.enableVideo();
//       await _engine?.startPreview();
//       await _engine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//
//       print("Generating token for channel: ${widget.channelName}...");
//       String token = RtcTokenBuilder.build(
//         appId: appId,
//         channelName: widget.channelName, // <-- Use widget.channelName
//         appCertificate: appCertificate,
//         uid: widget.isDoctor ? '2' : '1', // Consider making UIDs more dynamic or configurable
//         role: RtcRole.subscriber, // Consider if both users should be publishers
//         expireTimestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
//       );
//
//       print("Joining channel: ${widget.channelName}...");
//       await _engine?.joinChannel(
//         token: token,
//         channelId: widget.channelName, // <-- Use widget.channelName
//         uid: widget.isDoctor ? 2 : 1, // Ensure UIDs are unique within the channel
//         options: const ChannelMediaOptions(),
//       );
//     } catch (e) {
//       print("Error in initAgora: $e");
//       setState(() {
//         _statusMessage = "Error: $e";
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel(); // Cancel the timer to prevent memory leaks
//     remainingTimeNotifier.dispose();
//     _engine?.leaveChannel();
//     _engine?.release();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Scaffold(
//         body: Stack(
//           children: [
//             Center(
//               child: _remoteVideo(),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(right: 18.0, top: 48.0),
//               child: Align(
//                 alignment: Alignment.topRight,
//                 child: SizedBox(
//                   width: 100,
//                   height: 150,
//                   child: Center(
//                     child: _localUserJoined
//                         ? _engine != null
//                         ? AgoraVideoView(
//                       controller: VideoViewController(
//                         rtcEngine: _engine!,
//                         canvas: const VideoCanvas(uid: 0), // 0 for local view
//                       ),
//                     )
//                         : const CircularProgressIndicator()
//                         : const CircularProgressIndicator(),
//                   ),
//                 ),
//               ),
//             ),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 480), // Consider making this responsive
//                 Container(
//                   width: 130,
//                   height: 45,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.white,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(5),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.red.withOpacity(0.3),
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 2, horizontal: 2),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               AnimatedContainer(
//                                 duration: const Duration(milliseconds: 500),
//                                 width: 10,
//                                 height: 10,
//                                 decoration: const BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.red,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               ValueListenableBuilder<int>(
//                                 valueListenable: remainingTimeNotifier,
//                                 builder: (context, remainingTime, _) {
//                                   return Text(
//                                     "${remainingTime ~/ 60}:${(remainingTime % 60).toString().padLeft(2, '0')}",
//                                     style: const TextStyle(
//                                       color: Colors.red,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   );
//                                 },
//                               ),
//                               const SizedBox(width: 8),
//                               const Icon(
//                                 Icons.timer,
//                                 color: Colors.red,
//                                 size: 20,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 15), // Added some spacing
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     // Video On/Off Button
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           isVideoEnabled = !isVideoEnabled;
//                           if (_engine != null) {
//                             if (isVideoEnabled) {
//                               _engine!.enableVideo();
//                             } else {
//                               _engine!.disableVideo();
//                             }
//                           }
//                         });
//                       },
//                       child: Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.grey.withOpacity(0.3),
//                         ),
//                         child: Icon(
//                           isVideoEnabled ? Icons.videocam : Icons.videocam_off,
//                           color: Colors.white,
//                           size: 30,
//                         ),
//                       ),
//                     ),
//                     // Microphone On/Off Button
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           isMicEnabled = !isMicEnabled;
//                           if (_engine != null) {
//                             if (isMicEnabled) {
//                               _engine!.enableLocalAudio(true);
//                             } else {
//                               _engine!.enableLocalAudio(false);
//                             }
//                           }
//                         });
//                       },
//                       child: Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.grey.withOpacity(0.3),
//                         ),
//                         child: Icon(
//                           isMicEnabled ? Icons.mic : Icons.mic_off,
//                           color: Colors.white,
//                           size: 30,
//                         ),
//                       ),
//                     ),
//                     // End Call Button
//                     GestureDetector(
//                       onTap: () {
//                         _engine?.leaveChannel();
//                         // _engine?.release(); // Consider delaying release if you might rejoin quickly or handle errors
//                         Navigator.of(context).pop();
//                       },
//                       child: Container(
//                         width: 70,
//                         height: 70,
//                         decoration: const BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.red,
//                         ),
//                         child: const Icon(
//                           Icons.call_end,
//                           color: Colors.white,
//                           size: 30,
//                         ),
//                       ),
//                     ),
//                     // Switch Camera Button
//                     GestureDetector(
//                       onTap: () async {
//                         await _engine?.switchCamera();
//                       },
//                       child: Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.grey.withOpacity(0.3),
//                         ),
//                         child: const Icon(
//                           Icons.cameraswitch,
//                           color: Colors.white,
//                           size: 30,
//                         ),
//                       ),
//                     ),
//                     // Chat Button
//                     GestureDetector(
//                       onTap: () {
//                         // Implement chat functionality
//                         print("Chat button tapped. Channel: ${widget.channelName}");
//                       },
//                       child: Stack(
//                         children: [
//                           Container(
//                             width: 50,
//                             height: 50,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.grey.withOpacity(0.3),
//                             ),
//                             child: const Icon(
//                               Icons.chat,
//                               color: Colors.white,
//                               size: 30,
//                             ),
//                           ),
//                           if (receivedFilesCount > 0)
//                             Positioned(
//                               right: 0,
//                               top: 0,
//                               child: Container(
//                                 padding: const EdgeInsets.all(6),
//                                 decoration: const BoxDecoration(
//                                   color: Colors.red,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Text(
//                                   "$receivedFilesCount",
//                                   style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   'Glisați în sus pentru a afișa chatul', // "Swipe up to show chat"
//                   style: TextStyle(color: Colors.grey),
//                 ),
//                 const SizedBox(height: 20), // Ensure controls are not too close to the bottom
//               ],
//             ),
//             // Status Message Overlay (Optional)
//             // Positioned(
//             //   top: 100,
//             //   left: 20,
//             //   right: 20,
//             //   child: Container(
//             //     padding: EdgeInsets.all(8),
//             //     color: Colors.black54,
//             //     child: Text(
//             //       _statusMessage,
//             //       style: TextStyle(color: Colors.white),
//             //       textAlign: TextAlign.center,
//             //     ),
//             //   ),
//             // )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _remoteVideo() {
//     if (_remoteUid != null && _engine != null) { // Added _engine null check
//       return AgoraVideoView(
//         controller: VideoViewController.remote(
//           rtcEngine: _engine!,
//           canvas: VideoCanvas(uid: _remoteUid),
//           connection: RtcConnection(channelId: widget.channelName), // <-- Use widget.channelName
//         ),
//       );
//     } else {
//       String waitingMessage = widget.isDoctor
//           ? "Așteptați pacientul să se conecteze..." // "Waiting for the patient to connect..."
//           : "Vă rugăm așteptați după doctor să intre!"; // "Please wait for the doctor to join!"
//       if (!_localUserJoined) {
//         waitingMessage = "Conectare la canal..."; // "Connecting to channel..."
//       } else if (_statusMessage.isNotEmpty && _statusMessage != "Connected to channel" && _statusMessage != "Remote user connected") {
//         waitingMessage = _statusMessage;
//       }
//
//       return Text(
//         waitingMessage,
//         textAlign: TextAlign.center,
//         style: const TextStyle(fontSize: 16),
//       );
//     }
//   }
// }
//
//
//
//


///
import 'dart:async';

import 'package:agora_token_service/agora_token_service.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallScreeen extends StatefulWidget {
  final bool isDoctor;
  final String channelName;

  const VideoCallScreeen({
    Key? key,
    required this.isDoctor,
    required this.channelName,
  }) : super(key: key);

  @override
  State<VideoCallScreeen> createState() => _VideoCallScreeenState();
}

class _VideoCallScreeenState extends State<VideoCallScreeen> {
  RtcEngine? _engine;
  int? _remoteUid;
  bool _localUserJoined = false;
  String _statusMessage = "Initializing...";
  bool isVideoEnabled = true;
  bool isMicEnabled = true;
  List<String> receivedFiles = [];
  int receivedFilesCount = 0;
  ValueNotifier<int> remainingTimeNotifier = ValueNotifier(900); // 15 minutes
  bool _isTimeUp = false;
  Timer? _timer;

  static const appId = "da37c68ec4f64cd1af4093c758f20869";
  static const appCertificate = '69b34ac5d15044a7906063342cc15471';

  @override
  void initState() {
    super.initState();
    print("TestVideoCallScreen initialized for channel: ${widget.channelName}");
    initAgora();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTimeNotifier.value > 0) {
        remainingTimeNotifier.value -= 1;
      } else {
        setState(() {
          _isTimeUp = true;
        });
        timer.cancel();
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Call Ended"),
        content: const Text("The 15-minute call duration has ended."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _engine?.leaveChannel();
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );

    print("Time's up for channel: ${widget.channelName}");

    setState(() {
      _statusMessage = "Call ended due to time limit";
    });
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
            print("Local user joined successfully on channel: ${connection.channelId}");
            setState(() {
              _localUserJoined = true;
              _statusMessage = "Connected to channel";
            });
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            print("Remote user joined: $remoteUid on channel: ${connection.channelId}");
            setState(() {
              _remoteUid = remoteUid;
              _statusMessage = "Remote user connected";
            });
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            print("Remote user left: $remoteUid from channel: ${connection.channelId}");
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
          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
            print("⚠️ Token is about to expire for channel: ${connection.channelId}");
            // Here you can fetch a new token and call renewToken(token)
          },
        ),
      );

      print("Enabling video...");
      await _engine?.enableVideo();
      await _engine?.startPreview();
      await _engine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      final expireSeconds = 900; // 15 minutes
      final expireTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000 + expireSeconds;

      print("Generating token for channel: ${widget.channelName}...");
      String token = RtcTokenBuilder.build(
        appId: appId,
        channelName: widget.channelName,
        appCertificate: appCertificate,
        uid: widget.isDoctor ? '2' : '1',
        role: RtcRole.subscriber,
        expireTimestamp: expireTimestamp,
      );

      print("Joining channel: ${widget.channelName}...");
      await _engine?.joinChannel(
        token: token,
        channelId: widget.channelName,
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
    _timer?.cancel();
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
            Center(child: _remoteVideo()),
            Padding(
              padding: const EdgeInsets.only(right: 18.0, top: 48.0),
              child: Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: 100,
                  height: 150,
                  child: Center(
                    child: _localUserJoined && _engine != null
                        ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _engine!,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    )
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
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
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
                              const Icon(Icons.timer, color: Colors.red, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isVideoEnabled = !isVideoEnabled;
                          if (_engine != null) {
                            isVideoEnabled ? _engine!.enableVideo() : _engine!.disableVideo();
                          }
                        });
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        radius: 25,
                        child: Icon(
                          isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isMicEnabled = !isMicEnabled;
                          if (_engine != null) {
                            _engine!.enableLocalAudio(isMicEnabled);
                          }
                        });
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        radius: 25,
                        child: Icon(
                          isMicEnabled ? Icons.mic : Icons.mic_off,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        try {
                          _engine?.leaveChannel();
                          Navigator.of(context).pop();
                        }
                        catch(e){
                          print("error while ending hte call $e");

                        }

                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 35,
                        child: Icon(Icons.call_end, color: Colors.white, size: 30),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await _engine?.switchCamera();
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        radius: 25,
                        child: const Icon(Icons.cameraswitch, color: Colors.white, size: 30),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("Chat button tapped. Channel: ${widget.channelName}");
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            radius: 25,
                            child: const Icon(Icons.chat, color: Colors.white, size: 30),
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
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null && _engine != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      String waitingMessage = widget.isDoctor
          ? "Așteptați pacientul să se conecteze..."
          : "Vă rugăm așteptați după doctor să intre!";
      if (!_localUserJoined) {
        waitingMessage = "Conectare la canal...";
      } else if (_statusMessage.isNotEmpty && _statusMessage != "Connected to channel" && _statusMessage != "Remote user connected") {
        waitingMessage = _statusMessage;
      }

      return Text(
        waitingMessage,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      );
    }
  }
}
