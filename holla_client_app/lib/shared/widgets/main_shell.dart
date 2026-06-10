import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/orders'))   return 1;
    if (location.startsWith('/services')) return 2;
    if (location.startsWith('/chat'))     return 3;
    if (location.startsWith('/ai-assistant')) return 4; // Assuming AI Assistant is part of the chat section
    if (location.startsWith('/profile'))  return 5;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location     = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,

      // ── BOUTON FLOTTANT IA ─────────────────────────────
      floatingActionButton: _AIFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: _BottomBar(currentIndex: currentIndex),
    );
  }
}

// ── FAB IA ANIMÉ ──────────────────────────────────────────
class _AIFab extends StatefulWidget {
  @override
  State<_AIFab> createState() => _AIFabState();
}

class _AIFabState extends State<_AIFab> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, child) => Container(
        width: 58, height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: HollaColors.primary.withOpacity(_glow.value),
              blurRadius: 20, spreadRadius: 2,
            ),
          ],
        ),
        child: child,
      ),
      child: GestureDetector(
        onTap: () => context.push('/ai-assistant'),
        child: Container(
          width: 58, height: 58,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [HollaColors.secondary, HollaColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Text('🤖', style: TextStyle(fontSize: 26)),
          ),
        ),
      ),
    );
  }
}

// ── BOTTOM BAR ────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int currentIndex;
  const _BottomBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 12,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded,         label: 'Accueil',   index: 0, current: currentIndex, onTap: () => context.go('/')),
              _NavItem(icon: Icons.receipt_long_rounded, label: 'Commandes', index: 1, current: currentIndex, onTap: () => context.go('/orders')),
              _NavItem(icon: Icons.build_rounded,        label: 'Services',  index: 2, current: currentIndex, onTap: () => context.go('/services')),
              const SizedBox(width: 48), // Espace pour le FAB
              _NavItem(icon: Icons.chat_bubble_rounded, label: 'Messages',  index: 3, current: currentIndex, onTap: () => context.go('/chat')),
              _NavItem(icon: Icons.person_rounded,       label: 'Profil',    index: 5, current: currentIndex, onTap: () => context.go('/profile')),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon, required this.label,
    required this.index, required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? HollaColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22,
              color: isActive ? HollaColors.primary : HollaColors.grey500),
            const SizedBox(height: 3),
            Text(label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? HollaColors.primary : HollaColors.grey500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}