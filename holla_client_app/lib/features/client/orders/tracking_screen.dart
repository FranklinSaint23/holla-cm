import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/order_service.dart';
import '../../../main.dart';

// Stream position livreur en temps réel via Supabase Realtime
final deliveryLocationProvider =
    StreamProvider.family<Map<String, dynamic>, String>(
  (ref, agentId) {
    return supabase
        .from('delivery_agents')
        .stream(primaryKey: ['id'])
        .eq('id', agentId)
        .map((rows) => rows.isNotEmpty ? rows.first : {});
  },
);

class TrackingScreen extends ConsumerStatefulWidget {
  final String orderId;
  const TrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen>
    with TickerProviderStateMixin {
  OrderModel? _order;
  final _mapController = MapController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  int _eta = 15;
  Timer? _etaTimer;

  // Position simulée livreur (remplacer par Supabase Realtime en prod)
  LatLng _deliveryPos = const LatLng(3.848, 11.502);

  @override
  void initState() {
    super.initState();

    // Animation pulse marker livreur
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadOrder();

    // Simuler déplacement livreur toutes les 4 secondes
    _etaTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() {
          _deliveryPos = LatLng(
            _deliveryPos.latitude  + (DateTime.now().millisecond % 3 - 1) * 0.0003,
            _deliveryPos.longitude + (DateTime.now().millisecond % 3 - 1) * 0.0003,
          );
          if (_eta > 0) _eta--;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _etaTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    try {
      final order = await OrderService().getOrderById(widget.orderId);
      if (mounted) setState(() => _order = order);
    } catch (e) {
      debugPrint('$e');
    }
  }

  LatLng get _clientPos => LatLng(
    _order?.deliveryLat ?? 3.850,
    _order?.deliveryLng ?? 11.505,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── CARTE OPENSTREETMAP GRATUIT ──────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _deliveryPos,
              initialZoom: 15.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // Tuiles OSM — 100% gratuit
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'cm.holla.app',
              ),

              // Ligne trajet livreur → client
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_deliveryPos, _clientPos],
                    color: HollaColors.primary,
                    strokeWidth: 4,
                  ),
                ],
              ),

              // Markers
              MarkerLayer(
                markers: [
                  // Marker livreur animé
                  Marker(
                    point: _deliveryPos,
                    width: 56,
                    height: 56,
                    child: AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (_, child) => Transform.scale(
                        scale: _pulseAnim.value,
                        child: child,
                      ),
                      child: Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: HollaColors.primary, width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: HollaColors.primary.withOpacity(0.4),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🛵', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                    ),
                  ),

                  // Marker destination client
                  Marker(
                    point: _clientPos,
                    width: 44,
                    height: 44,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: HollaColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: HollaColors.error.withOpacity(0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.home_rounded,
                        color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── TOP BAR ─────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                        color: HollaColors.dark),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Text(
                        'Suivi de livraison',
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Bouton centrer sur livreur
                  GestureDetector(
                    onTap: () => _mapController.move(_deliveryPos, 15),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: HollaColors.primary,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: HollaColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.my_location_rounded,
                        color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── PANEL BAS ────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: HollaColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Statut
                  Row(
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: const BoxDecoration(
                          color: HollaColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('🛵 Votre livreur est en route',
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ETA
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: HollaColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                          color: HollaColors.primary, size: 20),
                        const SizedBox(width: 10),
                        const Text('Temps estimé :',
                          style: TextStyle(
                            color: HollaColors.grey700, fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text('~$_eta min',
                          style: const TextStyle(
                            color: HollaColors.primary, fontSize: 18,
                            fontWeight: FontWeight.w800, fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Infos livreur
                  if (_order?.deliveryAgentName != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: HollaColors.grey100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: const BoxDecoration(
                              color: HollaColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('🛵',
                                style: TextStyle(fontSize: 22)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _order!.deliveryAgentName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins', fontSize: 14,
                                  ),
                                ),
                                const Text('Votre livreur',
                                  style: TextStyle(
                                    color: HollaColors.grey500,
                                    fontFamily: 'Poppins', fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Boutons appel + chat
                          Row(
                            children: [
                              _ActionBtn(
                                icon: Icons.call_rounded,
                                color: HollaColors.success,
                                onTap: () {},
                              ),
                              const SizedBox(width: 8),
                              _ActionBtn(
                                icon: Icons.chat_bubble_rounded,
                                color: HollaColors.primary,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Bouton détails
                  GestureDetector(
                    onTap: () => context.push('/orders/${widget.orderId}'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Voir les détails',
                            style: TextStyle(
                              color: HollaColors.primary, fontSize: 14,
                              fontWeight: FontWeight.w600, fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right_rounded,
                            color: HollaColors.primary, size: 18),
                        ],
                      ),
                    ),
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

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    ),
  );
}