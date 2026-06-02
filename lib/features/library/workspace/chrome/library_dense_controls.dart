import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum LibraryDenseButtonTone { surface, accent, subtle }

class LibraryDenseMenuEntry<T> {
  const LibraryDenseMenuEntry({
    required this.value,
    required this.label,
    required this.icon,
    this.active = false,
    this.enabled = true,
    this.trailingLabel,
  });

  final T value;
  final String label;
  final IconData icon;
  final bool active;
  final bool enabled;
  final String? trailingLabel;
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
  });

  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;
  final LibraryDenseButtonTone tone;
  final EdgeInsetsGeometry? padding;

  @override
  State<LibraryDenseButton> createState() => _LibraryDenseButtonState();
}

class _LibraryDenseButtonState extends State<LibraryDenseButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final enabled = widget.onPressed != null;
    final background = switch (widget.tone) {
      LibraryDenseButtonTone.accent => enabled
          ? palette.accent
          : palette.accent.withValues(alpha: 0.45),
      LibraryDenseButtonTone.subtle => palette.surfaceSubtle,
      LibraryDenseButtonTone.surface => palette.panelRaised,
    };
    final foreground = widget.tone == LibraryDenseButtonTone.accent
        ? Colors.white
        : enabled
            ? palette.textPrimary
            : palette.textMuted;
    final borderColor = widget.tone == LibraryDenseButtonTone.accent
        ? palette.accent.withValues(alpha: 0.74)
        : palette.divider;
    final hoveredBackground = enabled
        ? Color.alphaBlend(
            (widget.tone == LibraryDenseButtonTone.accent
                    ? Colors.white
                    : palette.accent)
                .withValues(alpha: widget.tone == LibraryDenseButtonTone.accent ? 0.08 : 0.07),
            background,
          )
        : background;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: _hovered ? hoveredBackground : background,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: borderColor),
            ),
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1,
                  ) ??
                  TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w800,
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
    final enabled = widget.onPressed != null;
    final background = switch (widget.tone) {
      LibraryDenseButtonTone.accent => enabled
          ? palette.accent
          : palette.accent.withValues(alpha: 0.45),
      LibraryDenseButtonTone.subtle => palette.surfaceSubtle,
      LibraryDenseButtonTone.surface => palette.panelRaised,
    };
    final foreground = widget.tone == LibraryDenseButtonTone.accent
        ? Colors.white
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
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _hovered
                    ? Color.alphaBlend(
                        (widget.tone == LibraryDenseButtonTone.accent
                                ? Colors.white
                                : palette.accent)
                            .withValues(alpha: widget.tone == LibraryDenseButtonTone.accent ? 0.08 : 0.07),
                        background,
                      )
                    : background,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: widget.tone == LibraryDenseButtonTone.accent
                      ? palette.accent.withValues(alpha: 0.74)
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
    final palette = appPalette(context);
    return PopupMenuButton<T>(
      tooltip: tooltip ?? label,
      onSelected: onSelected,
      padding: EdgeInsets.zero,
      color: Color.alphaBlend(
        palette.accent.withValues(alpha: 0.025),
        palette.panelRaised,
      ),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.22),
      menuPadding: const EdgeInsets.symmetric(vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: palette.divider.withValues(alpha: 0.9)),
      ),
      itemBuilder: (context) => [
        for (final entry in entries)
          PopupMenuItem<T>(
            value: entry.value,
            enabled: entry.enabled,
            height: 32,
            child: _LibraryDenseMenuItemRow(entry: entry),
          ),
      ],
      child: LibraryDenseButton(
        label: label,
        icon: icon,
        trailingIcon: trailingIcon,
        tone: tone,
        padding: padding,
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
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final List<LibraryDenseMenuEntry<T>> entries;
  final ValueChanged<T> onSelected;
  final LibraryDenseButtonTone tone;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final background = switch (tone) {
      LibraryDenseButtonTone.accent => palette.accent,
      LibraryDenseButtonTone.subtle => palette.surfaceSubtle,
      LibraryDenseButtonTone.surface => palette.panelRaised,
    };
    final foreground = tone == LibraryDenseButtonTone.accent
        ? Colors.white
        : palette.textPrimary;
    final border = tone == LibraryDenseButtonTone.accent
        ? palette.accent.withValues(alpha: 0.74)
        : palette.divider;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: foreground),
                    const SizedBox(width: 7),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.1,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 1, height: 18, color: foreground.withValues(alpha: 0.18)),
          PopupMenuButton<T>(
            tooltip: tooltip ?? label,
            padding: EdgeInsets.zero,
            onSelected: onSelected,
            color: Color.alphaBlend(
              palette.accent.withValues(alpha: 0.025),
              palette.panelRaised,
            ),
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black.withValues(alpha: 0.22),
            menuPadding: const EdgeInsets.symmetric(vertical: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: palette.divider.withValues(alpha: 0.9)),
            ),
            itemBuilder: (context) => [
              for (final entry in entries)
                PopupMenuItem<T>(
                  value: entry.value,
                  enabled: entry.enabled,
                  height: 32,
                  child: _LibraryDenseMenuItemRow(entry: entry),
                ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              child: Icon(Icons.keyboard_arrow_down, size: 16, color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryDenseMenuItemRow<T> extends StatelessWidget {
  const _LibraryDenseMenuItemRow({required this.entry});

  final LibraryDenseMenuEntry<T> entry;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final foreground = entry.enabled ? palette.textPrimary : palette.textMuted;
    return Row(
      children: [
        Icon(
          entry.active ? Icons.check_circle : entry.icon,
          size: 14,
          color: entry.enabled
              ? (entry.active ? palette.accent : palette.textPrimary)
              : palette.textMuted,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            entry.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: foreground,
                  fontWeight: entry.active ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 13,
                ),
          ),
        ),
        if (entry.trailingLabel case final trailing?) ...[
          const SizedBox(width: 7),
          Text(
            trailing,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: palette.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.5,
                ),
          ),
        ],
      ],
    );
  }
}