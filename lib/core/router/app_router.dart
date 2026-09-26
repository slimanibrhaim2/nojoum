import 'package:go_router/go_router.dart';
import 'package:nojoum/core/router/app_routes.dart';
import 'package:nojoum/core/router/route_guards.dart';
import 'package:nojoum/features/auth/viewmodel/auth_viewmodel.dart';

import '../../features/auth/view/login_screen.dart';
import '../../features/explore/view/explore_screen.dart';
import '../../features/forecaster/view/forecaster_dashboard_screen.dart';
import '../../features/public/view/public_home_screen.dart';
import '../../features/settings/view/settings_screen.dart';
import '../../features/shell/view/main_shell.dart';
import '../../features/splash/view/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create(AuthViewModel auth) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: auth,
      redirect: (context, state) => RouteGuards.redirect(
        auth: auth,
        location: state.matchedLocation,
      ),
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.publicHome,
              builder: (context, state) => const PublicHomeScreen(),
            ),
            GoRoute(
              path: AppRoutes.forecasterDashboard,
              builder: (context, state) => const ForecasterDashboardScreen(),
            ),
            GoRoute(
              path: AppRoutes.explore,
              builder: (context, state) => const ExploreScreen(),
            ),
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    );
  }
}
