import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/config/app_config.dart';
import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/localization/l10n/locale_provider.dart';
import '../../../shared/widgets/nojoum_toast.dart';
import '../../../shared/widgets/star_sky_background.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../predictions/domain/prediction.dart';
import '../../predictions/view/widgets/prediction_card.dart';
import '../../predictions/viewmodel/predictions_viewmodel.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({super.key});

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  String? _loadedLang;

  void _ensureLoaded(PredictionsViewModel vm, String lang) {
    if (_loadedLang == lang) return;
    _loadedLang = lang;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      vm.load(languageCode: lang);
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

  Future<void> _sharePrediction(
    PredictionsViewModel vm,
    Prediction prediction,
  ) async {
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

      // Count when the user picked an app, or when the OS cannot report
      // the outcome (still opened the system share sheet).
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
    final vm = context.watch<PredictionsViewModel>();
    final lang = context.watch<LocaleProvider>().locale.languageCode;
    _ensureLoaded(vm, lang);
    final signedIn = user != null;

    return NightScaffold(
      title: t.appName,
      body: RefreshIndicator(
        color: scheme.primary,
        onRefresh: () => vm.load(languageCode: lang, force: true),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (user != null) ...[
              Text(
                '${t.welcomeBack}, ${user.fullName}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              t.homeEmptyTitle,
              style: TextStyle(
                color: scheme.primary,
                letterSpacing: 1.2,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            if (vm.loading && vm.items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(
                  child: CircularProgressIndicator(color: scheme.primary),
                ),
              )
            else if (vm.error != null)
              Text(vm.error!, style: TextStyle(color: scheme.error))
            else
              for (final prediction in vm.items)
                PredictionCard(
                  prediction: prediction,
                  busy: vm.isBusy(prediction.id),
                  onLike: () => _engage(
                    signedIn: signedIn,
                    action: () => vm.like(prediction.id),
                  ),
                  onDislike: () => _engage(
                    signedIn: signedIn,
                    action: () => vm.dislike(prediction.id),
                  ),
                  onShare: () => _sharePrediction(vm, prediction),
                ),
          ],
        ),
      ),
    );
  }
}
