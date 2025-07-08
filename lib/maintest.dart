// // lib/screens/video_call_screen.dart
//
// import 'package:flutter/material.dart';
// import '../services/video_call_service.dart';
// import '../config/api_config.dart';
//
// class VideoCallScreen extends StatefulWidget {
//   final int sessionId;
//   final String patientName;
//   final String doctorName;
//
//   const VideoCallScreen({
//     Key? key,
//     required this.sessionId,
//     required this.patientName,
//     required this.doctorName,
//   }) : super(key: key);
//
//   @override
//   State<VideoCallScreen> createState() => _VideoCallScreenState();
// }
//
// class _VideoCallScreenState extends State<VideoCallScreen> {
//   final _videoCallService = VideoCallService();
//   bool _isLoading = false;
//   bool _isCallActive = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeCall();
//   }
//
//   Future<void> _initializeCall() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       await _videoCallService.startCall(widget.sessionId);
//       setState(() {
//         _isCallActive = true;
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error starting call: ${e.toString()}')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _endCall() async {
//     // Show confirmation dialog
//     final shouldEnd = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('End Call'),
//         content: const Text('Are you sure you want to end this call?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('End Call'),
//           ),
//         ],
//       ),
//     );
//
//     if (shouldEnd != true) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       await _videoCallService.endCall(widget.sessionId);
//
//       if (mounted) {
//         // Show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Call ended successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//
//         // Navigate back or to a specific screen
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       if (mounted) {
//         // Show error message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error ending call: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Video Call'),
//         actions: [
//           // End call button
//           IconButton(
//             icon: const Icon(Icons.call_end),
//             color: Colors.red,
//             onPressed: _isLoading ? null : _endCall,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//         children: [
//           // Call status header
//           Container(
//             padding: const EdgeInsets.all(16),
//             color: Colors.grey[200],
//             child: Row(
//               children: [
//                 const Icon(Icons.person),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Call with ${widget.doctorName}',
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//               ],
//             ),
//           ),
//
//           // Video call UI
//           Expanded(
//             child: Stack(
//               children: [
//                 // Remote video (full screen)
//                 Center(
//                   child: _isCallActive
//                       ? const Text('Remote Video Stream')
//                       : const Text('Connecting...'),
//                 ),
//
//                 // Local video (small overlay)
//                 Positioned(
//                   right: 16,
//                   bottom: 16,
//                   width: 120,
//                   height: 160,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.black,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'Local Video',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 // Call controls
//                 Positioned(
//                   left: 0,
//                   right: 0,
//                   bottom: 0,
//                   child: Container(
//                     padding: const EdgeInsets.all(16),
//                     color: Colors.black54,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         // Mute button
//                         IconButton(
//                           icon: const Icon(Icons.mic),
//                           color: Colors.white,
//                           onPressed: () {
//                             // Implement mute functionality
//                           },
//                         ),
//                         // Camera toggle button
//                         IconButton(
//                           icon: const Icon(Icons.videocam),
//                           color: Colors.white,
//                           onPressed: () {
//                             // Implement camera toggle
//                           },
//                         ),
//                         // End call button
//                         IconButton(
//                           icon: const Icon(Icons.call_end),
//                           color: Colors.red,
//                           onPressed: _isLoading ? null : _endCall,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }