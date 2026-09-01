import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter/material.dart';

List<Widget> buildLibraryDetailCatalogSections({
  required BuildContext context,
  required LibraryKindRuntime type,
  required LibraryProjectionRuntime item,
  required Color accent,
  ValueChanged<String>? onFilterByValue,
}) {
  return type.presentation.builder.buildDetailCatalogSections(
    context: context,
    singularLabel: type.identity.singularLabel,
    mediaFields: type.edit.mediaFields,
    releaseFields: type.edit.releaseFields,
    item: item,
    accent: accent,
    relationCapability: type.relations,
    onFilterByValue: onFilterByValue,
  );
}

class LibraryDetailMetadataSection extends StatelessWidget {
  const LibraryDetailMetadataSection({
    super.key,
    required this.type,
    required this.item,
    required this.accent,
    this.onFilterByValue,
  });

  final LibraryKindRuntime type;
  final LibraryProjectionRuntime item;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    return type.presentation.builder.buildDetailIdentitySection(
      context: context,
      singularLabel: type.identity.singularLabel,
      mediaFields: type.edit.mediaFields,
      releaseFields: type.edit.releaseFields,
      item: item,
      accent: accent,
      relationCapability: type.relations,
      onFilterByValue: onFilterByValue,
    );
  }
}

class LibraryDetailContextSection extends StatelessWidget {
  const LibraryDetailContextSection({
    super.key,
    required this.type,
    required this.item,
    required this.accent,
    this.onFilterByValue,
  });

  final LibraryKindRuntime type;
  final LibraryProjectionRuntime item;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    return type.presentation.builder.buildDetailContextSection(
      context: context,
      singularLabel: type.identity.singularLabel,
      mediaFields: type.edit.mediaFields,
      releaseFields: type.edit.releaseFields,
      item: item,
      accent: accent,
      onFilterByValue: onFilterByValue,
    );
  }
}

class LibraryDetailCreditsSection extends StatelessWidget {
  const LibraryDetailCreditsSection({
    super.key,
    required this.type,
    required this.item,
    required this.accent,
    this.onFilterByValue,
  });

  final LibraryKindRuntime type;
  final LibraryProjectionRuntime item;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    return type.presentation.builder.buildDetailCreditsSection(
      context: context,
      singularLabel: type.identity.singularLabel,
      mediaFields: type.edit.mediaFields,
      releaseFields: type.edit.releaseFields,
      item: item,
      accent: accent,
      onFilterByValue: onFilterByValue,
    );
  }
}

class LibraryDetailProvenanceSection extends StatelessWidget {
  const LibraryDetailProvenanceSection({
    super.key,
    required this.type,
    required this.item,
    required this.accent,
  });

  final LibraryKindRuntime type;
  final LibraryProjectionRuntime item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final sourceKind = _sourceKind(item.node.titleItemId);
    final defaultProvider = type.metadata.defaultSupportedOption(type.kind);

    return LibraryDetailSection(
      title: 'Metadata source & system IDs',
      accentColor: accent,
      children: [
        LibraryDetailFieldTable(
          fields: [
            LibraryDetailField(label: 'Item ID', value: item.node.titleItemId),
            LibraryDetailField(label: 'Source', value: sourceKind.label),
            if (defaultProvider != null)
              LibraryDetailField(
                  label: 'Metadata provider', value: defaultProvider.label),
            LibraryDetailField(
                label: 'Sync profile', value: type.identity.singularLabel),
          ],
        ),
      ],
    );
  }
}

class LibraryDetailMetadataHealthSection extends StatelessWidget {
  const LibraryDetailMetadataHealthSection({
    super.key,
    required this.type,
    required this.item,
    required this.accent,
    this.onFilterByValue,
  });

  final LibraryKindRuntime type;
  final LibraryProjectionRuntime item;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    final health = _buildMetadataHealth(type, item);
    return LibraryDetailSection(
      title: 'Metadata health',
      accentColor: accent,
      children: [
        LibraryDetailFieldTable(
          fields: [
            LibraryDetailField(label: 'Score', value: '${health.score}/100'),
            LibraryDetailField(label: 'Status', value: health.label),
            LibraryDetailField(
                label: 'Missing signals',
                value: health.missingSignals.length.toString()),
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
          LibraryDetailChipGroupWidget(
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
    required this.item,
    required this.accent,
  });

  final LibraryProjectionRuntime item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final dto = item.dto;
    return LibraryDetailSection(
      title: 'Cover status',
      accentColor: accent,
      children: [
        LibraryDetailFieldTable(
          fields: [
            LibraryDetailField(
                label: 'Display',
                value: dto.coverImageUrl == null || dto.coverImageUrl!.isEmpty
                    ? 'Generated fallback'
                    : 'External URL'),
            LibraryDetailField(
                label: 'Cover URL',
                value: dto.coverImageUrl == null || dto.coverImageUrl!.isEmpty
                    ? '-'
                    : 'Available'),
          ],
        ),
        if (dto.coverImageUrl != null) ...[
          const SizedBox(height: 8),
          SelectableText(
            'cover: ${dto.coverImageUrl}',
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

  final LibraryKindRuntime type;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    final supportedProviders =
        type.metadata.supportedProvidersForKind(type.kind);
    final defaultProvider = type.metadata.defaultSupportedOption(type.kind);
    final defaultProviderId =
        defaultProvider?.id ?? type.metadata.defaultProviderId;
    return LibraryDetailSection(
      title: 'Providers',
      accentColor: accent,
      children: [
        if (supportedProviders.isEmpty)
          const Text(
            'No providers are registered for this media type yet. Manual local records still work and will sync as local snapshots.',
          )
        else ...[
          LibraryDetailChipGroupWidget(
            values: [
              for (final provider in supportedProviders)
                provider.id == defaultProviderId
                    ? '${provider.label} default'
                    : provider.label,
            ],
            onValueTap: onFilterByValue,
          ),
          const SizedBox(height: 8),
          LibraryDetailFieldTable(
            fields: [
              LibraryDetailField(
                  label: 'Default provider',
                  value: type.metadata.providerLabel(defaultProviderId)),
              LibraryDetailField(
                  label: 'Provider count',
                  value: supportedProviders.length.toString()),
              LibraryDetailField(
                  label: 'API keys',
                  value: supportedProviders.any(
                    (provider) => provider.requiresApiKey,
                  )
                      ? 'Some required'
                      : 'Not required'),
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
          for (final provider in supportedProviders)
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
      _MetadataSourceKind.providerPlaceholder =>
        'Provider placeholder snapshot',
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
  LibraryKindRuntime type,
  LibraryProjectionRuntime item,
) {
  var score = 0;
  final missingSignals = <String>[];
  final metadata = type.presentation.builder.buildMetadataPresentation(
    singularLabel: type.identity.singularLabel,
    mediaFields: type.edit.mediaFields,
    releaseFields: type.edit.releaseFields,
    item: item,
    includeIdentityFacts: true,
    tapFor: (_) => null,
  );
  final seriesLabel = type.presentation.filterLabels.labelFor(
    'series',
    fallback: 'Series',
  );

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

  final dto = item.dto;
  final adapter = dto is WorkspaceDtoAdapter ? dto : null;
  final catalogItem = item.source.catalogItem;
  addSignal(
    present: dto.coverImageUrl != null && dto.coverImageUrl!.isNotEmpty,
    weight: 18,
    missingLabel: 'Cover image',
  );
  addSignal(
    present: catalogItem?.synopsis?.trim().isNotEmpty ?? false,
    weight: 16,
    missingLabel: 'Synopsis',
  );
  addSignal(
    present: adapter?.publisher?.trim().isNotEmpty ?? false,
    weight: 10,
    missingLabel: 'Publisher',
  );
  addSignal(
    present: adapter?.releaseDate != null,
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
    present: adapter?.itemNumber?.trim().isNotEmpty ?? false,
    weight: 6,
    missingLabel: 'Item number',
  );
  for (final entry in metadata.sections.entries) {
    addSignal(
      present: entry.value.values.isNotEmpty,
      weight: entry.value.completenessWeight,
      missingLabel: metadata.labels.labelFor(entry.key),
    );
  }
  addSignal(
    present: !(adapter?.publisher == null || dto.coverImageUrl == null),
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
    'Strong' =>
      'This record has enough structured metadata to browse and compare confidently.',
    'Usable' =>
      'The core metadata is present, but a refresh would still add useful context.',
    'Thin' =>
      'This record is browsable, but several discovery and quality signals are still missing.',
    _ =>
      'This record needs a metadata refresh before it will feel trustworthy in the library.',
  };

  return _MetadataHealth(
    score: score,
    label: label,
    summary: summary,
    missingSignals: missingSignals,
  );
}
