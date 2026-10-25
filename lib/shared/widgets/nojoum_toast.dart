import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

enum NojoumToastKind { success, error, info }

class NojoumToast {
  NojoumToast._();

  static OverlayEntry? _entry;

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    NojoumToastKind kind = NojoumToastKind.success,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    hide();
    final overlay = Overlay.of(context, rootOverlay: true);
    final theme = Theme.of(context);
    final direction = Directionality.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return Directionality(
          textDirection: direction,
          child: Theme(
            data: theme,
            child: _NojoumToastCard(
              message: message,
              title: title,
              kind: kind,
              duration: duration,
              onFinished: hide,
            ),
          ),
        );
      },
    );
    _entry = entry;
    overlay.insert(entry);
  }

  static void hide() {
    final entry = _entry;
    _entry = null;
    entry?.remove();
  }
}

class _NojoumToastCard extends StatefulWidget {
  const _NojoumToastCard({
    required this.message,
    required this.title,
    required this.kind,
    required this.duration,
    required this.onFinished,
  });

  final String message;
  final String? title;
  final NojoumToastKind kind;
  final Duration duration;
  final VoidCallback onFinished;

  @override
  State<_NojoumToastCard> createState() => _NojoumToastCardState();
}

class _NojoumToastCardState extends State<_NojoumToastCard>
    with TickerProviderStateMixin {
  late final AnimationController _life;
  late final AnimationController _sparkle;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _life = AnimationController(vsync: this, duration: widget.duration)
      ..forward().whenComplete(widget.onFinished);
    _sparkle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    final appear = CurvedAnimation(
      parent: _life,
      curve: const Interval(0, 0.16, curve: Curves.easeOutCubic),
      reverseCurve: Curves.easeInCubic,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.35),
      end: Offset.zero,
    ).animate(appear);
    _fade = Tween<double>(begin: 0, end: 1).animate(appear);
  }

  @override
  void dispose() {
    _life.dispose();
    _sparkle.dispose();
    super.dispose();
  }

  _ToastPalette _palette(ColorScheme scheme) {
    switch (widget.kind) {
      case NojoumToastKind.success:
        return _ToastPalette(
          icon: Icons.auto_awesome,
          glow: scheme.accent,
          ink: scheme.onSurface,
        );
      case NojoumToastKind.error:
        return _ToastPalette(
          icon: Icons.nights_stay_rounded,
          glow: const Color(0xFFFF6B8A),
          ink: scheme.onSurface,
        );
      case NojoumToastKind.info:
        return _ToastPalette(
          icon: Icons.star_rounded,
          glow: scheme.primary,
          ink: scheme.onSurface,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final palette = _palette(scheme);
    final media = MediaQuery.of(context);

    return Positioned(
      top: media.padding.top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Dismissible(
              key: const ValueKey('nojoum-toast'),
              direction: DismissDirection.up,
              onDismissed: (_) => widget.onFinished(),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: palette.glow.withValues(alpha: dark ? 0.28 : 0.18),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: AlignmentDirectional.topStart,
                              end: AlignmentDirectional.bottomEnd,
                              colors: dark
                                  ? [
                                      const Color(0xFF2E2442),
                                      const Color(0xFF3D2F5C),
                                      const Color(0xFF4A3A4A),
                                    ]
                                  : [
                                      const Color(0xFFFFFBF4),
                                      const Color(0xFFF3E8FF),
                                      const Color(0xFFFFF1D6),
                                    ],
                            ),
                            border: Border.all(
                              color: palette.glow.withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: AnimatedBuilder(
                            animation: _sparkle,
                            builder: (context, _) {
                              return CustomPaint(
                                painter: _ToastStarPainter(
                                  tick: _sparkle.value,
                                  color: palette.glow,
                                  dark: dark,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                        child: Row(
                          children: [
                            _GlowIcon(icon: palette.icon, color: palette.glow),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.title != null) ...[
                                    Text(
                                      widget.title!,
                                      style: TextStyle(
                                        color: palette.ink,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                  ],
                                  Text(
                                    widget.message,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: palette.ink.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w600,
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: AnimatedBuilder(
                          animation: _life,
                          builder: (context, _) {
                            return Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: FractionallySizedBox(
                                widthFactor: (1 - _life.value).clamp(0.0, 1.0),
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        palette.glow,
                                        scheme.primary,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlowIcon extends StatelessWidget {
  const _GlowIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.45),
            color.withValues(alpha: 0.12),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _ToastPalette {
  const _ToastPalette({
    required this.icon,
    required this.glow,
    required this.ink,
  });

  final IconData icon;
  final Color glow;
  final Color ink;
}

class _ToastStarPainter extends CustomPainter {
  _ToastStarPainter({
    required this.tick,
    required this.color,
    required this.dark,
  });

  final double tick;
  final Color color;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final random = math.Random(7);
    for (var i = 0; i < 14; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final pulse = 0.35 + 0.65 * (0.5 + 0.5 * math.sin((tick * 6.28) + i));
      paint.color = color.withValues(alpha: (dark ? 0.55 : 0.28) * pulse);
      canvas.drawCircle(Offset(x, y), 1.2 + pulse, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ToastStarPainter oldDelegate) {
    return oldDelegate.tick != tick;
  }
}
