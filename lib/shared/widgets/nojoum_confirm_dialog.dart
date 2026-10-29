import 'package:flutter/material.dart';

enum NojoumConfirmKind { normal, danger }

class NojoumConfirmDialog {
  NojoumConfirmDialog._();

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String? cancelLabel,
    NojoumConfirmKind kind = NojoumConfirmKind.normal,
    IconData? icon,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _NojoumConfirmCard(
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel ??
              MaterialLocalizations.of(context).cancelButtonLabel,
          kind: kind,
          icon: icon,
        );
      },
      transitionBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
    return result ?? false;
  }
}

class _NojoumConfirmCard extends StatelessWidget {
  const _NojoumConfirmCard({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.kind,
    required this.icon,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final NojoumConfirmKind kind;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = kind == NojoumConfirmKind.danger
        ? scheme.error
        : scheme.primary;
    final resolvedIcon = icon ??
        (kind == NojoumConfirmKind.danger
            ? Icons.delete_outline_rounded
            : Icons.help_outline_rounded);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: dark
                      ? [
                          const Color(0xFF2E2442),
                          const Color(0xFF3A2D52),
                          const Color(0xFF46364A),
                        ]
                      : [
                          const Color(0xFFFFFBF4),
                          const Color(0xFFF3E8FF),
                          const Color(0xFFFFF1D6),
                        ],
                ),
                border: Border.all(
                  color: accent.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: dark ? 0.28 : 0.16),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            accent.withValues(alpha: 0.4),
                            accent.withValues(alpha: 0.1),
                          ],
                        ),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Icon(resolvedIcon, color: accent, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurface.withValues(alpha: 0.78),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(cancelLabel),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              backgroundColor: accent,
                              foregroundColor: kind == NojoumConfirmKind.danger
                                  ? scheme.onError
                                  : scheme.onPrimary,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(confirmLabel),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
