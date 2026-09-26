import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/localization/l10n/locale_provider.dart';
import '../../../shared/widgets/star_sky_background.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final user = context.watch<AuthViewModel>().currentUser;
    final vm = context.watch<PredictionsViewModel>();
    final lang = context.watch<LocaleProvider>().locale.languageCode;
    _ensureLoaded(vm, lang);

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
                  onLike: () => vm.like(prediction.id),
                ),
          ],
        ),
      ),
    );
  }
}
