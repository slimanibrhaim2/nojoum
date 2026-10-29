import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart' as app_theme;

/// Appearance control powered by [animated_theme_switcher].
class AnimatedThemeSwitch extends StatelessWidget {
  const AnimatedThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final mode = context.watch<app_theme.ThemeProvider>().mode;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, color: scheme.accent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t.appearance,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ThemeSwitcher.withTheme(
            builder: (context, switcher, theme) {
              return _ThemeModeTrack(
                selected: mode,
                systemLabel: t.themeSystem,
                lightLabel: t.themeLight,
                darkLabel: t.themeDark,
                onSelect: (next) {
                  final platform = MediaQuery.platformBrightnessOf(context);
                  final nextTheme = _themeFor(next, platform);
                  final currentDark = theme.brightness == Brightness.dark;
                  final nextDark = nextTheme.brightness == Brightness.dark;

                  context.read<app_theme.ThemeProvider>().setMode(next);
                  if (currentDark == nextDark) return;

                  switcher.changeTheme(
                    theme: nextTheme,
                    isReversed: currentDark && !nextDark,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

ThemeData _themeFor(ThemeMode mode, Brightness platform) {
  final dark = mode == ThemeMode.dark ||
      (mode == ThemeMode.system && platform == Brightness.dark);
  return dark ? AppTheme.dark() : AppTheme.light();
}

class _ThemeModeTrack extends StatelessWidget {
  const _ThemeModeTrack({
    required this.selected,
    required this.onSelect,
    required this.systemLabel,
    required this.lightLabel,
    required this.darkLabel,
  });

  final ThemeMode selected;
  final ValueChanged<ThemeMode> onSelect;
  final String systemLabel;
  final String lightLabel;
  final String darkLabel;

  int get _index => switch (selected) {
        ThemeMode.system => 0,
        ThemeMode.light => 1,
        ThemeMode.dark => 2,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return LayoutBuilder(
      builder: (context, constraints) {
        final segment = constraints.maxWidth / 3;
        return Container(
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: dark
                ? scheme.surfaceContainerHighest.withValues(alpha: 0.55)
                : scheme.surfaceContainerHighest.withValues(alpha: 0.7),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                left: rtl ? null : segment * _index + 4,
                right: rtl ? segment * _index + 4 : null,
                top: 4,
                bottom: 4,
                width: segment - 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        scheme.primary.withValues(alpha: 0.95),
                        scheme.primary.withValues(alpha: 0.72),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  _Segment(
                    icon: Icons.brightness_auto_rounded,
                    label: systemLabel,
                    selected: selected == ThemeMode.system,
                    onTap: () => onSelect(ThemeMode.system),
                  ),
                  _Segment(
                    icon: Icons.light_mode_rounded,
                    label: lightLabel,
                    selected: selected == ThemeMode.light,
                    onTap: () => onSelect(ThemeMode.light),
                  ),
                  _Segment(
                    icon: Icons.dark_mode_rounded,
                    label: darkLabel,
                    selected: selected == ThemeMode.dark,
                    onTap: () => onSelect(ThemeMode.dark),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? scheme.onPrimary : scheme.onSurface,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? scheme.onPrimary : scheme.accent,
                ),
                const SizedBox(height: 2),
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
