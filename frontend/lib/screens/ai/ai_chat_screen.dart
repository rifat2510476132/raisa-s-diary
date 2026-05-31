import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/chat_message_model.dart';
import '../../providers/providers.dart';
import '../../widgets/particle_background.dart';
import '../../widgets/tahsin_avatar.dart';

final chatMessagesProvider = FutureProvider.autoDispose<List<ChatMessageModel>>((ref) async {
  return ref.watch(aiChatRepositoryProvider).getMessages();
});

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;
  final List<ChatMessageModel> _localMessages = [];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      _localMessages.add(
        ChatMessageModel(
          id: 'local-${DateTime.now().millisecondsSinceEpoch}',
          role: 'user',
          content: text,
          createdAt: DateTime.now(),
        ),
      );
      _controller.clear();
    });
    _scrollToEnd();

    try {
      await HapticService.light();
      await ref.read(aiChatRepositoryProvider).sendMessage(text);
      if (!mounted) return;
      setState(() {
        _localMessages.clear();
        _sending = false;
      });
      ref.invalidate(chatMessagesProvider);
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not reach Tahsin: $e')),
      );
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(chatMessagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TahsinAvatar(size: 36, pulsing: false),
            SizedBox(width: 10),
            Text('Chat with Tahsin'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear chat?'),
                  content: const Text('This removes your conversation history with Tahsin.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear')),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(aiChatRepositoryProvider).clearHistory();
                setState(() => _localMessages.clear());
                ref.invalidate(chatMessagesProvider);
              }
            },
          ),
        ],
      ),
      body: ParticleBackground(
        child: Column(
          children: [
            Expanded(
              child: history.when(
                data: (serverMessages) {
                  final merged = <ChatMessageModel>[
                    ...serverMessages,
                    ..._localMessages.where(
                      (m) => !serverMessages.any((s) => s.id == m.id),
                    ),
                  ];
                  merged.sort((a, b) => a.createdAt.compareTo(b.createdAt));

                  if (merged.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Say hi to Tahsin 💕\nHe is always here for you, Raisa.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: merged.length + (_sending ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == merged.length) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              TahsinAvatar(size: 32, pulsing: true),
                              SizedBox(width: 12),
                              Text('Tahsin is typing...', style: TextStyle(color: AppColors.pink)),
                            ],
                          ),
                        );
                      }
                      return _ChatBubble(message: merged[i]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) {
                  if (_localMessages.isNotEmpty) {
                    return ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(16),
                      itemCount: _localMessages.length,
                      itemBuilder: (_, i) => _ChatBubble(message: _localMessages[i]),
                    );
                  }
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Start a conversation with Tahsin'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(chatMessagesProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLines: 4,
                        minLines: 1,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Message Tahsin...',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _sending ? null : _send,
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.pink.withValues(alpha: 0.25)
              : Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Text(message.content),
      ),
    );
  }
}
