import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/remote_avatar.dart';
import '../../domain/prediction.dart';

class PredictionCard extends StatefulWidget {
  const PredictionCard({
    super.key,
    required this.prediction,
    this.onLike,
    this.onDislike,
    this.onShare,
    this.busy = false,
  });

  final Prediction prediction;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;
  final VoidCallback? onShare;
  final bool busy;

  @override
  State<PredictionCard> createState() => _PredictionCardState();
}

class _PredictionCardState extends State<PredictionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _burstController;
  late final Animation<double> _burstScale;
  late final Animation<double> _burstOpacity;
  late final Animation<Offset> _burstSlide;

  IconData? _burstIcon;
  Color? _burstColor;

  @override
  void initState() {
    super.initState();
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );
    _burstScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.2, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
    ]).animate(_burstController);
    _burstOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 35),
    ]).animate(_burstController);
    _burstSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.18),
    ).animate(
      CurvedAnimation(
        parent: _burstController,
        curve: const Interval(0.35, 1, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _burstController.dispose();
    super.dispose();
  }

  void _playBurst(IconData icon, Color color) {
    setState(() {
      _burstIcon = icon;
      _burstColor = color;
    });
    _burstController
      ..stop()
      ..forward(from: 0);
  }

  void _handleLike({bool fromDoubleTap = false}) {
    if (widget.busy || widget.onLike == null) return;
    final alreadyLiked = widget.prediction.isLikedByCurrentUser;

    final scheme = Theme.of(context).colorScheme;

    // Instagram double-tap always shows love, and only likes (never unlikes).
    if (fromDoubleTap) {
      HapticFeedback.mediumImpact();
      _playBurst(Icons.favorite_rounded, scheme.reactionLike);
      if (!alreadyLiked) widget.onLike!();
      return;
    }

    HapticFeedback.lightImpact();
    if (!alreadyLiked) {
      _playBurst(Icons.favorite_rounded, scheme.reactionLike);
    }
    widget.onLike!();
  }

  void _handleDislike() {
    if (widget.busy || widget.onDislike == null) return;
    final activating = !widget.prediction.isDislikedByCurrentUser;
    HapticFeedback.selectionClick();
    if (activating) {
      _playBurst(
        Icons.thumb_down_alt_rounded,
        Theme.of(context).colorScheme.reactionDislike,
      );
    }
    widget.onDislike!();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);
    final date = DateFormat.yMMMd(locale.toString()).format(
      widget.prediction.date,
    );
    final zodiac = widget.prediction.zodiacSign.display(locale.languageCode);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 22 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
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
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              scheme.surfaceContainerHigh.withAlpha(120),
                              scheme.surfaceContainerHighest.withAlpha(120),
                            ]
                          : [
                              scheme.surface,
                              scheme.surfaceContainerLowest,
                            ],
                    ),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 18,
                bottom: 18,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onDoubleTap: widget.onLike == null || widget.busy
                    ? null
                    : () => _handleLike(fromDoubleTap: true),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(
                        prediction: widget.prediction,
                        date: date,
                        zodiac: zodiac,
                        scheme: scheme,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        widget.prediction.summary,
                        style: TextStyle(
                          color: scheme.onSurface,
                          height: 1.45,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (widget.prediction.details != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          height: 1,
                          color: scheme.outlineVariant.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.prediction.details!,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            height: 1.5,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      _Footer(
                        prediction: widget.prediction,
                        scheme: scheme,
                        busy: widget.busy,
                        onLike: widget.onLike == null ? null : _handleLike,
                        onDislike:
                            widget.onDislike == null ? null : _handleDislike,
                        onShare: widget.onShare,
                      ),
                    ],
                  ),
                ),
              ),
              if (_burstIcon != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _burstController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _burstOpacity.value,
                          child: SlideTransition(
                            position: _burstSlide,
                            child: Transform.scale(
                              scale: _burstScale.value,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: Center(
                        child: Icon(
                          _burstIcon,
                          size: 86,
                          color: (_burstColor ?? scheme.reactionLike)
                              .withValues(alpha: 0.92),
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({
    required this.prediction,
    required this.date,
    required this.zodiac,
    required this.scheme,
  });

  final Prediction prediction;
  final String date;
  final String zodiac;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final name = prediction.forecasterName.trim().isEmpty
        ? '—'
        : prediction.forecasterName;
    final showRating = prediction.forecasterAverageRate > 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primary, scheme.secondary],
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: RemoteAvatar(
            url: prediction.forecasterImageUrl,
            radius: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _ZodiacChip(label: zodiac, scheme: scheme),
                  if (showRating)
                    _RatingChip(
                      value: prediction.forecasterAverageRate,
                      scheme: scheme,
                    ),
                  Text(
                    date,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ZodiacChip extends StatelessWidget {
  const _ZodiacChip({required this.label, required this.scheme});

  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: scheme.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.value, required this.scheme});

  final double value;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.secondary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: scheme.secondary.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 13, color: scheme.secondary),
          const SizedBox(width: 3),
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// FOOTER — engagement row
// ─────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  const _Footer({
    required this.prediction,
    required this.scheme,
    required this.busy,
    required this.onLike,
    required this.onDislike,
    required this.onShare,
  });

  final Prediction prediction;
  final ColorScheme scheme;
  final bool busy;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final liked = prediction.isLikedByCurrentUser;
    final disliked = prediction.isDislikedByCurrentUser;

    return Row(
      children: [
        _EngageChip(
          icon: Icons.visibility_rounded,
          value: '${prediction.viewCount}',
          scheme: scheme,
        ),
        const SizedBox(width: 6),
        _ReactionChip(
          active: liked,
          value: '${prediction.likeCount}',
          activeIcon: Icons.favorite_rounded,
          inactiveIcon: Icons.favorite_border_rounded,
          activeColor: scheme.reactionLike,
          scheme: scheme,
          onTap: busy ? null : onLike,
        ),
        const SizedBox(width: 6),
        _ReactionChip(
          active: disliked,
          value: '${prediction.dislikeCount}',
          activeIcon: Icons.thumb_down_alt_rounded,
          inactiveIcon: Icons.thumb_down_off_alt_rounded,
          activeColor: scheme.reactionDislike,
          scheme: scheme,
          onTap: busy ? null : onDislike,
        ),
        const SizedBox(width: 6),
        _EngageChip(
          icon: Icons.ios_share_rounded,
          value: '${prediction.sharingCount}',
          scheme: scheme,
          onTap: busy ? null : onShare,
        ),
        if (busy) ...[
          const Spacer(),
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 1.8,
              color: scheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}

class _ReactionChip extends StatefulWidget {
  const _ReactionChip({
    required this.active,
    required this.value,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.activeColor,
    required this.scheme,
    this.onTap,
  });

  final bool active;
  final String value;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Color activeColor;
  final ColorScheme scheme;
  final VoidCallback? onTap;

  @override
  State<_ReactionChip> createState() => _ReactionChipState();
}

class _ReactionChipState extends State<_ReactionChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.72)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.72, end: 1.28)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.28, end: 1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant _ReactionChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active || oldWidget.value != widget.value) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (widget.onTap == null) return;
    _controller.forward(from: 0);
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.activeColor;
    final bg = widget.active
        ? accent.withValues(alpha: 0.16)
        : widget.scheme.surfaceContainerHighest.withValues(alpha: 0.45);
    final fg = widget.active ? accent : widget.scheme.onSurfaceVariant;
    final iconColor = widget.active ? accent : widget.scheme.accent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap == null ? null : _onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.active
                  ? accent.withValues(alpha: 0.35)
                  : widget.scheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Icon(
                  widget.active ? widget.activeIcon : widget.inactiveIcon,
                  size: 17,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 5),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  color: fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
                child: Text(widget.value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EngageChip extends StatelessWidget {
  const _EngageChip({
    required this.icon,
    required this.value,
    required this.scheme,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final ColorScheme scheme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.accent),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return chip;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: chip,
      ),
    );
  }
}
