import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:nojoum/core/localization/l10n/locale_provider.dart';
import 'package:nojoum/core/router/app_router.dart';
import 'package:nojoum/core/theme/theme_provider.dart' as app_theme;
import 'package:nojoum/core/config/app_config.dart';
import 'package:nojoum/core/network/api_client.dart';
import 'package:nojoum/core/network/token_storage.dart';
import 'package:nojoum/features/auth/data/auth_repository.dart';
import 'package:nojoum/features/auth/data/auth_repository_api.dart';
import 'package:nojoum/features/auth/data/auth_repository_mock.dart';
import 'package:nojoum/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:nojoum/features/forecaster/data/forecaster_repository.dart';
import 'package:nojoum/features/forecaster/data/forecaster_repository_api.dart';
import 'package:nojoum/features/forecaster/data/forecaster_repository_mock.dart';
import 'package:nojoum/features/forecaster/viewmodel/forecaster_viewmodels.dart';
import 'package:nojoum/features/predictions/data/prediction_repository.dart';
import 'package:nojoum/features/predictions/data/prediction_repository_api.dart';
import 'package:nojoum/features/predictions/data/prediction_repository_mock.dart';
import 'package:nojoum/features/predictions/viewmodel/predictions_viewmodel.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/localization/l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage);

  final AuthRepository authRepository = AppConfig.useMockApi
      ? AuthRepositoryMock()
      : AuthRepositoryApi(apiClient, tokenStorage);
  final PredictionRepository predictionRepository = AppConfig.useMockApi
      ? PredictionRepositoryMock()
      : PredictionRepositoryApi(apiClient);
  final ForecasterRepository forecasterRepository = AppConfig.useMockApi
      ? ForecasterRepositoryMock()
      : ForecasterRepositoryApi(apiClient);

  final platformDark =
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => app_theme.ThemeProvider()),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<PredictionRepository>.value(value: predictionRepository),
        Provider<ForecasterRepository>.value(value: forecasterRepository),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            authRepository,
            tokens: AppConfig.useMockApi ? null : tokenStorage,
          )..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => PredictionsViewModel(predictionRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ForecastersViewModel(forecasterRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ForecasterMeViewModel(forecasterRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(
            forecasterRepository,
            predictionRepository,
          ),
        ),
      ],
      child: MyApp(initTheme: platformDark ? AppTheme.dark() : AppTheme.light()),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initTheme});

  final ThemeData initTheme;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.create(context.read<AuthViewModel>());
  }

  @override
  Widget build(BuildContext context) {
    final localProvider = context.watch<LocaleProvider>();

    return ThemeProvider(
      initTheme: widget.initTheme,
      builder: (context, theme) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appName,
          theme: theme,
          locale: localProvider.locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: _router,
          builder: (context, child) {
            return ThemeSwitchingArea(
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
