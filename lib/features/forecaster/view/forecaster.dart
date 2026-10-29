import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../shared/widgets/star_sky_background.dart';
import '../viewmodel/forecaster_viewmodels.dart';
import 'widgets/forecaster_card.dart';

class Forecaster extends StatefulWidget {
  const Forecaster({super.key});

  @override
  State<Forecaster> createState() => _ForecasterState();
}

class _ForecasterState extends State<Forecaster> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ForecastersViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final vm = context.watch<ForecastersViewModel>();

    return NightScaffold(
      title: t.navForecasters,
      body: RefreshIndicator(
        color: scheme.primary,
        onRefresh: () => vm.load(force: true),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              t.exploreMessage,
              style: TextStyle(
                color: scheme.primary,
                letterSpacing: 1.2,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            if (vm.loading && vm.items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(
                  child: CircularProgressIndicator(color: scheme.primary),
                ),
              )
            else if (vm.error != null && vm.items.isEmpty)
              Text(vm.error!, style: TextStyle(color: scheme.error))
            else if (vm.items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Text(
                  t.comingSoonMessage,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              )
            else
              for (final profile in vm.items)
                ForecasterCard(profile: profile),
          ],
        ),
      ),
    );
  }
}
