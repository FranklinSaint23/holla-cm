import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/partner_model.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/home_provider.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../core/services/ai_service.dart';

// ── PROVIDERS IA ──
final aiPromotionsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, Map<String, double>>(
  (ref, coords) async {
    return AIService().getPromotions(lat: coords['lat']!, lng: coords['lng']!);
  },
);

final aiSuggestionsProvider =
    FutureProvider.family<Map<String, dynamic>?, Map<String, dynamic>>(
  (ref, params) async {
    return AIService().getPersonalizedFeed(
      clientId: params['clientId'] as String,
      lat: params['lat'] as double,
      lng: params['lng'] as double,
    );
  },
);

// Catégories HOLLA — style Gojek en grille
const _categories = [
  {'id': 'all', 'label': 'Tout', 'emoji': '🏠', 'color': 0xFF5B2EE8},
  {
    'id': 'restaurant',
    'label': 'Restaurants',
    'emoji': '🍽️',
    'color': 0xFFFF5722
  },
  {'id': 'pharmacy', 'label': 'Pharmacies', 'emoji': '💊', 'color': 0xFF00B14F},
  {'id': 'shop', 'label': 'Boutiques', 'emoji': '🛍️', 'color': 0xFF1E88E5},
  {'id': 'services', 'label': 'Services', 'emoji': '🔧', 'color': 0xFFFFB800},
  {'id': 'groceries', 'label': 'Courses', 'emoji': '🛒', 'color': 0xFF00C2CB},
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

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
    final profile = ref.watch(currentProfileProvider);

    final firstName =
        profile.value?['name']?.toString().split(' ').first ?? 'HOLLA';
    
    // Coordonnées pour l'IA
    const lat = 3.848; // Yaoundé
    const lng = 11.502;
    final promoAsyncValue = ref.watch(aiPromotionsProvider({'lat': lat, 'lng': lng}));

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

          // ── NOTIFICATION EXPIRATION PROMO ─────────────────
          promoAsyncValue.when(
            loading: () => const SliverToBoxAdapter(child: SizedBox()),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
            data: (promos) => SliverToBoxAdapter(
              child: _buildPromoExpiryBanner(promos),
            ),
          ),

          // ── SERVICES EN GRILLE GOJEK ───────────────────────
          SliverToBoxAdapter(child: _buildServicesGrid()),

          // ── PROMO BANNER DYNAMIQUE IA ──────────────────────
          SliverToBoxAdapter(child: _buildPromoBanner(promoAsyncValue)),

          // ── WIDGET SUGGESTIONS IA ─────────────────────────
          SliverToBoxAdapter(
            child: _buildAISuggestions(ref, profile.value?['id']?.toString() ?? ''),
          ),

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
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: HollaColors.dark,
                      fontFamily: 'Poppins',
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
                      const Text(
                        'Erreur de chargement',
                        style: TextStyle(
                          color: HollaColors.grey500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (list) => list.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Text('🔍', style: TextStyle(fontSize: 48)),
                            SizedBox(height: 12),
                            Text(
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
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: HollaColors.dark,
                      fontFamily: 'Poppins',
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

  // ── WIDGET EXPIRATION BANNER ────────────────────────────
  Widget _buildPromoExpiryBanner(List<Map<String, dynamic>> promos) {
    final soonExpiring = promos.where((p) {
      try {
        final end = DateTime.parse(p['ends_at']);
        final diff = end.difference(DateTime.now());
        return diff.inHours <= 2 && diff.isNegative == false;
      } catch (_) {
        return false;
      }
    }).toList();

    if (soonExpiring.isEmpty) return const SizedBox();

    final promo = soonExpiring.first;
    final end = DateTime.parse(promo['ends_at']);
    final diff = end.difference(DateTime.now());
    final label = diff.inMinutes < 60 ? '${diff.inMinutes} min' : '${diff.inHours}h';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: HollaColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HollaColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('⏰', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${promo['title']} — expire dans $label',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: HollaColors.error,
                fontFamily: 'Poppins',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: HollaColors.error),
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
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
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
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Yaoundé, Cameroun',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 16),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 8,
                              height: 8,
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
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 22),
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
            fontSize: 14,
            fontFamily: 'Poppins',
            color: HollaColors.dark,
          ),
          decoration: InputDecoration(
            hintText: 'Restaurants, pharmacies, services...',
            hintStyle: const TextStyle(
              color: HollaColors.grey500,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
            prefixIcon: const Icon(Icons.search_rounded, color: HollaColors.grey500, size: 22),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: HollaColors.grey500, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : const Icon(Icons.tune_rounded, color: HollaColors.primary, size: 22),
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
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: HollaColors.dark,
              fontFamily: 'Poppins',
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
              final cat = _categories[i];
              final color = Color(cat['color'] as int);
              final isSelected = ref.watch(selectedCategoryProvider) == cat['id'];
              return GestureDetector(
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state = cat['id'] as String;
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected ? color : color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
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
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── METHODE PROMO BANNER MODIFIÉE ───────────────────────
  Widget _buildPromoBanner(AsyncValue<List<Map<String, dynamic>>> promosState) {
    return promosState.when(
      loading: () => _buildStaticBanner(),
      error: (_, __) => _buildStaticBanner(),
      data: (list) {
        if (list.isEmpty) return _buildStaticBanner();
        return SizedBox(
          height: 150,
          child: PageView.builder(
            padEnds: false,
            controller: PageController(viewportFraction: 0.88),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final promo = list[i];
              return _PromoCard(promo: promo);
            },
          ),
        );
      },
    );
  }

  Widget _buildStaticBanner() {
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
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '🎉 OFFRE SPÉCIALE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Livraison gratuite\nsur votre 1ère commande',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          height: 1.3,
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

  // ── WIDGET SUGGESTIONS IA ─────────────────────────────────
  Widget _buildAISuggestions(WidgetRef ref, String userId) {
    final feed = ref.watch(aiSuggestionsProvider({
      'clientId': userId,
      'lat': 3.848,
      'lng': 11.502,
    }));

    return feed.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (data) {
        if (data == null) return const SizedBox();
        final favorites = data['favorites'] as List? ?? [];
        final timeLabel = data['time_label'] as String? ?? '';
        if (favorites.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: HollaColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      timeLabel,
                      style: const TextStyle(
                        color: HollaColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Vos favoris',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: favorites.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final partnerMap = favorites[i] as Map<String, dynamic>;
                  final partner = PartnerModel.fromJson(partnerMap);
                  return _NearbyCard(
                    partner: partner,
                    onTap: () => context.push('/partner/${partner.id}'),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── COMPOSANT AUXILIAIRE POUR LES PROMOS IA ─────────────────
class _PromoCard extends StatelessWidget {
  final Map<String, dynamic> promo;
  const _PromoCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    final promoPrice = promo['promo_price'] as int?;
    final originalPrice = promo['original_price'] as int?;
    final discount = promoPrice != null && originalPrice != null
        ? ((originalPrice - promoPrice) / originalPrice * 100).round()
        : null;

    return Container(
      margin: const EdgeInsets.only(right: 12, left: 4, top: 16, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            child: promo['image_url'] != null
                ? Image.network(
                    promo['image_url'],
                    width: 120,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 120,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [HollaColors.primary, HollaColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Text('🍽️', style: TextStyle(fontSize: 40)),
                    ),
                  ),
          ),

          // Infos
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (discount != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: HollaColors.error,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-$discount%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    promo['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    promo['partner_name'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: HollaColors.grey500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${promoPrice ?? ''} FCFA',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: HollaColors.primary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      if (originalPrice != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '$originalPrice F',
                          style: const TextStyle(
                            fontSize: 12,
                            color: HollaColors.grey500,
                            fontFamily: 'Poppins',
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: partner.imageUrl != null
                      ? Image.network(
                          partner.imageUrl!,
                          height: 120,
                          width: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 120,
      width: 200,
      color: HollaColors.grey100,
      child: const Icon(Icons.storefront, color: HollaColors.grey300),
    );
  }
}

// ── NEARBY CARD VERTICALE ─────────────────────────────────
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
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: partner.imageUrl != null
                  ? Image.network(partner.imageUrl!, width: 64, height: 64, fit: BoxFit.cover)
                  : Container(
                      width: 64,
                      height: 64,
                      color: HollaColors.grey100,
                      child: const Icon(Icons.storefront)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(partner.businessName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: HollaColors.warning, size: 14),
                      Text('${partner.rating} · ${partner.distance?.toStringAsFixed(1) ?? "0.0"} km'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}