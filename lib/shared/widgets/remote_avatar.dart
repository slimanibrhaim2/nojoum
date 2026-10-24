import 'package:flutter/material.dart';

/// Circular photo that falls back to an icon when the URL is empty or 404.
class RemoteAvatar extends StatelessWidget {
  const RemoteAvatar({
    super.key,
    this.url,
    this.radius = 24,
    this.icon = Icons.auto_awesome,
  });

  final String? url;
  final double radius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = radius * 2;
    final fallback = ColoredBox(
      color: scheme.primaryContainer,
      child: Icon(icon, size: radius, color: scheme.onPrimaryContainer),
    );

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url == null || url!.isEmpty
            ? fallback
            : Image.network(
                url!,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) => fallback,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return ColoredBox(
                    color: scheme.primaryContainer,
                    child: const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
