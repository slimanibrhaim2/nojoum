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
import '../../../shared/widgets/remote_avatar.dart';
import '../../../shared/widgets/star_sky_background.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../forecaster/data/forecaster_repository.dart';
import '../../forecaster/domain/forecaster.dart';
import '../data/prediction_repository.dart';
import '../domain/prediction.dart';
import '../viewmodel/prediction_detail_viewmodel.dart';
import 'widgets/prediction_card.dart';

class PredictionDetailScreen extends StatelessWidget {
  const PredictionDetailScreen({super.key, required this.predictionId});

  final String predictionId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PredictionDetailViewModel(
        context.read<PredictionRepository>(),
        context.read<ForecasterRepository>(),
      ),
      child: _PredictionDetailBody(predictionId: predictionId),
    );
  }
}

class _PredictionDetailBody extends StatefulWidget {
  const _PredictionDetailBody({required this.predictionId});

  final String predictionId;

  @override
  State<_PredictionDetailBody> createState() => _PredictionDetailBodyState();
}

class _PredictionDetailBodyState extends State<_PredictionDetailBody> {
  String? _loadedKey;

  void _ensureLoaded(PredictionDetailViewModel vm, String lang) {
    final key = '${widget.predictionId}:$lang';
    if (_loadedKey == key) return;
    _loadedKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      vm.load(id: widget.predictionId, languageCode: lang);
    });
  }

  Future<void> _engage({
    required Future<void> Function() action,
    required bool signedIn,
  }) async {
    final t = AppLocalizations.of(context);
    if (!signedIn) {
      NojoumToast.show(
        context,
        message: t.signInToContinue,
        kind: NojoumToastKind.info,
      );
      return;
    }
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

  Future<void> _share(PredictionDetailViewModel vm, Prediction prediction) async {
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
      await vm.recordShare();
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
    final lang = context.watch<LocaleProvider>().locale.languageCode;
    final signedIn = context.watch<AuthViewModel>().currentUser != null;
    final vm = context.watch<PredictionDetailViewModel>();
    _ensureLoaded(vm, lang);

    return NightScaffold(
      title: t.predictionDetails,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.publicHome);
          }
        },
      ),
      body: RefreshIndicator(
        color: scheme.primary,
        onRefresh: () => vm.load(
          id: widget.predictionId,
          languageCode: lang,
          force: true,
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            if (vm.loading && vm.prediction == null)
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Center(
                  child: CircularProgressIndicator(color: scheme.primary),
                ),
              )
            else if (vm.error != null && vm.prediction == null)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Text(vm.error!, style: TextStyle(color: scheme.error)),
              )
            else if (vm.prediction != null) ...[
              PredictionCard(
                prediction: vm.prediction!,
                busy: vm.busy,
                onLike: () => _engage(signedIn: signedIn, action: vm.like),
                onDislike: () =>
                    _engage(signedIn: signedIn, action: vm.dislike),
                onShare: () => _share(vm, vm.prediction!),
              ),
              const SizedBox(height: 8),
              Text(
                t.aboutForecaster,
                style: TextStyle(
                  color: scheme.primary,
                  letterSpacing: 1.1,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _ForecasterPreview(
                prediction: vm.prediction!,
                forecaster: vm.forecaster,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ForecasterPreview extends StatelessWidget {
  const _ForecasterPreview({
    required this.prediction,
    required this.forecaster,
  });

  final Prediction prediction;
  final ForecasterPublicProfile? forecaster;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final name = (forecaster?.name.trim().isNotEmpty ?? false)
        ? forecaster!.name
        : (prediction.forecasterName.trim().isEmpty
            ? '—'
            : prediction.forecasterName);
    final imageUrl = AppConfig.mediaUrl(
      forecaster?.imagePath ?? prediction.forecasterImageUrl,
    );
    final rating = forecaster?.averageRate ?? prediction.forecasterAverageRate;
    final reviews = forecaster?.reviewCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: scheme.panel,
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RemoteAvatar(url: imageUrl, radius: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (rating > 0 || reviews != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (rating > 0) rating.toStringAsFixed(1),
                          if (reviews != null) '$reviews ${t.reviews}',
                        ].join(' · '),
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (forecaster == null) ...[
            const SizedBox(height: 12),
            Text(
              t.forecasterUnavailable,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ] else if (forecaster!.money.amount > 0) ...[
            const SizedBox(height: 12),
            Text(
              forecaster!.money.label,
              style: TextStyle(
                color: scheme.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
