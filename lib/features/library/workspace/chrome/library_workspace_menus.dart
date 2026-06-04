import 'package:flutter/material.dart';

import '../config/library_workspace_tokens.dart';

BoxDecoration libraryToolbarMenuPanelDecoration(BuildContext context) {
  return BoxDecoration(
    color: libraryToolbarMenuSurface(context),
    border: Border.all(color: libraryToolbarMenuBorder(context)),
    boxShadow: [
      BoxShadow(
        color: Theme.of(context).shadowColor.withValues(alpha: 0.24),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

RoundedRectangleBorder libraryToolbarDropdownMenuShape(
  BuildContext context, {
  Color? borderColor,
}) {
  return RoundedRectangleBorder(
    side: BorderSide(
      color: borderColor ?? libraryToolbarMenuBorder(context),
    ),
  );
}

class LibraryWorkspaceMenuPanel extends StatelessWidget {
  const LibraryWorkspaceMenuPanel({
    super.key,
    required this.child,
    this.includeBackground = true,
  });

  final Widget child;
  final bool includeBackground;

  @override
  Widget build(BuildContext context) {
    final decoration = libraryToolbarMenuPanelDecoration(context);
    return DecoratedBox(
      decoration: includeBackground
          ? decoration
          : decoration.copyWith(color: Colors.transparent),
      child: child,
    );
  }
}

class LibraryWorkspaceMenuSectionDivider extends StatelessWidget {
  const LibraryWorkspaceMenuSectionDivider({
    super.key,
    required this.label,
    this.padding = const EdgeInsets.fromLTRB(12, 8, 12, 6),
    this.leadingInset = 0,
    this.leadingLineWidth = 0,
  });

  final String label;
  final EdgeInsetsGeometry padding;
  final double leadingInset;
  final double leadingLineWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (leadingInset > 0) SizedBox(width: leadingInset),
          if (leadingLineWidth > 0)
            SizedBox(
              width: leadingLineWidth,
              child:
                  Divider(height: 1, color: libraryToolbarMenuBorder(context)),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: libraryToolbarMenuMutedText(context),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
            ),
          ),
          Expanded(
            child: Divider(height: 1, color: libraryToolbarMenuBorder(context)),
          ),
        ],
      ),
    );
  }
}

class LibraryWorkspaceMenuRow extends StatelessWidget {
  const LibraryWorkspaceMenuRow({
    super.key,
    required this.label,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    this.leadingWidth,
    this.backgroundColor,
    this.textStyle,
    this.leadingSpacing = 8,
  });

  final String label;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double? leadingWidth;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final double leadingSpacing;

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle = textStyle ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: libraryToolbarMenuText(context),
              fontWeight: FontWeight.w500,
            );
    final content = Ink(
      decoration: BoxDecoration(color: backgroundColor ?? Colors.transparent),
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            if (leadingWidth != null)
              SizedBox(
                width: leadingWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: leading,
                ),
              )
            else if (leading != null)
              leading!,
            if (leading != null || leadingWidth != null)
              SizedBox(width: leadingSpacing),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: effectiveTextStyle,
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
    if (onTap == null) {
      return content;
    }
    final hover = libraryToolbarMenuHover(context);
    return InkWell(
      borderRadius: BorderRadius.zero,
      onTap: onTap,
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) {
          return hover.withValues(alpha: 0.92);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return hover.withValues(alpha: 0.80);
        }
        return null;
      }),
      child: content,
    );
  }
}

class LibraryWorkspaceMenuTreeHeader extends StatelessWidget {
  const LibraryWorkspaceMenuTreeHeader({
    super.key,
    required this.label,
    required this.expanded,
    required this.highlighted,
    required this.onTap,
  });

  final String label;
  final bool expanded;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LibraryWorkspaceMenuRow(
      label: label,
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
      trailing: Icon(
        expanded ? Icons.expand_less : Icons.expand_more,
        size: 18,
        color: libraryToolbarMenuMutedText(context),
      ),
      backgroundColor: highlighted
          ? libraryToolbarMenuHover(context).withValues(alpha: 0.55)
          : Colors.transparent,
      textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: libraryToolbarMenuText(context),
            fontWeight: highlighted ? FontWeight.w700 : FontWeight.w600,
          ),
    );
  }
}
