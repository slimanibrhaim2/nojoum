import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/localization/l10n/locale_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/star_sky_background.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final auth = context.watch<AuthViewModel>();
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.currentUser;

    return NightScaffold(
      title: t.navSettings,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _SectionTitle(t.account),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (auth.isLoggedIn) ...[
                    Text(t.loggedInAs(user?.fullName ?? user?.email ?? '')),
                    if (user != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ],
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context.read<AuthViewModel>().logout(),
                      icon: const Icon(Icons.logout),
                      label: Text(t.logout),
                    ),
                  ] else ...[
                    Text(t.guestAccountHint),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.push(AppRoutes.login),
                      icon: const Icon(Icons.login),
                      label: Text(t.login),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SectionTitle(t.language),
          Card(
            child: ListTile(
              leading: Icon(Icons.language, color: scheme.accent),
              title: Text(t.language),
              subtitle: Text(localeProvider.isArabic ? 'العربية' : 'English'),
              trailing: TextButton(
                onPressed: localeProvider.toggle,
                child: Text(
                  localeProvider.isArabic ? t.switchToEnglish : t.switchToArabic,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SectionTitle(t.appearance),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.brightness_auto, color: scheme.accent),
                  title: Text(t.themeSystem),
                  selected: themeProvider.isSystem,
                  trailing: themeProvider.isSystem
                      ? Icon(Icons.check, color: scheme.primary)
                      : null,
                  onTap: themeProvider.setSystem,
                ),
                ListTile(
                  leading: Icon(Icons.light_mode, color: scheme.accent),
                  title: Text(t.themeLight),
                  selected: themeProvider.isLight,
                  trailing: themeProvider.isLight
                      ? Icon(Icons.check, color: scheme.primary)
                      : null,
                  onTap: themeProvider.setLight,
                ),
                ListTile(
                  leading: Icon(Icons.dark_mode, color: scheme.accent),
                  title: Text(t.themeDark),
                  selected: themeProvider.isDark,
                  trailing: themeProvider.isDark
                      ? Icon(Icons.check, color: scheme.primary)
                      : null,
                  onTap: themeProvider.setDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8, start: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
