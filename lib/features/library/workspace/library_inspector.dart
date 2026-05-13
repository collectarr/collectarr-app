import 'package:flutter/material.dart';

const Color _kDefaultAccent = Color(0xFF10A8D8);
const Color _kDefaultMutedText = Color(0xFFB8B8B8);

class LibraryInspectorFactData {
  const LibraryInspectorFactData(this.label, this.value);

  final String label;
  final String value;
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xD51C1F21),
          border: Border(
            left: BorderSide(color: accentColor, width: 2),
            top: const BorderSide(color: Color(0x444DBBD5)),
            right: const BorderSide(color: Color(0x33222222)),
            bottom: const BorderSide(color: Color(0x33222222)),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(9, 7, 9, 9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0x224DBBD5)),
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
        final twoColumns = constraints.maxWidth >= 420;
        if (!twoColumns) {
          return Column(
            children: [
              for (final fact in facts)
                LibraryInspectorFact(fact.label, fact.value),
            ],
          );
        }
        return Wrap(
          runSpacing: 0,
          children: [
            for (final fact in facts)
              SizedBox(
                width: constraints.maxWidth / 2,
                child: LibraryInspectorFact(fact.label, fact.value),
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
  });

  final String label;
  final String value;
  final Color mutedTextColor;

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
            child: Text(
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
