import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';

const Color _kDefaultAccent = kAppAccent;
const Color _kDefaultMutedText = kAppTextMuted;
const double _kTwoColumnBreakpoint = 420;
const double _kInspectorSectionSpacing = 4;
const double _kInspectorSectionContentTopPadding = 6;
const double _kInspectorFactLabelWidth = 104;

class LibraryInspectorFactData {
  const LibraryInspectorFactData(
    this.label,
    this.value, {
    this.onTap,
    this.tooltip,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final String? tooltip;
}

class LibraryInspectorSection extends StatefulWidget {
  const LibraryInspectorSection({
    super.key,
    required this.title,
    required this.children,
    this.accentColor = _kDefaultAccent,
    this.mutedTextColor = _kDefaultMutedText,
    this.collapsible = true,
    this.initiallyExpanded = true,
  });

  final String title;
  final List<Widget> children;
  final Color accentColor;
  final Color mutedTextColor;
  final bool collapsible;
  final bool initiallyExpanded;

  @override
  State<LibraryInspectorSection> createState() =>
      _LibraryInspectorSectionState();
}

class _LibraryInspectorSectionState extends State<LibraryInspectorSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final resolvedMutedTextColor = widget.mutedTextColor == _kDefaultMutedText
        ? palette.textMuted
        : widget.mutedTextColor;
    final borderColor = palette.divider;
    final accentBorderColor = widget.accentColor.withValues(alpha: 0.18);

    return Padding(
      padding: const EdgeInsets.only(bottom: _kInspectorSectionSpacing),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: borderColor.withValues(alpha: 0.78)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: widget.collapsible
                    ? () => setState(() => _expanded = !_expanded)
                    : null,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: accentBorderColor),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          widget.title,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: palette.textMuted,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    letterSpacing: 0.35,
                                  ),
                        ),
                        const Spacer(),
                        if (widget.collapsible)
                          Icon(
                            _expanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_right,
                            size: 16,
                            color: resolvedMutedTextColor,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(
                    top: _kInspectorSectionContentTopPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.children,
                  ),
                ),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 180),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LibraryInspectorFactGrid extends StatelessWidget {
  const LibraryInspectorFactGrid({super.key, required this.facts});

  final List<LibraryInspectorFactData> facts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= _kTwoColumnBreakpoint;
        if (!twoColumns) {
          return Column(
            children: [
              for (final fact in facts)
                LibraryInspectorFact(
                  fact.label,
                  fact.value,
                  onTap: fact.onTap,
                  tooltip: fact.tooltip,
                ),
            ],
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 0,
          children: [
            for (final fact in facts)
              SizedBox(
                width: (constraints.maxWidth - 8) / 2,
                child: LibraryInspectorFact(
                  fact.label,
                  fact.value,
                  onTap: fact.onTap,
                  tooltip: fact.tooltip,
                ),
              ),
          ],
        );
      },
    );
  }
}

class LibraryInspectorFact extends StatelessWidget {
  const LibraryInspectorFact(
    this.label,
    this.value, {
    super.key,
    this.mutedTextColor = _kDefaultMutedText,
    this.onTap,
    this.tooltip,
  });

  final String label;
  final String value;
  final Color mutedTextColor;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final resolvedMutedTextColor = mutedTextColor == _kDefaultMutedText
        ? palette.textMuted
        : mutedTextColor;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _kInspectorFactLabelWidth,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: resolvedMutedTextColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: onTap != null && value != '-' && value.isNotEmpty
                ? Tooltip(
                    message: tooltip ?? 'Show all with $value',
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(4),
                      mouseCursor: SystemMouseCursors.click,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                value,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: onSurfaceColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      decoration: TextDecoration.underline,
                                      decorationColor:
                                          onSurfaceColor.withValues(alpha: 0.4),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.filter_alt_outlined,
                              size: 14,
                              color: resolvedMutedTextColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Text(
                    value,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: onSurfaceColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                  ),
          ),
        ],
      ),
    );
  }
}

class LibraryInspectorChipSection extends StatelessWidget {
  const LibraryInspectorChipSection({
    super.key,
    required this.title,
    required this.values,
    this.onValueTap,
  });

  final String title;
  final List<String> values;
  final ValueChanged<String>? onValueTap;

  @override
  Widget build(BuildContext context) {
    final accent = LibraryAccentScope.accentOf(context);
    return LibraryInspectorSection(
      title: title,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final value in values.take(10))
              LibraryInspectorChip(
                value,
                onTap: onValueTap == null ? null : () => onValueTap!(value),
                accent: accent,
              ),
          ],
        ),
      ],
    );
  }
}

class LibraryInspectorChipWrap extends StatelessWidget {
  const LibraryInspectorChipWrap({
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
    final palette = appPalette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              label!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
            ),
          ),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final value in values)
              LibraryInspectorChip(
                value,
                onTap: onValueTap == null ? null : () => onValueTap!(value),
                accent: accent,
              ),
          ],
        ),
      ],
    );
  }
}

class LibraryInspectorChip extends StatefulWidget {
  const LibraryInspectorChip(
    this.value, {
    super.key,
    this.onTap,
    this.accent,
  });

  final String value;
  final VoidCallback? onTap;
  final Color? accent;

  @override
  State<LibraryInspectorChip> createState() => _LibraryInspectorChipState();
}

class _LibraryInspectorChipState extends State<LibraryInspectorChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final baseChipColor = widget.accent ?? LibraryAccentScope.accentOf(context);
    final chipColor = _hovered
        ? Color.alphaBlend(
            (ThemeData.estimateBrightnessForColor(baseChipColor) ==
                        Brightness.dark
                    ? Colors.white
                    : Colors.black)
                .withValues(alpha: 0.18),
            baseChipColor,
          )
        : baseChipColor;
    final chipTextColor =
        ThemeData.estimateBrightnessForColor(chipColor) == Brightness.dark
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface;
    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _hovered
              ? baseChipColor.withValues(alpha: 0.9)
              : baseChipColor.withValues(alpha: 0.35),
        ),
        boxShadow: _hovered
            ? [
                BoxShadow(
                  color: baseChipColor.withValues(alpha: 0.22),
                  blurRadius: 9,
                  spreadRadius: 0.6,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          widget.value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: chipTextColor,
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
            borderRadius: BorderRadius.circular(3),
            hoverColor: Colors.transparent,
            splashColor: chipTextColor.withValues(alpha: 0.12),
            highlightColor: chipTextColor.withValues(alpha: 0.06),
            child: chip,
          ),
        ),
      ),
    );
  }
}

class LibraryEmptyInspector extends StatelessWidget {
  const LibraryEmptyInspector({
    super.key,
    required this.icon,
    required this.label,
    this.accent = _kDefaultAccent,
    this.mutedTextColor = _kDefaultMutedText,
    this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final Color mutedTextColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final palette = appPalette(context);
    final resolvedMutedTextColor = mutedTextColor == _kDefaultMutedText
        ? palette.textMuted
        : mutedTextColor;
    final content = Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: palette.divider),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, size: 28, color: accent),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Details panel',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: resolvedMutedTextColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'No $label selected',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select an item to inspect metadata, covers, and collection status here.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: resolvedMutedTextColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (backgroundColor != null) {
      return ColoredBox(color: backgroundColor!, child: content);
    }
    return content;
  }
}
