import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_content.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

List<Widget> buildComicInspectorSections(
  BuildContext _,
  LibraryInspectorRequest request,
) {
  final presentation = buildLibraryMetadataPresentation(
    type: request.type,
    entry: request.entry,
    onFilterByValue: request.onFilterByValue,
    includeIdentityFacts: true,
  );

  final sections = <Widget>[
    _ComicInspectorSection(
      title: 'Catalog identity',
      accent: request.accent,
      child: _ComicInspectorFactTiles(facts: presentation.identityFacts),
    ),
    _ComicInspectorSection(
      title: 'Catalog context',
      accent: request.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ComicInspectorFactTiles(facts: presentation.contextFacts),
          if (presentation.genres.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ComicInspectorTagGroup(
              label: 'Genres',
              values: presentation.genres,
              onValueTap: request.onFilterByValue,
            ),
          ],
        ],
      ),
    ),
  ];

  if (presentation.hasCredits) {
    sections.add(
      _ComicInspectorSection(
        title: 'Credits & Discovery',
        accent: request.accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (presentation.creators.isNotEmpty)
              _ComicCreditsList(
                credits: presentation.creators,
                onValueTap: request.onFilterByValue,
              ),
            if (presentation.characters.isNotEmpty) ...[
              if (presentation.creators.isNotEmpty) const SizedBox(height: 10),
              _ComicInspectorTagGroup(
                label: 'Characters',
                values: presentation.characters,
                onValueTap: request.onFilterByValue,
              ),
            ],
            if (presentation.storyArcs.isNotEmpty) ...[
              if (presentation.creators.isNotEmpty ||
                  presentation.characters.isNotEmpty)
                const SizedBox(height: 10),
              _ComicInspectorTagGroup(
                label: 'Story Arcs',
                values: presentation.storyArcs,
                onValueTap: request.onFilterByValue,
              ),
            ],
          ],
        ),
      ),
    );
  }

  final ownedItem = request.ownedItem;
  if (ownedItem == null) {
    return sections;
  }

  final ownedIsDigital = resolveOwnedDigitalFlag(
    ownedItem,
    request.entry.editions,
    fallbackLabel: request.entry.variant,
  );
  if (ownedIsDigital == true) {
    return sections;
  }

  final collectorFacts = <LibraryInspectorFactData>[
    if (ownedItem.rawOrSlabbed?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Raw / Slabbed', ownedItem.rawOrSlabbed!),
    if (ownedItem.gradingCompany?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Grading co.', ownedItem.gradingCompany!),
    if (ownedItem.certificationNumber?.trim().isNotEmpty == true)
      LibraryInspectorFactData(
        'Certification no.',
        ownedItem.certificationNumber!,
      ),
    if (ownedItem.labelType?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Label type', ownedItem.labelType!),
    if (ownedItem.customLabel?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Custom label', ownedItem.customLabel!),
    if (ownedItem.pageQuality?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Page quality', ownedItem.pageQuality!),
    if (ownedItem.signedBy?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Signed by', ownedItem.signedBy!),
    if (ownedItem.keyComic)
      LibraryInspectorFactData('Key', ownedItem.keyReason ?? 'Yes'),
    if (ownedItem.keyCategory?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Key category', ownedItem.keyCategory!),
    if (ownedItem.keySeverity?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Key severity', ownedItem.keySeverity!),
  ];
  if (collectorFacts.isNotEmpty) {
    sections.add(
      _ComicInspectorSection(
        title: 'Comic details',
        accent: request.accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ComicInspectorFactTiles(facts: collectorFacts),
            if (ownedItem.graderNotes?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 10),
              _ComicNarrativeFact(
                label: 'Grader notes',
                value: ownedItem.graderNotes!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  final currentValue = formatMoney(
    ownedItem.marketValueCents,
    ownedItem.currency,
  );
  final valueFacts = <LibraryInspectorFactData>[
    if (ownedItem.coverPriceCents != null)
      LibraryInspectorFactData(
        'Cover price',
        formatMoney(ownedItem.coverPriceCents, ownedItem.currency),
      ),
    if (currentValue.isNotEmpty)
      LibraryInspectorFactData('Current value', currentValue),
  ];
  if (valueFacts.isNotEmpty) {
    sections.add(
      _ComicInspectorSection(
        title: 'Value',
        accent: request.accent,
        child: _ComicInspectorFactTiles(facts: valueFacts),
      ),
    );
  }

  return sections;
}

class _ComicInspectorSection extends StatelessWidget {
  const _ComicInspectorSection({
    required this.title,
    required this.accent,
    required this.child,
  });

  final String title;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final colorScheme = Theme.of(context).colorScheme;
    final panel = Color.alphaBlend(
      accent.withValues(alpha: palette.isDark ? 0.12 : 0.06),
      palette.panelRaised,
    );
    final paper = Color.alphaBlend(
      Colors.white.withValues(alpha: palette.isDark ? 0.03 : 0.42),
      panel,
    );
    final headerFill = Color.alphaBlend(
      accent.withValues(alpha: palette.isDark ? 0.2 : 0.12),
      palette.panel,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [paper, panel],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accent.withValues(alpha: palette.isDark ? 0.4 : 0.28),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: headerFill,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: accent.withValues(alpha: palette.isDark ? 0.45 : 0.22),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.35,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _ComicInspectorFactTiles extends StatelessWidget {
  const _ComicInspectorFactTiles({required this.facts});

  final List<LibraryInspectorFactData> facts;

  @override
  Widget build(BuildContext context) {
    if (facts.isEmpty) {
      return const SizedBox.shrink();
    }

    final palette = appPalette(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 440 ? 2 : 1;
        const spacing = 8.0;
        final width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final fact in facts)
              SizedBox(
                width: width,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.panel.withValues(
                      alpha: palette.isDark ? 0.84 : 0.92,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: palette.divider.withValues(alpha: 0.9),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fact.label,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: palette.textMuted,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        _ComicInspectorValueText(fact: fact),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ComicInspectorValueText extends StatelessWidget {
  const _ComicInspectorValueText({required this.fact});

  final LibraryInspectorFactData fact;

  @override
  Widget build(BuildContext context) {
    final valueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          height: 1.25,
        );
    if (fact.onTap == null) {
      return Text(
        fact.value,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: valueStyle,
      );
    }

    return InkWell(
      onTap: fact.onTap,
      borderRadius: BorderRadius.circular(6),
      child: Text(
        fact.value,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: valueStyle?.copyWith(decoration: TextDecoration.underline),
      ),
    );
  }
}

class _ComicNarrativeFact extends StatelessWidget {
  const _ComicNarrativeFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel.withValues(alpha: palette.isDark ? 0.82 : 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.divider.withValues(alpha: 0.92)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComicCreditsList extends StatelessWidget {
  const _ComicCreditsList({required this.credits, this.onValueTap});

  final List<Map<String, dynamic>> credits;
  final ValueChanged<String>? onValueTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Creators',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: appPalette(context).textMuted,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
        ),
        const SizedBox(height: 8),
        for (final credit in credits)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ComicCreditRow(
              name: credit['name']?.toString() ?? '?',
              role: credit['role']?.toString(),
              onTap: onValueTap == null ||
                      (credit['name']?.toString().trim().isEmpty ?? true)
                  ? null
                  : () => onValueTap!(credit['name'].toString().trim()),
            ),
          ),
      ],
    );
  }
}

class _ComicCreditRow extends StatelessWidget {
  const _ComicCreditRow({required this.name, this.role, this.onTap});

  final String name;
  final String? role;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final row = DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel.withValues(alpha: palette.isDark ? 0.82 : 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.divider.withValues(alpha: 0.92)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      decoration:
                          onTap == null ? null : TextDecoration.underline,
                    ),
              ),
            ),
            if (role != null && role!.trim().isNotEmpty)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.selection,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    role!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    if (onTap == null) {
      return row;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: row,
      ),
    );
  }
}

class _ComicInspectorTagGroup extends StatelessWidget {
  const _ComicInspectorTagGroup({
    required this.label,
    required this.values,
    this.onValueTap,
  });

  final String label;
  final List<String> values;
  final ValueChanged<String>? onValueTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: palette.textMuted,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in values)
              _ComicInspectorTag(
                value: value,
                onTap: onValueTap == null ? null : () => onValueTap!(value),
              ),
          ],
        ),
      ],
    );
  }
}

class _ComicInspectorTag extends StatelessWidget {
  const _ComicInspectorTag({required this.value, this.onTap});

  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final chip = DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel.withValues(alpha: palette.isDark ? 0.88 : 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.divider.withValues(alpha: 0.95)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
        borderRadius: BorderRadius.circular(999),
        child: chip,
      ),
    );
  }
}