import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';

final SupabaseClient supabase = Supabase.instance.client;

class AuthService {
  // ── Inscription Centralisée dans l'App ──────────────────────────────────
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    // 1. Création de l'utilisateur dans Supabase Auth
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception("Erreur lors de la création de l'identifiant d'authentification.");
    }

    try {
      // 2. Insertion manuelle dans la table 'profiles'
      await supabase.from('profiles').insert({
        'id': user.id,
        'name': name,
        'phone': phone,
        'role': 'client', // Rôle par défaut
        'created_at': DateTime.now().toIso8601String(),
      });

      // 3. Insertion manuelle dans la table 'clients'
      await supabase.from('clients').insert({
        'id': user.id,
        'main_address': 'Non spécifiée',
      });

    } catch (e) {
      // Si l'insertion dans les profils échoue, on nettoie idéalement le user créé 
      // ou on lève une exception claire pour l'UI
      print("Erreur lors de la création des profils en cascade : $e");
      throw Exception("Compte créé mais impossible d'initialiser vos données de profil : $e");
    }

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

  // ── Profil utilisateur connecté (Version sécurisée) ─────────────────
  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    // Remplacement de .single() par .maybeSingle()
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle(); 

    return response; // Renverra null si la ligne n'existe pas, au lieu de crash
  }

  // ── Mot de passe oublié ───────────────────────────────────
  Future<void> resetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  Session? get currentSession => supabase.auth.currentSession;
  User? get currentUser => supabase.auth.currentUser;
  bool get isAuthenticated => currentSession != null;
}