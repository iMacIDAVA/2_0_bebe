import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/chat_screen.dart/chat_bubble.dart';
import 'package:sos_bebe_app/chat_screen.dart/chat_textfield.dart';
import 'package:sos_bebe_app/confirmare_servicii_screen.dart';
import 'package:sos_bebe_app/factura_screen.dart';
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;
import 'package:path/path.dart' as path;

class ChatScreenPage extends StatefulWidget {
  final MedicMobile medic;
  final ContClientMobile contClientMobile;
  final int tipServiciu;
  final String pret;
  final bool chatOnly;

  const ChatScreenPage({
    super.key,
    required this.medic,
    required this.contClientMobile,
    required this.pret,
    required this.tipServiciu,
    required this.chatOnly,
  });

  @override
  State<ChatScreenPage> createState() => _ChatScreenPageState();
}

class _ChatScreenPageState extends State<ChatScreenPage> {
  bool isFirstEnterPage = true;
  final ScrollController _controller = ScrollController();
  final ValueNotifier<bool> aRaspunsDoctorulNotifier = ValueNotifier(false);

  final TextEditingController _messageController = TextEditingController();
  List<ConversatieMobile> listaConversatii = [];
  ApiCallFunctions apiCallFunctions = ApiCallFunctions();
  List<MesajConversatieMobile> mesajeConversatie = [];
  Timer? _messageUpdateTimer;

  Future<void> _fetchMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    final newMessages = await apiCallFunctions.getListaMesajePeConversatie(
          pUser: user,
          pParola: userPassMD5,
          pIdConversatie: widget.medic.id.toString(),
        ) ??
        [];

    if (mounted && newMessages.length > mesajeConversatie.length) {
      setState(() {
        mesajeConversatie = newMessages;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) {
          _controller.jumpTo(_controller.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

      OneSignal.Notifications.addForegroundWillDisplayListener(_onNotificationDisplayed);
      
    _fetchMessages(); // Fetch initial messages

    _messageUpdateTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => _fetchMessages(),
    );
  }

  @override
  void dispose() {
    _messageUpdateTimer?.cancel();

      OneSignal.Notifications.removeForegroundWillDisplayListener(_onNotificationDisplayed);

    super.dispose();
  }

  
  void _onNotificationDisplayed(OSNotificationWillDisplayEvent event) {
    final notification = event.notification;

    // Suppress notifications containing "Aveți un mesaj" in the alert text
    if (notification.body != null && notification.body!.contains('Aveți un mesaj')) {
      // Suppress the notification
      OneSignal.Notifications.preventDefault(notification.notificationId!);
      return;
    }

    // Allow other notifications to show
    OneSignal.Notifications.displayNotification(notification.notificationId!);
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String user = prefs.getString('user') ?? '';
      String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

      await apiCallFunctions.adaugaMesajDinContClient(
        pUser: user,
        pParola: userPassMD5,
        pIdMedic: widget.medic.id.toString(),
        pMesaj: _messageController.text,
      );

      _messageController.clear();
      _fetchMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                _topAppBar(),
                const SizedBox(height: 50),
                Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[400],
                      ),
                      child: widget.medic.linkPozaProfil.isNotEmpty
                          ? Image.network(widget.medic.linkPozaProfil)
                          : Image.asset(
                              './assets/images/user_fara_poza.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.medic.titulatura} ${widget.medic.numeleComplet}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Color(0xff0EBE7F),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.medic.locDeMunca,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xff677294),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            widget.medic.specializarea,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xff677294),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: _buildMessageList(),
                ),
                if (!widget.chatOnly) _trimiteAtasament(),
                if (!widget.chatOnly) const SizedBox(height: 10),
                ValueListenableBuilder(
                  valueListenable: aRaspunsDoctorulNotifier,
                  builder: (context, value, child) {
                    if (value == true) {
                      return _maiPuneIntrbeare();
                    } else {
                      return _buildMessageInput();
                    }
                  },
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _controller,
      itemCount: mesajeConversatie.length,
      itemBuilder: (context, index) {
        return _buildMessageItem(mesajeConversatie[index]);
      },
    );
  }

  Widget _maiPuneIntrbeare() {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Mai doriți o întrebare?",
            style: TextStyle(
              color: Color(0xff0EBE7F),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () async {
                  FacturaClientMobile? ultimaFactura;

                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String user = prefs.getString('user') ?? '';
                  String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

                  ultimaFactura = await apiCallFunctions.getUltimaFactura(
                    pUser: user,
                    pParola: userPassMD5,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FacturaScreen(
                        facturaDetalii: ultimaFactura!,
                        user: user,
                        isFromChat: true,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(width: 1, color: Colors.grey[300]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "NU",
                        style: TextStyle(
                          color: Colors.grey[500]!,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Vă mulțumesc!",
                        style: TextStyle(
                          color: Colors.grey[500]!,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Handle further actions
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xff0EBE7F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "DA",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Mai doresc o întrebare",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              Expanded(
                child: MyTextField(
                  textEditingController: _messageController,
                  hintText: 'Mesaj',
                  obscureText: false,
                ),
              ),
              GestureDetector(
                onTap: sendMessage,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xff0EBE7F),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/icons/send (1).png",
                      scale: 0.8,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(MesajConversatieMobile message) {
    var alignment =
        (message.idExpeditor == widget.contClientMobile.id) ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.all(8),
      child: ChatBubble(
        data: message.dataMesaj,
        message: message.comentariu,
        linkPoza: message.linkFisier,
        sentByCurrentUser: (message.idExpeditor == widget.contClientMobile.id),
      ),
    );
  }

  Widget _topAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              confirmaIesireChat();
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.grey[400],
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  void confirmaIesireChat() {
    // Logic for confirming exit
  }

  Widget _trimiteAtasament() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              // Open dialog for attachments
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              height: 46,
              width: 45,
              decoration: BoxDecoration(
                color: const Color(0xff0EBE7F),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.image,
                  size: 25,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
