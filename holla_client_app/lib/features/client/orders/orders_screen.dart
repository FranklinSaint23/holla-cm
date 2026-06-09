import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/order_service.dart';

final myOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  return OrderService().getMyOrders();
});

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(myOrdersProvider);

    return Scaffold(
      backgroundColor: HollaColors.grey100,
      appBar: AppBar(
        title: const Text('Mes Commandes'),
        backgroundColor: Colors.white,
        foregroundColor: HollaColors.dark,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(myOrdersProvider),
          ),
        ],
      ),
      body: orders.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: HollaColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded,
                color: HollaColors.grey300, size: 56),
              const SizedBox(height: 16),
              Text('$e',
                style: const TextStyle(
                  color: HollaColors.grey500, fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.invalidate(myOrdersProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (list) => list.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🛵', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    const Text('Aucune commande',
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Passez votre première commande !',
                      style: TextStyle(
                        color: HollaColors.grey500, fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => context.go('/'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [HollaColors.primary, HollaColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text('Explorer',
                          style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) => _OrderCard(
                  order: list[i],
                  onTap: () => context.push('/orders/${list[i].id}'),
                ),
              ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  const _OrderCard({required this.order, required this.onTap});

  Color get _statusColor {
    switch (order.status) {
      case 'pending':     return HollaColors.statusPending;
      case 'confirmed':   return HollaColors.statusConfirmed;
      case 'preparing':   return HollaColors.statusPreparing;
      case 'in_delivery': return HollaColors.statusDelivery;
      case 'delivered':   return HollaColors.statusDelivered;
      case 'cancelled':   return HollaColors.statusCancelled;
      default:            return HollaColors.grey500;
    }
  }

  String get _statusLabel {
    switch (order.status) {
      case 'pending':     return 'En attente';
      case 'confirmed':   return 'Confirmée';
      case 'preparing':   return 'En préparation';
      case 'in_delivery': return 'En livraison';
      case 'delivered':   return 'Livrée';
      case 'cancelled':   return 'Annulée';
      default:            return order.status;
    }
  }

  String get _statusEmoji {
    switch (order.status) {
      case 'pending':     return '⏳';
      case 'confirmed':   return '✅';
      case 'preparing':   return '👨‍🍳';
      case 'in_delivery': return '🛵';
      case 'delivered':   return '🎉';
      case 'cancelled':   return '❌';
      default:            return '📦';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10, offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Header ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Image partenaire
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: order.partnerImage != null
                        ? Image.network(
                            order.partnerImage!,
                            width: 52, height: 52, fit: BoxFit.cover,
                          )
                        : Container(
                            width: 52, height: 52,
                            color: HollaColors.primaryLight,
                            child: const Icon(Icons.storefront_rounded,
                              color: HollaColors.primary, size: 26),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.partnerName,
                          style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          order.items.map((i) =>
                              '${i.quantity}x ${i.productName}').join(', '),
                          style: const TextStyle(
                            fontSize: 12, color: HollaColors.grey500,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Montant
                  Text('${order.totalAmount} F',
                    style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800,
                      color: HollaColors.primary, fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            // ── Footer ────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.06),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Text(_statusEmoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(_statusLabel,
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: _statusColor, fontFamily: 'Poppins',
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(order.createdAt),
                    style: const TextStyle(
                      fontSize: 11, color: HollaColors.grey500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded,
                    color: HollaColors.grey500, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24)   return 'Il y a ${diff.inHours}h';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}