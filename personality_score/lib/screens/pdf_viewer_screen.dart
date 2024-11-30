import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:html' as html;

/// Preload the certificate data and store it in memory
class CertificateManager {
  Uint8List? _certificateBytes;

  /// Get the preloaded certificate bytes
  Uint8List? get certificateBytes => _certificateBytes;
}

/// CertificateManager instance
final certificateManager = CertificateManager();

/// Function to download the existing PDF
Future<void> downloadExistingPDFFromFirebase(String storagePath, String fileName) async {
  try {
    // Get the Firebase Storage reference
    final storageRef = FirebaseStorage.instance.refFromURL(storagePath);

    // Get the download URL for the file
    final String downloadUrl = await storageRef.getDownloadURL();

    // Create an anchor element to trigger the download
    final html.AnchorElement anchor = html.AnchorElement(href: downloadUrl)
      ..download = fileName
      ..target = 'blank';

    // Trigger the click to download the file
    anchor.click();
  } catch (e) {
    print('Error downloading PDF from Firebase Storage: $e');
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
