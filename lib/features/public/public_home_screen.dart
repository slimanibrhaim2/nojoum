import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/localization/l10n/app_localizations.dart';
import '../../core/localization/l10n/locale_provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/theme_provider.dart';
import '../auth/viewmodel/auth_viewmodel.dart';


class PublicHomeScreen extends StatelessWidget {
  const PublicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthViewModel>();


    return Scaffold(
      appBar: AppBar(
        title: Text(t.appName),
        actions: [
          TextButton.icon(
            onPressed: localeProvider.toggle,
            icon: Icon( Icons.language),
            label: Text(localeProvider.isArabic ? t.switchToEnglish : t.switchToArabic,),
          ),
          IconButton(
            onPressed: themeProvider.cycle,
            icon: Icon(
              themeProvider.isDark
                  ? Icons.dark_mode
                  : themeProvider.isLight
                  ? Icons.light_mode
                  : Icons.brightness_auto,
            ),
            tooltip: themeProvider.mode.name,
          ),
          if (!auth.isLoggedIn)
            IconButton(
              tooltip: t.login,
              onPressed: () => context.go(AppRoutes.login),
              icon: const Icon(Icons.login),
            )
          else
            IconButton(
              tooltip: t.logout,
              onPressed: () => context.read<AuthViewModel>().logout(),
              icon: const Icon(Icons.logout),
            ),

        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(t.welcomeBack,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(t.signInToContinue,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

