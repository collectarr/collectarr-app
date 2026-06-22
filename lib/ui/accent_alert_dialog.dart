import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';

/// Alert dialog with unified accent strip header.
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
    this.accent,
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
  final Color? accent;
  final VoidCallback? headerOnClose;

  static const _defaultRadius = 0.0;

  @override
  Widget build(BuildContext context) {
    final resolvedAccent = accent ?? LibraryAccentScope.accentOf(context);
    final titleWidget = _buildTitle(context, resolvedAccent);
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

  Widget? _buildTitle(BuildContext context, Color resolvedAccent) {
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
        accent: resolvedAccent,
        onClose: headerOnClose,
      );
    }
    return Container(
      decoration: BoxDecoration(color: resolvedAccent),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
        child: IconTheme(
          data: const IconThemeData(color: Colors.white),
          child: baseTitle,
        ),
      ),
    );
  }
}
