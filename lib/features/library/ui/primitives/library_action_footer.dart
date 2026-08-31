import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A standard action footer bar for forms and dialogs in Library UI.
///
/// Standardizes:
/// - Button alignment (end-aligned or space-between when leading widget present)
/// - Button height and padding
/// - Button spacing
/// - Primary / secondary ordering (Cancel first, Save/Submit last)
/// - Loading state
class LibraryActionFooter extends StatelessWidget {
  const LibraryActionFooter({
    super.key,
    this.onCancel,
    this.onSubmit,
    this.cancelLabel = 'Cancel',
    this.submitLabel = 'Save',
    this.submitIcon,
    this.isLoading = false,
    this.leading,
    this.extraActions = const [],
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.accent,
    this.showTopDivider = true,
  });

  final VoidCallback? onCancel;
  final VoidCallback? onSubmit;
  final String cancelLabel;
  final String submitLabel;
  final IconData? submitIcon;
  final bool isLoading;
  final Widget? leading;
  final List<Widget> extraActions;
  final EdgeInsetsGeometry padding;
  final Color? accent;
  final bool showTopDivider;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final effectiveAccent = accent ?? palette.accent;

    return Container(
      decoration: BoxDecoration(
        color: palette.panel,
        border: showTopDivider
            ? Border(top: BorderSide(color: palette.divider))
            : null,
      ),
      padding: padding,
      child: Row(
        children: [
          if (leading != null) ...[
            Expanded(child: leading!),
            const SizedBox(width: 12),
          ] else
            const Spacer(),
          ...extraActions.map((action) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: action,
              )),
          if (onCancel != null) ...[
            OutlinedButton(
              onPressed: isLoading ? null : onCancel,
              child: Text(cancelLabel),
            ),
            const SizedBox(width: 8),
          ],
          if (onSubmit != null)
            FilledButton.icon(
              onPressed: isLoading ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: effectiveAccent,
                foregroundColor: Colors.white,
              ),
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : (submitIcon != null
                      ? Icon(submitIcon, size: 16)
                      : const SizedBox.shrink()),
              label: Text(submitLabel),
            ),
        ],
      ),
    );
  }
}
