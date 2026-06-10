import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../main.dart';

class AIHistoryScreen extends StatelessWidget {
  const AIHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: HollaColors.grey100,
      appBar: AppBar(
        title: const Text('Mes conversations IA'),
        backgroundColor: Colors.white,
        foregroundColor: HollaColors.dark,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: supabase
            .from('ai_conversations')
            .select()
            .eq('client_id', userId!)
            .order('updated_at', ascending: false),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: HollaColors.primary),
            );
          }
          final list = snap.data as List? ?? [];
          if (list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('💬', style: TextStyle(fontSize: 56)),
                  SizedBox(height: 16),
                  Text('Aucune conversation',
                    style: TextStyle(
                      fontSize: 16, fontFamily: 'Poppins',
                      color: HollaColors.grey500,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final conv = list[i] as Map<String, dynamic>;
              final msgs = conv['messages'] as List? ?? [];
              final lastMsg = msgs.isNotEmpty
                  ? (msgs.last as Map)['content'] as String? ?? ''
                  : '';
              final date = DateTime.parse(conv['updated_at']);

              return GestureDetector(
                onTap: () => context.push(
                  '/ai-assistant',
                  extra: {'conversationId': conv['id']},
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: HollaColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🤖', style: TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('HOLLA Assistant',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins', fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(lastMsg,
                              style: const TextStyle(
                                fontSize: 12, color: HollaColors.grey500,
                                fontFamily: 'Poppins',
                              ),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${date.day}/${date.month}',
                        style: const TextStyle(
                          fontSize: 11, color: HollaColors.grey500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}