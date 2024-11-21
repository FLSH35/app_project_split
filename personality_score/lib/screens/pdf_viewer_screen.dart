import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:html' as html;

/// Preload the certificate data and store it in memory
class CertificateManager {
  Uint8List? _certificateBytes;



  /// Generate the certificate and store it in memory
  Future<void> preloadCertificateData({
    required String title,
    required String name,
  }) async {
    // Start loading resources
    final ByteData pngData = await rootBundle.load('Input_Certificate.png');
    final Uint8List pngBytes = pngData.buffer.asUint8List();

    final ByteData goudyFontData = await rootBundle.load('fonts/SortsMillGoudy-Italic.ttf');
    final pw.Font sortsMillGoudyFont = pw.Font.ttf(goudyFontData);

    final ByteData alexBrushFontData = await rootBundle.load('fonts/AlexBrush-Regular.ttf');
    final pw.Font alexBrushFont = pw.Font.ttf(alexBrushFontData);

    // Build the PDF
    final pw.Document pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          final pageWidth = PdfPageFormat.a4.width;
          final pageHeight = PdfPageFormat.a4.height;

          return pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Image(
                  pw.MemoryImage(pngBytes),
                  fit: pw.BoxFit.fill,
                ),
              ),
              pw.Positioned(
                left: pageWidth / 2.9,
                top: pageHeight * 0.2,
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    font: sortsMillGoudyFont,
                    fontSize: 53,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Positioned(
                left: pageWidth / 2.9,
                top: pageHeight * 0.4,
                child: pw.Text(
                  name,
                  style: pw.TextStyle(
                    font: alexBrushFont,
                    fontSize: 80,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save the certificate bytes
    _certificateBytes = await pdf.save();
  }


  /// Get the preloaded certificate bytes
  Uint8List? get certificateBytes => _certificateBytes;
}

/// CertificateManager instance
final certificateManager = CertificateManager();

/// Function to download the preloaded certificate
void _downloadGeneratedCertificate() {
  try {
    if (certificateManager.certificateBytes == null) {
      throw Exception("Certificate not preloaded!");
    }

    final Uint8List certificateBytes = certificateManager.certificateBytes!;
    final blob = html.Blob([certificateBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..download = 'certificate_generated.pdf'
      ..target = 'blank';
    anchor.click();

    html.Url.revokeObjectUrl(url);
  } catch (e) {
    print('Error downloading preloaded certificate: $e');
  }
}

/// Function to download the existing PDF
Future<void> _downloadExistingPDF() async {
  try {
    final ByteData pdfData = await rootBundle.load('Input_Certificate.pdf');
    final Uint8List pdfBytes = pdfData.buffer.asUint8List();

    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..download = 'Input_Certificate.pdf'
      ..target = 'blank';
    anchor.click();

    html.Url.revokeObjectUrl(url);
  } catch (e) {
    print('Error downloading existing PDF: $e');
  }
}

/// PDFListItem widget for individual PDF items
class PDFListItem extends StatelessWidget {
  final String pdfName;
  final VoidCallback? onDownload;
  final bool isLoading;

  PDFListItem({
    required this.pdfName,
    this.onDownload,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(pdfName),
      trailing: isLoading
          ? SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(),
      )
          : IconButton(
        icon: Icon(Icons.download),
        tooltip: 'Herunterladen',
        onPressed: onDownload,
      ),
    );
  }
}
