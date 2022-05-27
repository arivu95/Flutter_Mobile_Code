import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';

class PdfViewr extends StatefulWidget {
  final String url, file_name;

  const PdfViewr({Key? key, required this.url, required this.file_name}) : super(key: key);
  @override
  PdfViewrState createState() => PdfViewrState();
}

class PdfViewrState extends State<PdfViewr> {
  bool _isLoading = true;
  late PDFDocument document;
  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  @override
  void dispose() {
    document.clearImageCache();
    super.dispose();
  }

  loadDocument() async {
    document = await PDFDocument.fromAsset('assets/sample.pdf');
    changePDF(widget.url);
  }

  changePDF(value) async {
    PDFDocument docu = await PDFDocument.fromURL(value);
    setState(() {
      document = docu;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.file_name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: Center(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : PDFViewer(
                  document: document,
                  zoomSteps: 1,
                ),
        ),
      ),
    );
  }
}
