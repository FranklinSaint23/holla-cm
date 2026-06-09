import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../models/partner_model.dart';
import 'dart:math';

class PartnerService {
  // Distance Haversine en km
  double _distance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _rad(double deg) => deg * pi / 180;

  Future<List<PartnerModel>> getPartners({
    String? businessType,
    double? lat,
    double? lng,
    String? search,
  }) async {
    var query = supabase
        .from('partners')
        .select()
        .eq('is_verified', true);

    if (businessType != null && businessType != 'all') {
      query = query.eq('business_type', businessType);
    }

    if (search != null && search.isNotEmpty) {
      query = query.ilike('business_name', '%$search%');
    }

    final data = await query.order('rating', ascending: false);

    var partners = (data as List)
        .map((e) => PartnerModel.fromJson(e))
        .toList();

    // Calculer et trier par distance
    if (lat != null && lng != null) {
      for (final p in partners) {
        p.distance = _distance(lat, lng, p.latitude, p.longitude);
      }
      partners = partners
          .where((p) => (p.distance ?? 999) <= 20)
          .toList()
        ..sort((a, b) => (a.distance ?? 999).compareTo(b.distance ?? 999));
    }

    return partners;
  }

  Future<PartnerModel> getPartnerById(String id) async {
    final data = await supabase
        .from('partners')
        .select()
        .eq('id', id)
        .single();
    return PartnerModel.fromJson(data);
  }
}