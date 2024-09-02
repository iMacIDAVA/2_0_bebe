import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String linkPoza;
  final bool sentByCurrentUser;
  final DateTime data;
  const ChatBubble(
      {super.key,
      required this.message,
      required this.sentByCurrentUser,
      required this.linkPoza,
      required this.data});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

    return Column(
      crossAxisAlignment:
          sentByCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(8),
                  topRight: const Radius.circular(8),
                  bottomLeft: sentByCurrentUser
                      ? const Radius.circular(8)
                      : const Radius.circular(0),
                  bottomRight: sentByCurrentUser
                      ? const Radius.circular(0)
                      : const Radius.circular(8)),
              color: sentByCurrentUser ? Color(0xff0EBE7F) : Color(0xffF4F5FB)),
          child: Column(
            children: [
              Text(
                message,
                style: TextStyle(
                    color: sentByCurrentUser
                        ? Colors.white
                        : const Color(0xff677294),
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              ),
              if (linkPoza.isNotEmpty)
                path.extension(linkPoza) == ".pdf"
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: 200,
                        child: SfPdfViewer.network(
                          linkPoza,
                          key: _pdfViewerKey,
                        ),
                      )
                    : Image.network(linkPoza),
            ],
          ),
        ),
        Text(
          DateFormat("h:mm a").format(data),
          style: TextStyle(color: Colors.grey[500]),
        )
      ],
    );
  }
}
