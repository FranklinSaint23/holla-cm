import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/partner_model.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/home_provider.dart';
import '../../../shared/widgets/skeleton_loader.dart';

// Catégories HOLLA — style Gojek en grille
const _categories = [
  {'id': 'all',        'label': 'Tout',        'emoji': '🏠', 'color': 0xFF5B2EE8},
  {'id': 'restaurant', 'label': 'Restaurants', 'emoji': '🍽️', 'color': 0xFFFF5722},
  {'id': 'pharmacy',   'label': 'Pharmacies',  'emoji': '💊', 'color': 0xFF00B14F},
  {'id': 'shop',       'label': 'Boutiques',   'emoji': '🛍️', 'color': 0xFF1E88E5},
  {'id': 'services',   'label': 'Services',    'emoji': '🔧', 'color': 0xFFFFB800},
  {'id': 'groceries',  'label': 'Courses',     'emoji': '🛒', 'color': 0xFF00C2CB},
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    final category = ref.watch(selectedCategoryProvider);
    final partners = ref.watch(partnersProvider(category));
    final profile  = ref.watch(currentProfileProvider);

    final firstName = profile.value?['name']?.toString().split(' ').first ?? 'HOLLA';

    return Scaffold(
      backgroundColor: HollaColors.grey100,
      body: CustomScrollView(
        slivers: [
          // ── HEADER DÉGRADÉ GOJEK-STYLE ────────────────────
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: HollaColors.primary,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(firstName),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: _buildSearchBar(),
            ),
          ),

          // ── SERVICES EN GRILLE GOJEK ───────────────────────
          SliverToBoxAdapter(child: _buildServicesGrid()),

          // ── PROMO BANNER ──────────────────────────────────
          SliverToBoxAdapter(child: _buildPromoBanner()),

          // ── SECTION PARTENAIRES ───────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recommandés pour vous',
                    style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700,
                      color: HollaColors.dark, fontFamily: 'Poppins',
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Voir tout',
                      style: TextStyle(
                        color: HollaColors.primary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── LISTE PARTENAIRES ─────────────────────────────
          partners.when(
            loading: () => SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (_, __) => const SkeletonPartnerCard(),
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                        color: HollaColors.grey300, size: 48),
                      const SizedBox(height: 12),
                      Text('Erreur de chargement',
                        style: TextStyle(
                          color: HollaColors.grey500, fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (list) => list.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Text('🔍', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            const Text(
                              'Aucun partenaire trouvé',
                              style: TextStyle(
                                color: HollaColors.grey500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverToBoxAdapter(
                    child: SizedBox(
                      height: 240,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (_, i) => _PartnerCard(
                          partner: list[i],
                          onTap: () => context.push('/partner/${list[i].id}'),
                        ),
                      ),
                    ),
                  ),
          ),

          // ── SECTION PRÈS DE VOUS ───────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Près de vous',
                    style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700,
                      color: HollaColors.dark, fontFamily: 'Poppins',
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Voir tout',
                      style: TextStyle(
                        color: HollaColors.primary, fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins', fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          partners.when(
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: SkeletonNearbyCard(),
                ),
                childCount: 3,
              ),
            ),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
            data: (list) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: _NearbyCard(
                    partner: list[i],
                    onTap: () => context.push('/partner/${list[i].id}'),
                  ),
                ),
                childCount: list.length > 6 ? 6 : list.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────
  Widget _buildHeader(String firstName) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [HollaColors.primary, HollaColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Cercles décoratifs
          Positioned(
            top: -50, right: -50,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            top: 30, right: 60,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Contenu
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_greeting()}, $firstName 👋',
                        style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700,
                          color: Colors.white, fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                            color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Yaoundé, Cameroun',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                            color: Colors.white70, size: 16),
                        ],
                      ),
                    ],
                  ),
                  // Avatar + notif
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.notifications_outlined,
                              color: Colors.white, size: 22),
                          ),
                          Positioned(
                            top: 6, right: 6,
                            child: Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(
                                color: HollaColors.warning,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.person_outline_rounded,
                          color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SEARCH BAR ─────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: HollaColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            fontSize: 14, fontFamily: 'Poppins', color: HollaColors.dark,
          ),
          decoration: InputDecoration(
            hintText: 'Restaurants, pharmacies, services...',
            hintStyle: const TextStyle(
              color: HollaColors.grey500, fontSize: 14, fontFamily: 'Poppins',
            ),
            prefixIcon: const Icon(Icons.search_rounded,
              color: HollaColors.grey500, size: 22),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                      color: HollaColors.grey500, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : const Icon(Icons.tune_rounded,
                    color: HollaColors.primary, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: (v) => setState(() {}),
        ),
      ),
    );
  }

  // ── GRILLE SERVICES GOJEK ──────────────────────────────
  Widget _buildServicesGrid() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nos Services',
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: HollaColors.dark, fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final cat   = _categories[i];
              final color = Color(cat['color'] as int);
              final isSelected = ref.watch(selectedCategoryProvider) == cat['id'];

              return GestureDetector(
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state =
                      cat['id'] as String;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color
                              : color.withOpacity(0.12),
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
                          child: Text(
                            cat['emoji'] as String,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
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
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── PROMO BANNER ──────────────────────────────────────
  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      height: 130,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B2EE8), Color(0xFF00C2CB)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: HollaColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Cercle décoratif
          Positioned(
            right: -20, top: -20,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '🎉 OFFRE SPÉCIALE',
                          style: TextStyle(
                            color: Colors.white, fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Livraison gratuite\nsur votre 1ère commande',
                        style: TextStyle(
                          color: Colors.white, fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins', height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text('🛵', style: TextStyle(fontSize: 56)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── PARTNER CARD HORIZONTALE ──────────────────────────────
class _PartnerCard extends StatelessWidget {
  final PartnerModel partner;
  final VoidCallback onTap;
  const _PartnerCard({required this.partner, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: partner.imageUrl != null
                      ? Image.network(
                          partner.imageUrl!,
                          height: 120, width: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                // Badge ouvert/fermé
                Positioned(
                  top: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: partner.isOpen
                          ? HollaColors.success
                          : HollaColors.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      partner.isOpen ? '● Ouvert' : '● Fermé',
                      style: const TextStyle(
                        color: Colors.white, fontSize: 10,
                        fontWeight: FontWeight.w700, fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                // Badge vérifié
                if (partner.isVerified)
                  Positioned(
                    top: 10, right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.verified_rounded,
                        color: HollaColors.info, size: 14),
                    ),
                  ),
              ],
            ),
            // Infos
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner.businessName,
                    style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: HollaColors.dark, fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                        color: HollaColors.warning, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        partner.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: HollaColors.dark, fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        ' · ${partner.deliveryTime ?? 30} min',
                        style: const TextStyle(
                          fontSize: 11, color: HollaColors.grey500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      if (partner.distance != null)
                        Text(
                          ' · ${partner.distance!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 11, color: HollaColors.grey500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                    ],
                  ),
                  if (partner.minOrder != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Min: ${partner.minOrder} FCFA',
                      style: const TextStyle(
                        fontSize: 11, color: HollaColors.primary,
                        fontWeight: FontWeight.w600, fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 120, width: 200,
      color: HollaColors.primaryLight,
      child: const Center(
        child: Icon(Icons.storefront_rounded,
          color: HollaColors.primary, size: 36),
      ),
    );
  }
}

// ── NEARBY CARD VERTICALE ────────────────────────────────
class _NearbyCard extends StatelessWidget {
  final PartnerModel partner;
  final VoidCallback onTap;
  const _NearbyCard({required this.partner, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
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
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: partner.imageUrl != null
                  ? Image.network(
                      partner.imageUrl!,
                      width: 64, height: 64, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner.businessName,
                    style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: HollaColors.dark, fontFamily: 'Poppins',
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    partner.address,
                    style: const TextStyle(
                      fontSize: 12, color: HollaColors.grey500,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                        color: HollaColors.warning, size: 13),
                      const SizedBox(width: 2),
                      Text(
                        partner.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        ' · ${partner.deliveryTime ?? 30} min',
                        style: const TextStyle(
                          fontSize: 11, color: HollaColors.grey500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      if (partner.distance != null)
                        Text(
                          ' · ${partner.distance!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 11, color: HollaColors.grey500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Chevron
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: HollaColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_right_rounded,
                color: HollaColors.primary, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 64, height: 64,
      color: HollaColors.primaryLight,
      child: const Icon(Icons.storefront_rounded,
        color: HollaColors.primary, size: 28),
    );
  }
}