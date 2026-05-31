import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ParticleBackground extends StatefulWidget {
  const ParticleBackground({super.key, required this.child});
  final Widget child;

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _random = Random();
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _particles = List.generate(24, (_) => _Particle.random(_random));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [AppColors.darkBg, AppColors.darkSurface, const Color(0xFF3D2035)]
                  : [AppColors.pinkSoft, Colors.white, AppColors.pinkLight.withValues(alpha: 0.3)],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _ParticlePainter(
                particles: _particles,
                progress: _controller.value,
                isDark: isDark,
              ),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  _Particle({required this.x, required this.y, required this.size, required this.speed});
  final double x;
  final double y;
  final double size;
  final double speed;

  factory _Particle.random(Random r) {
    return _Particle(
      x: r.nextDouble(),
      y: r.nextDouble(),
      size: r.nextDouble() * 4 + 2,
      speed: r.nextDouble() * 0.3 + 0.1,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.isDark,
  });

  final List<_Particle> particles;
  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? AppColors.rose : AppColors.pink).withValues(alpha: 0.25);

    for (final p in particles) {
      final dy = ((p.y + progress * p.speed) % 1.0) * size.height;
      canvas.drawCircle(
        Offset(p.x * size.width, dy),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.progress != progress;
}
