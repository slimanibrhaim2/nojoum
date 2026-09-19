import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nojoum/core/localization/l10n/locale_provider.dart';
import 'package:nojoum/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/localization/l10n/app_localizations.dart';


void main() {
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_)=>LocaleProvider()),
          ChangeNotifierProvider(create: (_)=>ThemeProvider()),
        ],
        child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localProvider =context.watch<LocaleProvider>();
    final themeProvider= context.watch<ThemeProvider>();


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appName,

      // ── Our theme ──
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.mode,

      // ── Our localization ──
      locale: localProvider.locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();


    return Scaffold(
      appBar: AppBar(
        title: Text(t.appName),
        actions: [
          TextButton.icon(
              onPressed: localeProvider.toggle,
              icon: Icon( Icons.language),
              label: Text(localeProvider.isArabic ? t.switchToEnglish : t.switchToArabic,),
          ),
          IconButton(
            onPressed: themeProvider.cycle,
            icon: Icon(
              themeProvider.isDark
                  ? Icons.dark_mode
                  : themeProvider.isLight
                  ? Icons.light_mode
                  : Icons.brightness_auto,
            ),
            tooltip: themeProvider.mode.name,
          ),

        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(t.welcomeBack,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(t.signInToContinue,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}