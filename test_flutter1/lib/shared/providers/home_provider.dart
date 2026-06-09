import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/partner_model.dart';
import '../../core/services/partner_service.dart';

final partnerServiceProvider = Provider<PartnerService>((ref) => PartnerService());

// Catégorie sélectionnée
final selectedCategoryProvider = StateProvider<String>((ref) => 'all');

// Liste des partenaires
final partnersProvider = FutureProvider.family<List<PartnerModel>, String>(
  (ref, category) async {
    final service = ref.read(partnerServiceProvider);
    return service.getPartners(
      businessType: category == 'all' ? null : category,
    );
  },
);