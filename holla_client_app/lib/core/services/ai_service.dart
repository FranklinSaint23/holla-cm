import 'package:dio/dio.dart';
import '../../config/supabase_config.dart';

class AIService {
  final _dio = Dio(BaseOptions(
    baseUrl: SupabaseConfig.aiUrl,
    headers: {
      'Authorization': 'Bearer holla_ai_secret',
      'Content-Type':  'application/json',
    },
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // ── ASSISTANT CONVERSATIONNEL ────────────────────────────
  Future<Map<String, dynamic>?> sendMessage({
    required String clientId,
    required String message,
    String? conversationId,
    double? lat,
    double? lng,
  }) async {
    try {
      final response = await _dio.post('/chat/message', data: {
        'client_id':       clientId,
        'message':         message,
        'conversation_id': conversationId,
        'lat':             lat,
        'lng':             lng,
      });
      return response.data;
    } catch (e) {
      return null;
    }
  }

  // ── SOUMETTRE UN AVIS ────────────────────────────────────
  Future<Map<String, dynamic>?> submitReview({
    required String orderId,
    required String clientId,
    required String partnerId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await _dio.post('/reviews/submit', data: {
        'order_id':   orderId,
        'client_id':  clientId,
        'partner_id': partnerId,
        'rating':     rating,
        'comment':    comment,
      });
      return response.data;
    } catch (e) {
      return null;
    }
  }

  // ── OFFRES DU JOUR ───────────────────────────────────────
  Future<List<Map<String, dynamic>>> getPromotions({
    required double lat,
    required double lng,
    double radius = 10,
  }) async {
    try {
      final response = await _dio.get('/promotions/nearby', queryParameters: {
        'lat':    lat,
        'lng':    lng,
        'radius': radius,
      });
      return List<Map<String, dynamic>>.from(
        response.data['promotions'] ?? [],
      );
    } catch (e) {
      return [];
    }
  }

  // ── FEED PERSONNALISÉ ────────────────────────────────────
  Future<Map<String, dynamic>?> getPersonalizedFeed({
    required String clientId,
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _dio.get(
        '/promotions/feed/$clientId',
        queryParameters: {'lat': lat, 'lng': lng},
      );
      return response.data;
    } catch (e) {
      return null;
    }
  }

  // ── PRÉDIRE DÉLAI ────────────────────────────────────────
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
      return null;
    }
  }

  // ── SUGGESTIONS ──────────────────────────────────────────
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

  // ── AFFECTER UN LIVREUR ──────────────────────────────────
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