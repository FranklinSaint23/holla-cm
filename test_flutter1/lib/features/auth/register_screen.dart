import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/widgets/holla_button.dart';
import '../../shared/widgets/holla_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _phoneController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();
  final _formKey            = GlobalKey<FormState>();

  bool _loading      = false;
  bool _showPassword = false;
  bool _acceptTerms  = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      setState(() => _error = 'Veuillez accepter les conditions');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(authServiceProvider).register(
        name:     _nameController.text.trim(),
        email:    _emailController.text.trim(),
        phone:    _phoneController.text.trim(),
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
      backgroundColor: const Color(0xFFF1FBFF),
      body: Stack(
        children: [
          // ─── FOND DE PAGE GLOBAL ───
          Positioned.fill(
            child: Container(
              color: const Color(0xFFF1FBFF),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/images/global.png', 
                repeat: ImageRepeat.repeat,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint("Erreur chargement global.png: $error");
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          // ─── CONTENU DÉROULANT ───
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // ─── HEADER IMMERSIF ───
                  Stack(
                    children: [
                      Container(
                        height: 240,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/local.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: HollaColors.primary,
                                ),
                              ),
                              Container(color: Colors.black.withOpacity(0.55)), 
                            ],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 10),
                                Image.asset(
                                  'assets/images/logo.jpeg',
                                  height: 50,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const CircleAvatar(
                                    backgroundColor: Colors.white24,
                                    child: Icon(Icons.apps, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Créer un compte',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Inscrivez-vous pour commencer votre expérience avec Holla',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.85),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 50,
                        left: 20,
                        child: GestureDetector(
                          onTap: () => context.go('/auth/login'),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white30),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ─── CARD PRINCIPALE ───
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.4)),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_error != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFDAD6), 
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0x4DBA1A1A)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded, color: Color(0xFFBA1A1A), size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _error!,
                                          style: const TextStyle(color: Color(0xFFBA1A1A), fontSize: 13, fontFamily: 'Inter'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              HollaTextField(
                                controller: _nameController,
                                label: 'Nom complet',
                                hint: 'Alex Douala',
                                prefixIcon: Icons.person_outline_rounded,
                                validator: (v) {
                                  if (v == null || v.trim().length < 2) {
                                    return 'Nom requis (min 2 caractères)';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              HollaTextField(
                                controller: _emailController,
                                label: 'Email',
                                hint: 'alex@exemple.cm',
                                prefixIcon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || !v.contains('@')) {
                                    return 'Email invalide';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Champ Téléphone corrigé pour forcer le préfixe visible en continu
                              HollaTextField(
                                controller: _phoneController,
                                label: 'Numéro de téléphone',
                                hint: '6XX XXX XXX',
                                prefixIcon: Icons.phone_outlined,
                                // Utilisation d'un Row dans prefixIcon pour forcer l'affichage continu
                                prefix: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    SizedBox(width: 4),
                                    Text(
                                      '+237 ',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                keyboardType: TextInputType.phone,
                                maxLength: 9,
                                validator: (v) {
                                  if (v == null || !RegExp(r'^6[5-9]\d{7}$').hasMatch(v)) {
                                    return 'Numéro invalide. Ex: 677123456';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              HollaTextField(
                                controller: _passwordController,
                                label: 'Mot de passe',
                                hint: '••••••••',
                                prefixIcon: Icons.lock_outline_rounded,
                                obscureText: !_showPassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => setState(() => _showPassword = !_showPassword),
                                ),
                                validator: (v) {
                                  if (v == null || v.length < 8) {
                                    return 'Minimum 8 caractères';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              HollaTextField(
                                controller: _confirmController,
                                label: 'Confirmer le mot de passe',
                                hint: '••••••••',
                                prefixIcon: Icons.lock_reset_rounded,
                                obscureText: true,
                                validator: (v) {
                                  if (v != _passwordController.text) {
                                    return 'Les mots de passe ne correspondent pas';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),

                              GestureDetector(
                                onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: _acceptTerms ? const Color(0xFF5341CD) : Colors.transparent,
                                        border: Border.all(
                                          color: _acceptTerms ? const Color(0xFF5341CD) : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: _acceptTerms
                                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: RichText(
                                        text: const TextSpan(
                                          text: "J'accepte les ",
                                          style: TextStyle(color: Colors.black54, fontSize: 13, fontFamily: 'Inter'),
                                          children: [
                                            TextSpan(
                                              text: "Conditions d'utilisation",
                                              style: TextStyle(color: Color(0xFF5341CD), fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(text: ' et la '),
                                            TextSpan(
                                              text: 'Politique de confidentialité',
                                              style: TextStyle(color: Color(0xFF5341CD), fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              HollaButton(
                                label: "S'inscrire",
                                loading: _loading,
                                onPressed: _handleRegister,
                              ),
                              const SizedBox(height: 24),

                              Row(
                                children: const [
                                  Expanded(child: Divider(color: Colors.black12, thickness: 1)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'OU S\'INSCRIRE AVEC',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.2),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: Colors.black12, thickness: 1)),
                                ],
                              ),
                              const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSocialButton(imagePath: 'assets/icons/google.png'),
                                  const SizedBox(width: 20),
                                  _buildSocialButton(imagePath: 'assets/icons/apple.png'),
                                  const SizedBox(width: 20),
                                  _buildSocialButton(imagePath: 'assets/icons/face.png'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ─── LIEN VERS LOGIN ───
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Vous avez déjà un compte ? ",
                          style: TextStyle(color: Colors.grey, fontFamily: 'Inter'),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/auth/login'),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              color: Color(0xFF5341CD),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
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
        ],
      ),
    );
  }

  Widget _buildSocialButton({required String imagePath}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000), 
            blurRadius: 6, 
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          imagePath, 
          width: 28, 
          height: 28,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            debugPrint("Erreur icône ($imagePath): $error");
            return const Icon(Icons.star_border, color: Colors.grey);
          },
        ),
      ),
    );
  }
}