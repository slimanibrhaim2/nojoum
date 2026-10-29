import 'package:nojoum/core/router/app_routes.dart';
import 'package:nojoum/features/auth/viewmodel/auth_viewmodel.dart';

class RouteGuards {
  RouteGuards._();

  static const _guestAllowed = {
    AppRoutes.splash,
    AppRoutes.login,
    AppRoutes.publicHome,
    AppRoutes.settings,
    AppRoutes.forecasters,
  };

  static bool _isGuestAllowed(String location) {
    if (_guestAllowed.contains(location)) return true;
    if (location.startsWith('${AppRoutes.predictions}/')) return true;
    return false;
  }

  static String? redirect({
    required AuthViewModel auth,
    required String location,
  }) {
    if (auth.status == AuthStatus.unknown) {
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    }

    final isLoggedIn = auth.isLoggedIn;
    final isForecaster = auth.isForecaster;

    if (!isLoggedIn && location == AppRoutes.splash) {
      return AppRoutes.publicHome;
    }

    if (!isLoggedIn && !_isGuestAllowed(location)) {
      return AppRoutes.login;
    }

    if (isLoggedIn &&
        (location == AppRoutes.login || location == AppRoutes.splash)) {
      return isForecaster
          ? AppRoutes.forecasterDashboard
          : AppRoutes.publicHome;
    }

    if (location == AppRoutes.forecasterDashboard &&
        (!isLoggedIn || !isForecaster)) {
      return isLoggedIn ? AppRoutes.publicHome : AppRoutes.login;
    }

    return null;
  }
}
