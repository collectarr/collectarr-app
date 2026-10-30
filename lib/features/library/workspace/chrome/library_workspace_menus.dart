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
    this.padding = const EdgeInsets.fromLTRB(5, 2, 5, 2),
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
            padding: const EdgeInsets.symmetric(horizontal: 5),
            // The reference heading is the rule's own #666, 14/400.
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: libraryToolbarMenuBorder(context),
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 20 / 14,
                    letterSpacing: 0,
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
    this.hoverColor,
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

  /// A solid hover shade in place of the default tint.
  final Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    // Callers adjust size and weight; the menu's font and color stay.
    final effectiveTextStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(
          color: libraryToolbarMenuText(context),
          fontWeight: FontWeight.w400,
        )
        .merge(textStyle);
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
                  child: _menuIcon(context, leading),
                ),
              )
            else if (leading != null)
              _menuIcon(context, leading!),
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
    final solidHover = hoverColor;
    final hover = solidHover ?? libraryToolbarMenuHover(context);
    return InkWell(
      mouseCursor: WidgetStateMouseCursor.clickable,
      borderRadius: BorderRadius.zero,
      onTap: onTap,
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) {
          return solidHover ?? hover.withValues(alpha: 0.92);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return solidHover ?? hover.withValues(alpha: 0.80);
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
    required this.onTap,
    this.leading,
  });

  final String label;
  final bool expanded;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return LibraryWorkspaceMenuRow(
      label: label,
      onTap: onTap,
      leading: leading,
      padding: const EdgeInsets.fromLTRB(7, 6, 7, 6),
      leadingWidth: 16,
      leadingSpacing: 6,
      trailing: Icon(
        expanded ? Icons.expand_less : Icons.expand_more,
        size: 18,
        color: libraryToolbarMenuText(context),
      ),
      // An open category is lit, as is the bar beside its rows.
      backgroundColor:
          expanded ? libraryToolbarMenuOpenGroup(context) : Colors.transparent,
      hoverColor: libraryToolbarMenuBorder(context),
      textStyle: TextStyle(
        fontSize: 14,
        color: libraryToolbarMenuText(context),
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

/// Menu glyphs take the menu's text color unless they set their own.
Widget _menuIcon(BuildContext context, Widget? icon) => IconTheme.merge(
    data: IconThemeData(color: libraryToolbarMenuText(context)),
    child: icon ?? const SizedBox.shrink());
