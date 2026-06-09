import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class OrderService {
  // ── Produits d'un partenaire ─────────────────────────────
  Future<List<ProductModel>> getProducts(String partnerId) async {
    final data = await supabase
        .from('products')
        .select()
        .eq('partner_id', partnerId)
        .eq('is_available', true)
        .order('category');

    return (data as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  // ── Créer une commande ───────────────────────────────────
  Future<OrderModel> createOrder({
    required String partnerId,
    required List<CartItem> items,
    required String deliveryAddress,
    double? deliveryLat,
    double? deliveryLng,
    String? notes,
  }) async {
    final userId = supabase.auth.currentUser!.id;

    // Calculer le total
    final subtotal    = items.fold(0, (sum, i) => sum + i.subtotal);
    const deliveryFee = 500;
    final total       = subtotal + deliveryFee;

    // Créer la commande
    final orderData = await supabase.from('orders').insert({
      'client_id':       userId,
      'partner_id':      partnerId,
      'status':          'pending',
      'total_amount':    total,
      'delivery_fee':    deliveryFee,
      'delivery_address': deliveryAddress,
      'delivery_lat':    deliveryLat,
      'delivery_lng':    deliveryLng,
      'notes':           notes,
      'idempotency_key': '${userId}_${DateTime.now().millisecondsSinceEpoch}',
    }).select().single();

    // Créer les articles
    final orderItems = items.map((i) => {
      'order_id':   orderData['id'],
      'product_id': i.product.id,
      'quantity':   i.quantity,
      'unit_price': i.product.price,
    }).toList();

    await supabase.from('order_items').insert(orderItems);

    return getOrderById(orderData['id']);
  }

  // ── Détail d'une commande ────────────────────────────────
  Future<OrderModel> getOrderById(String id) async {
    final data = await supabase
        .from('orders')
        .select('''
          *,
          partners (business_name, image_url),
          order_items (
            id, quantity, unit_price,
            products (name)
          ),
          delivery_agents (
            profiles (name)
          )
        ''')
        .eq('id', id)
        .single();

    return OrderModel.fromJson(data);
  }

  // ── Liste des commandes du client ────────────────────────
  Future<List<OrderModel>> getMyOrders() async {
    final userId = supabase.auth.currentUser!.id;

    final data = await supabase
        .from('orders')
        .select('''
          *,
          partners (business_name, image_url),
          order_items (
            id, quantity, unit_price,
            products (name)
          )
        ''')
        .eq('client_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  // ── Annuler une commande ─────────────────────────────────
  Future<void> cancelOrder(String id) async {
    await supabase
        .from('orders')
        .update({'status': 'cancelled'})
        .eq('id', id)
        .inFilter('status', ['pending', 'confirmed']);
  }

  // ── Écouter le statut en temps réel ─────────────────────
  Stream<Map<String, dynamic>> watchOrderStatus(String orderId) {
    return supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((rows) => rows.isNotEmpty ? rows.first : {});
  }
}