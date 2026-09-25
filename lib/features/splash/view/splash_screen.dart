import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/localization/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _pulse;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _rise;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _fade = CurvedAnimation(parent: _intro, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(parent: _intro, curve: Curves.easeOutBack),
    );
    _rise = Tween<double>(begin: 18, end: 0).animate(
      CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_intro, _pulse]),
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF070B1A),
                      Color(0xFF12183A),
                      Color(0xFF1B1240),
                    ],
                  ),
                ),
              ),
              CustomPaint(
                painter: _StarFieldPainter(twinkle: _pulse.value),
              ),
              SafeArea(
                child: FadeTransition(
                  opacity: _fade,
                  child: Transform.translate(
                    offset: Offset(0, _rise.value),
                    child: ScaleTransition(
                      scale: _scale,
                      child: Column(
                        children: [
                          const Spacer(flex: 3),
                          _Emblem(glow: _pulse.value),
                          const SizedBox(height: 28),
                          Text(
                            t.appName,
                            style: const TextStyle(
                              color: Color(0xFFF6E7C1),
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            t.splashTagline,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFFF6E7C1)
                                  .withValues(alpha: 0.72),
                              fontSize: 16,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const Spacer(flex: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 36),
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color.lerp(
                                  const Color(0xFFC9A227),
                                  const Color(0xFFF6E7C1),
                                  _pulse.value,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Emblem extends StatelessWidget {
  const _Emblem({required this.glow});

  final double glow;

  @override
  Widget build(BuildContext context) {
    final halo = 18 + (glow * 14);

    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC9A227).withValues(alpha: 0.28 + glow * 0.18),
            blurRadius: halo,
            spreadRadius: 2,
          ),
        ],
        gradient: const RadialGradient(
          colors: [
            Color(0xFF2A2158),
            Color(0xFF14102F),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFE8C872).withValues(alpha: 0.85),
          width: 1.4,
        ),
      ),
      child: const Icon(
        Icons.auto_awesome,
        size: 54,
        color: Color(0xFFF6E7C1),
      ),
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  _StarFieldPainter({required this.twinkle});

  final double twinkle;

  static final List<_Star> _stars = _buildStars();

  static List<_Star> _buildStars() {
    final random = math.Random(7);
    return List.generate(70, (i) {
      return _Star(
        dx: random.nextDouble(),
        dy: random.nextDouble(),
        radius: 0.5 + random.nextDouble() * 1.6,
        phase: random.nextDouble(),
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in _stars) {
      final wave = (math.sin((twinkle + star.phase) * math.pi * 2) + 1) / 2;
      paint.color = Color.fromRGBO(
        246,
        231,
        193,
        0.18 + wave * 0.72,
      );
      canvas.drawCircle(
        Offset(star.dx * size.width, star.dy * size.height),
        star.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter oldDelegate) {
    return oldDelegate.twinkle != twinkle;
  }
}

class _Star {
  const _Star({
    required this.dx,
    required this.dy,
    required this.radius,
    required this.phase,
  });

  final double dx;
  final double dy;
  final double radius;
  final double phase;
}
