import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/config/app_config.dart';
import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/localization/l10n/locale_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/nojoum_toast.dart';
import '../../../shared/widgets/star_sky_background.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../predictions/domain/prediction.dart';
import '../../predictions/view/widgets/prediction_card.dart';
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

  Future<void> _engage(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      NojoumToast.show(
        context,
        message: e.toString(),
        kind: NojoumToastKind.error,
      );
    }
  }

  Future<void> _share(DashboardViewModel vm, Prediction prediction) async {
    final box = context.findRenderObject() as RenderBox?;
    final locale = Localizations.localeOf(context);
    final name = prediction.forecasterName.trim().isEmpty
        ? 'Nojoum'
        : prediction.forecasterName.trim();
    final date = DateFormat.yMMMd(locale.toString()).format(prediction.date);
    final zodiac = prediction.zodiacSign.display(locale.languageCode);
    final link = AppConfig.predictionShareUrl(prediction.id);
    final buffer = StringBuffer()
      ..writeln(prediction.summary)
      ..writeln()
      ..writeln(prediction.details ?? '')
      ..writeln()
      ..writeln(zodiac)
      ..writeln(date)
      ..writeln('— $name')
      ..writeln()
      ..write(link);

    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          text: buffer.toString().trim(),
          subject: prediction.summary,
          title: 'Nojoum',
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
      if (result.status == ShareResultStatus.dismissed) return;
      await vm.recordShare(prediction.id);
    } catch (e) {
      if (!mounted) return;
      NojoumToast.show(
        context,
        message: e.toString(),
        kind: NojoumToastKind.error,
      );
    }
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
                child: Center(
                  child: CircularProgressIndicator(color: scheme.primary),
                ),
              )
            else if (vm.error != null && vm.dashboard == null)
              Text(vm.error!, style: TextStyle(color: scheme.error))
            else if (vm.dashboard != null) ...[
              Text(
                vm.dashboard!.fullName ?? user?.fullName ?? '',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if ((vm.dashboard!.email ?? '').isNotEmpty)
                Text(
                  vm.dashboard!.email!,
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
              const SizedBox(height: 24),
              Text(
                t.myPredictions,
                style: TextStyle(
                  color: scheme.primary,
                  letterSpacing: 1.2,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (vm.loading && vm.myPredictions.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Center(
                    child: CircularProgressIndicator(color: scheme.primary),
                  ),
                )
              else if (vm.myPredictions.isEmpty)
                Text(
                  t.noMyPredictions,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                )
              else
                for (final prediction in vm.myPredictions)
                  PredictionCard(
                    prediction: prediction,
                    busy: vm.isBusy(prediction.id),
                    onOpen: () => context.push(
                      AppRoutes.prediction(prediction.id),
                    ),
                    onLike: () => _engage(() => vm.like(prediction.id)),
                    onDislike: () => _engage(() => vm.dislike(prediction.id)),
                    onShare: () => _share(vm, prediction),
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
