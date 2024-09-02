import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/chat_screen.dart/chat_bubble.dart';
import 'package:sos_bebe_app/utils_api/api_call_functions.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;

class IstoricDeschis extends StatefulWidget {
  final int medic;
  final ContClientMobile contClientMobile;
  const IstoricDeschis(
      {super.key, required this.contClientMobile, required this.medic});

  @override
  State<IstoricDeschis> createState() => _IstoricDeschisState();
}

class _IstoricDeschisState extends State<IstoricDeschis> {
  List<ConversatieMobile> listaConversatii = [];
  ScrollController _controller = ScrollController();

  ApiCallFunctions apiCallFunctions = ApiCallFunctions();
  ConversatieMobile? conversatiaMeaMobile;
  bool isDoneLoading = false;
  bool aRaspunsDoctorul = false;
  //! send function

  void getListaConversatii() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
    listaConversatii = await apiCallFunctions.getListaConversatii(
          pUser: user,
          pParola: userPassMD5,
        ) ??
        [];
    listaConversatii.forEach((element) {
      if (widget.medic == element.idDestinatar &&
          element.idExpeditor == widget.contClientMobile.id) {
        conversatiaMeaMobile = element;
      }
    });
    isDoneLoading = true;
    setState(() {});
  }

  Future<List<MesajConversatieMobile>> streamListaMesaje() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';
    List<MesajConversatieMobile> mesajeConversatie = [];

    // Initial fetch of messages
    mesajeConversatie = await apiCallFunctions.getListaMesajePeConversatie(
          pUser: user,
          pParola: userPassMD5,
          pIdConversatie: widget.medic.toString(),
        ) ??
        [];
    return mesajeConversatie;
  }

  void _loadMessagesFromList() async {
    List<MesajConversatieMobile> listaMesaje = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();

    //prefs.setString(pref_keys.userPassMD5, controllerEmail.text);

    String user = prefs.getString('user') ?? '';
    String userPassMD5 = prefs.getString(pref_keys.userPassMD5) ?? '';

    listaMesaje = await apiCallFunctions.getListaMesajePeConversatie(
          pUser: user,
          pParola: userPassMD5,
          pIdConversatie: listaConversatii[0].id.toString(),
        ) ??
        [];
  }

  @override
  void initState() {
    super.initState();
    getListaConversatii();
  }

  //! timer
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              size: 28,
              color: Color(0xffCDD3DF),
            ),
          ),
        ),
        body: isDoneLoading
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      //display name & photo
                      _topAppBar(),
                      const SizedBox(
                        height: 50,
                      ),
                      Expanded(
                        child: _buildMessageBuilder(),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()));
  }

  Widget _buildMessageBuilder() {
    return FutureBuilder(
      future: streamListaMesaje(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Eroare ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Se incarca..');
        }
        // return Text(snapshot.data!.length.toString());
        return ListView.builder(
          controller: _controller,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              _controller.jumpTo(_controller.position.maxScrollExtent);
            });
            return _buildMessageItem(snapshot.data![index]);
          },
        );
        // return ListView.builder(
        //     itemCount: snapshot.data!.length + 1, // 3 elemente : index ==  2
        //     itemBuilder: (context, index) {
        //       if (index == snapshot.data!.length) {
        //         if (snapshot.data![index - 1].senderId == "2") {
        //           return _maiPuneIntrbeare();
        //         } else {
        //           return Container();
        //         }
        //       }
        //       return _buildMessageItem(snapshot.data![index]);
        //     });
      },
    );
  }

  Widget _buildMessageItem(
    MesajConversatieMobile message,
  ) {
    //align the message bubble based on who sent it
    var alignment = (message.idExpeditor == widget.contClientMobile.id)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: (message.idExpeditor == widget.contClientMobile.id)
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisAlignment: (message.idExpeditor == widget.contClientMobile.id)
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          ChatBubble(
            data: message.dataMesaj,
            message: message.comentariu,
            linkPoza: message.linkFisier,
            sentByCurrentUser:
                (message.idExpeditor == widget.contClientMobile.id),
          )
        ],
      ),
    );
  }

  Widget _topAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.grey[400]),
              child: conversatiaMeaMobile!.linkPozaProfil.isNotEmpty
                  ? Image.network(conversatiaMeaMobile!.linkPozaProfil)
                  : Image.asset(
                      './assets/images/user_fara_poza.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
              //! to implement
              // child: Image.network(""),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                height: 15,
                width: 15,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff0EBE7F),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 20,
        ),
        //! display nume doctor + iconita

        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${conversatiaMeaMobile!.titulaturaDestinatar} ${conversatiaMeaMobile!.identitateDestinatar}",
                style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xff0EBE7F),
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                conversatiaMeaMobile!.locDeMunca,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xff677294),
                    fontWeight: FontWeight.w700),
              ),
              Text(
                conversatiaMeaMobile!.specializarea,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xff677294),
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
