import 'package:collectarr_app/ui/library_square_close_button.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryDialogScaffold extends StatelessWidget {
  const LibraryDialogScaffold({
    super.key,
    required this.title,
    required this.child,
    this.footer,
    this.onClose,
    this.maxWidth = 420,
    this.maxHeight = 560,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget title;
  final Widget child;
  final Widget? footer;
  final VoidCallback? onClose;
  final double maxWidth;
  final double maxHeight;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Dialog(
      backgroundColor: palette.panel,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  Expanded(child: title),
                  if (onClose != null)
                    LibrarySquareCloseButton(onPressed: onClose!),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }
}
