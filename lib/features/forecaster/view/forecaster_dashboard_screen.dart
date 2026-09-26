import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/localization/l10n/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/star_sky_background.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/forecaster_viewmodels.dart';

class ForecasterDashboardScreen extends StatefulWidget {
  const ForecasterDashboardScreen({super.key});

  @override
  State<ForecasterDashboardScreen> createState() =>
      _ForecasterDashboardScreenState();
}

class _ForecasterDashboardScreenState extends State<ForecasterDashboardScreen> {
  String? _loadedKey;

  void _ensureLoaded(DashboardViewModel vm, String? userId, String lang) {
    if (userId == null) return;
    final key = '$userId:$lang';
    if (_loadedKey == key && vm.dashboard != null) return;
    _loadedKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      vm.load(forecasterId: userId, languageCode: lang);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final user = context.watch<AuthViewModel>().currentUser;
    final vm = context.watch<DashboardViewModel>();
    final lang = context.watch<LocaleProvider>().locale.languageCode;
    _ensureLoaded(vm, user?.id, lang);

    return NightScaffold(
      title: t.dashboard,
      body: RefreshIndicator(
        color: scheme.primary,
        onRefresh: () async {
          if (user == null) return;
          await vm.load(
            forecasterId: user.id,
            languageCode: lang,
            force: true,
          );
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (vm.loading && vm.dashboard == null)
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator(color: scheme.primary)),
              )
            else if (vm.dashboard != null) ...[
              Text(
                vm.dashboard!.fullName ?? user?.fullName ?? '',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                vm.dashboard!.email ?? '',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: t.totalPredictions,
                      value: '${vm.dashboard!.totalPredictions}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      label: t.reviews,
                      value: '${vm.dashboard!.reviewCount}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      label: t.rating,
                      value: '${vm.dashboard!.averageRate}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                t.noBookings,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: scheme.panel,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: scheme.accent,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurface, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
