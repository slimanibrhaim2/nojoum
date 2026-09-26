import 'dart:math' as math;

import 'package:flutter/material.dart';

class StarSkyBackground extends StatefulWidget {
  const StarSkyBackground({
    super.key,
    this.child,
    this.forceDark = false,
  });

  final Widget? child;
  final bool forceDark;

  @override
  State<StarSkyBackground> createState() => _StarSkyBackgroundState();
}

class _StarSkyBackgroundState extends State<StarSkyBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.forceDark ||
        Theme.of(context).brightness == Brightness.dark;
    final colors = dark
        ? const [
      Color(0xFF2A3054),
      Color(0xFF3E457A),
      Color(0xFF5A4F92),
      Color(0xFF8368C4),
    ]
        : const [
      Color(0xFFE0D4F0),
      Color(0xFFFFFDF8),
      Color(0xFFF5ECDF),
      Color(0xFFEFE1F2),
    ];;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: colors,
                ),
              ),
            ),
            CustomPaint(
              painter: StarFieldPainter(
                tick: _controller.value,
                isDark: dark,
              ),
            ),
            if (widget.child != null) Positioned.fill(child: widget.child!),
          ],
        );
      },
    );
  }
}

class StarFieldPainter extends CustomPainter {
  StarFieldPainter({required this.tick, required this.isDark});

  final double tick;
  final bool isDark;
  static final List<_Star> _stars = _buildStars();

  static List<_Star> _buildStars() {
    final random = math.Random(21);
    return List.generate(90, (i) {
      return _Star(
        dx: random.nextDouble(),
        dy: random.nextDouble(),
        radius: 0.5 + random.nextDouble() * 1.7,
        phase: random.nextDouble(),
        drift: (random.nextDouble() - 0.5) * 0.08,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in _stars) {
      final wave = (math.sin((tick + star.phase) * math.pi * 2) + 1) / 2;
      final x = (((star.dx + star.drift * tick) % 1.0) + 1.0) % 1.0 * size.width;
      final y = (((star.dy + tick * 0.04) % 1.0) + 1.0) % 1.0 * size.height;
      paint.color = isDark
          ? Color.fromRGBO(246, 231, 193, 0.16 + wave * 0.78)
          : Color.fromRGBO(91, 58, 140, 0.08 + wave * 0.28);
      canvas.drawCircle(
        Offset(x, y),
        isDark ? star.radius : star.radius * 0.85,
        paint,
      );
    }

    final meteorT = (tick * 4) % 1.0;
    if (meteorT < 0.22) {
      final p = meteorT / 0.22;
      final start = Offset(size.width * 0.08, size.height * 0.12);
      final end = Offset(size.width * 0.72, size.height * 0.42);
      final head = Offset.lerp(start, end, p)!;
      final tail = Offset.lerp(start, end, (p - 0.18).clamp(0.0, 1.0))!;
      final meteor = isDark ? const Color(0xFFF6E7C1) : const Color(0xFF8A6A12);
      paint
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..color = meteor.withValues(alpha: 0.75 * (1 - p));
      canvas.drawLine(tail, head, paint);
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(head, 2.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarFieldPainter oldDelegate) {
    return oldDelegate.tick != tick || oldDelegate.isDark != isDark;
  }
}

class _Star {
  const _Star({
    required this.dx,
    required this.dy,
    required this.radius,
    required this.phase,
    required this.drift,
  });

  final double dx;
  final double dy;
  final double radius;
  final double phase;
  final double drift;
}

class NightScaffold extends StatelessWidget {
  const NightScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.leading,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StarSkyBackground(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: scheme.onSurface,
              elevation: 0,
              automaticallyImplyLeading: leading != null,
              title: Text(title),
              leading: leading,
              actions: actions,
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
