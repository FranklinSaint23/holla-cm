import 'dart:ui'; // Nécessaire pour l'effet de flou BackdropFilter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/widgets/holla_button.dart';
import '../../shared/widgets/holla_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _showPassword = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(authServiceProvider).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (mounted) context.go('/');
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Arrière-plan global
      backgroundColor: const Color(0xFFF1FBFF),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/global.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          top: false, // Permet à l'image du haut de monter jusqu'en haut de l'écran
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── 1. HEADER IMMERSIF (Image du marché + Logo + Titres) ──
                Stack(
                  children: [
                    Container(
                      height: 320,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                        image: DecorationImage(
                          image: AssetImage('assets/images/local.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Overlay sombre pour la lisibilité du texte
                    Container(
                      height: 320,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                    // Boutons de contrôle supérieurs (Langue & Thème)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 10,
                      right: 16,
                      child: Row(
                        children: [
                          _buildHeaderButton(
                            child: const Row(
                              children: [
                                Icon(Icons.translate, size: 16, color: Color(0xFF474554)),
                                SizedBox(width: 4),
                                Text('FR', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF474554))),
                              ],
                            ),
                            onTap: () {/* Logique de langue */},
                          ),
                          const SizedBox(width: 8),
                          _buildHeaderButton(
                            child: const Icon(Icons.wb_sunny_outlined, size: 18, color: Color(0xFF474554)),
                            onTap: () {/* Logique de thème */},
                          ),
                        ],
                      ),
                    ),
                    // Contenu textuel et illustration
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Conteneur de l'illustration
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Image.asset(
                              'assets/images/logo.jpeg',
                              height: 50,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Holla',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const Text(
                            'Bon retour !',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Connectez-vous pour continuer à naviguer.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── 2. CARTE EN VERRE FLOUTÉ (Glassmorphism Form) ──
                Transform.translate(
                  offset: const Offset(0, -24), // Remonte sur l'image du haut
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white.withOpacity(0.5)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Message d'erreur dynamique de Supabase
                                if (_error != null) ...[
                                  _buildErrorWidget(),
                                  const SizedBox(height: 16),
                                ],

                                // Champ Email / Téléphone (Correction : suppression du doublon de label textuel)
                                HollaTextField(
                                  label: 'Email ou Téléphone',
                                  controller: _emailController,
                                  hint: 'votre@email.com',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Ce champ est requis';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Ligne d'options pour le Mot de passe oublié
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {/* Logique mot de passe oublié */},
                                      child: const Text(
                                        'Mot de passe oublié ?',
                                        style: TextStyle(
                                          color: Color(0xFF5341CD),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Champ Mot de passe (Correction : suppression du doublon de label textuel)
                                HollaTextField(
                                  label: 'Mot de passe',
                                  controller: _passwordController,
                                  hint: '••••••••',
                                  obscureText: !_showPassword,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Mot de passe requis';
                                    return null;
                                  },
                                  // Optionnel : Ajoute un suffixIcon si ton HollaTextField personnalisé le gère, 
                                  // pour permettre de changer l'état de `_showPassword` au clic.
                                ),
                                const SizedBox(height: 24),

                                // Bouton Soumettre
                                HollaButton(
                                  label: 'Se connecter',
                                  loading: _loading,
                                  onPressed: _handleLogin,
                                ),
                                const SizedBox(height: 24),

                                // Séparateur "OU CONTINUER AVEC"
                                Row(
                                  children: [
                                    const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        'OU CONTINUER AVEC',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF474554).withOpacity(0.5),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Boutons Sociaux (Google, Apple, Facebook)
                                Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSocialButton(
                                    imagePath: 'assets/icons/google.png',
                                    onTap: () {
                                      // TODO: handle Google sign-in
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  _buildSocialButton(
                                    imagePath: 'assets/icons/apple.png',
                                    isApple: true,
                                    onTap: () {
                                      // TODO: handle Apple sign-in
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  _buildSocialButton(
                                    imagePath: 'assets/icons/face.png',
                                    onTap: () {
                                      // TODO: handle Facebook sign-in
                                    },
                                  ),
                                ],
                              ),
                                const SizedBox(height: 24),

                                // Pied de page de la carte
                                Center(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text("Vous n'avez pas de compte ? ", style: TextStyle(color: Color(0xFF474554))),
                                          GestureDetector(
                                            onTap: () => context.go('/auth/register'),
                                            child: const Text(
                                              "S'inscrire",
                                              style: TextStyle(
                                                color: Color(0xFF5341CD),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          "EN CONTINUANT, VOUS ACCEPTEZ NOS CONDITIONS ET NOTRE POLITIQUE DE CONFIDENTIALITÉ.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF474554).withOpacity(0.5),
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget : Boutons d'en-tête (Langue, Thème)
  Widget _buildHeaderButton({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFC8C4D7).withOpacity(0.3)),
        ),
        child: child,
      ),
    );
  }

  // Helper Widget : Boutons de connexion sociale
  Widget _buildSocialButton({String? imagePath, IconData? iconData, Color? iconColor, bool isApple = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isApple ? Colors.white : null,
          border: Border.all(color: const Color(0xFFC8C4D7)),
        ),
        child: Center(
          child: imagePath != null
              ? Image.asset(imagePath, width: 26, height: 26)
              : Icon(iconData, size: 32, color: isApple ? Colors.white : iconColor), // Augmenté légèrement la taille pour l'impact visuel
        ),
      ),
    );
  }

  // Helper Widget : Alerte Erreur Supabase
  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDAD6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBA1A1A).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFBA1A1A), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: Color(0xFFBA1A1A), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}