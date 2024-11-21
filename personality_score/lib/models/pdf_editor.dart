import 'dart:typed_data';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart' as pw;
import 'package:pdf/widgets.dart' as pwWidgets;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusionPdf; // Prefix added

class PDFEditor {
  // Step 1: Fetch original PDF as bytes
  Future<Uint8List> fetchOriginalPDF(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception("Failed to load PDF.");
    }
  }

  // Step 2: Preload fonts
  Future<pwWidgets.Font> loadFont(String fontPath) async {
    final fontData = await rootBundle.load(fontPath);
    return pwWidgets.Font.ttf(fontData);
  }

  // Step 3: Create an overlay PDF
  Future<Uint8List> createTextOverlay({
    required String title,
    required String name,
    required pw.PdfPageFormat pageSize,
    required pwWidgets.Font titleFont,
    required pwWidgets.Font nameFont,
  }) async {
    final pdf = pwWidgets.Document();

    pdf.addPage(
      pwWidgets.Page(
        pageFormat: pageSize,
        build: (pwWidgets.Context context) {
          return pwWidgets.Stack(
            children: [
              pwWidgets.Positioned(
                left: 217.66,
                top: 428.03,
                child: pwWidgets.Text(
                  title,
                  style: pwWidgets.TextStyle(
                    font: titleFont,
                    fontSize: 53,
                  ),
                ),
              ),
              pwWidgets.Positioned(
                left: 272.11,
                top: 335.97,
                child: pwWidgets.Text(
                  name,
                  style: pwWidgets.TextStyle(
                    font: nameFont,
                    fontSize: 80,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Step 4: Merge the overlay with the original PDF
  Future<Uint8List> mergePDFs(Uint8List originalPDF, Uint8List overlayPDF) async {
    // Load the original PDF document
    syncfusionPdf.PdfDocument originalDoc = syncfusionPdf.PdfDocument(inputBytes: originalPDF);

    // Load the overlay PDF document
    syncfusionPdf.PdfDocument overlayDoc = syncfusionPdf.PdfDocument(inputBytes: overlayPDF);

    // Get the first page of the original PDF
    syncfusionPdf.PdfPage page = originalDoc.pages[0];

    // Create a template from the overlay PDF's first page
    syncfusionPdf.PdfTemplate template = overlayDoc.pages[0].createTemplate();

    // Draw the overlay template onto the original PDF page
    page.graphics.drawPdfTemplate(
      template,
      Offset(0, 0),
      Size(page.size.width, page.size.height),
    );

    // Save the modified PDF document asynchronously
    List<int> bytes = await originalDoc.save();

    // Dispose the documents
    originalDoc.dispose();
    overlayDoc.dispose();

    return Uint8List.fromList(bytes);
  }


  // Step 5: Trigger the download
  Future<void> downloadModifiedPDF(BuildContext context, Uint8List modifiedPDF) async {
    await Printing.sharePdf(
      bytes: modifiedPDF,
      filename: 'Updated_Certificate.pdf',
    );
  }
}
