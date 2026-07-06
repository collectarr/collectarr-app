import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/ui/library_square_close_button.dart';
import 'package:flutter/material.dart';

class LibraryPanelHeader extends StatelessWidget {
  const LibraryPanelHeader({
    super.key,
    this.child,
    this.title,
    this.subtitle,
    this.count,
    this.primaryAction,
    this.menuActions = const [],
    this.leading,
    this.trailing,
    this.onClose,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding,
    this.minHeight,
    this.density = LibraryDensity.comfortable,
  }) : assert(child != null || title != null);

  const LibraryPanelHeader.bar({
    super.key,
    required this.title,
    this.subtitle,
    this.count,
    this.primaryAction,
    this.menuActions = const [],
    this.leading,
    this.trailing,
    this.onClose,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding,
    this.minHeight,
    this.density = LibraryDensity.comfortable,
  }) : child = null;

  final Widget? child;
  final String? title;
  final String? subtitle;
  final int? count;
  final Widget? primaryAction;
  final List<Widget> menuActions;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onClose;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final EdgeInsets? padding;
  final double? minHeight;
  final LibraryDensity density;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.primary;
    final fg = foregroundColor ?? Colors.white;
    final resolvedPadding = padding ??
        EdgeInsets.symmetric(
          horizontal: kLibraryPanelHorizontalPadding,
          vertical: density == LibraryDensity.comfortable ? 6 : 4,
        );
    final resolvedMinHeight = minHeight ??
        (density == LibraryDensity.comfortable
            ? kLibraryPanelHeaderMinHeight
            : kLibraryPanelHeaderCompactMinHeight);
    return Container(
      constraints: BoxConstraints(minHeight: resolvedMinHeight),
      padding: resolvedPadding,
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          bottom: BorderSide(color: borderColor ?? bg.withValues(alpha: 0.92)),
        ),
      ),
      child: IconTheme(
        data: IconThemeData(color: fg),
        child: DefaultTextStyle(
          style: theme.textTheme.titleSmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w800,
              ) ??
              TextStyle(
                color: fg,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 10),
              ],
              Expanded(child: child ?? _buildTextContent(context, fg)),
              if (trailing != null) ...[
                const SizedBox(width: 10),
                trailing!,
              ],
              if (primaryAction != null) ...[
                const SizedBox(width: 10),
                primaryAction!,
              ],
              if (menuActions.isNotEmpty) ...[
                const SizedBox(width: 8),
                ...menuActions,
              ],
              if (onClose != null) ...[
                const SizedBox(width: 10),
                LibrarySquareCloseButton(
                  tooltip: 'Close',
                  onPressed: onClose!,
                  borderColor: fg.withValues(alpha: 0.8),
                  foregroundColor: fg,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, Color foregroundColor) {
    final titleText = title ?? '';
    final subtitleText = subtitle?.trim();
    final countText = count == null ? null : '($count)';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          [titleText, if (countText != null) countText].join(' '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: foregroundColor,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtitleText != null && subtitleText.isNotEmpty)
          Text(
            subtitleText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foregroundColor.withValues(alpha: 0.82),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
