import 'dart:async';
import 'package:flutter/material.dart';

class CountdownWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final VoidCallback onTimeout;

  const CountdownWrapper({
    Key? key,
    required this.child,
    this.duration = const Duration(minutes: 30),
    required this.onTimeout,
  }) : super(key: key);
//
  @override
  CountdownWrapperState createState() => CountdownWrapperState();
}

class CountdownWrapperState extends State<CountdownWrapper> {
  Timer? _timer;
  late int _secondsLeft;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.duration.inSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        if (mounted && ModalRoute.of(context)?.isCurrent == true) {
          widget.onTimeout();
        }
      } else {
        if (mounted) {
          setState(() {
            _secondsLeft--;
          });
        }
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Center(
            child:  Container(
              width: 150,
              height: 50,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Color(0xFFFFE4E3),
                  borderRadius: BorderRadius.circular(30)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                  height: 15,
                    width:  15,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30)
                    ),
                  ),
                  SizedBox(width: 5,) ,
                  Text(
                    '${_formatTime(_secondsLeft)}',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10,) ,
                  Image.asset('assets/images/sss.png',width: 30,)
                ],
              ),
            ),
          ),
        ),

      ],
    );
  }
}


// import 'dart:async';
// import 'package:flutter/material.dart';

// class CountdownWrapper extends StatefulWidget {
//   final Widget child;
//   final Duration duration;
//   final VoidCallback onTimeout;

//   const CountdownWrapper({
//     Key? key,
//     required this.child,
//     this.duration = const Duration(minutes: 20),
//     required this.onTimeout,
//   }) : super(key: key);

//   @override
//   _CountdownWrapperState createState() => _CountdownWrapperState();
// }

// class _CountdownWrapperState extends State<CountdownWrapper> {
//   Timer? _timer;
//   late int _secondsLeft;

//   @override
//   void initState() {
//     super.initState();
//     _secondsLeft = widget.duration.inSeconds;
//     _startTimer();
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_secondsLeft <= 1) {
//         timer.cancel();
//         // 🔐 Trigger timeout only if still on this route
//         if (mounted && ModalRoute.of(context)?.isCurrent == true) {
//           widget.onTimeout();
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             _secondsLeft--;
//           });
//         }
//       }
//     });
//   }

//   String _formatTime(int seconds) {
//     final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
//     final secs = (seconds % 60).toString().padLeft(2, '0');
//     return '$minutes:$secs';
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         widget.child,
//         Positioned(
//           bottom: 100,
//           left: 0,
//           right: 0,
//           child: Center(
//             child: Text(
//               'Time left: ${_formatTime(_secondsLeft)}',
//               style: TextStyle(
//                 color: Colors.redAccent,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }


