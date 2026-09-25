import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:flutter/material.dart';

/// Alert dialog with a header using the application's main accent.
class AccentAlertDialog extends StatelessWidget {
  const AccentAlertDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.icon,
    this.iconPadding,
    this.iconColor,
    this.titlePadding,
    this.contentPadding,
    this.actionsPadding,
    this.buttonPadding,
    this.backgroundColor,
    this.surfaceTintColor,
    this.insetPadding,
    this.clipBehavior,
    this.shape,
    this.alignment,
    this.semanticLabel,
    this.scrollable = false,
    this.headerOnClose,
  });

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final Widget? icon;
  final EdgeInsets? iconPadding;
  final Color? iconColor;
  final EdgeInsets? titlePadding;
  final EdgeInsets? contentPadding;
  final EdgeInsets? actionsPadding;
  final EdgeInsets? buttonPadding;
  final Color? backgroundColor;
  final Color? surfaceTintColor;
  final EdgeInsets? insetPadding;
  final Clip? clipBehavior;
  final ShapeBorder? shape;
  final AlignmentGeometry? alignment;
  final String? semanticLabel;
  final bool scrollable;
  final VoidCallback? headerOnClose;

  static const _defaultRadius = 0.0;

  @override
  Widget build(BuildContext context) {
    final titleWidget = _buildTitle(context);
    final hasAccentHeader = titleWidget is AccentDialogHeader;

    return AlertDialog(
      icon: icon,
      iconPadding: iconPadding,
      iconColor: iconColor,
      title: titleWidget,
      content: content,
      actions: actions,
      titlePadding: hasAccentHeader ? EdgeInsets.zero : titlePadding,
      contentPadding: contentPadding,
      actionsPadding: actionsPadding,
      buttonPadding: buttonPadding,
      backgroundColor: backgroundColor,
      surfaceTintColor: surfaceTintColor,
      insetPadding: insetPadding,
      clipBehavior: clipBehavior ?? Clip.antiAlias,
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_defaultRadius),
          ),
      alignment: alignment,
      semanticLabel: semanticLabel,
      scrollable: scrollable,
    );
  }

  Widget? _buildTitle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedAccent = colorScheme.primary;
    final accentForeground = colorScheme.onPrimary;
    final baseTitle = title;
    if (baseTitle == null) {
      return null;
    }
    if (baseTitle is AccentDialogHeader) {
      return baseTitle;
    }
    if (baseTitle is Text && (baseTitle.data?.trim().isNotEmpty ?? false)) {
      return AccentDialogHeader(
        title: baseTitle.data!,
        onClose: headerOnClose,
      );
    }
    return Container(
      decoration: BoxDecoration(color: resolvedAccent),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: DefaultTextStyle(
        style: TextStyle(
          color: accentForeground,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
        child: IconTheme(
          data: IconThemeData(color: accentForeground),
          child: baseTitle,
        ),
      ),
    );
  }
}
