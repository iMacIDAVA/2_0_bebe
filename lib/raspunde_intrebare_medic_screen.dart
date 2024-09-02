import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
//import 'package:auto_size_text/auto_size_text.dart';
import 'package:open_filex/open_filex.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import './utils/chat.dart' as chat;
import './utils/chat_l10n.dart' as chat_l10n;
import './utils/chat_theme.dart' as chat_theme;
import './utils/typing_indicator.dart' as typing_indicator;

import 'package:sos_bebe_app/localizations/1_localizations.dart';

class RaspundeIntrebareMedicScreen extends StatefulWidget {
  final String textNume;
  final String textIntrebare;
  final String textRaspuns;

  final int idMedic;

  const RaspundeIntrebareMedicScreen({
    super.key,
    required this.textNume,
    required this.textIntrebare,
    required this.textRaspuns,
    required this.idMedic,
  });

  @override
  State<RaspundeIntrebareMedicScreen> createState() =>
      _RaspundeIntrebareMedicScreenState();
}

class _RaspundeIntrebareMedicScreenState
    extends State<RaspundeIntrebareMedicScreen> {
  String textNume = '';
  String textIntrebare = '';
  String textRaspuns = '';

  List<types.Message> _messages = [];

  final _user = const types.User(
    id: 'e52552f4-835d-4dbe-ba77-b076e659774d',
  );

  //final _user = const types.User(id: '12345', imageUrl: 'https://i.pravatar.cc/300', firstName: 'Test', lastName: 'Test');

  @override
  initState() {
    super.initState();
    //textNume = '';
    //textIntrebare = '';
    //textRaspuns = '';
    _loadMessages();
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAttachmentPressed() {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    //'Imagine', //IGV
                    l.raspundeIntrebareMedicImagine,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    //'Fișier' //old IGV
                    l.raspundeIntrebareMedicFisier,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    //'Anulează' //old IGV
                    l.raspundeIntrebareMedicAnuleaza,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    /*
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any, allowMultiple: false,

      //type: FileType.custom,
      // 2. Only allow these formats
      //allowedExtensions: ['jpg', 'pdf', 'doc', 'png'],

    );
    */

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,

      type: FileType.custom,
      allowedExtensions: ['pdf'],
      // 2. Only allow these formats
      //allowedExtensions: ['jpg', 'pdf', 'doc', 'png'],
    );

    List<File> files = [];

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
    } else {
      print("No file selected");
    }

    final bytes = await files[0].readAsBytes();

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        width: image.width.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
      );

      _addMessage(message);
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);
  }

  void _loadMessages() async {
    final response = await rootBundle.loadString('./assets/messages.json');

    //print('test');

    final messages = (jsonDecode(response) as List)
        .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      _messages = messages;
    });
  }

  void callbackTextIntrebare(String newTextIntrebare) {
    setState(() {
      textIntrebare = newTextIntrebare;

      // ignore: avoid_print
      //print('is checked alergic: ' + isAlergic.toString());
    });
  }

  void callbackTextRaspuns(String newTextRaspuns) {
    setState(() {
      textRaspuns = newTextRaspuns;

      // ignore: avoid_print
      //print('is checked alergic: ' + isAlergic.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        //resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 75,
          //title: const RaspundeIntrebareTopIconsTextWidget(iconPath: './assets/images/raspunde_intrebare_pacienta.png', textNume: 'Nume pacienta',), //old IGV
          title: RaspundeIntrebareTopIconsTextWidget(
            iconPath: './assets/images/raspunde_intrebare_pacienta.png',
            textNume: l.raspundeIntrebareMedicNumePacient,
          ),
        ),
        body:
            //const RaspundeIntrebareTopIconsTextWidget(iconPath: './assets/images/raspunde_intrebare_pacienta.png', textNume: 'Nume pacienta',),
            chat.Chat(
          messages: _messages,
          onSendPressed: _handleSendPressed,
          user: _user,
          onAttachmentPressed: _handleAttachmentPressed,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,
          showUserAvatars: true,
          showUserNames: true,
          //l10n: const ChatL10nRo().toChatL10n,
          l10n: chat_l10n.ChatL10nEn(
            // attachmentButtonAccessibilityLabel : 'Trimite media', //old IGV
            attachmentButtonAccessibilityLabel:
                l.raspundeIntrebareMedicTrimiteMedia,
            //emptyChatPlaceholder : 'Nu aveți nici un mesaj încă', //old IGV
            emptyChatPlaceholder: l.raspundeIntrebareMedicNuAvetiNiciUnMesaj,
            //fileButtonAccessibilityLabel : 'Fișier', //old IGV
            fileButtonAccessibilityLabel:
                l.raspundeIntrebareMedicFisierMesajChat,
            //inputPlaceholder : 'Scrie un mesaj...', //old IGV
            inputPlaceholder: l.raspundeIntrebareMedicScrieMesaj,
            //sendButtonAccessibilityLabel : 'Trimite', //old IGV
            sendButtonAccessibilityLabel: l.raspundeIntrebareMedicTrimite,
            //unreadMessagesLabel : 'Marchează mesajul ca necitit', //old IGV
            unreadMessagesLabel:
                l.raspundeIntrebareMedicMarcheazaMesajulCaNecitit,
          ),
          typingIndicatorOptions:
              const typing_indicator.TypingIndicatorOptions(),
          theme: const chat_theme.DefaultChatTheme(
            inputBackgroundColor: Color.fromRGBO(
                255, 255, 255, 1), // Color.fromRGBO(30, 214, 158, 1),
            inputTextColor: Color.fromRGBO(
                103, 114, 148, 1), // Color.fromRGBO(30, 214, 158, 1),
            //backgroundColor: Color.fromRGBO(14, 190, 127, 1),
            primaryColor: Color.fromRGBO(14, 190, 127, 1),
          ),
        ),
        //Column(
        //  children: [
        //const RaspundeIntrebareTopIconsTextWidget(iconPath: './assets/images/raspunde_intrebare_pacienta.png', textNume: 'Nume pacienta',),
        //    const InkWell(
        //      child: ChatWidget(),
        //      ),
        //    ),
        //  ],
        //),
      ),
    );
  }
}

// ignore: must_be_immutable
class RaspundeIntrebareTopIconsTextWidget extends StatelessWidget {
  final String iconPath;
  final String textNume;

  const RaspundeIntrebareTopIconsTextWidget(
      {super.key, required this.iconPath, required this.textNume});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 20),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Image.asset('./assets/images/inapoi_chat_icon.png'),
              color: const Color.fromRGBO(103, 114, 148, 1),
            ),
            const SizedBox(width: 5),
            CircleAvatar(foregroundImage: AssetImage(iconPath), radius: 25),
            const SizedBox(width: 15),
            Text(textNume,
                style: GoogleFonts.rubik(
                    color: const Color.fromRGBO(14, 190, 127, 1),
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
            //const SizedBox(width: 160),
          ],
        ),
      ],
    );
  }
}
