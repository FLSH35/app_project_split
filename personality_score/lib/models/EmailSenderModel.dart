import 'dart:io' show File, Directory;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:universal_html/html.dart' as html;

class EmailSenderModel {
  /// Generates a PDF certificate with the provided details.
  Future<File?> generateCertificate({
    required String name,
    required String personalityType,
    required int percentage,
  }) async {
    final pdf = pw.Document();

    // Load the certificate background
    final ByteData backgroundData = await rootBundle.load('assets/Input_Certificate.pdf');
    final Uint8List backgroundBytes = backgroundData.buffer.asUint8List();

    // Load fonts before the build method
    final pw.Font fontAlexBrush = pw.Font.ttf(await rootBundle.load('assets/fonts/AlexBrush-Regular.ttf'));
    final pw.Font fontSortsMillGoudy = pw.Font.ttf(await rootBundle.load('assets/fonts/SortsMillGoudy-Italic.ttf'));

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Image(
                  pw.MemoryImage(backgroundBytes),
                  fit: pw.BoxFit.cover,
                ),
              ),
              // Name
              pw.Positioned(
                left: 270,
                top: 230,
                child: pw.Text(
                  name,
                  style: pw.TextStyle(
                    fontSize: 40,
                    font: fontAlexBrush,
                  ),
                ),
              ),
              // Personality Type
              pw.Positioned(
                left: 220,
                top: 400,
                child: pw.Text(
                  personalityType,
                  style: pw.TextStyle(
                    fontSize: 33,
                    font: fontSortsMillGoudy,
                  ),
                ),
              ),
              // Percentage
              pw.Positioned(
                left: 300,
                top: 500,
                child: pw.Text(
                  '$percentage%',
                  style: pw.TextStyle(
                    fontSize: 30,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();

    if (kIsWeb) {
      // For web, prompt the user to download the PDF
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..download = 'Certificate.pdf'
        ..click();
      html.Url.revokeObjectUrl(url);
      return null; // Return null since we can't return a File on web
    } else {
      // For mobile and desktop platforms
      final Directory tempDir = await getTemporaryDirectory();
      final File pdfFile = File('${tempDir.path}/Certificate.pdf');
      await pdfFile.writeAsBytes(bytes);
      return pdfFile;
    }
  }

  /// Sends the results via email to the specified email address.
  Future<void> sendResultByEmail(
      String email,
      String finalCharacter,
      String finalCharacterDescription,
      int finalScore,
      ) async {
    if (kIsWeb) {
      // For web, open mail client (attachments not supported via mailto)
      final subject = Uri.encodeComponent('Your Certificate');
      final body = Uri.encodeComponent('Please find your certificate attached.');
      final mailtoLink = 'mailto:$email?subject=$subject&body=$body';
      html.window.open(mailtoLink, '_blank');
    } else {
      // For mobile and desktop platforms
      try {
        // Load the existing file from assets
        final ByteData fileData = await rootBundle.load('assets/Input_Certificate.pdf');
        final Directory tempDir = await getTemporaryDirectory();
        final File pdfFile = File('${tempDir.path}/Input_Certificate.pdf');

        // Write the file to the temporary directory
        await pdfFile.writeAsBytes(fileData.buffer.asUint8List());

        // Create the email with the existing file as an attachment
        final Email emailToSend = Email(
          body: 'Please find attached your certificate.',
          subject: 'Your Certificate',
          recipients: [email],
          attachmentPaths: [pdfFile.path],
          isHTML: false,
        );

        await FlutterEmailSender.send(emailToSend);
      } catch (e) {
        print('Error while sending email: $e');
        throw Exception('Failed to send email with attachment.');
      }
    }
  }

}
