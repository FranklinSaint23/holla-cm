import 'package:flutter/material.dart';
import 'colors.dart';

class HollaTextStyles {
  // ── Titres ───────────────────────────────────────────────
  static const h1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700,
    color: HollaColors.dark, fontFamily: 'Poppins', height: 1.2,
  );
  static const h2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700,
    color: HollaColors.dark, fontFamily: 'Poppins', height: 1.3,
  );
  static const h3 = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600,
    color: HollaColors.dark, fontFamily: 'Poppins', height: 1.4,
  );
  static const h4 = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: HollaColors.dark, fontFamily: 'Poppins',
  );

  // ── Corps ────────────────────────────────────────────────
  static const bodyLarge = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: HollaColors.dark, fontFamily: 'Poppins', height: 1.5,
  );
  static const bodyMedium = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: HollaColors.grey700, fontFamily: 'Poppins', height: 1.5,
  );
  static const bodySmall = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w400,
    color: HollaColors.grey500, fontFamily: 'Poppins',
  );

  // ── Labels ───────────────────────────────────────────────
  static const labelLarge = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: HollaColors.dark, fontFamily: 'Poppins',
  );
  static const labelMedium = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600,
    color: HollaColors.grey500, fontFamily: 'Poppins',
    letterSpacing: 0.5,
  );
  static const labelSmall = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w700,
    color: HollaColors.grey500, fontFamily: 'Poppins',
    letterSpacing: 1.0,
  );

  // ── Boutons ──────────────────────────────────────────────
  static const buttonLarge = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700,
    color: HollaColors.white, fontFamily: 'Poppins',
    letterSpacing: 0.3,
  );
  static const buttonMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: HollaColors.white, fontFamily: 'Poppins',
  );
}