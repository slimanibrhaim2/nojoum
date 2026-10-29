import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/remote_avatar.dart';
import '../../domain/prediction.dart';

class PredictionCard extends StatelessWidget {
  const PredictionCard({
    super.key,
    required this.prediction,
    this.onLike,
    this.onDislike,
    this.busy = false,
  });

  final Prediction prediction;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat.yMMMd(locale).format(prediction.date);

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
          // Soft outer glow
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
              // ── Background: subtle vertical gradient panel ──
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

              // ── Accent bar on the left edge ──
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

              // ── Content ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      prediction: prediction,
                      date: date,
                      scheme: scheme,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      prediction.summary,
                      style: TextStyle(
                        color: scheme.onSurface,
                        height: 1.45,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (prediction.details != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        height: 1,
                        color: scheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        prediction.details!,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          height: 1.5,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    _Footer(
                      prediction: prediction,
                      scheme: scheme,
                      busy: busy,
                      onLike: onLike,
                      onDislike: onDislike,
                    ),
                  ],
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
    required this.scheme,
  });

  final Prediction prediction;
  final String date;
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
              Row(
                children: [
                  if (showRating) ...[
                    _RatingChip(
                      value: prediction.forecasterAverageRate,
                      scheme: scheme,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      date,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
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
  });

  final Prediction prediction;
  final ColorScheme scheme;
  final bool busy;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;

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
        _EngageChip(
          icon: liked
              ? Icons.thumb_up_alt_rounded
              : Icons.thumb_up_off_alt_rounded,
          value: '${prediction.likeCount}',
          scheme: scheme,
          active: liked,
          activeColor: scheme.primary,
          onTap: busy ? null : onLike,
        ),
        const SizedBox(width: 6),
        _EngageChip(
          icon: disliked
              ? Icons.thumb_down_alt_rounded
              : Icons.thumb_down_off_alt_rounded,
          value: '${prediction.dislikeCount}',
          scheme: scheme,
          active: disliked,
          activeColor: scheme.error,
          onTap: busy ? null : onDislike,
        ),
        const SizedBox(width: 6),
        _EngageChip(
          icon: Icons.ios_share_rounded,
          value: '${prediction.sharingCount}',
          scheme: scheme,
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

class _EngageChip extends StatelessWidget {
  const _EngageChip({
    required this.icon,
    required this.value,
    required this.scheme,
    this.active = false,
    this.activeColor,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final ColorScheme scheme;
  final bool active;
  final Color? activeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = activeColor ?? scheme.secondary;
    final bg = active
        ? accent.withValues(alpha: 0.16)
        : scheme.surfaceContainerHighest.withValues(alpha: 0.45);
    final fg = active ? accent : scheme.onSurfaceVariant;
    final iconColor = active ? accent : scheme.accent;

    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active
              ? accent.withValues(alpha: 0.35)
              : scheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              color: fg,
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