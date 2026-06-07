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

    setState(() { _loading = true; _error = null; });

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
      backgroundColor: HollaColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 36),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [HollaColors.primary, HollaColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft:  Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -30, right: -30,
                      child: Container(
                        width: 140, height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bouton retour
                        GestureDetector(
                          onTap: () => context.go('/auth/login'),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white, size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Créer un compte',
                          style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w700,
                            color: Colors.white, fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rejoignez la communauté HOLLA',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Formulaire ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: HollaColors.errorLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: HollaColors.error.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                color: HollaColors.error, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(_error!,
                                  style: const TextStyle(
                                    color: HollaColors.error, fontSize: 13,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Nom complet
                      HollaTextField(
                        controller: _nameController,
                        label: 'Nom complet',
                        hint: 'Jean Kamdem',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (v) {
                          if (v == null || v.trim().length < 2)
                            return 'Nom requis (min 2 caractères)';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Email
                      HollaTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'votre@email.com',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || !v.contains('@'))
                            return 'Email invalide';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Téléphone camerounais
                      HollaTextField(
                        controller: _phoneController,
                        label: 'Téléphone',
                        hint: '677 123 456',
                        prefixIcon: Icons.phone_outlined,
                        prefix: const Text(
                          '+237  ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: HollaColors.dark,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        maxLength: 9,
                        validator: (v) {
                          if (v == null || !RegExp(r'^6[5-9]\d{7}$').hasMatch(v))
                            return 'Numéro invalide. Ex: 677123456';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Mot de passe
                      HollaTextField(
                        controller: _passwordController,
                        label: 'Mot de passe',
                        hint: 'Minimum 8 caractères',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: !_showPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: HollaColors.grey500,
                          ),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                        validator: (v) {
                          if (v == null || v.length < 8)
                            return 'Minimum 8 caractères';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Confirmer mot de passe
                      HollaTextField(
                        controller: _confirmController,
                        label: 'Confirmer le mot de passe',
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: true,
                        validator: (v) {
                          if (v != _passwordController.text)
                            return 'Les mots de passe ne correspondent pas';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // CGU
                      GestureDetector(
                        onTap: () =>
                            setState(() => _acceptTerms = !_acceptTerms),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                color: _acceptTerms
                                    ? HollaColors.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _acceptTerms
                                      ? HollaColors.primary
                                      : HollaColors.grey300,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: _acceptTerms
                                  ? const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 14)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  text: "J'accepte les ",
                                  style: TextStyle(
                                    color: HollaColors.grey700,
                                    fontSize: 13,
                                    fontFamily: 'Poppins',
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Conditions d'utilisation",
                                      style: TextStyle(
                                        color: HollaColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(text: ' et la '),
                                    TextSpan(
                                      text: 'Politique de confidentialité',
                                      style: TextStyle(
                                        color: HollaColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bouton inscription
                      HollaButton(
                        label: "Créer mon compte",
                        loading: _loading,
                        onPressed: _handleRegister,
                      ),
                      const SizedBox(height: 24),

                      // Lien connexion
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Déjà un compte ? ",
                            style: TextStyle(
                              color: HollaColors.grey500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/auth/login'),
                            child: const Text(
                              'Se connecter',
                              style: TextStyle(
                                color: HollaColors.primary,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
}