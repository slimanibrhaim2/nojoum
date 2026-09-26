import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/mock/fake_ids.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/star_sky_background.dart';
import '../../forecaster/domain/forecaster.dart';
import '../../forecaster/viewmodel/forecaster_viewmodels.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ExploreViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final vm = context.watch<ExploreViewModel>();

    return NightScaffold(
      title: t.navExplore,
      body: RefreshIndicator(
        color: scheme.primary,
        onRefresh: () => vm.load(force: true),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              t.exploreMessage,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (vm.loading && vm.items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator(color: scheme.primary)),
              )
            else
              for (final profile in vm.items) _ForecasterCard(profile: profile),
          ],
        ),
      ),
    );
  }
}

class _ForecasterCard extends StatelessWidget {
  const _ForecasterCard({required this.profile});

  final ForecasterPublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final types = <String>[
      if (profile.hasType(ForecastingType.palm)) t.typePalm,
      if (profile.hasType(ForecastingType.coffeeCup)) t.typeCoffee,
      if (profile.hasType(ForecastingType.astrology)) t.typeAstrology,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: scheme.panel,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: scheme.primaryContainer,
                child: Icon(Icons.auto_awesome, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${profile.averageRate.toStringAsFixed(1)} · ${profile.reviewCount} ${t.reviews}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Text(
                profile.money.label,
                style: TextStyle(
                  color: scheme.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in types)
                Chip(
                  label: Text(type),
                  backgroundColor: scheme.secondaryContainer,
                  labelStyle: TextStyle(color: scheme.onSecondaryContainer),
                  side: BorderSide.none,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            t.sessionMinutes(profile.availabilitySettings.sessionDurationInMinutes),
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
