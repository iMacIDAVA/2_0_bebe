import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/chat_attachment_screen.dart';
import 'package:sos_bebe_app/chat_screen.dart/chat_bubble.dart';
import 'package:sos_bebe_app/chat_screen.dart/chat_textfield.dart';
import 'package:sos_bebe_app/confirmare_servicii_screen.dart';
import 'package:sos_bebe_app/factura_screen.dart';
import 'package:sos_bebe_app/testimonial_screen.dart';
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
  final List<String>? initialFiles;

  const ChatScreenPage({
    super.key,
    required this.medic,
    required this.contClientMobile,
    required this.pret,
    required this.tipServiciu,
    required this.chatOnly,
    this.initialFiles,
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

  bool _isChatStarted = false;

  int remainingTime = 180;
  Timer? countdownTimer;

  bool _showUploadScreen = false;

  ValueNotifier<int> remainingTimeNotifier = ValueNotifier(600);

  void _onSecondButtonPressed() async {
    await sendWaitingForPayentNotificationToDoctor();

    // ✅ Navigate back to the payment screen
    if (mounted) {
      Future.delayed(Duration(milliseconds: 300), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmareServiciiScreen(
              pret: widget.pret,
              tipServiciu: widget.tipServiciu,
              contClientMobile: widget.contClientMobile,
              medicDetalii: widget.medic,
            ),
          ),
        );
      });
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          color: const Color.fromRGBO(14, 190, 127, 1),
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: const BackButton(color: Colors.white),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _selectedFiles[index];
                    final isImage =
                        file.path.endsWith(".jpg") || file.path.endsWith(".jpeg") || file.path.endsWith(".png");
                    final isPdf = file.path.endsWith(".pdf");

                    return GestureDetector(
                      onTap: () => _viewFile(file),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Center(
                          child: isImage
                              ? Image.file(file, fit: BoxFit.cover)
                              : isPdf
                                  ? const Icon(Icons.picture_as_pdf, size: 40, color: Colors.red)
                                  : const Icon(Icons.file_present, size: 40, color: Colors.grey),
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

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTimeNotifier.value > 0) {
        remainingTimeNotifier.value--;
      } else {
        timer.cancel();
        // navigateToRejectScreen("Ne para rău, timpul a expirat. \nMedicul nu a răspuns");
      }
    });
  }

  void _sendAndNavigate(String message) async {
    if (message.trim().isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    await apiCallFunctions.adaugaMesajDinContClient(
      pUser: user,
      pParola: userPassMD5,
      pIdMedic: widget.medic.id.toString(),
      pMesaj: message,
    );

    // Close the modal
    Navigator.pop(context);

    // Update local state instead of modifying widget.chatOnly
    setState(() {
      _isChatStarted = true;
    });
  }

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
        // Filter out system messages
        newMessages.removeWhere((msg) =>
            msg.comentariu.trim() == "Pacientul a părăsit consultația" ||
            msg.comentariu.trim() == "medicul a părăsit consultația" ||
            msg.comentariu.trim() == "Vă rugăm să așteptați plata pacientului");

        setState(() {
          mesajeConversatie = newMessages;
        });

        // Scroll handling
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_controller.hasClients) {
            // First load: always scroll to bottom
            if (!_initialFetchDone) {
              _controller.jumpTo(_controller.position.maxScrollExtent);
              _initialFetchDone = true;
            }
            // Subsequent loads: only scroll if near bottom
            else {
              final isNearBottom = _controller.position.pixels >= (_controller.position.maxScrollExtent - 200);
              if (isNearBottom) {
                _controller.animateTo(
                  _controller.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            }
          }
        });
      }
    } catch (error) {
      print("Error fetching messages: $error");
    }
  }

  final List<File> _selectedFiles = [];
  final int _maxFiles = 10;

  final ImagePicker _imagePicker = ImagePicker();

  void _openCamera() async {
    if (_selectedFiles.length >= _maxFiles) return;

    final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _selectedFiles.add(File(photo.path));
      });
    }
  }

  void _chooseFromPhone() async {
    if (_selectedFiles.length >= _maxFiles) return;

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.paths.map((path) => File(path!)).toList());
      });
    }
  }

  void _viewFile(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileViewerScreen(file: file),
      ),
    );
  }

  void _sendAttachmentsAndStartChat() {
    print("🚀 Sending Attachments...");

    if (_selectedFiles.isEmpty) {
      print("⚠️ No files selected!");
      return;
    }

    List<String> filePaths = _selectedFiles.map((file) => file.path).toList();
    print("📂 Files passed: $filePaths");

    setState(() {
      _showUploadScreen = false; // Hide upload screen, show chat
      _isChatStarted = true;
    });

    _sendFilesAsMessage(filePaths);
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    _fetchData();
    getUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        // Scroll to the bottom of the list immediately after layout
        _controller.jumpTo(_controller.position.maxScrollExtent);
      }
    });

    if (widget.initialFiles != null && widget.initialFiles!.isNotEmpty) {
      print("📂 Received files in ChatScreen: ${widget.initialFiles}");
    }

    if (!widget.chatOnly) {
      _showUploadScreen = true; // Show RecomandareScreen first when chatOnly is false
    }

    if (widget.initialFiles != null && widget.initialFiles!.isNotEmpty) {
      _sendFilesAsMessage(widget.initialFiles!);
    }

    OneSignal.Notifications.addForegroundWillDisplayListener(_onNotificationDisplayed);
    _fetchMessages().then((_) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_controller.hasClients) {
            _controller.animateTo(
              _controller.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    _messageUpdateTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => _fetchMessages(),
    );
  }

  void _sendFilesAsMessage(List<String> files) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    List<String> uploadedUrls = [];

    for (String filePath in files) {
      File file = File(filePath);
      String fileName = path.basenameWithoutExtension(file.path);
      String extension = path.extension(file.path);
      List<int> fileBytes = await file.readAsBytes();
      String base64File = base64Encode(fileBytes);
      String pCheie = keyAppPacienti;

      try {
        // Upload the file
        String? fileUrl = await apiCallFunctions.adaugaMesajCuAtasamentDinContMedic(
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
          uploadedUrls.add(fileUrl);
        } else {
          print("❌ Failed to upload: $filePath");
        }
      } catch (error) {
        print("❌ Error uploading file: $error");
      }
    }

    // Send message with uploaded file URLs
    if (uploadedUrls.isNotEmpty) {
      for (String fileUrl in uploadedUrls) {
        await apiCallFunctions.adaugaMesajDinContClient(
          pUser: user,
          pParola: userPassMD5,
          pIdMedic: widget.medic.id.toString(),
          pMesaj: fileUrl,
        );
      }

      print("✅ Sent files as actual images.");
      _fetchMessages(); // Refresh chat
    }
  }

  void _proceedToChat() {
    setState(() {
      _showUploadScreen = false; // Show the actual chat screen
    });
  }

  void _openMessageSheet() {
    TextEditingController messageController = TextEditingController();
    int maxLength = 400;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // Prevents keyboard overlap
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                height: 600, // Increased height for a longer text field
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Bar with Icon and Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 40), // Balancing the alignment
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Container(
                            // decoration: BoxDecoration(
                            //   color: Colors.red.withOpacity(0.3),
                            //   borderRadius: BorderRadius.circular(15),
                            // ),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
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
                        IconButton(
                            icon: Icon(Icons.close, size: 24, color: Colors.black87),
                            onPressed: () {
                              Navigator.pop(context);
                            } // Close modal
                            ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // Taller Text Field with Character Counter
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        maxLines: 20, // Increased maxLines for a taller text field
                        maxLength: maxLength,
                        onChanged: (text) {
                          setState(() {}); // Refresh UI to update character counter
                        },
                        decoration: InputDecoration(
                          hintText: "Scrie text",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(16), // Adds inner padding
                          counterText: "${maxLength - messageController.text.length} de caractere",
                          counterStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Send Button
                    ElevatedButton(
                      onPressed: () => _sendAndNavigate(messageController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: Text("TRIMITE ÎNTREBAREA", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _messageUpdateTimer?.cancel();
    OneSignal.Notifications.removeForegroundWillDisplayListener(
      _onNotificationDisplayed,
    );
    remainingTimeNotifier.dispose();
    countdownTimer?.cancel(); // ✅ Cancel the countdown timer
    super.dispose();
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

  void _onNotificationDisplayed(OSNotificationWillDisplayEvent event) {
    final notification = event.notification;
    final String? notificationBody = notification.body?.trim();

    if (notificationBody != null) {
      print("📢 Notification received: $notificationBody");

      if (notificationBody.contains("medicul a părăsit consultația")) {
        print("🚪 Doctor left consultation. Closing screen...");

        // Cancel timers & dispose
        _messageUpdateTimer?.cancel();
        countdownTimer?.cancel();
        remainingTimeNotifier.dispose();

        if (mounted) {
          // 🚀 Navigate to doctor selection screen
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

        return; // ⛔ Do NOT display this notification in the chat
      }
    }

    // Default behavior for other notifications
    OneSignal.Notifications.displayNotification(notification.notificationId!);
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

  List<MedicMobile> listaMedici = [];
  ContClientMobile? resGetCont;

  Future<void> getContUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    if (user.isEmpty || userPassMD5.isEmpty) {
      throw Exception("Missing user credentials");
    }

    resGetCont = await apiCallFunctions.getContClient(
      pUser: user,
      pParola: userPassMD5,
      pDeviceToken: prefs.getString('oneSignalId') ?? "",
      pTipDispozitiv: Platform.isAndroid ? '1' : '2',
      pModelDispozitiv: await apiCallFunctions.getDeviceInfo(),
      pTokenVoip: '',
    );

    if (resGetCont == null) {
      throw Exception("Failed to fetch account data");
    }
  }

  Future<void> getListaMedici() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    listaMedici = await apiCallFunctions.getListaMedici(
          pUser: user,
          pParola: userPassMD5,
        ) ??
        [];
  }

  void _onFirstButtonPressed() async {
    await sendExitNotificationToDoctor(); // 🚀 Send a push notification instead!

    Future.delayed(Duration(seconds: 1), () async {
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
    });
  }

  Future<void> sendWaitingForPayentNotificationToDoctor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String pCheie = keyAppPacienti; // App key for patients
    int pIdMedic = widget.medic.id; // Doctor ID
    String pTip = widget.tipServiciu.toString();

    String patientId = prefs.getString(pref_keys.userId) ?? '';
    String patientNume = prefs.getString(pref_keys.userNume) ?? '';
    String patientPrenume = prefs.getString(pref_keys.userPrenume) ?? '';

    String pObservatii = '$patientId\$#\$$patientPrenume $patientNume';

    // Exit message
    String pMesaj = "Vă rugăm să așteptați plata pacientului";

    await apiCallFunctions.trimitePushPrinOneSignalCatreMedic(
      pCheie: pCheie,
      pIdMedic: pIdMedic,
      pTip: pTip,
      pMesaj: pMesaj,
      pObservatii: pObservatii,
    );

    print("📢 Exit notification sent to doctor!");
  }

  Future<void> sendExitNotificationToDoctor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String pCheie = keyAppPacienti; // App key for patients
    int pIdMedic = widget.medic.id; // Doctor ID
    String pTip = widget.tipServiciu.toString();

    String patientId = prefs.getString(pref_keys.userId) ?? '';
    String patientNume = prefs.getString(pref_keys.userNume) ?? '';
    String patientPrenume = prefs.getString(pref_keys.userPrenume) ?? '';

    String pObservatii = '$patientId\$#\$$patientPrenume $patientNume';

    // Exit message
    String pMesaj = "Pacientul a părăsit consultația";

    await apiCallFunctions.trimitePushPrinOneSignalCatreMedic(
      pCheie: pCheie,
      pIdMedic: pIdMedic,
      pTip: pTip,
      pMesaj: pMesaj,
      pObservatii: pObservatii,
    );

    print("📢 Exit notification sent to doctor!");
  }

  void _downloadFileAndShowSnackbar(String url) async {
    try {
      String savedPath = await _downloadFile(url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Descărcat pe: $savedPath"),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: "DESCHIDE",
            onPressed: () {
              OpenFilex.open(savedPath);
            },
          ),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nu s-a putut descărca fișierul: $error")),
      );
    }
  }

  Widget _buildChatOnlyIntroScreen() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // ❌ Removes the back button
        backgroundColor: const Color.fromRGBO(30, 214, 158, 1),
        toolbarHeight: 75,
        title: Text(
          widget.medic.numeleComplet,
          style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "În atenția dumneavoastră",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("• Vă rugăm să adresați medicului o singură întrebare.",
                      style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
                  SizedBox(height: 8),
                  Text("• Textul poate avea maxim 400 de caractere.",
                      style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
                  SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      text: "• Butonul ",
                      style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                      children: [
                        TextSpan(
                          text: "TRIMITE ÎNTREBAREA",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        TextSpan(
                          text: " se utilizează o singură dată după finalizarea scrierii mesajului.",
                          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text("• Vă informăm că după 10 minute fereastra se închide automat!",
                      style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Vă mulțumim!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _openMessageSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              child: const Text(
                "Scrie text",
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
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
      String? fileUrl = await apiCallFunctions.adaugaMesajCuAtasamentDinContMedic(
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
        final bool isImageUrl =
            text.endsWith('.jpg') || text.endsWith('.png') || text.endsWith('.jpeg') || text.endsWith('.gif');
        final bool isPdf = text.endsWith('.pdf');
        final bool isUrl = text.startsWith('http://') || text.startsWith('https://');

        // Skip messages containing "File Attachment"
        if (text.contains("File Attachment")) {
          return const SizedBox.shrink(); // Return an empty widget for such messages
        }

        // Skip rendering files if chatOnly is true
        if (widget.chatOnly && isUrl) {
          return const SizedBox.shrink(); // Do not render files in chat-only mode
        }

        return Align(
          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrentUser ? const Color.fromRGBO(14, 190, 127, 1) : const Color.fromRGBO(240, 240, 240, 1),
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
              crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (isUrl && !widget.chatOnly) // Render files only if chatOnly is false
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
                                isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
                                color: isPdf ? Colors.red : Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              // IconButton(
                              //   icon: const Icon(Icons.download, color: Colors.red),
                              //   onPressed: () => _downloadFileAndShowSnackbar(text),
                              // ),
                              Flexible(
                                child: Text(
                                  path.basename(text),
                                  style: TextStyle(
                                    color: isCurrentUser ? Colors.white : Colors.black,
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
    // ✅ Apply restriction only for chatOnly: false (chatOnly: true remains unchanged)
    if (_isChatStarted && !widget.chatOnly) {
      return _buildLimitedMessageOptions();
    }

    if (widget.chatOnly && _isChatStarted) {
      return _buildLimitedMessageOptions();
    }

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
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.send, color: Color.fromRGBO(14, 190, 127, 1)),
            onPressed: () async {
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

                _fetchMessages().then((_) {
                  if (mounted) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_controller.hasClients) {
                        _controller.animateTo(
                          _controller.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                  }
                });

                _fetchMessages();

                // Disable further messages for chatOnly users
                if (!widget.chatOnly) {
                  setState(() {
                    _isChatStarted = true; // Ensure user can't send more messages
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLimitedMessageOptions() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.chatOnly ? "Mai doriți o întrebare?" : "Doriți să adresați o întrebare medicului?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color.fromRGBO(30, 214, 158, 1),
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _onFirstButtonPressed, // Placeholder function
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10), // Equal height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Slightly rounded edges
                      side: BorderSide(color: Colors.grey.shade400, width: 1.5), // Border
                    ),
                  ),
                  child: Column(
                    children: [
                      Text("NU", style: TextStyle(color: Colors.black, fontSize: 18)),
                      SizedBox(height: 3),
                      Text("Vă mulțumesc", style: TextStyle(color: Colors.black, fontSize: 11)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: _onSecondButtonPressed, // Placeholder function
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(30, 214, 158, 1),
                    padding: EdgeInsets.symmetric(vertical: 10), // Equal height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Slightly rounded edges
                      side: BorderSide(color: Colors.grey.shade400, width: 1.5), // Border
                    ),
                  ),
                  child: Column(
                    children: [
                      Text("DA", style: TextStyle(color: Colors.white, fontSize: 18)),
                      SizedBox(height: 3),
                      Text("Mai doresc o întrebare", style: TextStyle(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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

  Widget _buildUploadScreen() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Vă rugăm să încarcați documentele'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _chooseFromPhone,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xff0EBE7F).withOpacity(0.2),
                      border: Border.all(color: const Color(0xff0EBE7F), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library, color: Color(0xff0EBE7F), size: 30),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: _openCamera,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xff0EBE7F).withOpacity(0.2),
                      border: Border.all(color: const Color(0xff0EBE7F), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt, color: Color(0xff0EBE7F), size: 30),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _showBottomSheet, // ✅ Opens the bottom sheet
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text("Previzualizare atașament", style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 120),
            ElevatedButton(
              onPressed: _sendAttachmentsAndStartChat, // Start chat after upload
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text("TRIMITE ÎNTREBAREA", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showUploadScreen) {
      return _buildUploadScreen(); // Show upload screen first
    }

    if (widget.chatOnly && !_isChatStarted) {
      return _buildChatOnlyIntroScreen(); // ✅ Show intro only if chat hasn’t started
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(30, 214, 158, 1),
        toolbarHeight: 75,
        leading: const SizedBox(),
        title: Text(
          widget.medic.numeleComplet,
          style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: (_isChatStarted || !widget.chatOnly)
          ? // Show the new intro screen
          WillPopScope(
              onWillPop: () async => false,
              child: Column(
                children: [
                  Expanded(child: _buildMessageList()),
                  _buildMessageInput(),
                ],
              ),
            )
          : _buildChatOnlyIntroScreen(),
    );
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;

  const ImagePreviewScreen({Key? key, required this.imageUrl}) : super(key: key);

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
