import 'package:flutter/material.dart';
import 'package:sos_bebe_app/confirmare_servicii_screen.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';

class NotificationContentScreen extends StatefulWidget {
  final String body;
  final String pret;
  final int tipServiciu;
  final ContClientMobile contClientMobile;
  final MedicMobile medicDetalii;

  const NotificationContentScreen({
    Key? key,
    required this.body,
    required this.pret,
    required this.tipServiciu,
    required this.contClientMobile,
    required this.medicDetalii,
  }) : super(key: key);

  @override
  State<NotificationContentScreen> createState() =>
      _NotificationContentScreenState();
}

class _NotificationContentScreenState extends State<NotificationContentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Confirmare',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10.0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.body,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ConfirmareServiciiScreen(
                          pret: widget.pret,
                          tipServiciu: widget.tipServiciu,
                          contClientMobile: widget.contClientMobile,
                          medicDetalii: widget.medicDetalii,
                        );
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(14, 190, 127, 1),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 24.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Efectuați plata',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
    );
  }
}
