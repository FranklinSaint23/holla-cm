import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/order_service.dart';

final orderDetailProvider = StreamProvider.family<Map<String, dynamic>, String>(
  (ref, orderId) => OrderService().watchOrderStatus(orderId),
);

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  static const _steps = [
    {'status': 'pending',     'label': 'Commande reçue',      'icon': Icons.receipt_long_rounded},
    {'status': 'confirmed',   'label': 'Commande confirmée',  'icon': Icons.check_circle_rounded},
    {'status': 'preparing',   'label': 'En préparation',      'icon': Icons.restaurant_rounded},
    {'status': 'in_delivery', 'label': 'En livraison',        'icon': Icons.delivery_dining_rounded},
    {'status': 'delivered',   'label': 'Livrée !',            'icon': Icons.celebration_rounded},
  ];

  int _stepIndex(String status) {
    switch (status) {
      case 'pending':     return 0;
      case 'confirmed':   return 1;
      case 'preparing':   return 2;
      case 'in_delivery': return 3;
      case 'delivered':   return 4;
      default:            return 0;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderStream = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: HollaColors.grey100,
      appBar: AppBar(
        title: const Text('Détail commande'),
        backgroundColor: Colors.white,
        foregroundColor: HollaColors.dark,
        elevation: 0,
      ),
      body: orderStream.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: HollaColors.primary),
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text('Commande introuvable'));
          }
          final status = data['status'] as String;
          final isCancelled = status == 'cancelled';
          final currentStep = _stepIndex(status);

          return FutureBuilder<OrderModel>(
            future: OrderService().getOrderById(orderId),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: HollaColors.primary),
                );
              }
              final order = snap.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ── TIMELINE ────────────────────────────
                    if (!isCancelled)
                      _buildTimeline(currentStep)
                    else
                      _buildCancelled(),

                    const SizedBox(height: 12),

                    // ── BOUTON TRACKING ─────────────────────
                    if (status == 'in_delivery') ...[
                      GestureDetector(
                        onTap: () => context.push('/tracking/$orderId'),
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [HollaColors.primary, HollaColors.primaryDark],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.navigation_rounded, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Suivre en temps réel',
                                style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── INFOS PARTENAIRE ────────────────────
                    _buildCard(
                      title: 'Restaurant / Boutique',
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: HollaColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.storefront_rounded,
                              color: HollaColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(order.partnerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins', fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── ARTICLES ────────────────────────────
                    _buildCard(
                      title: 'Votre commande',
                      child: Column(
                        children: [
                          ...order.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: HollaColors.primaryLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('${item.quantity}x',
                                    style: const TextStyle(
                                      color: HollaColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins', fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(item.productName,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins', fontSize: 14,
                                    ),
                                  ),
                                ),
                                Text('${item.subtotal} F',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          )),
                          const Divider(height: 20),
                          _priceRow('Sous-total',
                              '${order.totalAmount - order.deliveryFee} F'),
                          const SizedBox(height: 6),
                          _priceRow('Livraison', '${order.deliveryFee} F'),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text('${order.totalAmount} FCFA',
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
                    const SizedBox(height: 10),

                    // ── ADRESSE ─────────────────────────────
                    _buildCard(
                      title: 'Adresse de livraison',
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                            color: HollaColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(order.deliveryAddress,
                              style: const TextStyle(
                                fontFamily: 'Poppins', fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTimeline(int currentStep) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Suivi de commande',
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 20),
          ..._steps.asMap().entries.map((entry) {
            final i     = entry.key;
            final step  = entry.value;
            final isDone    = i <= currentStep;
            final isCurrent = i == currentStep;
            final isLast    = i == _steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ligne verticale + dot
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: isDone
                            ? HollaColors.primary
                            : HollaColors.grey100,
                        shape: BoxShape.circle,
                        border: isCurrent
                            ? Border.all(color: HollaColors.primary, width: 3)
                            : null,
                        boxShadow: isCurrent
                            ? [BoxShadow(
                                color: HollaColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                              )]
                            : null,
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        size: 18,
                        color: isDone
                            ? Colors.white
                            : HollaColors.grey300,
                      ),
                    ),
                    if (!isLast)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 2, height: 36,
                        color: isDone
                            ? HollaColors.primary
                            : HollaColors.grey300,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 36),
                  child: Text(
                    step['label'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isCurrent
                          ? HollaColors.primary
                          : isDone
                              ? HollaColors.dark
                              : HollaColors.grey300,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCancelled() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HollaColors.errorLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HollaColors.error.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.cancel_rounded, color: HollaColors.error, size: 28),
          SizedBox(width: 12),
          Text('Commande annulée',
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: HollaColors.error, fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: HollaColors.grey500, fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
          style: const TextStyle(
            color: HollaColors.grey500, fontFamily: 'Poppins', fontSize: 13,
          ),
        ),
        Text(value,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
      ],
    );
  }
}