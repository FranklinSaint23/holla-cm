import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

enum HollaButtonVariant { primary, secondary, outline, danger, ghost }

class HollaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final HollaButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double height;

  const HollaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.variant = HollaButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = loading || onPressed == null;

    Color bgColor;
    Color textColor;
    BoxBorder? border;
    List<Color> gradientColors;
    bool useGradient = false;

    switch (variant) {
      case HollaButtonVariant.primary:
        useGradient = true;
        gradientColors = [HollaColors.primary, HollaColors.primaryDark];
        textColor = Colors.white;
        bgColor = HollaColors.primary;
        break;
      case HollaButtonVariant.secondary:
        bgColor = HollaColors.secondary;
        textColor = Colors.white;
        gradientColors = [HollaColors.secondary, HollaColors.secondary];
        break;
      case HollaButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = HollaColors.primary;
        border = Border.all(color: HollaColors.primary, width: 1.5);
        gradientColors = [];
        break;
      case HollaButtonVariant.danger:
        bgColor = HollaColors.error;
        textColor = Colors.white;
        gradientColors = [HollaColors.error, HollaColors.error];
        break;
      case HollaButtonVariant.ghost:
        bgColor = HollaColors.primaryLight;
        textColor = HollaColors.primary;
        gradientColors = [];
        break;
    }

    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.65 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: width ?? double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: useGradient && !isDisabled
                ? LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: useGradient ? null : bgColor,
            borderRadius: BorderRadius.circular(16),
            border: border,
            boxShadow: variant == HollaButtonVariant.primary && !isDisabled
                ? [
                    BoxShadow(
                      color: HollaColors.primary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: textColor, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          fontFamily: 'Poppins',
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}