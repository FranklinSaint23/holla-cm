import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../main.dart';

final chatMessagesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, orderId) {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('order_id', orderId)
        .order('created_at')
        .map((rows) => List<Map<String, dynamic>>.from(rows));
  },
);

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: HollaColors.grey100,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.white,
        foregroundColor: HollaColors.dark,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💬', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('Vos messages',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Les conversations avec vos livreurs\napparaîtront ici',
              style: TextStyle(
                color: HollaColors.grey500, fontFamily: 'Poppins',
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── CONVERSATION AVEC UN LIVREUR ──────────────────────────
class ConversationScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String agentName;
  const ConversationScreen({
    super.key,
    required this.orderId,
    required this.agentName,
  });

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    await supabase.from('messages').insert({
      'order_id':  widget.orderId,
      'sender_id': supabase.auth.currentUser!.id,
      'content':   text,
    });

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider(widget.orderId));
    final myId     = supabase.auth.currentUser!.id;

    return Scaffold(
      backgroundColor: HollaColors.grey100,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(
                color: HollaColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.agentName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: HollaColors.primary, fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.agentName,
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const Text('Votre livreur',
                  style: TextStyle(
                    fontSize: 11, color: HollaColors.success,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: HollaColors.dark,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: messages.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: HollaColors.primary),
              ),
              error: (e, _) => Center(child: Text('$e')),
              data: (list) => ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final msg   = list[i];
                  final isMe  = msg['sender_id'] == myId;
                  final text  = msg['content'] as String;

                  return Align(
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: isMe
                            ? HollaColors.primary
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft:     const Radius.circular(16),
                          topRight:    const Radius.circular(16),
                          bottomLeft:  Radius.circular(isMe ? 16 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(text,
                        style: TextStyle(
                          color: isMe ? Colors.white : HollaColors.dark,
                          fontSize: 14, fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Input message
          Container(
            padding: EdgeInsets.only(
              left: 16, right: 8, top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            ),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      hintText: 'Écrire un message...',
                      hintStyle: const TextStyle(
                        color: HollaColors.grey500, fontFamily: 'Poppins',
                      ),
                      filled: true,
                      fillColor: HollaColors.grey100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [HollaColors.primary, HollaColors.primaryDark],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: HollaColors.primary.withOpacity(0.35),
                          blurRadius: 8, offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}