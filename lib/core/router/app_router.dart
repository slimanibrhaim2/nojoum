import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nojoum/core/router/app_routes.dart';
import 'package:nojoum/core/router/route_guards.dart';
import 'package:nojoum/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../features/auth/view/login_screen.dart';
import '../../features/public/public_home_screen.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create(BuildContext context){
    final auth = context.read<AuthViewModel>();
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: auth,

      redirect: (context, state)=>RouteGuards.redirect(
        auth: auth,
        location: state.matchedLocation,
      ),
      routes: [
      GoRoute(
      path: AppRoutes.splash,
      builder: (_, __) => const _SplashScreen(),
    ),
    GoRoute(
    path: AppRoutes.login,
    builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
    path: AppRoutes.publicHome,
    builder: (_, __) => const PublicHomeScreen(),

    ),]
    );
  }
}
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}