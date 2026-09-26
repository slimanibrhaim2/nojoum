import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

class _Tab {
  const _Tab({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  List<_Tab> _tabs(AppLocalizations t, bool isForecaster) {
    return [
      _Tab(
        path: AppRoutes.publicHome,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: t.navHome,
      ),
      if (isForecaster)
        _Tab(
          path: AppRoutes.forecasterDashboard,
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          label: t.dashboard,
        ),
      _Tab(
        path: AppRoutes.explore,
        icon: Icons.explore_outlined,
        selectedIcon: Icons.explore,
        label: t.navExplore,
      ),
      _Tab(
        path: AppRoutes.settings,
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: t.navSettings,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isForecaster = context.watch<AuthViewModel>().isForecaster;
    final location = GoRouterState.of(context).uri.path;
    final tabs = _tabs(t, isForecaster);

    var selectedIndex = tabs.indexWhere((tab) => tab.path == location);
    if (selectedIndex < 0) selectedIndex = 0;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: child,
      bottomNavigationBar: Material(
        color: Colors.transparent,
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => context.go(tabs[index].path),
          destinations: [
            for (final tab in tabs)
              NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.selectedIcon),
                label: tab.label,
              ),
          ],
        ),
      ),
    );
  }
}
