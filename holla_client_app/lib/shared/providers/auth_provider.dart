import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/auth_service.dart';

// Service Auth
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// État de session Supabase — écoute les changements en temps réel
final authStateProvider = StreamProvider<AuthState>((ref) {
  return supabase.auth.onAuthStateChange;
});

// Profil utilisateur connecté
final currentProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) async {
      if (state.session == null) return null;
      return await ref.read(authServiceProvider).getCurrentProfile();
    },
    loading: () => null,
    error: (_, __) => null,
  );
});