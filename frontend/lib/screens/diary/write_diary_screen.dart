import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/particle_background.dart';
import '../../widgets/tahsin_avatar.dart';
import '../../widgets/typing_text.dart';
import '../../widgets/glass_card.dart';

class WriteDiaryScreen extends ConsumerStatefulWidget {
  const WriteDiaryScreen({super.key});

  @override
  ConsumerState<WriteDiaryScreen> createState() => _WriteDiaryScreenState();
}

class _WriteDiaryScreenState extends ConsumerState<WriteDiaryScreen> {
  final _content = TextEditingController();
  final _title = TextEditingController();
  String? _moodSticker;
  bool _loading = false;
  String? _tahsinReply;
  File? _attachedImage;
  final _picker = ImagePicker();

  final _stickers = ['😊', '😢', '😠', '🥰', '😴', '💪', '🌧️', '✨'];

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) setState(() => _attachedImage = File(file.path));
  }

  Future<void> _submit() async {
    if (_content.text.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() { _loading = true; _tahsinReply = null; });

    try {
      if (_attachedImage != null) {
        await ref.read(mediaRepositoryProvider).uploadFile(_attachedImage!);
      }

      final result = await ref.read(diaryRepositoryProvider).createEntry(
        content: _content.text.trim(),
        title: _title.text.trim().isEmpty ? null : _title.text.trim(),
        moodSticker: _moodSticker,
      );

      final reply = result['tahsinReply']?['reply_text'] as String?;
      setState(() => _tahsinReply = reply);

      ref.invalidate(diaryListProvider);
      ref.invalidate(authStateProvider);

      if (mounted && reply != null) {
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved offline or error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pour your heart'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        actions: [
          TextButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ParticleBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _stickers.map((s) {
                    final selected = _moodSticker == s;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _moodSticker = s),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected ? AppColors.pink.withValues(alpha: 0.3) : Colors.transparent,
                            border: Border.all(
                              color: selected ? AppColors.pink : Colors.transparent,
                            ),
                          ),
                          child: Text(s, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _title,
                decoration: const InputDecoration(hintText: 'Title (optional)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_outlined, size: 18),
                    label: const Text('Photo'),
                  ),
                  if (_attachedImage != null) ...[
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_attachedImage!, width: 56, height: 56, fit: BoxFit.cover),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _content,
                maxLines: 12,
                decoration: const InputDecoration(
                  hintText: 'Dear Tahsin, today I feel...',
                  alignLabelWithHint: true,
                ),
              ),
              if (_tahsinReply != null) ...[
                const SizedBox(height: 24),
                GlassCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TahsinAvatar(size: 40, pulsing: false),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tahsin', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.pink)),
                            const SizedBox(height: 8),
                            TypingText(
                              text: _tahsinReply!,
                              style: const TextStyle(height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
