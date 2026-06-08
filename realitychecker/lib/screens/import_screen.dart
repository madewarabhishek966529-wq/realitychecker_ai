import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/openai_service.dart';
import '../services/pdf_extractor_service.dart';
import '../services/hive_storage_service.dart';
import '../models/study_deck_model.dart';
import 'package:uuid/uuid.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  static const _uuid = Uuid();

  String? _extractedText;
  String? _pdfFileName;
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Extracting text from PDF…';
    });
    try {
      final result = await PdfExtractorService.pickAndExtract();
      if (result != null) {
        setState(() {
          _extractedText = result.text;
          _pdfFileName = result.fileName;
          _titleController.text =
              result.fileName.replaceAll('.pdf', '').replaceAll('_', ' ');
        });
      }
    } catch (e) {
      _showError('Failed to extract PDF: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _statusMessage = null;
      });
    }
  }

  String get _activeText {
    if (_tabController.index == 0) return _extractedText ?? '';
    return _textController.text.trim();
  }

  Future<void> _generate() async {
    final text = _activeText;
    if (text.isEmpty) {
      _showError('Please add text first');
      return;
    }
    final title = _titleController.text.trim().isEmpty
        ? 'Untitled Deck'
        : _titleController.text.trim();

    setState(() {
      _isLoading = true;
      _statusMessage = '🤖 Generating flashcards with AI…';
    });

    try {
      final content = await OpenAiService.generateStudyContent(text);

      final deck = StudyDeck(id: _uuid.v4(), title: title);
      deck.flashcards = content.flashcards;
      deck.quizQuestions = content.quizQuestions;

      await HiveStorageService.saveDeck(deck);

      if (mounted) {
        setState(() {
          _statusMessage = '✅ ${content.flashcards.length} cards generated!';
        });
        await Future.delayed(const Duration(milliseconds: 900));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = null;
        });
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.outfit()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        title: Text('New Deck',
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF818CF8),
          unselectedLabelColor: Colors.white38,
          indicatorColor: const Color(0xFF818CF8),
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.picture_as_pdf_rounded), text: 'Import PDF'),
            Tab(icon: Icon(Icons.edit_note_rounded), text: 'Paste Text'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPdfTab(),
                _buildTextTab(),
              ],
            ),
          ),
          _buildBottom(),
        ],
      ),
    );
  }

  Widget _buildPdfTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _isLoading ? null : _pickPdf,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF818CF8).withOpacity(0.4), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.upload_file_rounded,
                      color: Color(0xFF818CF8), size: 40),
                  const SizedBox(height: 12),
                  Text('Tap to pick a PDF',
                      style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          if (_extractedText != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF34D399), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _pdfFileName ?? '',
                    style: GoogleFonts.outfit(
                        color: const Color(0xFF34D399),
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 160,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: SingleChildScrollView(
                child: Text(_extractedText!,
                    style: GoogleFonts.outfit(
                        color: Colors.white54, fontSize: 13, height: 1.6)),
              ),
            ),
            const SizedBox(height: 20),
            _titleField(),
          ],
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildTextTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            maxLines: 10,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText:
                  'Paste your study notes, lecture text, or any content…',
              hintStyle: GoogleFonts.outfit(color: Colors.white30),
              filled: true,
              fillColor: const Color(0xFF1A1A2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.white12, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: Color(0xFF818CF8), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _titleField(),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _titleField() {
    return TextField(
      controller: _titleController,
      style: GoogleFonts.outfit(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Deck title',
        labelStyle: GoogleFonts.outfit(color: Colors.white54),
        prefixIcon: const Icon(Icons.drive_file_rename_outline_rounded,
            color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF818CF8), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildBottom() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A1A),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          if (_statusMessage != null) ...[
            Text(_statusMessage!,
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _generate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF818CF8),
                disabledBackgroundColor: Colors.white12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.auto_awesome_rounded, color: Colors.white),
              label: Text(
                _isLoading ? 'Generating…' : 'Generate with AI',
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
