import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';

class LibraryDetailChip extends StatefulWidget {
  const LibraryDetailChip(
    this.value, {
    super.key,
    this.onTap,
    this.accent,
  });

  final String value;
  final VoidCallback? onTap;
  final Color? accent;

  @override
  State<LibraryDetailChip> createState() => _LibraryDetailChipState();
}

class _LibraryDetailChipState extends State<LibraryDetailChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final base = widget.accent ?? LibraryAccentScope.accentOf(context);
    final chipColor = _hovered
        ? Color.alphaBlend(
            (ThemeData.estimateBrightnessForColor(base) == Brightness.dark
                    ? Colors.white
                    : Colors.black)
                .withValues(alpha: 0.12),
            base,
          )
        : base;
    final textColor =
        ThemeData.estimateBrightnessForColor(chipColor) == Brightness.dark
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface;
    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: _hovered ? base.withValues(alpha: 0.9) : base.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          widget.value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
    if (widget.onTap == null) {
      return chip;
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: 'Show all with ${widget.value}',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.zero,
            child: chip,
          ),
        ),
      ),
    );
  }
}

class LibraryDetailChipGroupWidget extends StatelessWidget {
  const LibraryDetailChipGroupWidget({
    super.key,
    required this.values,
    this.label,
    this.onValueTap,
  });

  final List<String> values;
  final String? label;
  final ValueChanged<String>? onValueTap;

  @override
  Widget build(BuildContext context) {
    final accent = LibraryAccentScope.accentOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              label!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final value in values)
              LibraryDetailChip(
                value,
                accent: accent,
                onTap: onValueTap == null ? null : () => onValueTap!(value),
              ),
          ],
        ),
      ],
    );
  }
}

