import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/product_service.dart';
import '../theme/colors.dart';
import '../utils/booklist_text.dart';
import '../utils/formatters.dart';

/// Minimum word overlap to pre-tick a match; below this it is only suggested.
const double _confident = 0.6;
const double _possible = 0.34;

class _Match {
  _Match(this.line, this.product, this.score)
      : selected = product != null && score >= _confident;
  final String line;
  final Product? product;
  final double score;
  bool selected;
  bool get isConfident => score >= _confident;
}

/// Photograph a printed booklist: the text is read on-device (ML Kit), each
/// line is searched in the live catalogue, and matches can be added to cart.
class ScanBooklistScreen extends StatefulWidget {
  const ScanBooklistScreen({super.key});

  @override
  State<ScanBooklistScreen> createState() => _ScanBooklistScreenState();
}

class _ScanBooklistScreenState extends State<ScanBooklistScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _working = false;
  String? _error;
  List<_Match> _matches = [];

  /// Searches the catalogue and returns the best-scoring hit (or none).
  Future<(Product?, double)> _search(String line) async {
    Future<(Product?, double)> best(String q) async {
      final page = await ApiProductService.instance
          .fetchApiProducts(keyword: q, perPage: 10);
      Product? top;
      var topScore = 0.0;
      for (final api in page.data.take(10)) {
        final p = Product.fromApi(api);
        final score = matchScore(line, p.title);
        if (score > topScore) {
          top = p;
          topScore = score;
        }
      }
      return (top, topScore);
    }

    try {
      var (hit, score) = await best(line);
      if (score < _confident) {
        final words = line.split(' ');
        if (words.length > 3) {
          final (h2, s2) = await best(words.take(3).join(' '));
          if (s2 > score) {
            hit = h2;
            score = s2;
          }
        }
      }
      return (score >= _possible ? hit : null, score);
    } catch (_) {
      return (null, 0.0);
    }
  }

  Future<void> _pick(ImageSource source) async {
    if (kIsWeb) {
      setState(() => _error =
          'Scanning works in the Android and iOS app, not in the browser.');
      return;
    }
    final XFile? file;
    try {
      file = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2400,
      );
    } catch (e) {
      setState(() => _error = 'Could not open the camera or gallery.');
      return;
    }
    if (file == null) return;
    setState(() {
      _image = file;
      _working = true;
      _error = null;
      _matches = [];
    });

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final text =
          await recognizer.processImage(InputImage.fromFilePath(file.path));
      final lines = cleanBooklistLines([
        for (final b in text.blocks)
          for (final l in b.lines) l.text,
      ]);
      if (lines.isEmpty) {
        setState(() {
          _working = false;
          _error = 'We could not read any text. Try a clearer, well-lit photo.';
        });
        return;
      }
      final results = <_Match>[];
      for (var i = 0; i < lines.length; i += 5) {
        final batch = lines.skip(i).take(5).toList();
        final found = await Future.wait(batch.map(_search));
        for (var j = 0; j < batch.length; j++) {
          results.add(_Match(batch[j], found[j].$1, found[j].$2));
        }
      }
      if (!mounted) return;
      setState(() {
        _matches = results;
        _working = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _working = false;
        _error = 'Scanning failed. Please try again.';
      });
    } finally {
      await recognizer.close();
    }
  }

  void _addSelected() {
    final cart = context.read<CartProvider>();
    var n = 0;
    for (final m in _matches) {
      if (m.selected && m.product != null) {
        cart.addItem(m.product!);
        n++;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$n books added to cart'),
        backgroundColor: AppColors.primaryPurple,
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _sendPhoto() async {
    final file = _image;
    if (file == null) return;
    await SharePlus.instance.share(ShareParams(
      text: 'MyBidhaa booklist photo. Please quote the books and prices.',
      files: [XFile(file.path)],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final selected = _matches.where((m) => m.selected && m.product != null);
    final matched = _matches.where((m) => m.isConfident).length;
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Scan booklist',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_image == null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: const Column(
                children: [
                  Icon(Icons.document_scanner_outlined,
                      size: 56, color: AppColors.primaryPurple),
                  SizedBox(height: 12),
                  Text(
                    "Photograph your school's booklist",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We read the titles on your phone and find the matching '
                    'books. Use good light and keep the page flat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: kIsWeb
                    ? Image.network(_image!.path, fit: BoxFit.cover)
                    : Image.file(File(_image!.path), fit: BoxFit.cover),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _working ? null : () => _pick(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(_image == null ? 'Take photo' : 'Retake'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _working ? null : () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_working) ...[
            const SizedBox(height: 28),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 12),
            const Center(
              child: Text('Reading your list and finding books...',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_error!,
                  style: const TextStyle(color: Color(0xFF991B1B))),
            ),
          ],
          if (_matches.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              '$matched of ${_matches.length} lines matched a book with confidence',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < _matches.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    _row(_matches[i]),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: selected.isEmpty ? null : _addSelected,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              child: Text('Add ${selected.length} selected to cart'),
            ),
          ],
          if (_image != null && !_working) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _sendPhoto,
              icon: const Icon(Icons.chat_outlined),
              label: const Text('Not right? Send the photo on WhatsApp'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF147A3F),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(_Match m) {
    final p = m.product;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Checkbox(
            value: m.selected,
            onChanged: p == null ? null : (v) => setState(() => m.selected = v ?? false),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Read: ${m.line}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                if (p != null && !m.isConfident)
                  const Text('Possible match, please check',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB45309))),
                Text(
                  p?.title ?? 'No matching book found',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: p == null ? FontWeight.w400 : FontWeight.w600,
                    color: p == null
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (p != null)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Text(
                formatKES(p.newPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
