import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:flutter/material.dart';
import 'library_workspace_menus.dart';
import 'library_workspace_controls.dart';
import 'package:collectarr_app/ui/app_icons.dart';

enum LibraryDenseButtonTone { surface, accent, subtle }

class LibraryDenseMenuEntry<T> {
  const LibraryDenseMenuEntry({
    required this.value,
    required this.label,
    required this.icon,
    this.active = false,
    this.enabled = true,
    this.trailingLabel,
    this.section,
  });

  final T value;
  final String label;
  final IconData? icon;
  final bool active;
  final bool enabled;
  final String? trailingLabel;
  final String? section;
}

class LibraryDenseButton extends StatefulWidget {
  const LibraryDenseButton({
    super.key,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.tone = LibraryDenseButtonTone.surface,
    this.padding,
    this.menuTrigger = false,
  });

  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;
  final LibraryDenseButtonTone tone;
  final EdgeInsetsGeometry? padding;
  final bool menuTrigger;

  @override
  State<LibraryDenseButton> createState() => _LibraryDenseButtonState();
}

class _LibraryDenseButtonState extends State<LibraryDenseButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accent = LibraryAccentScope.accentOf(context);
    final enabled = widget.onPressed != null || widget.menuTrigger;
    final background = switch (widget.tone) {
      LibraryDenseButtonTone.accent => enabled
          ? accent
          : Color.alphaBlend(
              accent.withValues(alpha: 0.45),
              palette.panelRaised,
            ),
      LibraryDenseButtonTone.subtle => palette.surfaceSubtle,
      LibraryDenseButtonTone.surface => libraryToolbarControlSurface(context),
    };
    final borderColor = widget.tone == LibraryDenseButtonTone.accent
        ? accent.withValues(alpha: 0.74)
        : palette.divider;
    final hoveredBackground = enabled
        ? Color.alphaBlend(
            (widget.tone == LibraryDenseButtonTone.accent
                    ? Colors.white
                    : accent)
                .withValues(
                    alpha: widget.tone == LibraryDenseButtonTone.accent
                        ? 0.08
                        : 0.07),
            background,
          )
        : background;
    final foreground = widget.tone == LibraryDenseButtonTone.accent
        ? appContrastingTextColor(
            _hovered ? hoveredBackground : background,
          )
        : enabled
            ? palette.textPrimary
            : palette.textMuted;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          mouseCursor: widget.menuTrigger
              ? SystemMouseCursors.click
              : WidgetStateMouseCursor.clickable,
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            constraints:
                const BoxConstraints(minHeight: kLibraryDenseControlHeight),
            padding: widget.padding ??
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _hovered ? hoveredBackground : background,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: borderColor),
            ),
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ) ??
                  TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    letterSpacing: 0.1,
                  ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 14, color: foreground),
                    const SizedBox(width: 7),
                  ],
                  Text(widget.label),
                  if (widget.trailingIcon != null) ...[
                    const SizedBox(width: 6),
                    Icon(widget.trailingIcon, size: 14, color: foreground),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LibraryDenseIconButton extends StatefulWidget {
  const LibraryDenseIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.tone = LibraryDenseButtonTone.surface,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final LibraryDenseButtonTone tone;

  @override
  State<LibraryDenseIconButton> createState() => _LibraryDenseIconButtonState();
}

class _LibraryDenseIconButtonState extends State<LibraryDenseIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accent = LibraryAccentScope.accentOf(context);
    final enabled = widget.onPressed != null;
    final background = switch (widget.tone) {
      LibraryDenseButtonTone.accent => enabled
          ? accent
          : Color.alphaBlend(
              accent.withValues(alpha: 0.45),
              palette.panelRaised,
            ),
      LibraryDenseButtonTone.subtle => palette.surfaceSubtle,
      LibraryDenseButtonTone.surface => libraryToolbarControlSurface(context),
    };
    final hoveredBackground = _hovered
        ? Color.alphaBlend(
            (widget.tone == LibraryDenseButtonTone.accent
                    ? Colors.white
                    : accent)
                .withValues(
                    alpha: widget.tone == LibraryDenseButtonTone.accent
                        ? 0.08
                        : 0.07),
            background,
          )
        : background;
    final foreground = widget.tone == LibraryDenseButtonTone.accent
        ? appContrastingTextColor(hoveredBackground)
        : enabled
            ? palette.textPrimary
            : palette.textMuted;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            mouseCursor: WidgetStateMouseCursor.clickable,
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              width: kLibraryDenseControlHeight,
              height: kLibraryDenseControlHeight,
              decoration: BoxDecoration(
                color: hoveredBackground,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: widget.tone == LibraryDenseButtonTone.accent
                      ? accent.withValues(alpha: 0.74)
                      : palette.divider,
                ),
              ),
              child: Icon(widget.icon, size: 15, color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}

class LibraryDenseMenuButton<T> extends StatelessWidget {
  const LibraryDenseMenuButton({
    super.key,
    required this.label,
    required this.icon,
    required this.entries,
    required this.onSelected,
    this.tone = LibraryDenseButtonTone.surface,
    this.tooltip,
    this.padding,
    this.trailingIcon = Icons.keyboard_arrow_down,
  });

  final String label;
  final IconData icon;
  final List<LibraryDenseMenuEntry<T>> entries;
  final ValueChanged<T> onSelected;
  final LibraryDenseButtonTone tone;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final accent = LibraryAccentScope.accentOf(context);
    return PopupMenuButton<T>(
      popUpAnimationStyle: AnimationStyle.noAnimation,
      tooltip: tooltip ?? label,
      onSelected: onSelected,
      padding: EdgeInsets.zero,
      color: libraryToolbarMenuSurface(context),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.22),
      menuPadding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      shape: libraryToolbarDropdownMenuShape(context),
      itemBuilder: (context) => [
        for (final entry in entries)
          PopupMenuItem<T>(
            value: entry.value,
            enabled: entry.enabled,
            height: kLibraryToolbarPopupItemHeight,
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: _LibraryDenseMenuItemRow(entry: entry, accent: accent),
          ),
      ],
      child: LibraryDenseButton(
        label: label,
        icon: icon,
        trailingIcon: trailingIcon,
        tone: tone,
        padding: padding,
        menuTrigger: true,
      ),
    );
  }
}

class LibraryDenseSplitButton<T> extends StatelessWidget {
  const LibraryDenseSplitButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.entries,
    required this.onSelected,
    this.tone = LibraryDenseButtonTone.surface,
    this.tooltip,
    this.iconOnly = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final List<LibraryDenseMenuEntry<T>> entries;
  final ValueChanged<T> onSelected;
  final LibraryDenseButtonTone tone;
  final String? tooltip;

  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accent = LibraryAccentScope.accentOf(context);
    final background = switch (tone) {
      LibraryDenseButtonTone.accent => accent,
      LibraryDenseButtonTone.subtle => palette.surfaceSubtle,
      LibraryDenseButtonTone.surface => libraryToolbarControlSurface(context),
    };
    final foreground = tone == LibraryDenseButtonTone.accent
        ? appContrastingTextColor(background)
        : palette.textPrimary;
    final border = tone == LibraryDenseButtonTone.accent
        ? accent.withValues(alpha: 0.74)
        : palette.divider;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        border: Border(right: BorderSide(color: border)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: iconOnly ? label : null,
            button: iconOnly,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                mouseCursor: WidgetStateMouseCursor.clickable,
                onTap: onPressed,
                hoverColor: libraryToolbarControlHover(context),
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(4)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: iconOnly ? 7 : 10,
                      vertical: iconOnly ? 7 : 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: iconOnly ? 16 : 14, color: foreground),
                      if (!iconOnly) ...[
                        const SizedBox(width: 7),
                        Text(
                          label,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: foreground,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.1,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
              width: 1, height: 20, color: foreground.withValues(alpha: 0.18)),
          PopupMenuButton<T>(
            popUpAnimationStyle: AnimationStyle.noAnimation,
            tooltip: tooltip ?? label,
            padding: EdgeInsets.zero,
            onSelected: onSelected,
            color: libraryToolbarMenuSurface(context),
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black.withValues(alpha: 0.22),
            menuPadding: EdgeInsets.zero,
            position: PopupMenuPosition.under,
            shape: libraryToolbarDropdownMenuShape(context),
            itemBuilder: (context) => [
              for (final entry in entries) ...[
                if (entry.section != null)
                  PopupMenuItem<T>(
                      enabled: false,
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Text(entry.section!,
                          style: TextStyle(
                              fontSize: 14,
                              color: libraryToolbarMenuMutedText(context)))),
                PopupMenuItem<T>(
                  value: entry.value,
                  enabled: entry.enabled,
                  height: kLibraryToolbarPopupItemHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: _LibraryDenseMenuItemRow(entry: entry, accent: accent),
                ),
              ],
            ],
            child: LibraryToolbarHoverSurface(
              child: SizedBox(
                  width: 18,
                  height: 30,
                  child: Center(
                      child: Icon(AppIcons.chevronDown,
                          size: 12, color: foreground))),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryDenseMenuItemRow<T> extends StatelessWidget {
  const _LibraryDenseMenuItemRow({required this.entry, required this.accent});

  final LibraryDenseMenuEntry<T> entry;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final foreground = entry.enabled ? palette.textPrimary : palette.textMuted;
    return LibraryWorkspaceMenuRow(
      label: entry.label,
      padding: EdgeInsets.zero,
      leadingSpacing: 7,
      leading: Icon(entry.active ? Icons.check : entry.icon,
          size: 14,
          color: entry.enabled
              ? (entry.active ? accent : foreground)
              : palette.textMuted),
      textStyle: TextStyle(
          color: foreground, fontWeight: FontWeight.w500, fontSize: 14),
      trailing: entry.trailingLabel == null
          ? null
          : Text(entry.trailingLabel!,
              style: TextStyle(
                  color: palette.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
    );
  }
}
