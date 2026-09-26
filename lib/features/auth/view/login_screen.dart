import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/widgets/star_sky_background.dart';
import '../viewmodel/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'user@test.com');
  final _passwordCtrl = TextEditingController(text: '123456');

  static const _forecasterDemoEmail = 'fore@test.com';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();
    final ok = await vm.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (!ok || !mounted) return;

    if (vm.isForecaster) {
      context.go(AppRoutes.forecasterDashboard);
    } else {
      context.go(AppRoutes.publicHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final vm = context.watch<AuthViewModel>();
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return NightScaffold(
      title: t.login,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.publicHome);
          }
        },
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.auto_awesome, size: 48, color: scheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    t.appName,
                    style: text.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.signInToContinue,
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: t.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? t.invalidEmail
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: t.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: (v) => (v == null || v.length < 3)
                        ? t.passwordTooShort
                        : null,
                  ),
                  if (vm.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      vm.error == 'invalidCredentials'
                          ? t.invalidCredentials
                          : vm.error!,
                      style: TextStyle(color: scheme.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: vm.busy ? null : _submit,
                    child: vm.busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(t.login),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.forecasterLoginTip(_forecasterDemoEmail),
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
