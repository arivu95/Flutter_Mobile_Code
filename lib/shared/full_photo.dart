import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:swarapp/shared/app_colors.dart';

class FullPhoto extends StatelessWidget {
  final String? url;
  final String? title;
  final String? file_type;
  FullPhoto({Key? key, required this.url, required this.title, required this.file_type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title!,
          style: TextStyle(color: activeColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FullPhotoScreen(url: url, file_type: file_type),
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  final String? url;
  final String? file_type;

  FullPhotoScreen({Key? key, required this.url, required this.file_type}) : super(key: key);

  @override
  State createState() => FullPhotoScreenState(url: url, file_type: file_type);
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  final String? url;

  final String? file_type;

  FullPhotoScreenState({Key? key, required this.url, required this.file_type});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PDFDocument document = PDFDocument.fromURL(
      "https://swartest.blob.core.windows.net/swardoctor/maternity_6104fb42aca56f09801e52a5_1628137792306.pdf",
    ) as PDFDocument;
    if (file_type == "pdf") {
      return PDFViewer(document: document, zoomSteps: 1);
    } else {
      return Container(child: PhotoView(imageProvider: NetworkImage(url!)));
    }
  }
}
