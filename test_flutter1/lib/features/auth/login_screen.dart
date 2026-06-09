import 'dart:ui';
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
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();

  bool _loading      = false;
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
        email:    _emailController.text.trim(),
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
                                  'Ravi de vous revoir',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Connectez-vous pour continuer votre expérience avec Holla',
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
                                  if (v == null || v.isEmpty) {
                                    return 'Mot de passe requis';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              HollaButton(
                                label: "Se connecter",
                                loading: _loading,
                                onPressed: _handleLogin,
                              ),
                              const SizedBox(height: 24),

                              const Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.black12, thickness: 1)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'OU SE CONNECTER AVEC',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.2),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: Colors.black12, thickness: 1)),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Boutons sociaux locaux synchronisés avec Register
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

                  // ─── LIEN VERS REGISTER ───
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Vous n'avez pas de compte ? ",
                          style: TextStyle(color: Colors.grey, fontFamily: 'Inter'),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/auth/register'),
                          child: const Text(
                            "S'inscrire",
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