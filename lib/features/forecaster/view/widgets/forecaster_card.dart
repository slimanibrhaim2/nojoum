import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/mock/fake_ids.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/remote_avatar.dart';
import '../../domain/forecaster.dart';

class ForecasterCard extends StatelessWidget {
  const ForecasterCard({
    super.key,
    required this.profile,
    this.onTap,
  });

  final ForecasterPublicProfile profile;
  final VoidCallback? onTap;

  String _typeLabel(AppLocalizations t, int flag) {
    switch (flag) {
      case ForecastingType.westernAstrology:
        return t.typeWesternAstrology;
      case ForecastingType.vedicAstrology:
        return t.typeVedicAstrology;
      case ForecastingType.chineseAstrology:
        return t.typeChineseAstrology;
      case ForecastingType.tarotReading:
        return t.typeTarot;
      case ForecastingType.numerology:
        return t.typeNumerology;
      case ForecastingType.palmistry:
        return t.typePalm;
      case ForecastingType.mediumship:
        return t.typeMediumship;
      case ForecastingType.clairvoyance:
        return t.typeClairvoyance;
      default:
        return t.forecastingTypeCode(flag);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = profile.name.trim().isEmpty ? '—' : profile.name;
    final types = ForecastingType.activeFlags(profile.type)
        .map((flag) => _typeLabel(t, flag))
        .toList();
    final imageUrl = AppConfig.mediaUrl(profile.imagePath);

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
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [scheme.primary, scheme.secondary],
                                ),
                              ),
                              padding: const EdgeInsets.all(2),
                              child: RemoteAvatar(url: imageUrl, radius: 26),
                            ),
                            const SizedBox(width: 14),
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
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      _StatPill(
                                        icon: Icons.star_rounded,
                                        label: profile.averageRate
                                            .toStringAsFixed(1),
                                        scheme: scheme,
                                        emphasis: true,
                                      ),
                                      _StatPill(
                                        icon: Icons.reviews_outlined,
                                        label:
                                            '${profile.reviewCount} ${t.reviews}',
                                        scheme: scheme,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (types.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Container(
                            height: 1,
                            color:
                                scheme.outlineVariant.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final type in types)
                                _TypePill(label: type, scheme: scheme),
                            ],
                          ),
                        ],
                      ],
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

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.scheme,
    this.emphasis = false,
  });

  final IconData icon;
  final String label;
  final ColorScheme scheme;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final accent = emphasis ? scheme.secondary : scheme.accent;
    final bg = emphasis
        ? scheme.secondary.withValues(alpha: 0.16)
        : scheme.surfaceContainerHighest.withValues(alpha: 0.5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: emphasis
              ? scheme.secondary.withValues(alpha: 0.35)
              : scheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: accent),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: emphasis ? scheme.onSurface : scheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.label, required this.scheme});

  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: scheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
