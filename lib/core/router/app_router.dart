import 'package:go_router/go_router.dart';
import 'package:nojoum/core/router/app_routes.dart';
import 'package:nojoum/core/router/route_guards.dart';
import 'package:nojoum/features/auth/viewmodel/auth_viewmodel.dart';

import '../../features/auth/view/login_screen.dart';
import '../../features/forecaster/view/forecaster_dashboard_screen.dart';
import '../../features/public/public_home_screen.dart';
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
        GoRoute(
          path: AppRoutes.publicHome,
          builder: (context, state) => const PublicHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.forecasterDashboard,
          builder: (context, state) => const ForecasterDashboardScreen(),
        ),
      ],
    );
  }
}
