import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/app_theme.dart';

class ButterSurface extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final bool showBorder;
  final bool showGlow;

  const ButterSurface({
    super.key,
    required this.child,
    this.borderRadius = 0,
    this.blur = 30.0,
    this.opacity = 0.05,
    this.color,
    this.padding,
    this.showBorder = true,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = color ?? AppTheme.textColor.withValues(alpha: opacity);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: showBorder
                ? Border.all(
                    color: AppTheme.textColor.withValues(alpha: 0.08),
                    width: 0.5,
                  )
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
