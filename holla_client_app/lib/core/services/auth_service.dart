import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';

final SupabaseClient supabase = Supabase.instance.client;

class AuthService {
  // ── Inscription ──────────────────────────────────────────
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    // 1. Créer le compte Supabase Auth
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'phone': phone,
        'role': 'client',
      },
    );

    if (response.user == null) {
      throw Exception('Erreur lors de la création du compte');
    }

    // 2. Créer le profil dans la table profiles
    await supabase.from('profiles').insert({
      'id': response.user!.id,
      'name': name,
      'phone': phone,
      'role': 'client',
    });

    // 3. Créer le profil client
    await supabase.from('clients').insert({
      'id': response.user!.id,
    });

    return response;
  }

  // ── Connexion ─────────────────────────────────────────────
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Email ou mot de passe incorrect');
    }

    return response;
  }

  // ── Déconnexion ───────────────────────────────────────────
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  // ── Profil utilisateur connecté ───────────────────────────
  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    return await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
  }

  // ── Mot de passe oublié ───────────────────────────────────
  Future<void> resetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  // ── Session actuelle ──────────────────────────────────────
  Session? get currentSession => supabase.auth.currentSession;
  User? get currentUser => supabase.auth.currentUser;
  bool get isAuthenticated => currentSession != null;
}