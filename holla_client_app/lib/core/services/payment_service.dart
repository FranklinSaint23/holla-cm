import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';

class PaymentService {
  final _dio = Dio();
  static const _notchpayUrl = 'https://api.notchpay.co';

  // ── Paiement Cash ────────────────────────────────────────
  Future<void> payCash(String orderId) async {
    // Enregistrer le paiement en BDD
    await supabase.from('payments').insert({
      'order_id':        orderId,
      'amount':          await _getOrderTotal(orderId),
      'method':          'cash',
      'status':          'pending',
      'transaction_ref': 'CASH-${DateTime.now().millisecondsSinceEpoch}',
    });

    // Confirmer la commande
    await supabase
        .from('orders')
        .update({'status': 'confirmed'})
        .eq('id', orderId);
  }

  // ── Mobile Money via Notchpay ────────────────────────────
  Future<Map<String, dynamic>> payMobileMoney({
    required String orderId,
    required String method,
    required String phone,
    required int amount,
  }) async {
    final reference = 'HOLLA-${DateTime.now().millisecondsSinceEpoch}';

    // Enregistrer en BDD
    await supabase.from('payments').insert({
      'order_id':        orderId,
      'amount':          amount,
      'method':          method,
      'status':          'pending',
      'phone':           phone,
      'transaction_ref': reference,
    });

    // Mode sandbox si pas de clé
    final publicKey = const String.fromEnvironment('NOTCHPAY_KEY');
    if (publicKey.isEmpty) {
      // Simuler succès en sandbox
      await Future.delayed(const Duration(seconds: 2));
      await supabase.from('payments')
          .update({'status': 'success', 'paid_at': DateTime.now().toIso8601String()})
          .eq('transaction_ref', reference);
      await supabase.from('orders')
          .update({'status': 'confirmed'})
          .eq('id', orderId);

      return {'status': 'success', 'reference': reference, 'sandbox': true};
    }

    // Appel Notchpay réel
    final response = await _dio.post(
      '$_notchpayUrl/payments',
      options: Options(headers: {
        'Authorization': 'Bearer $publicKey',
        'Content-Type': 'application/json',
      }),
      data: {
        'amount':      amount,
        'currency':    'XAF',
        'phone':       phone,
        'reference':   reference,
        'description': 'Paiement HOLLA',
        'callback':    'https://api.holla.cm/api/v1/payments/webhook',
      },
    );

    return response.data;
  }

  Future<int> _getOrderTotal(String orderId) async {
    final data = await supabase
        .from('orders')
        .select('total_amount')
        .eq('id', orderId)
        .single();
    return data['total_amount'];
  }
}