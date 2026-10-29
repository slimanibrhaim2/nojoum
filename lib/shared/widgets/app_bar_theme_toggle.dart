import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart' as app_theme;

/// Compact light/dark toggle for app bars (no system mode).
class AppBarThemeToggle extends StatelessWidget {
  const AppBarThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mode = context.watch<app_theme.ThemeProvider>().mode;
    final platform = MediaQuery.platformBrightnessOf(context);
    final isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system && platform == Brightness.dark);

    return ThemeSwitcher.withTheme(
      builder: (context, switcher, theme) {
        return IconButton(
          tooltip: isDark ? 'Light' : 'Dark',
          onPressed: () {
            final nextMode = isDark ? ThemeMode.light : ThemeMode.dark;
            final nextTheme =
                nextMode == ThemeMode.dark ? AppTheme.dark() : AppTheme.light();

            context.read<app_theme.ThemeProvider>().setMode(nextMode);
            switcher.changeTheme(
              theme: nextTheme,
              isReversed: isDark && nextMode == ThemeMode.light,
            );
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: Tween(begin: 0.75, end: 1.0).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDark),
              color: scheme.accent,
            ),
          ),
        );
      },
    );
  }
}
