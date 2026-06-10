import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/ai_service.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../main.dart';

class AIAssistantScreen extends ConsumerStatefulWidget {
  final String? initialConversationId;

  const AIAssistantScreen({
    super.key,
    this.initialConversationId,
  });

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final _controller       = TextEditingController();
  final _scrollController = ScrollController();
  final _aiService        = AIService();

  String? _conversationId;
  bool _loading = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'assistant',
      'content': '👋 Bonjour ! Je suis HOLLA Assistant. Comment puis-je vous aider ?\n\nJe peux vous informer sur :\n🍽️ Les offres du jour\n📦 Le suivi de vos commandes\n🔧 Les services disponibles\n💳 L\'aide au paiement',
    },
  ];

  // Questions rapides Gojek-style
  static const _quickReplies = [
    '🍕 Offres du jour',
    '📦 Ma commande',
    '💳 Problème paiement',
    '🔧 Services dispo',
    '⭐ Laisser un avis',
  ];

  @override
  void initState() {
    super.initState();
    // On récupère l'identifiant de conversation initial fourni par GoRoute
    _conversationId = widget.initialConversationId;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _loading = true;
    });

    _scrollToBottom();

    final userId = supabase.auth.currentUser?.id ?? '';

    final result = await _aiService.sendMessage(
      clientId:       userId,
      message:        text,
      conversationId: _conversationId,
    );

    if (mounted) {
      setState(() {
        _loading = false;
        if (result != null) {
          _conversationId = result['conversation_id'];
          _messages.add({
            'role':    'assistant',
            'content': result['response'],
          });
        } else {
          _messages.add({
            'role':    'assistant',
            'content': '😕 Désolé, je ne suis pas disponible en ce moment. Réessayez dans quelques instants.',
          });
        }
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HollaColors.grey100,
      appBar: AppBar(
        backgroundColor: HollaColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('HOLLA Assistant',
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text('En ligne',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length) return _buildTyping();
                final msg   = _messages[i];
                final isMe  = msg['role'] == 'user';
                return _buildMessage(msg['content'] as String, isMe);
              },
            ),
          ),

          // Quick replies
          if (_messages.length <= 1)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickReplies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _send(_quickReplies[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: HollaColors.primary),
                    ),
                    child: Text(_quickReplies[i],
                      style: const TextStyle(
                        color: HollaColors.primary, fontSize: 13,
                        fontWeight: FontWeight.w600, fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Input
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
                    style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Posez votre question...',
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
                    onSubmitted: _send,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _send(_controller.text),
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

  Widget _buildMessage(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Avatar IA
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22, height: 22,
                      decoration: const BoxDecoration(
                        color: HollaColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🤖', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('HOLLA AI',
                      style: TextStyle(
                        fontSize: 10, color: HollaColors.grey500,
                        fontFamily: 'Poppins', fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? HollaColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(18),
                  topRight:    const Radius.circular(18),
                  bottomLeft:  Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6, offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(text,
                style: TextStyle(
                  color: isMe ? Colors.white : HollaColors.dark,
                  fontSize: 14, fontFamily: 'Poppins', height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTyping() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft:     Radius.circular(18),
            topRight:    Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft:  Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => _Dot(delay: i * 200)),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(
      width: 8, height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: const BoxDecoration(
        color: HollaColors.primary, shape: BoxShape.circle,
      ),
    ),
  );
}