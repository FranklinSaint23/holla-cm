import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/ai_service.dart';
import '../../../main.dart';

class ReviewScreen extends StatefulWidget {
  final String orderId;
  final String partnerId;
  final String partnerName;

  const ReviewScreen({
    super.key,
    required this.orderId,
    required this.partnerId,
    required this.partnerName,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _loading     = false;
  bool _submitted   = false;
  String? _aiResponse;
  String? _sentiment;

  static const _ratingLabels = [
    '', 'Très mauvais 😤', 'Mauvais 😕',
    'Correct 😐', 'Bien 😊', 'Excellent 🤩',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) return;
    setState(() => _loading = true);

    final result = await AIService().submitReview(
      orderId:   widget.orderId,
      clientId:  supabase.auth.currentUser!.id,
      partnerId: widget.partnerId,
      rating:    _rating,
      comment:   _commentController.text.trim().isEmpty
          ? _ratingLabels[_rating]
          : _commentController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _loading     = false;
        _submitted   = true;
        _aiResponse  = result?['ai_response'];
        _sentiment   = result?['sentiment'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HollaColors.grey100,
      appBar: AppBar(
        title: const Text('Laisser un avis'),
        backgroundColor: Colors.white,
        foregroundColor: HollaColors.dark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _submitted ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        // Header partenaire
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: HollaColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront_rounded,
                  color: HollaColors.primary, size: 30),
              ),
              const SizedBox(height: 10),
              Text(widget.partnerName,
                style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              const Text('Comment était votre expérience ?',
                style: TextStyle(
                  color: HollaColors.grey500, fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Étoiles
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final starIndex = i + 1;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = starIndex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        _rating >= starIndex
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 44,
                        color: _rating >= starIndex
                            ? HollaColors.warning
                            : HollaColors.grey300,
                      ),
                    ),
                  );
                }),
              ),
              if (_rating > 0) ...[
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _ratingLabels[_rating],
                    key: ValueKey(_rating),
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: _rating >= 4
                          ? HollaColors.success
                          : _rating >= 3
                              ? HollaColors.warning
                              : HollaColors.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Commentaire
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Commentaire (optionnel)',
                style: TextStyle(
                  fontWeight: FontWeight.w600, fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 4,
                maxLength: 500,
                style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Partagez votre expérience...',
                  hintStyle: const TextStyle(
                    color: HollaColors.grey500, fontFamily: 'Poppins',
                  ),
                  filled: true,
                  fillColor: HollaColors.grey100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Emojis rapides
              Wrap(
                spacing: 8,
                children: [
                  '🍕 Délicieux', '⚡ Rapide', '📦 Bien emballé',
                  '🥶 Froid à l\'arrivée', '⏰ En retard',
                ].map((tag) => GestureDetector(
                  onTap: () {
                    final current = _commentController.text;
                    _commentController.text =
                        current.isEmpty ? tag : '$current, $tag';
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: HollaColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(tag,
                      style: const TextStyle(
                        fontSize: 12, color: HollaColors.primary,
                        fontWeight: FontWeight.w600, fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Bouton soumettre
        GestureDetector(
          onTap: _rating == 0 || _loading ? null : _submit,
          child: AnimatedOpacity(
            opacity: _rating == 0 ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [HollaColors.primary, HollaColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: _rating == 0 ? null : [
                  BoxShadow(
                    color: HollaColors.primary.withOpacity(0.35),
                    blurRadius: 16, offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5,
                        ),
                      )
                    : const Text('Envoyer mon avis',
                        style: TextStyle(
                          color: Colors.white, fontSize: 16,
                          fontWeight: FontWeight.w700, fontFamily: 'Poppins',
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    final isPositive = _sentiment == 'positive';
    final isNegative = _sentiment == 'negative';

    return Column(
      children: [
        const SizedBox(height: 20),
        // Animation succès
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            color: HollaColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded,
            color: HollaColors.success, size: 60),
        ),
        const SizedBox(height: 20),
        const Text('Merci pour votre avis !',
          style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w800,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isPositive
              ? 'Votre avis positif aide d\'autres clients 🎉'
              : isNegative
                  ? 'Votre retour nous aide à nous améliorer 🙏'
                  : 'Merci d\'avoir partagé votre expérience',
          style: const TextStyle(
            color: HollaColors.grey500, fontFamily: 'Poppins',
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Réponse IA du restaurant
        if (_aiResponse != null) ...[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: HollaColors.primaryLight, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: HollaColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront_rounded,
                        color: HollaColors.primary, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(widget.partnerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700, fontFamily: 'Poppins',
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: HollaColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('🤖 IA',
                        style: TextStyle(
                          fontSize: 10, color: HollaColors.primary,
                          fontWeight: FontWeight.w700, fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(_aiResponse!,
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 14,
                    color: HollaColors.dark, height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Bouton retour
        GestureDetector(
          onTap: () => context.go('/'),
          child: Container(
            height: 52, width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [HollaColors.primary, HollaColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text("Retour à l'accueil",
                style: TextStyle(
                  color: Colors.white, fontSize: 15,
                  fontWeight: FontWeight.w700, fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}