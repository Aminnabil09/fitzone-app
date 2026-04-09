import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/theme_service.dart';


class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.5, -0.5),
                  radius: 1.5,
                  colors: ThemeService().isDarkMode 
                    ? const [
                        Color(0xFF121212),
                        Color(0xFF050505),
                      ]
                    : [
                        AppTheme.backgroundColor,
                        AppTheme.surfaceColor,
                      ],
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: 0.3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      -0.8 * (1 + 0.1 * _animation.value), 
                      0.8 * (1 + 0.1 * _animation.value)
                    ),
                    radius: 1.2,
                    colors: [
                      AppTheme.textColor.withValues(alpha: 0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}
