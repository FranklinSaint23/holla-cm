import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/payment_service.dart';

const _methods = [
  {
    'key':   'mtn_momo',
    'label': 'MTN Mobile Money',
    'emoji': '📱',
    'color': 0xFFFFCB05,
    'hint':  'Ex: 677 123 456',
  },
  {
    'key':   'orange_money',
    'label': 'Orange Money',
    'emoji': '🟠',
    'color': 0xFFFF6600,
    'hint':  'Ex: 690 123 456',
  },
  {
    'key':   'cash',
    'label': 'Paiement à la livraison',
    'emoji': '💵',
    'color': 0xFF00B14F,
    'hint':  null,
  },
];

class PaymentScreen extends ConsumerStatefulWidget {
  final String orderId;
  final int amount;
  final int deliveryFee;

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.deliveryFee,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String? _selectedMethod;
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _success = false;

  int get _total => widget.amount + widget.deliveryFee;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    if (_selectedMethod == null) return;

    // Valider téléphone si Mobile Money
    if (_selectedMethod != 'cash') {
      final phone = _phoneController.text.trim();
      if (!RegExp(r'^6[5-9]\d{7}$').hasMatch(phone)) {
        setState(() => _error = 'Numéro invalide. Ex: 677 123 456');
        return;
      }
    }

    setState(() { _loading = true; _error = null; });

    try {
      final service = PaymentService();

      if (_selectedMethod == 'cash') {
        await service.payCash(widget.orderId);
      } else {
        await service.payMobileMoney(
          orderId: widget.orderId,
          method:  _selectedMethod!,
          phone:   '+237${_phoneController.text.trim()}',
          amount:  _total,
        );
      }

      setState(() => _success = true);

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
    if (_success) return _buildSuccess();

    return Scaffold(
      backgroundColor: HollaColors.grey100,
      appBar: AppBar(
        title: const Text('Paiement'),
        backgroundColor: Colors.white,
        foregroundColor: HollaColors.dark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── RÉSUMÉ MONTANT ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [HollaColors.primary, HollaColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: HollaColors.primary.withOpacity(0.3),
                    blurRadius: 16, offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text('Total à payer',
                    style: TextStyle(
                      color: Colors.white70, fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('$_total FCFA',
                    style: const TextStyle(
                      color: Colors.white, fontSize: 32,
                      fontWeight: FontWeight.w800, fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AmountChip(
                        label: 'Articles',
                        value: '${widget.amount} FCFA',
                      ),
                      const SizedBox(width: 12),
                      _AmountChip(
                        label: 'Livraison',
                        value: '${widget.deliveryFee} FCFA',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── ERREUR ──────────────────────────────────────
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

            // ── MÉTHODES ────────────────────────────────────
            const Text('Mode de paiement',
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),

            ..._methods.map((method) {
              final isSelected = _selectedMethod == method['key'];
              final color = Color(method['color'] as int);

              return GestureDetector(
                onTap: () => setState(() {
                  _selectedMethod = method['key'] as String;
                  _error = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? color : HollaColors.grey300,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(
                            color: color.withOpacity(0.15),
                            blurRadius: 12, offset: const Offset(0, 4),
                          )]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(method['emoji'] as String,
                            style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(method['label'] as String,
                              style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: isSelected ? color : HollaColors.dark,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            if (method['hint'] != null)
                              Text(method['hint'] as String,
                                style: const TextStyle(
                                  fontSize: 12, color: HollaColors.grey500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? color : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? color : HollaColors.grey300,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 13)
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),

            // ── CHAMP TÉLÉPHONE ─────────────────────────────
            if (_selectedMethod != null && _selectedMethod != 'cash') ...[
              const SizedBox(height: 8),
              const Text('Numéro Mobile Money',
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 9,
                style: const TextStyle(
                  fontSize: 18, letterSpacing: 2,
                  fontFamily: 'Poppins', fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '677 123 456',
                  prefix: const Text('+237  ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  prefixIcon: const Icon(Icons.phone_rounded,
                    color: HollaColors.primary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: HollaColors.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: HollaColors.primary, width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: HollaColors.grey300),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '💡 Vous recevrez une notification pour confirmer le paiement',
                style: TextStyle(
                  fontSize: 12, color: HollaColors.grey500,
                  fontFamily: 'Poppins',
                ),
              ),
            ],

            const SizedBox(height: 32),

            // ── BOUTON CONFIRMER ────────────────────────────
            GestureDetector(
              onTap: _selectedMethod == null || _loading
                  ? null
                  : _handlePayment,
              child: AnimatedOpacity(
                opacity: _selectedMethod == null ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [HollaColors.primary, HollaColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: HollaColors.primary.withOpacity(0.35),
                        blurRadius: 16, offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _selectedMethod == null
                                ? 'Choisir un mode de paiement'
                                : 'Confirmer · $_total FCFA',
                            style: const TextStyle(
                              color: Colors.white, fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animation succès
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: HollaColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                  color: HollaColors.success, size: 70),
              ),
              const SizedBox(height: 28),
              const Text('Paiement réussi !',
                style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _selectedMethod == 'cash'
                    ? 'Votre commande est confirmée.\nPaiement à la livraison.'
                    : 'Votre commande est confirmée.\nLe restaurant prépare votre commande.',
                style: const TextStyle(
                  color: HollaColors.grey500, fontSize: 15,
                  fontFamily: 'Poppins', height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Bouton suivi
              GestureDetector(
                onTap: () => context.go('/orders/${widget.orderId}'),
                child: Container(
                  height: 56, width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [HollaColors.primary, HollaColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: HollaColors.primary.withOpacity(0.35),
                        blurRadius: 16, offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('Suivre ma commande',
                      style: TextStyle(
                        color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.w700, fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Bouton retour accueil
              GestureDetector(
                onTap: () => context.go('/'),
                child: Container(
                  height: 52, width: double.infinity,
                  decoration: BoxDecoration(
                    color: HollaColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text("Retour à l'accueil",
                      style: TextStyle(
                        color: HollaColors.primary, fontSize: 15,
                        fontWeight: FontWeight.w600, fontFamily: 'Poppins',
                      ),
                    ),
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

class _AmountChip extends StatelessWidget {
  final String label;
  final String value;
  const _AmountChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label,
            style: const TextStyle(
              color: Colors.white70, fontSize: 11, fontFamily: 'Poppins',
            ),
          ),
          Text(value,
            style: const TextStyle(
              color: Colors.white, fontSize: 13,
              fontWeight: FontWeight.w700, fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}