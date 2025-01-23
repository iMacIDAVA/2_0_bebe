import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/chat_screen.dart/chat_bubble.dart';
import 'package:sos_bebe_app/chat_screen.dart/chat_textfield.dart';
import 'package:sos_bebe_app/confirmare_servicii_screen.dart';
import 'package:sos_bebe_app/factura_screen.dart';
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:sos_bebe_app/utils_api/api_config.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';
import 'package:sos_bebe_app/utils_api/doctor_busy_service.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:sos_bebe_app/vezi_toti_medicii_screen.dart';

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
  final ScrollController _controller = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final ApiCallFunctions apiCallFunctions = ApiCallFunctions();
  List<MesajConversatieMobile> mesajeConversatie = [];
  Timer? _messageUpdateTimer;

  bool _initialFetchDone = false;

Future<void> _fetchMessages() async {
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

    if (mounted && newMessages.isNotEmpty) {
      setState(() {
        mesajeConversatie = newMessages;
      });

      // Check if the specific message exists
// bool doctorLeftChat = newMessages.isNotEmpty &&
//     newMessages.last.comentariu.trim() == "Doctorul a părăsit chatul";


      // if (doctorLeftChat && _initialFetchDone) { // Navigate only after initialization
      //   await notificaDoctor();
      //   if (mounted && resGetCont != null && listaMedici.isNotEmpty) {
      //     doctorStatusService.doctorBusyStatus[widget.medic.id] = false;
      //     Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => VeziTotiMediciiScreen(
      //           listaMedici: listaMedici,
      //           contClientMobile: resGetCont!,
      //         ),
      //       ),
      //     );
      //   }
      // }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) {
          _controller.jumpTo(_controller.position.maxScrollExtent);
        }
      });

      // Mark that the initial fetch is done
      _initialFetchDone = true;
    }
  } catch (error) {
    print("Error fetching messages: $error");
  }
}


@override
void initState() {
  super.initState();
  _fetchData();
  OneSignal.Notifications.addForegroundWillDisplayListener(
      _onNotificationDisplayed);
  _fetchMessages().then((_) {
    // Ensure the chat scrolls to the bottom on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      }
    });
  });
  _messageUpdateTimer = Timer.periodic(
    const Duration(seconds: 5),
    (timer) => _fetchMessages(),
  );
}



@override
void dispose() {
  _messageUpdateTimer?.cancel();
  OneSignal.Notifications.removeForegroundWillDisplayListener(
    _onNotificationDisplayed,
  );
  super.dispose();
}

  void _onNotificationDisplayed(OSNotificationWillDisplayEvent event) {
    print("Notification displayed: ${event.notification.body}");
    if (event.notification.body?.contains('Aveți un mesaj') ?? false) {
      OneSignal.Notifications.preventDefault(
          event.notification.notificationId!);
    }
  }

  void _handleFileOpen(String fileUrl) async {
    try {
      // Download the file if necessary
      String localPath = await _downloadFile(fileUrl);

      // Open the file using OpenFilex
      OpenFilex.open(localPath);
    } catch (error) {
      print("Error opening file: $error");
    }
  }

  Future<String> _downloadFile(String url) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(url);
    final filePath = path.join(directory.path, fileName);

    if (await File(filePath).exists()) {
      return filePath; // File already exists
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } else {
      throw Exception('Failed to download file: ${response.statusCode}');
    }
  }

  Future<void> _sendFile(File file) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    String fileName = path.basenameWithoutExtension(file.path);
    String extension = path.extension(file.path);
    List<int> fileBytes = await file.readAsBytes();
    String base64File = base64Encode(fileBytes);
    String pCheie = keyAppPacienti;

    try {
      print("Sending file with the following data...");

      // Upload file and get the URL
      String? fileUrl =
          await apiCallFunctions.adaugaMesajCuAtasamentDinContMedic(
        pCheie: pCheie,
        pUser: user,
        pParolaMD5: userPassMD5,
        pIdMedic: widget.medic.id.toString(),
        pMesaj: "File Attachment: $fileName$extension",
        pDenumireFisier: fileName,
        pExtensie: extension,
        pSirBitiDocument: base64File,
      );

      if (fileUrl != null) {
        print("File uploaded successfully. Sending URL as a message: $fileUrl");

        // Send the URL as a text message
        await apiCallFunctions.adaugaMesajDinContClient(
          pUser: user,
          pParola: userPassMD5,
          pIdMedic: widget.medic.id.toString(),
          pMesaj: fileUrl,
        );

        print("URL sent successfully as a message.");
        _fetchMessages(); // Refresh chat messages
      } else {
        print("Failed to upload file. URL is null.");
      }
    } catch (error) {
      print("Error sending file: $error");
    }
  }

  Future<void> _pickAndSendFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      print("File selected: ${file.path}");
      await _sendFile(file);
    } else {
      print("No file selected.");
    }
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _controller,
      itemCount: mesajeConversatie.length,
      itemBuilder: (context, index) {
        final message = mesajeConversatie[index];
        final isCurrentUser = message.idExpeditor == widget.contClientMobile.id;

        // Extract the message text
        final String text = message.comentariu.trim();
        final bool isImageUrl = text.endsWith('.jpg') ||
            text.endsWith('.png') ||
            text.endsWith('.jpeg') ||
            text.endsWith('.gif');
        final bool isPdf = text.endsWith('.pdf');
        final bool isUrl =
            text.startsWith('http://') || text.startsWith('https://');

        // Skip messages containing "File Attachment"
        if (text.contains("File Attachment")) {
          return const SizedBox
              .shrink(); // Return an empty widget for such messages
        }

        // Skip rendering files if chatOnly is true
        if (widget.chatOnly && isUrl) {
          return const SizedBox
              .shrink(); // Do not render files in chat-only mode
        }

        return Align(
          alignment:
              isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? const Color.fromRGBO(14, 190, 127, 1)
                  : const Color.fromRGBO(240, 240, 240, 1),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10),
                bottomLeft: Radius.circular(isCurrentUser ? 10 : 0),
                bottomRight: Radius.circular(isCurrentUser ? 0 : 10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 3),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (isUrl &&
                    !widget.chatOnly) // Render files only if chatOnly is false
                  isImageUrl
                      ? GestureDetector(
                          onTap: () {
                            print('Opening image: $text');
                            _handleFileOpen(text);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Image.network(
                              text,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  "Failed to load image.",
                                  style: TextStyle(color: Colors.red),
                                );
                              },
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () => _handleFileOpen(text),
                          child: Row(
                            children: [
                              Icon(
                                isPdf
                                    ? Icons.picture_as_pdf
                                    : Icons.insert_drive_file,
                                color: isPdf ? Colors.red : Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  path.basename(text),
                                  style: TextStyle(
                                    color: isCurrentUser
                                        ? Colors.white
                                        : Colors.black,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                if (!isUrl)
                  Text(
                    text,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black,
                      fontSize: 18,
                      height: 1.5,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          if (!widget.chatOnly)
            IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.grey),
              onPressed: _pickAndSendFile,
            ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Scrie un mesaj...",
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon:
                const Icon(Icons.send, color: Color.fromRGBO(14, 190, 127, 1)),
            onPressed: () async {
              if (_messageController.text.isNotEmpty) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String user = prefs.getString('user') ?? '';
                String userPassMD5 =
                    prefs.getString(pref_keys.userPassMD5) ?? '';

                await apiCallFunctions.adaugaMesajDinContClient(
                  pUser: user,
                  pParola: userPassMD5,
                  pIdMedic: widget.medic.id.toString(),
                  pMesaj: _messageController.text,
                );
                _messageController.clear();
                _fetchMessages();
              }
            },
          ),
        ],
      ),
    );
  }

  List<MedicMobile> listaMedici = [];
  ContClientMobile? resGetCont;

Future<void> _fetchData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String user = prefs.getString('user') ?? '';
  String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

  try {
    listaMedici = await apiCallFunctions.getListaMedici(
          pUser: user,
          pParola: userPassMD5,
        ) ??
        [];

    resGetCont = await apiCallFunctions.getContClient(
      pUser: user,
      pParola: userPassMD5,
      pDeviceToken: prefs.getString('oneSignalId') ?? "",
      pTipDispozitiv: Platform.isAndroid ? '1' : '2',
      pModelDispozitiv: await apiCallFunctions.getDeviceInfo(),
      pTokenVoip: '',
    );

    if (mounted) {
      setState(() {});
    }
  } catch (e) {
    print("Error fetching data: $e");
  }
}


  Future<void> notificaDoctor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
    apiCallFunctions.anuntaMedicDeServiciuTerminat(
        pUser: user,
        pParola: userPassMD5,
        pIdMedic: widget.medic.id.toString(),
        tipPlata: widget.tipServiciu.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
      toolbarHeight: 75,
      title: Text(
        "${widget.medic.numeleComplet}",
        style: const TextStyle(fontSize: 18),
      ),
leading: IconButton(
  icon: const Icon(Icons.exit_to_app),
  onPressed: () async {
    // Show a confirmation dialog before exiting
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Exit"),
        content: const Text("Do you really want to leave the chat?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String user = prefs.getString('user') ?? '';
        String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

        // Send the "Pacientul a părăsit chatul" message ONLY here
        // await apiCallFunctions.adaugaMesajDinContClient(
        //   pUser: user,
        //   pParola: userPassMD5,
        //   pIdMedic: widget.medic.id.toString(),
        //   pMesaj: "Pacientul a părăsit chatul",
        // );

        // Notify the doctor ONLY here
        await notificaDoctor();

        // Close the loading dialog
        Navigator.pop(context);

        // Navigate to the doctors list screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VeziTotiMediciiScreen(
              listaMedici: listaMedici,
              contClientMobile: resGetCont!,
            ),
          ),
        );
      } catch (e) {
        // Close the loading dialog
        Navigator.pop(context);

        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send exit message")),
        );
      }
    }
  },
),

    ),
      body: WillPopScope(
        onWillPop: () async => false,
        child: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;

  const ImagePreviewScreen({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Preview"),
      ),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}
