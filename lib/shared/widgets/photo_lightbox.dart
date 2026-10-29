import 'dart:io';

import 'package:flutter/material.dart';

class PhotoLightbox {
  PhotoLightbox._();

  static Future<void> open(
    BuildContext context, {
    String? networkUrl,
    String? filePath,
    String heroTag = 'profile-photo',
  }) {
    final hasFile = filePath != null && filePath.isNotEmpty;
    final hasNetwork = networkUrl != null && networkUrl.isNotEmpty;
    if (!hasFile && !hasNetwork) return Future.value();

    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.86),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _PhotoLightboxPage(
          networkUrl: hasNetwork ? networkUrl : null,
          filePath: hasFile ? filePath : null,
          heroTag: heroTag,
        );
      },
      transitionBuilder: (context, animation, secondary, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }
}

class _PhotoLightboxPage extends StatelessWidget {
  const _PhotoLightboxPage({
    required this.networkUrl,
    required this.filePath,
    required this.heroTag,
  });

  final String? networkUrl;
  final String? filePath;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (filePath != null) {
      image = Image.file(File(filePath!), fit: BoxFit.contain);
    } else {
      image = Image.network(
        networkUrl!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.auto_awesome,
            size: 88,
            color: Colors.white.withValues(alpha: 0.8),
          );
        },
      );
    }

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: heroTag,
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: image,
                ),
              ),
            ),
            PositionedDirectional(
              top: 8,
              end: 8,
              child: Material(
                color: Colors.white.withValues(alpha: 0.12),
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
