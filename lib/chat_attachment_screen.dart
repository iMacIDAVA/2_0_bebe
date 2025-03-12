import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:sos_bebe_app/utils_api/api_config.dart';
import 'package:sos_bebe_app/utils_api/classes.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart';
import 'package:path/path.dart' as path;

import 'chat_screen.dart/chat_screen.dart';
import 'datefacturare/date_facturare_completare_rapida.dart';

class RecomandareScreen extends StatefulWidget {
  final MedicMobile medic;
  final ContClientMobile contClientMobile;
  final int tipServiciu;
  final String pret;
  final VoidCallback onProceed;

  const RecomandareScreen(
      {Key? key,
      required this.medic,
      required this.contClientMobile,
      required this.tipServiciu,
      required this.pret,
      required this.onProceed})
      : super(key: key);

  @override
  State<RecomandareScreen> createState() => _RecomandareScreenState();
}

class _RecomandareScreenState extends State<RecomandareScreen> {
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

  void _sendAttachmentsAndNavigate() {
    print("🚀 Passing Attachments to Chat Screen...");

    if (_selectedFiles.isEmpty) {
      print("⚠️ No files selected!");
      return;
    }

    List<String> filePaths = _selectedFiles.map((file) => file.path).toList();

    print("📂 Sending files to ChatScreen: $filePaths");

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreenPage(
              medic: widget.medic,
              contClientMobile: widget.contClientMobile,
              pret: widget.pret,
              tipServiciu: widget.tipServiciu,
              chatOnly: false,
              initialFiles: filePaths,
            ),
          ),
        );
      } else {
        print("❌ Navigation skipped: Widget is not mounted.");
      }
    });
  }

  Future<String?> _uploadFile(File file) async {
    String fileName = path.basename(file.path);
    String extension = path.extension(file.path);
    List<int> fileBytes = await file.readAsBytes();
    String base64File = base64Encode(fileBytes);

    return await apiCallFunctions.adaugaMesajCuAtasamentDinContMedic(
      pCheie: keyAppPacienti,
      pUser: user,
      pParolaMD5: userPassMD5,
      pIdMedic: widget.medic.id.toString(),
      pMesaj: "File Attachment: $fileName$extension",
      pDenumireFisier: fileName,
      pExtensie: extension,
      pSirBitiDocument: base64File,
    );
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

    print("📂 Files selected in RecomandareScreen: ${_selectedFiles.map((f) => f.path).toList()}");
  }

  Future<Uint8List> _generatePdfThumbnail(File file) async {
    final document = await PdfDocument.openFile(file.path);
    final page = await document.getPage(1);
    final pageImage = await page.render(
      width: page.width.toInt(),
      height: page.height.toInt(),
    );
    return Uint8List.fromList(pageImage.pixels);
  }

  void _viewFile(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileViewerScreen(file: file),
      ),
    );
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
              const Align(
                alignment: Alignment.centerLeft, // Move BackButton to the left
                child: BackButton(
                  color: Colors.white,
                ),
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
                                  ? FutureBuilder<Uint8List>(
                                      future: _generatePdfThumbnail(file),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                          return Image.memory(snapshot.data!, fit: BoxFit.cover);
                                        }
                                        return const Icon(Icons.picture_as_pdf, size: 40, color: Colors.red);
                                      },
                                    )
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _showBottomSheet,
      child: Scaffold(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _selectedFiles.length >= _maxFiles ? null : _chooseFromPhone,
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
                        onTap: _selectedFiles.length >= _maxFiles ? null : _openCamera,
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
                  )
                ],
              ),
              const SizedBox(height: 120),
              ElevatedButton(
                onPressed: _sendAttachmentsAndNavigate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text("TRIMITE ÎNTREBAREA", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FileViewerScreen extends StatelessWidget {
  final File file;

  const FileViewerScreen({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isImage = file.path.endsWith(".jpg") || file.path.endsWith(".jpeg") || file.path.endsWith(".png");
    final isPdf = file.path.endsWith(".pdf");

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: isImage
                ? InteractiveViewer(
                    child: Image.file(
                      file,
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.8,
                    ),
                  )
                : isPdf
                    ? PdfViewer.openFile(file.path)
                    : const Text(
                        "Eroare",
                        style: TextStyle(fontSize: 16),
                      ),
          ),
        ),
      ),
    );
  }
}
