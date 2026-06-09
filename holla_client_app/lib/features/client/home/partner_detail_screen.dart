import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/partner_model.dart';
import '../../../core/models/product_model.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/partner_service.dart';
import '../../../shared/providers/cart_provider.dart';

final partnerDetailProvider = FutureProvider.family<PartnerModel, String>(
  (ref, id) => PartnerService().getPartnerById(id),
);

final productsProvider = FutureProvider.family<List<ProductModel>, String>(
  (ref, partnerId) => OrderService().getProducts(partnerId),
);

class PartnerDetailScreen extends ConsumerWidget {
  final String partnerId;
  const PartnerDetailScreen({super.key, required this.partnerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partner  = ref.watch(partnerDetailProvider(partnerId));
    final products = ref.watch(productsProvider(partnerId));
    final cart     = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: HollaColors.grey100,
      body: partner.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: HollaColors.primary),
        ),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (p) => Stack(
          children: [
            CustomScrollView(
              slivers: [
                // ── APP BAR AVEC IMAGE ───────────────────────
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  backgroundColor: HollaColors.primary,
                  leading: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                        color: HollaColors.dark),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        p.imageUrl != null
                            ? Image.network(p.imageUrl!, fit: BoxFit.cover)
                            : Container(
                                color: HollaColors.primaryLight,
                                child: const Icon(Icons.storefront_rounded,
                                  color: HollaColors.primary, size: 64),
                              ),
                        // Gradient overlay
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent,
                                       Color(0x99000000)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── INFOS PARTENAIRE ─────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(p.businessName,
                                style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            if (p.isVerified)
                              const Icon(Icons.verified_rounded,
                                color: HollaColors.info, size: 22),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(p.address,
                          style: const TextStyle(
                            color: HollaColors.grey500,
                            fontFamily: 'Poppins', fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Stats row
                        Row(
                          children: [
                            _StatChip(
                              icon: Icons.star_rounded,
                              color: HollaColors.warning,
                              label: p.rating.toStringAsFixed(1),
                            ),
                            const SizedBox(width: 10),
                            _StatChip(
                              icon: Icons.access_time_rounded,
                              color: HollaColors.info,
                              label: '${p.deliveryTime ?? 30} min',
                            ),
                            if (p.distance != null) ...[
                              const SizedBox(width: 10),
                              _StatChip(
                                icon: Icons.location_on_rounded,
                                color: HollaColors.success,
                                label: '${p.distance!.toStringAsFixed(1)} km',
                              ),
                            ],
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: p.isOpen
                                    ? HollaColors.successLight
                                    : HollaColors.errorLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                p.isOpen ? '● Ouvert' : '● Fermé',
                                style: TextStyle(
                                  color: p.isOpen
                                      ? HollaColors.success
                                      : HollaColors.error,
                                  fontSize: 12, fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (p.minOrder != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: HollaColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Commande min. ${p.minOrder} FCFA',
                              style: const TextStyle(
                                color: HollaColors.primary, fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // ── PRODUITS ─────────────────────────────────
                products.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          color: HollaColors.primary,
                        ),
                      ),
                    ),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Center(child: Text('$e')),
                  ),
                  data: (prods) {
                    // Grouper par catégorie
                    final categories = <String, List<ProductModel>>{};
                    for (final p in prods) {
                      final cat = p.category ?? 'Autres';
                      categories.putIfAbsent(cat, () => []).add(p);
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final cat  = categories.keys.elementAt(i);
                          final list = categories[cat]!;
                          return _ProductSection(
                            category: cat,
                            products: list,
                            cart: cart,
                            onAdd: (prod) {
                              if (!p.isOpen) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ce partenaire est fermé'),
                                    backgroundColor: HollaColors.error,
                                  ),
                                );
                                return;
                              }
                              cartNotifier.add(prod);
                            },
                            onRemove: cartNotifier.remove,
                          );
                        },
                        childCount: categories.length,
                      ),
                    );
                  },
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),

            // ── PANIER FLOTTANT GOJEK-STYLE ──────────────────
            if (cart.isNotEmpty)
              Positioned(
                bottom: 20, left: 20, right: 20,
                child: _CartBar(
                  cartNotifier: cartNotifier,
                  partnerId: partnerId,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── STAT CHIP ─────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _StatChip({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(
            color: color, fontSize: 12,
            fontWeight: FontWeight.w600, fontFamily: 'Poppins',
          )),
        ],
      ),
    );
  }
}

// ── SECTION PRODUITS PAR CATÉGORIE ────────────────────────
class _ProductSection extends StatelessWidget {
  final String category;
  final List<ProductModel> products;
  final List<CartItem> cart;
  final void Function(ProductModel) onAdd;
  final void Function(ProductModel) onRemove;

  const _ProductSection({
    required this.category,
    required this.products,
    required this.cart,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: HollaColors.dark, fontFamily: 'Poppins',
              ),
            ),
          ),
          ...products.map((product) {
            final qty = cart
                .where((i) => i.product.id == product.id)
                .fold(0, (s, i) => s + i.quantity);

            return _ProductTile(
              product: product,
              quantity: qty,
              onAdd: () => onAdd(product),
              onRemove: () => onRemove(product),
            );
          }),
        ],
      ),
    );
  }
}

// ── PRODUCT TILE ──────────────────────────────────────────
class _ProductTile extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _ProductTile({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: HollaColors.grey100, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Image produit
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: product.imageUrl != null
                ? Image.network(
                    product.imageUrl!,
                    width: 80, height: 80, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 14),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: HollaColors.dark, fontFamily: 'Poppins',
                  ),
                ),
                if (product.description != null) ...[
                  const SizedBox(height: 3),
                  Text(product.description!,
                    style: const TextStyle(
                      fontSize: 12, color: HollaColors.grey500,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '${product.price} FCFA',
                  style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: HollaColors.primary, fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),

          // Contrôle quantité
          if (!product.isAvailable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: HollaColors.errorLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Indisponible',
                style: TextStyle(
                  color: HollaColors.error, fontSize: 11,
                  fontWeight: FontWeight.w600, fontFamily: 'Poppins',
                ),
              ),
            )
          else if (quantity == 0)
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: HollaColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: HollaColors.primary.withOpacity(0.3),
                      blurRadius: 8, offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 20),
              ),
            )
          else
            Row(
              children: [
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: HollaColors.primary),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.remove_rounded,
                      color: HollaColors.primary, size: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('$quantity',
                    style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: HollaColors.dark, fontFamily: 'Poppins',
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: HollaColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 80, height: 80,
    decoration: BoxDecoration(
      color: HollaColors.primaryLight,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Icon(Icons.fastfood_rounded,
      color: HollaColors.primary, size: 32),
  );
}

// ── BARRE PANIER FLOTTANTE ────────────────────────────────
class _CartBar extends ConsumerWidget {
  final CartNotifier cartNotifier;
  final String partnerId;

  const _CartBar({
    required this.cartNotifier,
    required this.partnerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart  = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final count = cartNotifier.totalItems;

    return GestureDetector(
      onTap: () => _showCartSheet(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [HollaColors.primary, HollaColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: HollaColors.primary.withOpacity(0.4),
              blurRadius: 20, offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Badge count
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text('$count',
                  style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800,
                    fontSize: 13, fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Voir le panier',
              style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600,
                fontSize: 15, fontFamily: 'Poppins',
              ),
            ),
            const Spacer(),
            Text(
              '$total FCFA',
              style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800,
                fontSize: 15, fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white70, size: 14),
          ],
        ),
      ),
    );
  }

  void _showCartSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CartSheet(
        cartNotifier: cartNotifier,
        partnerId: partnerId,
      ),
    );
  }
}

// ── BOTTOM SHEET PANIER ───────────────────────────────────
class _CartSheet extends ConsumerStatefulWidget {
  final CartNotifier cartNotifier;
  final String partnerId;

  const _CartSheet({
    required this.cartNotifier,
    required this.partnerId,
  });

  @override
  ConsumerState<_CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends ConsumerState<_CartSheet> {
  final _addressController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez entrer votre adresse de livraison"),
          backgroundColor: HollaColors.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final cart  = ref.read(cartProvider);
      final order = await OrderService().createOrder(
        partnerId:       widget.partnerId,
        items:           cart,
        deliveryAddress: _addressController.text.trim(),
      );

      widget.cartNotifier.clear();

      if (mounted) {
        Navigator.pop(context);
        context.push('/payment', extra: {
          'orderId':     order.id,
          'amount':      order.totalAmount - order.deliveryFee,
          'deliveryFee': order.deliveryFee,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: HollaColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart  = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: HollaColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                const Text('Mon Panier',
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    widget.cartNotifier.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Vider',
                    style: TextStyle(
                      color: HollaColors.error, fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Articles
          ...cart.map((item) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Text(item.product.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600, fontFamily: 'Poppins',
              ),
            ),
            subtitle: Text('${item.product.price} FCFA × ${item.quantity}',
              style: const TextStyle(
                color: HollaColors.grey500, fontFamily: 'Poppins',
              ),
            ),
            trailing: Text('${item.subtotal} FCFA',
              style: const TextStyle(
                fontWeight: FontWeight.w700, color: HollaColors.primary,
                fontFamily: 'Poppins',
              ),
            ),
          )),

          const Divider(height: 24),

          // Adresse de livraison
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Adresse de livraison',
                  style: TextStyle(
                    fontWeight: FontWeight.w600, fontFamily: 'Poppins',
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ex: Bastos, face à la pharmacie...',
                    hintStyle: const TextStyle(
                      color: HollaColors.grey500,
                      fontFamily: 'Poppins', fontSize: 13,
                    ),
                    prefixIcon: const Icon(Icons.location_on_outlined,
                      color: HollaColors.primary),
                    filled: true,
                    fillColor: HollaColors.grey100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Résumé prix
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sous-total',
                      style: TextStyle(color: HollaColors.grey500,
                        fontFamily: 'Poppins')),
                    Text('${total - 500} FCFA',
                      style: const TextStyle(fontFamily: 'Poppins')),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Frais de livraison',
                      style: TextStyle(color: HollaColors.grey500,
                        fontFamily: 'Poppins')),
                    const Text('500 FCFA',
                      style: TextStyle(fontFamily: 'Poppins')),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                      style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text('$total FCFA',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 18,
                        color: HollaColors.primary, fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bouton commander
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: GestureDetector(
              onTap: _loading ? null : _placeOrder,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [HollaColors.primary, HollaColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
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
                      : const Text(
                          'Commander maintenant',
                          style: TextStyle(
                            color: Colors.white, fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}