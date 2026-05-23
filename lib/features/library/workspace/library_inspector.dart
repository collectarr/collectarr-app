import 'package:flutter/material.dart';

const Color _kDefaultAccent = Color(0xFF10A8D8);
const Color _kDefaultMutedText = Color(0xFFB8B8B8);
const double _kTwoColumnBreakpoint = 420;

class LibraryInspectorFactData {
  const LibraryInspectorFactData(this.label, this.value, {this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;
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
    final colorScheme = Theme.of(context).colorScheme;
    final sectionColor = Color.alphaBlend(
      colorScheme.surfaceContainerHigh.withValues(alpha: 0.84),
      colorScheme.surface,
    );
    final borderColor = colorScheme.outlineVariant.withValues(alpha: 0.42);
    final accentBorderColor = widget.accentColor.withValues(alpha: 0.28);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: sectionColor,
          border: Border(
            left: BorderSide(color: widget.accentColor, width: 2),
            top: BorderSide(color: accentBorderColor),
            right: BorderSide(color: borderColor),
            bottom: BorderSide(color: borderColor),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(9, 7, 9, 9),
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
                      bottom: BorderSide(
                        color: widget.accentColor.withValues(alpha: 0.14),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: widget.accentColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                        ),
                        const Spacer(),
                        if (widget.collapsible)
                          Icon(
                            _expanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_right,
                            size: 16,
                            color: widget.mutedTextColor,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 7),
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
                LibraryInspectorFact(fact.label, fact.value, onTap: fact.onTap),
            ],
          );
        }
        return Wrap(
          runSpacing: 0,
          children: [
            for (final fact in facts)
              SizedBox(
                width: constraints.maxWidth / 2,
                child: LibraryInspectorFact(fact.label, fact.value, onTap: fact.onTap),
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
  });

  final String label;
  final String value;
  final Color mutedTextColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: mutedTextColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
            ),
          ),
          Expanded(
            child: onTap != null && value != '-' && value.isNotEmpty
                ? InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(4),
                    child: Text(
                      value,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor:
                                Colors.white.withValues(alpha: 0.4),
                          ),
                    ),
                  )
                : Text(
                    value,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              label!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final value in values)
              LibraryInspectorChip(
                value,
                onTap: onValueTap == null ? null : () => onValueTap!(value),
              ),
          ],
        ),
      ],
    );
  }
}

class LibraryInspectorChip extends StatelessWidget {
  const LibraryInspectorChip(this.value, {super.key, this.onTap});

  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chip = DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF183B44),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0x8837C7E8)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Text(
          value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
    if (onTap == null) {
      return chip;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(3),
        child: chip,
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
    final content = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: accent),
          const SizedBox(height: 12),
          Text(
            'No $label selected',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select an item to inspect metadata, cover, and local status.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: mutedTextColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
    if (backgroundColor != null) {
      return ColoredBox(color: backgroundColor!, child: content);
    }
    return content;
  }
}
