import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  const ChatScreenPage(
      {super.key,
      required this.medic,
      required this.contClientMobile,
      required this.pret,
      required this.tipServiciu,
      required this.chatOnly});

  @override
  State<ChatScreenPage> createState() => _ChatScreenPageState();
}

class _ChatScreenPageState extends State<ChatScreenPage> {
  bool isFirstEnterPage = true;
  final ScrollController _controller = ScrollController();
  final ValueNotifier<bool> aRaspunsDoctorulNotifier = ValueNotifier(false);
  //!chat controller
  final TextEditingController _messageController = TextEditingController();
  List<ConversatieMobile> listaConversatii = [];
  ApiCallFunctions apiCallFunctions = ApiCallFunctions();
  ConversatieMobile? conversatiaMeaMobile;
  bool isDoneLoading = false;
  bool aRaspunsDoctorul = false;
  List<MesajConversatieMobile> mesajeConversatie = [];
  List<MesajConversatieMobile> mesajeConversatieNou = [];

  void _fetchMessagesPeriodically() {
    mesajeConversatieNou = mesajeConversatie;
  }

  Future<List<MesajConversatieMobile>> getNewMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
    List<MesajConversatieMobile> mesajeConversatie = [];

    // Initial fetch of messages
    mesajeConversatie = await apiCallFunctions.getListaMesajePeConversatie(
          pUser: user,
          pParola: userPassMD5,
          pIdConversatie: widget.medic.id.toString(),
        ) ??
        [];
    return mesajeConversatie;
  }

  //! send function
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      });
      isFirstEnterPage = false;
      setState(() {});
    }
  }

  Stream<List<MesajConversatieMobile>> streamListaMesaje() async* {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
    // List<MesajConversatieMobile> mesajeConversatie = [];

    // Initial fetch of messages
    mesajeConversatie = await apiCallFunctions.getListaMesajePeConversatie(
          pUser: user,
          pParola: userPassMD5,
          pIdConversatie: widget.medic.id.toString(),
        ) ??
        [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    });
    yield mesajeConversatie;
    // Subsequent updates
    // while (true) {
    //   await Future.delayed(Duration(seconds: 15));

    //   // Fetch messages excluding the user's own messages
    //   List<MesajConversatieMobile> messages =
    //       await apiCallFunctions.getListaMesajePeConversatie(
    //             pUser: user,
    //             pParola: userPassMD5,
    //             pIdConversatie: widget.medic.id.toString(),
    //           ) ??
    //           [];

    //   // Yield only if there are new messages from other users
    //   if (messages.isNotEmpty) {
    //     if (isFirstEnterPage == false) {
    //       if (messages[messages.length - 1].idExpeditor == widget.medic.id) {
    //         aRaspunsDoctorulNotifier.value = true;
    //         Future.delayed(Duration(seconds: 60), () async {
    //           FacturaClientMobile? utlimaFactura;

    //           SharedPreferences prefs = await SharedPreferences.getInstance();

    //           String user = prefs.getString('user') ?? '';
    //           String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
    //           utlimaFactura = await apiCallFunctions.getUltimaFactura(
    //               pUser: user, pParola: userPassMD5);
    //           Navigator.push(context, MaterialPageRoute(builder: (context) {
    //             return FacturaScreen(
    //               facturaDetalii: utlimaFactura!,
    //               user: user,
    //               isFromChat: true,
    //             );
    //           }));
    //         });
    //       }
    //     }

    //     yield messages;
    //   }
    // }
  }

  @override
  void initState() {
    super.initState();
    getNewMessages().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) {
          _controller.jumpTo(_controller.position.minScrollExtent);
        }
      });
    });
    _fetchMessagesPeriodically();
  }

  //! timer
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
                  //display name & photo
                  _topAppBar(),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[400]),
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
                              style:
                                  const TextStyle(fontSize: 18, color: Color(0xff0EBE7F), fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              widget.medic.locDeMunca,
                              style:
                                  const TextStyle(fontSize: 13, color: Color(0xff677294), fontWeight: FontWeight.w700),
                            ),
                            Text(
                              widget.medic.specializarea,
                              style:
                                  const TextStyle(fontSize: 11, color: Color(0xff677294), fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: _buildMessageBuilder(),
                  ),
                  if (!widget.chatOnly) _trimiteAtasament(),
                  if (!widget.chatOnly)
                    const SizedBox(
                      height: 10,
                    ),
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
                  // _maiPuneIntrbeare(),

                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildMessageBuilder() {
    return StreamBuilder(
      stream: streamListaMesaje(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Eroare ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Se incarca..');
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_controller.hasClients) {
            _controller.jumpTo(_controller.position.minScrollExtent); // Scroll to the bottom
          }
        });

        // return Text(snapshot.data!.length.toString());
        return ListView.builder(
          controller: _controller,
          itemCount: snapshot.data!.length,
          reverse: true,
          itemBuilder: (context, index) {
            return _buildMessageItem(snapshot.data![index]);
          },
        );
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
            style: TextStyle(color: Color(0xff0EBE7F), fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () async {
                  FacturaClientMobile? utlimaFactura;

                  SharedPreferences prefs = await SharedPreferences.getInstance();

                  String user = prefs.getString('user') ?? '';
                  String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
                  utlimaFactura = await apiCallFunctions.getUltimaFactura(pUser: user, pParola: userPassMD5);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return FacturaScreen(
                      facturaDetalii: utlimaFactura!,
                      user: user,
                      isFromChat: true,
                    );
                  }));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  height: 64,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8), border: Border.all(width: 1, color: Colors.grey[300]!)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "NU",
                        style: TextStyle(color: Colors.grey[500]!, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Vă mulțumesc!",
                        style: TextStyle(color: Colors.grey[500]!, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return ConfirmareServiciiScreen(
                          pret: widget.pret,
                          tipServiciu: widget.tipServiciu,
                          contClientMobile: widget.contClientMobile,
                          medicDetalii: widget.medic);
                    },
                  ));
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
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Mai doresc o întrebare",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
        ],
      ),
    );
  }

  Widget _trimiteAtasament() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () async {
              await _updatePhotoDialog();
              setState(() {});
            },
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                height: 46,
                width: 45,
                decoration: BoxDecoration(color: const Color(0xff0EBE7F), borderRadius: BorderRadius.circular(10)),
                child: const Center(
                  child: Icon(
                    Icons.image,
                    size: 25,
                    color: Colors.white,
                  ),
                )),
          )
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
              const Expanded(
                child: SizedBox(),
              ),
              GestureDetector(
                onTap: sendMessage,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xff0EBE7F),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.textsms_outlined,
                    color: Colors.white,
                    size: 23, // Icon size
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              //textfield
              Expanded(
                child: SizedBox(
                  // height: 65,
                  child: MyTextField(
                    textEditingController: _messageController,
                    hintText: 'Mesaj',
                    obscureText: false,
                  ),
                ),
              ),
              //send button
              const SizedBox(
                width: 5,
              ),
              GestureDetector(
                onTap: sendMessage,
                child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(color: const Color(0xff0EBE7F), borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Image.asset("assets/icons/send (1).png", scale: 0.8, color: Colors.white),
                      // child: Icon(
                      //   Icons.send,
                      //   size: 25,
                      //   color: Colors.white,
                      // ),
                    )),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(
    MesajConversatieMobile message,
  ) {
    //align the message bubble based on who sent it
    var alignment = (message.idExpeditor == widget.contClientMobile.id) ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment:
            (message.idExpeditor == widget.contClientMobile.id) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment:
            (message.idExpeditor == widget.contClientMobile.id) ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          ChatBubble(
            data: message.dataMesaj,
            message: message.comentariu,
            linkPoza: message.linkFisier,
            sentByCurrentUser: (message.idExpeditor == widget.contClientMobile.id),
          )
        ],
      ),
    );
  }

  confirmaIesireChat() async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Părăsește conversația'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Ești sigur că vrei să părăsești conversația?'),
              ],
            ),
          ),
          actions: <Widget>[
            GestureDetector(
              child: const Text('Anulează'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            GestureDetector(
              child: const Text('Părăsește'),
              onTap: () async {
                // Perform leaving action here
                Navigator.of(context).pop();
                // print(mesajeConversatie.length);

                FacturaClientMobile? utlimaFactura;

                SharedPreferences prefs = await SharedPreferences.getInstance();

                String user = prefs.getString('user') ?? '';
                String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
                utlimaFactura = await apiCallFunctions.getUltimaFactura(pUser: user, pParola: userPassMD5);
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FacturaScreen(
                    facturaDetalii: utlimaFactura!,
                    user: user,
                    isFromChat: true,
                  );
                }));
              },
            ),
          ],
        );
      },
    );
  }

  Widget _topAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button on the left
          GestureDetector(
            onTap: () {
              if (mesajeConversatie[mesajeConversatie.length - 1].esteUltimulMesaj == true) confirmaIesireChat();
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.grey[400],
              size: 28,
            ),
          ),

          Row(
            children: [
              Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Image.asset(
                      "assets/images/recipe (1).png",
                      scale: 0.8,
                    ),
                  )),
              const SizedBox(width: 20),
              Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Image.asset(
                      "assets/images/phone-call_apel_video.png",
                      scale: 0.8,
                    ),
                  )),
            ],
          )
        ],
      ),
    );
  }

  final ImagePicker _picker = ImagePicker();
  File _selectedImage = File('');

  Future<void> _takePhoto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Uint8List? selectedImageBytes;

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      _selectedImage = File(photo.path);
      selectedImageBytes = Uint8List.fromList(bytes);

      await apiCallFunctions.adaugaMesajCuAtasamentDinContClient(
        pExtensie: path.extension(photo.path),
        pUser: user,
        pParola: userPassMD5,
        pIdMedic: widget.medic.id.toString(),
        denumireFisier: photo.name,
        mesaj: _messageController.text,
        pBitiDocument: selectedImageBytes.toString(),
      );
      _messageController.clear();
      setState(() {});
    }
  }

  Future<void> _chooseFromGallery() async {
    Uint8List? selectedImageBytes;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      _selectedImage = File(photo.path);
      selectedImageBytes = Uint8List.fromList(bytes);

      await apiCallFunctions.adaugaMesajCuAtasamentDinContClient(
        pExtensie: path.extension(photo.path),
        pUser: user,
        pParola: userPassMD5,
        pIdMedic: widget.medic.id.toString(),
        denumireFisier: _selectedImage.path,
        mesaj: _messageController.text,
        pBitiDocument: selectedImageBytes.toString(),
      );
      _messageController.clear();
      setState(() {});
    }
  }

  _updatePhotoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Trimite atașament"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.camera),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galerie'),
                  onTap: () {
                    Navigator.pop(context);
                    _chooseFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
