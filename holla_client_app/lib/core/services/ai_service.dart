import 'package:dio/dio.dart';
import '../../config/supabase_config.dart';

class AIService {
  final _dio = Dio(BaseOptions(
    baseUrl: SupabaseConfig.aiUrl,
    headers: {
      'Authorization': 'Bearer holla_ai_secret_2024',
      'Content-Type': 'application/json',
    },
  ));

  // Prédire le délai de livraison
  Future<int?> predictDeliveryTime({
    required double partnerLat,
    required double partnerLng,
    required double deliveryLat,
    required double deliveryLng,
  }) async {
    try {
      final response = await _dio.post('/predict/delivery-time', data: {
        'partner_lat':  partnerLat,
        'partner_lng':  partnerLng,
        'delivery_lat': deliveryLat,
        'delivery_lng': deliveryLng,
      });
      return response.data['estimated_minutes'];
    } catch (e) {
      return null; // Silencieux si IA indisponible
    }
  }

  // Suggestions personnalisées
  Future<List<Map<String, dynamic>>> getSuggestions(String userId) async {
    try {
      final response = await _dio.get('/suggestions/$userId');
      return List<Map<String, dynamic>>.from(
        response.data['suggestions'] ?? [],
      );
    } catch (e) {
      return [];
    }
  }

  // Affecter un livreur
  Future<Map<String, dynamic>?> assignDelivery({
    required String orderId,
    required double deliveryLat,
    required double deliveryLng,
    required double partnerLat,
    required double partnerLng,
  }) async {
    try {
      final response = await _dio.post('/delivery/assign', data: {
        'order_id':     orderId,
        'delivery_lat': deliveryLat,
        'delivery_lng': deliveryLng,
        'partner_lat':  partnerLat,
        'partner_lng':  partnerLng,
      });
      return response.data;
    } catch (e) {
      return null;
    }
  }
}