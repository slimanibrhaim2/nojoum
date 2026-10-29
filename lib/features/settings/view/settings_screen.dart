import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/localization/l10n/locale_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/animated_theme_switch.dart';
import '../../../shared/widgets/star_sky_background.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../forecaster/viewmodel/forecaster_viewmodels.dart';
import 'widgets/forecaster_availability_editor.dart';
import 'widgets/forecaster_profile_editor.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _askedForProfile = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthViewModel>();
    final me = context.read<ForecasterMeViewModel>();
    if (auth.isForecaster && !_askedForProfile) {
      _askedForProfile = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) me.load();
      });
    }
    if (!auth.isForecaster && _askedForProfile) {
      _askedForProfile = false;
      me.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final auth = context.watch<AuthViewModel>();
    final localeProvider = context.watch<LocaleProvider>();
    final user = auth.currentUser;
    final me = context.watch<ForecasterMeViewModel>();

    return NightScaffold(
      title: t.navSettings,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (auth.isForecaster) ...[
            if (me.loading && me.profile == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (me.error != null && me.profile == null)
              Card(
                child: ListTile(
                  leading: Icon(Icons.error_outline, color: scheme.error),
                  title: Text(me.error!),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => me.load(force: true),
                  ),
                ),
              )
            else if (me.profile != null) ...[
              ForecasterProfileEditor(
                profile: me.profile!,
                viewModel: me,
              ),
              const SizedBox(height: 20),
              _SectionTitle(t.availability),
              if (me.availability != null)
                ForecasterAvailabilityEditor(
                  availability: me.availability!,
                  viewModel: me,
                )
              else if (me.availabilityError != null)
                Card(
                  child: ListTile(
                    leading: Icon(Icons.error_outline, color: scheme.error),
                    title: Text(me.availabilityError!),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => me.load(force: true),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 24),
          ],
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
          const Card(
            child: AnimatedThemeSwitch(),
          ),
          const SizedBox(height: 28),
          _SectionTitle(t.account),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (auth.isLoggedIn) ...[
                    Text(
                      t.loggedInAs(user?.fullName ?? user?.email ?? ''),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (user != null && user.email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ],
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        context.read<ForecasterMeViewModel>().clear();
                        context.read<AuthViewModel>().logout();
                      },
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
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
