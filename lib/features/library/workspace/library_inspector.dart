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

class LibraryInspectorSection extends StatelessWidget {
  const LibraryInspectorSection({
    super.key,
    required this.title,
    required this.children,
    this.accentColor = _kDefaultAccent,
    this.mutedTextColor = _kDefaultMutedText,
  });

  final String title;
  final List<Widget> children;
  final Color accentColor;
  final Color mutedTextColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sectionColor = Color.alphaBlend(
      colorScheme.surfaceContainerHigh.withValues(alpha: 0.84),
      colorScheme.surface,
    );
    final borderColor = colorScheme.outlineVariant.withValues(alpha: 0.42);
    final accentBorderColor = accentColor.withValues(alpha: 0.28);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: sectionColor,
          border: Border(
            left: BorderSide(color: accentColor, width: 2),
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
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: accentColor.withValues(alpha: 0.14),
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: mutedTextColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 7),
              ...children,
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
  });

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return LibraryInspectorSection(
      title: title,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final value in values.take(10)) LibraryInspectorChip(value),
          ],
        ),
      ],
    );
  }
}

class LibraryInspectorChipWrap extends StatelessWidget {
  const LibraryInspectorChipWrap({super.key, required this.values});

  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final value in values) LibraryInspectorChip(value),
      ],
    );
  }
}

class LibraryInspectorChip extends StatelessWidget {
  const LibraryInspectorChip(this.value, {super.key});

  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
