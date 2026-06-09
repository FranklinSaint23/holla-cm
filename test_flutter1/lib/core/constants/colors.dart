import 'package:flutter/material.dart';

class HollaColors {
  // ── Couleurs principales HOLLA ──────────────────────────
  // Inspiré Gojek : vert bold → on garde notre violet mais
  // avec la même énergie visuelle
  static const primary       = Color(0xFF5B2EE8); // Violet HOLLA bold
  static const primaryLight  = Color(0xFFEDE9FE); // Violet très clair
  static const primaryDark   = Color(0xFF3B1AAF); // Violet foncé

  static const secondary     = Color(0xFF00C2CB); // Cyan accent
  static const secondaryLight= Color(0xFFE0FAFA);

  // ── Couleurs fonctionnelles ──────────────────────────────
  static const success       = Color(0xFF00B14F); // Vert Gojek-like
  static const successLight  = Color(0xFFE6F9EE);
  static const warning       = Color(0xFFFFB800);
  static const warningLight  = Color(0xFFFFF8E6);
  static const error         = Color(0xFFE53935);
  static const errorLight    = Color(0xFFFFEBEE);
  static const info          = Color(0xFF1E88E5);

  // ── Neutres ─────────────────────────────────────────────
  static const dark          = Color(0xFF1A1A2E); // Quasi noir
  static const grey700       = Color(0xFF424242);
  static const grey500       = Color(0xFF9E9E9E);
  static const grey300       = Color(0xFFE0E0E0);
  static const grey100       = Color(0xFFF5F5F5);
  static const white         = Color(0xFFFFFFFF);

  // ── Background dégradé Gojek-style ──────────────────────
  static const bgGradientStart = Color(0xFF5B2EE8);
  static const bgGradientEnd   = Color(0xFF3B1AAF);

  // ── Statuts commandes ────────────────────────────────────
  static const statusPending   = Color(0xFFFFB800);
  static const statusConfirmed = Color(0xFF1E88E5);
  static const statusPreparing = Color(0xFF5B2EE8);
  static const statusDelivery  = Color(0xFF00C2CB);
  static const statusDelivered = Color(0xFF00B14F);
  static const statusCancelled = Color(0xFFE53935);

  // ── Mode sombre ─────────────────────────────────────────
  static const darkBg          = Color(0xFF0F0E17);
  static const darkCard        = Color(0xFF1C1B29);
  static const darkBorder      = Color(0xFF2D2B3D);
  static const darkText        = Color(0xFFE8E6F0);
  static const darkSubtext     = Color(0xFF9896AA);
}