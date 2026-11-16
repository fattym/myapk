import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/colors.dart';

/// Pick a booklist (photo or PDF) and send it to MyBidhaa on WhatsApp.
class UploadBooklistScreen extends StatefulWidget {
  const UploadBooklistScreen({super.key});

  @override
  State<UploadBooklistScreen> createState() => _UploadBooklistScreenState();
}

class _UploadBooklistScreenState extends State<UploadBooklistScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _note = TextEditingController();
  String? _path;
  String? _name;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _photo(ImageSource source) async {
    try {
      final f = await _picker.pickImage(source: source, imageQuality: 90);
      if (f != null) {
        setState(() {
          _path = f.path;
          _name = f.name;
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = 'Could not open the camera or gallery: $e');
    }
  }

  Future<void> _file() async {
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (picked.isNotEmpty && picked.first.path != null) {
        setState(() {
          _path = picked.first.path;
          _name = picked.first.name;
          _error = null;
        });
      }
    } catch (_) {
      setState(() => _error = 'Could not open the file picker.');
    }
  }

  Future<void> _send() async {
    final path = _path;
    if (path == null) return;
    final note = _note.text.trim();
    try {
      final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(ShareParams(
      // iPad needs an anchor for the share popover.
      sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
        text: note.isEmpty
            ? 'MyBidhaa booklist. Please quote the books and prices. '
                '(Send to WhatsApp +254 797 100 500)'
            : 'MyBidhaa booklist: $note\nPlease quote the books and prices. '
                '(Send to WhatsApp +254 797 100 500)',
        files: [XFile(path)],
      ));
    } catch (_) {
      setState(() => _error = 'Could not open the share sheet.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Upload booklist',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Send us your school\'s booklist (photo or PDF) and we will '
            'reply on WhatsApp with the books and prices.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          if (!kIsWeb)
            Row(
              children: [
                Expanded(child: _source(Icons.photo_camera_outlined, 'Camera', () => _photo(ImageSource.camera))),
                const SizedBox(width: 10),
                Expanded(child: _source(Icons.photo_library_outlined, 'Gallery', () => _photo(ImageSource.gallery))),
                const SizedBox(width: 10),
                Expanded(child: _source(Icons.picture_as_pdf_outlined, 'PDF / file', _file)),
              ],
            )
          else
            const Text('Uploading works in the Android and iOS app.',
                style: TextStyle(color: AppColors.textSecondary)),
          if (_name != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined,
                      color: AppColors.primaryPurple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_name!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ),
                  IconButton(
                    tooltip: 'Remove file',
                    onPressed: () => setState(() {
                      _path = null;
                      _name = null;
                    }),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              decoration: const InputDecoration(
                labelText: 'School and grade (optional)',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Color(0xFF991B1B))),
          ],
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _path == null ? null : _send,
            icon: const Icon(Icons.chat_outlined),
            label: const Text('Send to MyBidhaa WhatsApp (+254 797 100 500)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF147A3F),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'In the share sheet choose WhatsApp, then the MyBidhaa chat '
            '(+254 797 100 500).',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _source(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryPurple, size: 26),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
