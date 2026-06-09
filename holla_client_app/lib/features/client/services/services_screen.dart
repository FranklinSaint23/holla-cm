import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../main.dart';

const _skills = [
  {'key': 'plumbing',     'label': 'Plomberie',     'emoji': '🔧', 'color': 0xFF1E88E5},
  {'key': 'electricity',  'label': 'Électricité',   'emoji': '⚡', 'color': 0xFFFFB800},
  {'key': 'cleaning',     'label': 'Ménage',        'emoji': '🧹', 'color': 0xFF00B14F},
  {'key': 'painting',     'label': 'Peinture',      'emoji': '🎨', 'color': 0xFFE53935},
  {'key': 'carpentry',    'label': 'Menuiserie',    'emoji': '🪚', 'color': 0xFF795548},
  {'key': 'aircon',       'label': 'Climatisation', 'emoji': '❄️', 'color': 0xFF00C2CB},
  {'key': 'it',           'label': 'Informatique',  'emoji': '💻', 'color': 0xFF5B2EE8},
  {'key': 'security',     'label': 'Sécurité',      'emoji': '🔒', 'color': 0xFF424242},
];

final providersProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, skill) async {
    final data = await supabase
        .from('providers')
        .select('*, profiles(name, avatar_url)')
        .eq('skill', skill)
        .eq('is_available', true)
        .order('rating', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  },
);

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  String? _selectedSkill;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HollaColors.grey100,
      appBar: AppBar(
        title: const Text('Services à domicile'),
        backgroundColor: Colors.white,
        foregroundColor: HollaColors.dark,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── GRILLE SKILLS GOJEK-STYLE ──────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Que recherchez-vous ?',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _skills.length,
                    itemBuilder: (_, i) {
                      final skill = _skills[i];
                      final color = Color(skill['color'] as int);
                      final isSelected = _selectedSkill == skill['key'];

                      return GestureDetector(
                        onTap: () => setState(() =>
                            _selectedSkill = skill['key'] as String),
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color
                                    : color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: isSelected
                                    ? [BoxShadow(
                                        color: color.withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )]
                                    : null,
                              ),
                              child: Center(
                                child: Text(skill['emoji'] as String,
                                  style: const TextStyle(fontSize: 26)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(skill['label'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected ? color : HollaColors.grey700,
                                fontFamily: 'Poppins',
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── PRESTATAIRES DISPONIBLES ───────────────────
            if (_selectedSkill != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prestataires disponibles',
                    style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        context.push('/service-selection/$_selectedSkill'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [HollaColors.primary, HollaColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Faire une demande',
                        style: TextStyle(
                          color: Colors.white, fontSize: 12,
                          fontWeight: FontWeight.w700, fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Consumer(
                builder: (_, ref, __) {
                  final providers = ref.watch(providersProvider(_selectedSkill!));
                  return providers.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: HollaColors.primary,
                      ),
                    ),
                    error: (e, _) => Text('$e'),
                    data: (list) => list.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Center(
                              child: Column(
                                children: [
                                  Text('😕', style: TextStyle(fontSize: 40)),
                                  SizedBox(height: 12),
                                  Text('Aucun prestataire disponible',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: HollaColors.grey500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            children: list.map((p) => _ProviderCard(
                              provider: p,
                              skill: _selectedSkill!,
                            )).toList(),
                          ),
                  );
                },
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Text('👆', style: TextStyle(fontSize: 40)),
                      SizedBox(height: 12),
                      Text('Sélectionnez un service\npour voir les prestataires',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: HollaColors.grey500,
                        ),
                        textAlign: TextAlign.center,
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

class _ProviderCard extends StatelessWidget {
  final Map<String, dynamic> provider;
  final String skill;
  const _ProviderCard({required this.provider, required this.skill});

  @override
  Widget build(BuildContext context) {
    final name    = provider['profiles']?['name'] ?? 'Prestataire';
    final rating  = (provider['rating'] as num?)?.toDouble() ?? 0;
    final years   = provider['years_experience'];
    final zone    = provider['intervention_zone'] ?? '';
    final isAvail = provider['is_available'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: HollaColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800,
                  color: HollaColors.primary, fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                      color: HollaColors.warning, size: 14),
                    const SizedBox(width: 3),
                    Text(rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    if (years != null)
                      Text(' · $years ans exp.',
                        style: const TextStyle(
                          fontSize: 12, color: HollaColors.grey500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                  ],
                ),
                if (zone.isNotEmpty)
                  Text(zone,
                    style: const TextStyle(
                      fontSize: 11, color: HollaColors.grey500,
                      fontFamily: 'Poppins',
                    ),
                  ),
              ],
            ),
          ),
          // Disponibilité + bouton
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isAvail
                      ? HollaColors.successLight
                      : HollaColors.errorLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isAvail ? 'Disponible' : 'Occupé',
                  style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: isAvail ? HollaColors.success : HollaColors.error,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              if (isAvail) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => context.push('/service-selection/$skill'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: HollaColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Contacter',
                      style: TextStyle(
                        color: HollaColors.primary, fontSize: 11,
                        fontWeight: FontWeight.w700, fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}