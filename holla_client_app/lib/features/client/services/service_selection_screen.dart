import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../main.dart';

class ServiceSelectionScreen extends ConsumerStatefulWidget {
  final String skill;
  const ServiceSelectionScreen({super.key, required this.skill});

  @override
  ConsumerState<ServiceSelectionScreen> createState() =>
      _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState
    extends ConsumerState<ServiceSelectionScreen> {
  final _addressController     = TextEditingController();
  final _landmarkController    = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _scheduleNow = true;
  DateTime _scheduledDate = DateTime.now().add(const Duration(hours: 2));
  bool _loading = false;
  String? _error;

  static const _skillLabels = {
    'plumbing':    'Plomberie 🔧',
    'electricity': 'Électricité ⚡',
    'cleaning':    'Ménage 🧹',
    'painting':    'Peinture 🎨',
    'carpentry':   'Menuiserie 🪚',
    'aircon':      'Climatisation ❄️',
    'it':          'Informatique 💻',
    'security':    'Sécurité 🔒',
  };

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validate() {
    if (_addressController.text.trim().isEmpty) {
      setState(() => _error = 'Veuillez entrer votre adresse');
      return false;
    }
    if (_descriptionController.text.trim().length < 10) {
      setState(() => _error = 'Décrivez votre problème (min 10 caractères)');
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final userId = supabase.auth.currentUser!.id;

      await supabase.from('service_requests').insert({
        'client_id':    userId,
        'skill_needed': widget.skill,
        'description':  _descriptionController.text.trim(),
        'address':      _addressController.text.trim(),
        'landmark':     _landmarkController.text.trim().isEmpty
            ? null
            : _landmarkController.text.trim(),
        'scheduled_at': _scheduleNow
            ? null
            : _scheduledDate.toIso8601String(),
        'status':       'pending',
      });

      if (mounted) {
        // Succès
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: HollaColors.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                    color: HollaColors.success, size: 48),
                ),
                const SizedBox(height: 16),
                const Text('Demande envoyée !',
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Un prestataire vous contactera bientôt.',
                  style: TextStyle(
                    color: HollaColors.grey500, fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/');
                  },
                  child: Container(
                    height: 48, width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [HollaColors.primary, HollaColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text("Retour à l'accueil",
                        style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _error = 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skillLabel =
        _skillLabels[widget.skill] ?? widget.skill;

    return Scaffold(
      backgroundColor: HollaColors.grey100,
      appBar: AppBar(
        title: Text(skillLabel),
        backgroundColor: Colors.white,
        foregroundColor: HollaColors.dark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              const SizedBox(height: 14),
            ],

            // ── ADRESSE ─────────────────────────────────────
            _buildCard(
              title: '📍 Adresse d\'intervention',
              child: Column(
                children: [
                  _buildField(
                    controller: _addressController,
                    hint: 'Quartier, rue... Ex: Bastos, Yaoundé',
                    icon: Icons.location_on_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _landmarkController,
                    hint: 'Repère local (optionnel). Ex: Face à la pharmacie',
                    icon: Icons.flag_rounded,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: HollaColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lightbulb_rounded,
                          color: HollaColors.primary, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Les repères aident le prestataire à vous trouver facilement',
                            style: TextStyle(
                              fontSize: 11, color: HollaColors.primary,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── DESCRIPTION ──────────────────────────────────
            _buildCard(
              title: '📝 Décrivez votre besoin',
              child: Column(
                children: [
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    maxLength: 500,
                    style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Ex: La robinetterie de la cuisine fuit depuis 2 jours...',
                      hintStyle: const TextStyle(
                        color: HollaColors.grey500,
                        fontFamily: 'Poppins', fontSize: 13,
                      ),
                      filled: true,
                      fillColor: HollaColors.grey100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => setState(() => _error = null),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── PLANIFICATION ────────────────────────────────
            _buildCard(
              title: '📅 Quand ?',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ScheduleOption(
                          icon: Icons.bolt_rounded,
                          label: 'Maintenant',
                          isSelected: _scheduleNow,
                          onTap: () => setState(() => _scheduleNow = true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ScheduleOption(
                          icon: Icons.calendar_month_rounded,
                          label: 'Planifier',
                          isSelected: !_scheduleNow,
                          onTap: () => setState(() => _scheduleNow = false),
                        ),
                      ),
                    ],
                  ),
                  if (!_scheduleNow) ...[
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _scheduledDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_scheduledDate),
                          );
                          if (time != null) {
                            setState(() {
                              _scheduledDate = DateTime(
                                date.year, date.month, date.day,
                                time.hour, time.minute,
                              );
                            });
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: HollaColors.grey100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: HollaColors.grey300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                              color: HollaColors.primary, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              '${_scheduledDate.day}/${_scheduledDate.month}/${_scheduledDate.year} '
                              '${_scheduledDate.hour}:${_scheduledDate.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontFamily: 'Poppins', fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right_rounded,
                              color: HollaColors.grey500, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── BOUTON CONFIRMER ─────────────────────────────
            GestureDetector(
              onTap: _loading ? null : _submit,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 56,
                decoration: BoxDecoration(
                  gradient: _loading
                      ? null
                      : const LinearGradient(
                          colors: [HollaColors.primary, HollaColors.primaryDark],
                        ),
                  color: _loading ? HollaColors.grey300 : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _loading
                      ? null
                      : [
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
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Confirmer la demande',
                              style: TextStyle(
                                color: Colors.white, fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
      onChanged: (_) => setState(() => _error = null),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: HollaColors.grey500,
          fontFamily: 'Poppins', fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: HollaColors.primary, size: 20),
        filled: true,
        fillColor: HollaColors.grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _ScheduleOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _ScheduleOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? HollaColors.primary : HollaColors.grey100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? HollaColors.primary : HollaColors.grey300,
          width: 2,
        ),
        boxShadow: isSelected
            ? [BoxShadow(
                color: HollaColors.primary.withOpacity(0.3),
                blurRadius: 10, offset: const Offset(0, 4),
              )]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
            color: isSelected ? Colors.white : HollaColors.grey500,
            size: 18),
          const SizedBox(width: 6),
          Text(label,
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : HollaColors.grey500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    ),
  );
}