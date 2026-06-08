import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfExtractorService {
  /// Opens the file picker and extracts text from the selected PDF.
  /// Returns null if user cancels.
  static Future<PdfExtractionResult?> pickAndExtract() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return null;

    final document = PdfDocument(inputBytes: bytes);
    final extractor = PdfTextExtractor(document);
    final buffer = StringBuffer();

    for (int i = 0; i < document.pages.count; i++) {
      final text = extractor.extractText(startPageIndex: i, endPageIndex: i);
      buffer.write(text);
      buffer.write('\n\n');
    }

    document.dispose();

    return PdfExtractionResult(
      fileName: file.name,
      text: buffer.toString().trim(),
    );
  }
}

class PdfExtractionResult {
  final String fileName;
  final String text;

  PdfExtractionResult({required this.fileName, required this.text});
}
