import 'package:flutter/material.dart';
import 'package:nojoum/core/localization/l10n/app_localizations.dart';
import 'package:nojoum/shared/widgets/star_sky_background.dart';

class Forecaster extends StatelessWidget {
  const Forecaster({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return NightScaffold(title: t.navForecasters, body: Center(child: Text('best'),),);
  }
}
