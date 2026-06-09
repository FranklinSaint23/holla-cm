import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);

    return Scaffold(
      backgroundColor: HollaColors.grey100,
      body: CustomScrollView(
        slivers: [
          // ── HEADER ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: HollaColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [HollaColors.primary, HollaColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -40, right: -40,
                      child: Container(
                        width: 180, height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 64, height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      (profile.value?['name'] as String?)
                                              ?.substring(0, 1)
                                              .toUpperCase() ??
                                          'H',
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: HollaColors.primary,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.value?['name'] ?? 'Utilisateur',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        profile.value?['phone'] ?? '',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white.withOpacity(0.8),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Bouton éditer
                                Container(
                                  width: 38, height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.edit_rounded,
                                    color: Colors.white, size: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── CONTENU ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── STATS ──────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        _StatItem(
                          emoji: '📦',
                          value: '12',
                          label: 'Commandes',
                        ),
                        _Vdivider(),
                        _StatItem(
                          emoji: '🔧',
                          value: '4',
                          label: 'Services',
                        ),
                        _Vdivider(),
                        _StatItem(
                          emoji: '⭐',
                          value: '4.8',
                          label: 'Ma note',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── SECTION COMPTE ─────────────────────
                  _SectionTitle(title: 'MON COMPTE'),
                  _MenuTile(
                    icon: Icons.receipt_long_rounded,
                    label: 'Mes commandes',
                    onTap: () => context.go('/orders'),
                  ),
                  _MenuTile(
                    icon: Icons.location_on_rounded,
                    label: 'Mes adresses',
                    onTap: () {},
                  ),
                  _MenuTile(
                    icon: Icons.credit_card_rounded,
                    label: 'Modes de paiement',
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),

                  // ── SECTION PRÉFÉRENCES ────────────────
                  _SectionTitle(title: 'PRÉFÉRENCES'),
                  _MenuTile(
                    icon: Icons.notifications_rounded,
                    label: 'Notifications',
                    onTap: () {},
                  ),
                  _MenuTile(
                    icon: Icons.language_rounded,
                    label: 'Langue',
                    trailing: const Text('Français',
                      style: TextStyle(
                        color: HollaColors.grey500,
                        fontFamily: 'Poppins', fontSize: 13,
                      ),
                    ),
                    onTap: () {},
                  ),
                  _MenuTile(
                    icon: Icons.dark_mode_rounded,
                    label: 'Mode sombre',
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),

                  // ── SECTION SUPPORT ───────────────────
                  _SectionTitle(title: 'SUPPORT'),
                  _MenuTile(
                    icon: Icons.help_rounded,
                    label: 'Aide & Support',
                    onTap: () {},
                  ),
                  _MenuTile(
                    icon: Icons.star_rounded,
                    label: "Noter l'application",
                    onTap: () {},
                  ),
                  _MenuTile(
                    icon: Icons.info_rounded,
                    label: 'À propos de HOLLA',
                    trailing: const Text('v2.0.0',
                      style: TextStyle(
                        color: HollaColors.grey500,
                        fontFamily: 'Poppins', fontSize: 13,
                      ),
                    ),
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),

                  // ── DÉCONNEXION ───────────────────────
                  GestureDetector(
                    onTap: () => _confirmLogout(context, ref),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: HollaColors.errorLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: HollaColors.error.withOpacity(0.2),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.logout_rounded,
                            color: HollaColors.error, size: 22),
                          SizedBox(width: 14),
                          Text('Se déconnecter',
                            style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600,
                              color: HollaColors.error, fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  const SizedBox(height: 30),
                  const Text('Made with ❤️ in Cameroon 🇨🇲',
                    style: TextStyle(
                      color: HollaColors.grey300, fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Déconnexion',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Voulez-vous vous déconnecter ?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
              style: TextStyle(fontFamily: 'Poppins', color: HollaColors.grey500),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authServiceProvider).logout();
              if (context.mounted) context.go('/auth/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: HollaColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Déconnecter',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _StatItem({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w800,
          fontFamily: 'Poppins',
        )),
        Text(label, style: const TextStyle(
          fontSize: 11, color: HollaColors.grey500,
          fontFamily: 'Poppins',
        )),
      ],
    ),
  );
}

class _Vdivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 50, color: HollaColors.grey100,
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title,
      style: const TextStyle(
        fontSize: 11, fontWeight: FontWeight.w700,
        color: HollaColors.grey500, fontFamily: 'Poppins',
        letterSpacing: 1.2,
      ),
    ),
  );
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: HollaColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: HollaColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            )),
          ),
          trailing ?? const Icon(Icons.chevron_right_rounded,
            color: HollaColors.grey300, size: 20),
        ],
      ),
    ),
  );
}