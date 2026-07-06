import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/details/library_detail_inspector_compat.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';

List<Widget> buildLibraryDetailCatalogSections({
  required BuildContext context,
  required LibraryTypeConfig type,
  required LibraryWorkspaceEntry entry,
  required Color accent,
  ValueChanged<String>? onFilterByValue,
}) {
  return type.presentation.builder.buildDetailCatalogSections(
    context: context,
    singularLabel: type.singularLabel,
    mediaFields: type.mediaFields,
    releaseFields: type.releaseFields,
    entry: entry,
    accent: accent,
    onFilterByValue: onFilterByValue,
  );
}

class LibraryDetailMetadataSection extends StatelessWidget {
  const LibraryDetailMetadataSection({
    super.key,
    required this.type,
    required this.entry,
    required this.accent,
    this.onFilterByValue,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    return type.presentation.builder.buildDetailIdentitySection(
      context: context,
      singularLabel: type.singularLabel,
      mediaFields: type.mediaFields,
      releaseFields: type.releaseFields,
      entry: entry,
      accent: accent,
      onFilterByValue: onFilterByValue,
    );
  }
}

class LibraryDetailContextSection extends StatelessWidget {
  const LibraryDetailContextSection({
    super.key,
    required this.type,
    required this.entry,
    required this.accent,
    this.onFilterByValue,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    return type.presentation.builder.buildDetailContextSection(
      context: context,
      singularLabel: type.singularLabel,
      mediaFields: type.mediaFields,
      releaseFields: type.releaseFields,
      entry: entry,
      accent: accent,
      onFilterByValue: onFilterByValue,
    );
  }
}

class LibraryDetailCreditsSection extends StatelessWidget {
  const LibraryDetailCreditsSection({
    super.key,
    required this.type,
    required this.entry,
    required this.accent,
    this.onFilterByValue,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    return type.presentation.builder.buildDetailCreditsSection(
      context: context,
      singularLabel: type.singularLabel,
      mediaFields: type.mediaFields,
      releaseFields: type.releaseFields,
      entry: entry,
      accent: accent,
      onFilterByValue: onFilterByValue,
    );
  }
}

class LibraryDetailProvenanceSection extends StatelessWidget {
  const LibraryDetailProvenanceSection({
    super.key,
    required this.type,
    required this.entry,
    required this.accent,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final sourceKind = _sourceKind(entry.id);
    final defaultProvider = type.defaultSupportedMetadataProviderOption;
    return LibraryInspectorSection(
      title: 'Metadata provenance',
      accentColor: accent,
      children: [
        LibraryInspectorFactGrid(
          facts: [
            LibraryInspectorFactData('Source', sourceKind.label),
            LibraryInspectorFactData(
              'Snapshot updated',
              formatNullableDate(entry.updatedAt) ?? '-',
            ),
            LibraryInspectorFactData(
              'Metadata state',
              entry.hasMissingMetadata ? 'Incomplete' : 'Ready',
            ),
            LibraryInspectorFactData(
              'Cover state',
              entry.hasMissingCover ? 'Missing' : 'Ready',
            ),
            LibraryInspectorFactData(
              'Image delivery',
              entry.displayCoverUrl == null
                  ? 'Generated fallback'
                  : 'External provider URL',
            ),
            LibraryInspectorFactData(
              'Preferred provider',
              defaultProvider?.label ??
                  type.metadataProviderLabel(
                    type.defaultSupportedMetadataProvider,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          sourceKind.helpText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: appPalette(context).textMuted,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class LibraryDetailMetadataHealthSection extends StatelessWidget {
  const LibraryDetailMetadataHealthSection({
    super.key,
    required this.type,
    required this.entry,
    required this.accent,
    this.onFilterByValue,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    final health = _buildMetadataHealth(type, entry);
    return LibraryInspectorSection(
      title: 'Metadata health',
      accentColor: accent,
      children: [
        LibraryInspectorFactGrid(
          facts: [
            LibraryInspectorFactData('Score', '${health.score}/100'),
            LibraryInspectorFactData('Status', health.label),
            LibraryInspectorFactData(
              'Missing signals',
              health.missingSignals.length.toString(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          health.summary,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: appPalette(context).textMuted,
                fontWeight: FontWeight.w700,
              ),
        ),
        if (health.missingSignals.isNotEmpty) ...[
          const SizedBox(height: 10),
          LibraryInspectorChipWrap(
            label: 'Needs attention',
            values: health.missingSignals,
            onValueTap: onFilterByValue,
          ),
        ],
      ],
    );
  }
}

class LibraryDetailCoverStatusSection extends StatelessWidget {
  const LibraryDetailCoverStatusSection({
    super.key,
    required this.entry,
    required this.accent,
  });

  final LibraryWorkspaceEntry entry;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LibraryInspectorSection(
      title: 'Cover status',
      accentColor: accent,
      children: [
        LibraryInspectorFactGrid(
          facts: [
            LibraryInspectorFactData(
              'Display',
              entry.displayCoverUrl == null
                  ? 'Generated fallback'
                  : 'External URL',
            ),
            LibraryInspectorFactData(
              'Cover URL',
              entry.coverImageUrl == null ? '-' : 'Available',
            ),
            LibraryInspectorFactData(
              'Thumbnail URL',
              entry.thumbnailImageUrl == null ? '-' : 'Available',
            ),
          ],
        ),
        if (entry.coverImageUrl != null || entry.thumbnailImageUrl != null) ...[
          const SizedBox(height: 8),
          SelectableText(
            [
              if (entry.coverImageUrl != null) 'cover: ${entry.coverImageUrl}',
              if (entry.thumbnailImageUrl != null)
                'thumb: ${entry.thumbnailImageUrl}',
            ].join('\n'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: appPalette(context).textMuted,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ],
    );
  }
}

class LibraryDetailProviderSection extends StatelessWidget {
  const LibraryDetailProviderSection({
    super.key,
    required this.type,
    required this.accent,
    this.onFilterByValue,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    return LibraryInspectorSection(
      title: 'Providers',
      accentColor: accent,
      children: [
        if (type.supportedMetadataProviders.isEmpty)
          const Text(
            'No providers are registered for this media type yet. Manual local records still work and will sync as local snapshots.',
          )
        else ...[
          LibraryInspectorChipWrap(
            values: [
              for (final provider in type.supportedMetadataProviders)
                provider.id == type.defaultSupportedMetadataProvider
                    ? '${provider.label} default'
                    : provider.label,
            ],
            onValueTap: onFilterByValue,
          ),
          const SizedBox(height: 8),
          LibraryInspectorFactGrid(
            facts: [
              LibraryInspectorFactData(
                'Default provider',
                type.metadataProviderLabel(
                  type.defaultSupportedMetadataProvider,
                ),
              ),
              LibraryInspectorFactData(
                'Provider count',
                type.supportedMetadataProviders.length.toString(),
              ),
              LibraryInspectorFactData(
                'API keys',
                type.supportedMetadataProviders.any(
                  (provider) => provider.requiresApiKey,
                )
                    ? 'Some required'
                    : 'Not required',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Provider search depends on Collectarr Core being reachable. Local collection data remains available offline.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appPalette(context).textMuted,
                  fontWeight: FontWeight.w700,
                ),
          ),
          for (final provider in type.supportedMetadataProviders)
            if (provider.usagePolicy != null) ...[
              const SizedBox(height: 8),
              Text(
                '${provider.label}: ${provider.usagePolicy!.summary}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: appPalette(context).textMuted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
        ],
      ],
    );
  }
}

enum _MetadataSourceKind {
  localSnapshot,
  providerPlaceholder,
}

extension on _MetadataSourceKind {
  String get label {
    return switch (this) {
      _MetadataSourceKind.localSnapshot => 'Collectarr Core catalog snapshot',
      _MetadataSourceKind.providerPlaceholder => 'Provider placeholder snapshot',
    };
  }

  String get helpText {
    return switch (this) {
      _MetadataSourceKind.localSnapshot =>
        'This item is being shown from the app\'s cached catalog snapshot. Metadata stays available offline until you refresh it from Collectarr Core.',
      _MetadataSourceKind.providerPlaceholder =>
        'This record started as a provider-side placeholder. Review and refresh it after full catalog metadata is available from Collectarr Core.',
    };
  }
}

_MetadataSourceKind _sourceKind(String entryId) {
  if (entryId.startsWith('provider:')) {
    return _MetadataSourceKind.providerPlaceholder;
  }
  return _MetadataSourceKind.localSnapshot;
}

class _MetadataHealth {
  const _MetadataHealth({
    required this.score,
    required this.label,
    required this.summary,
    required this.missingSignals,
  });

  final int score;
  final String label;
  final String summary;
  final List<String> missingSignals;
}

_MetadataHealth _buildMetadataHealth(
  LibraryTypeConfig type,
  LibraryWorkspaceEntry entry,
) {
  var score = 0;
  final missingSignals = <String>[];
  final metadata = type.presentation.builder.buildMetadataPresentation(
    singularLabel: type.singularLabel,
    mediaFields: type.mediaFields,
    releaseFields: type.releaseFields,
    entry: entry,
    includeIdentityFacts: true,
    tapFor: (_) => null,
  );
  final seriesLabel = type.presentation.filterLabels.series;

  void addSignal({
    required bool present,
    required int weight,
    required String missingLabel,
  }) {
    if (present) {
      score += weight;
    } else {
      missingSignals.add(missingLabel);
    }
  }

  addSignal(
    present: entry.displayCoverUrl != null,
    weight: 18,
    missingLabel: 'Cover image',
  );
  addSignal(
    present: entry.synopsis?.trim().isNotEmpty ?? false,
    weight: 16,
    missingLabel: 'Synopsis',
  );
  addSignal(
    present: entry.publisher?.trim().isNotEmpty ?? false,
    weight: 10,
    missingLabel: 'Publisher',
  );
  addSignal(
    present: entry.releaseDate != null || entry.releaseYear != null,
    weight: 10,
    missingLabel: 'Release date',
  );
  addSignal(
    present: metadata.identityFacts.any(
      (fact) => fact.label == seriesLabel && fact.value.trim().isNotEmpty,
    ),
    weight: 10,
    missingLabel: 'Series',
  );
  addSignal(
    present: entry.itemNumber?.trim().isNotEmpty ?? false,
    weight: 6,
    missingLabel: 'Item number',
  );
  addSignal(
    present: metadata.creators.isNotEmpty,
    weight: 12,
    missingLabel: metadata.labels.creators,
  );
  addSignal(
    present: metadata.characters.isNotEmpty,
    weight: 6,
    missingLabel: metadata.labels.characters,
  );
  addSignal(
    present: metadata.storyArcs.isNotEmpty,
    weight: 4,
    missingLabel: metadata.labels.storyArcsInline,
  );
  addSignal(
    present: metadata.genres.isNotEmpty,
    weight: 4,
    missingLabel: metadata.labels.genres,
  );
  addSignal(
    present: !(entry.hasMissingMetadata || entry.hasMissingCover),
    weight: 4,
    missingLabel: 'Catalog refresh',
  );

  final label = switch (score) {
    >= 85 => 'Strong',
    >= 65 => 'Usable',
    >= 45 => 'Thin',
    _ => 'Needs work',
  };
  final summary = switch (label) {
    'Strong' => 'This record has enough structured metadata to browse and compare confidently.',
    'Usable' => 'The core metadata is present, but a refresh would still add useful context.',
    'Thin' => 'This record is browsable, but several discovery and quality signals are still missing.',
    _ => 'This record needs a metadata refresh before it will feel trustworthy in the library.',
  };

  return _MetadataHealth(
    score: score,
    label: label,
    summary: summary,
    missingSignals: missingSignals,
  );
}
