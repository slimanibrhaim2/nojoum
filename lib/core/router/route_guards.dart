import 'package:nojoum/core/router/app_routes.dart';
import 'package:nojoum/features/auth/viewmodel/auth_viewmodel.dart';

class RouteGuards {
  RouteGuards._();

  static String? redirect({
    required AuthViewModel auth,
    required String location,
  }) {
    if (auth.status == AuthStatus.unknown) {
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    }

    final isLoggedIn = auth.isLoggedIn;
    final isForecaster = auth.isForecaster;
    final isGuestAllowed = location == AppRoutes.login ||
        location == AppRoutes.splash ||
        location == AppRoutes.publicHome;

    if (!isLoggedIn && location == AppRoutes.splash) {
      return AppRoutes.publicHome;
    }

    if (!isLoggedIn && !isGuestAllowed) {
      return AppRoutes.login;
    }

    if (isLoggedIn &&
        (location == AppRoutes.login || location == AppRoutes.splash)) {
      return isForecaster
          ? AppRoutes.forecasterDashboard
          : AppRoutes.publicHome;
    }

    if (isLoggedIn &&
        !isForecaster &&
        location == AppRoutes.forecasterDashboard) {
      return AppRoutes.publicHome;
    }

    return null;
  }
}
