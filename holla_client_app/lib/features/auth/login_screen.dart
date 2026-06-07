import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
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
    // Style Gojek : Fond d'application très légèrement grisé pour faire ressortir les éléments blancs
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        top: false, // Permet au dégradé du header de monter jusqu'en haut de l'écran
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header Dégradé Style Gojek Super-App ─────────────────
              Container(
                width: double.infinity,
                height: 290,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [HollaColors.primary, HollaColors.primaryDark],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Stack(
                  children: [
                    // Motifs de cercles d'arrière-plan géométriques et épurés
                    Positioned(
                      top: -50,
                      right: -30,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: -40,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.04),
                        ),
                      ),
                    ),
                    // Contenu du Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Emplacement de l'image du logo (Remplaçant le texte 'H')
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/images/logo.jpeg', // Chemin de votre image
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback visuel élégant si l'image est manquante au premier build
                                return const Center(
                                  child: Icon(Icons.local_shipping_rounded, color: HollaColors.primary, size: 32),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Bienvenue sur HOLLA 👋',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'La livraison urbaine intelligente et rapide',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.85),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Section Formulaire et Actions ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message d'erreur API
                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: HollaColors.errorLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: HollaColors.error.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: HollaColors.error, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: HollaColors.error,
                                    fontSize: 13,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Formulaire regroupé dans une carte blanche style Gojek
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEAEAEA)),
                        ),
                        child: Column(
                          children: [
                            HollaTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'votre@email.com',
                              prefixIcon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Email requis';
                                if (!v.contains('@')) return 'Email invalide';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            HollaTextField(
                              controller: _passwordController,
                              label: 'Mot de passe',
                              hint: '••••••••',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: !_showPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: HollaColors.grey500,
                                ),
                                onPressed: () => setState(() => _showPassword = !_showPassword),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Mot de passe requis';
                                if (v.length < 6) return 'Minimum 6 caractères';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      // Mot de passe oublié
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Mot de passe oublié ?',
                            style: TextStyle(
                              color: HollaColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Bouton de connexion principal
                      HollaButton(
                        label: 'Se connecter',
                        loading: _loading,
                        onPressed: _handleLogin,
                      ),
                      const SizedBox(height: 28),

                      // Séparateur épuré
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Color(0xFFEAEAEA), thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'ou continuer avec',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: Color(0xFFEAEAEA), thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Grille des Boutons Sociaux (Style Gojek ID) ─────────────────
                      Row(
                        children: [
                          // Google Button
                          Expanded(
                            child: _buildSocialButton(
                              label: 'Google',
                              iconWidget: const Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold, 
                                  color: Color(0xFFDB4437),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Facebook Button
                          Expanded(
                            child: _buildSocialButton(
                              label: 'Facebook',
                              iconWidget: const Icon(
                                Icons.facebook,
                                color: Color(0xFF1877F2),
                                size: 22,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Apple Button (Plein écran en dessous car très utilisé sur mobile)
                      _buildSocialButton(
                        label: 'Continuer avec Apple',
                        iconWidget: const Icon(
                          Icons.apple,
                          color: Colors.black,
                          size: 22,
                        ),
                        onPressed: () {},
                        isFullWidth: true,
                      ),
                      
                      const SizedBox(height: 36),

                      // Zone d'inscription
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Pas encore de compte ? ",
                            style: TextStyle(color: HollaColors.grey500, fontFamily: 'Poppins'),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/auth/register'),
                            child: const Text(
                              'Créer un compte',
                              style: TextStyle(
                                color: HollaColors.primary,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Composant réutilisable pour structurer les boutons réseaux sociaux
  Widget _buildSocialButton({
    required String label,
    required Widget iconWidget,
    required VoidCallback onPressed,
    bool isFullWidth = false,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        side: const BorderSide(color: Color(0xFFEAEAEA)),
        minimumSize: Size(isFullWidth ? double.infinity : 0, 48),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF2A2A2A),
            ),
          ),
        ],
      ),
    );
  }
}