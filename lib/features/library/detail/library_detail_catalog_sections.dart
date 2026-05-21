import 'package:collectarr_app/ui/clz_style.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_content.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

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
    final presentation = buildLibraryMetadataPresentation(
      type: type,
      entry: entry,
      onFilterByValue: onFilterByValue,
      includeIdentityFacts: true,
    );
    return LibraryInspectorSection(
      title: 'Catalog identity',
      accentColor: accent,
      children: [
        LibraryInspectorFactGrid(facts: presentation.identityFacts),
      ],
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
    final presentation = buildLibraryMetadataPresentation(
      type: type,
      entry: entry,
      onFilterByValue: onFilterByValue,
    );
    return LibraryInspectorSection(
      title: 'Catalog context',
      accentColor: accent,
      children: [
        LibraryInspectorFactGrid(facts: presentation.contextFacts),
        if (presentation.genres.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorChipWrap(
            label: 'Genres',
            values: presentation.genres,
            onValueTap: onFilterByValue,
          ),
        ],
      ],
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
    final presentation = buildLibraryMetadataPresentation(
      type: type,
      entry: entry,
      onFilterByValue: onFilterByValue,
    );
    if (!presentation.hasCredits) {
      return const SizedBox.shrink();
    }
    return LibraryInspectorSection(
      title: 'Credits & Discovery',
      accentColor: accent,
      children: [
        if (presentation.creators.isNotEmpty)
          LibraryMetadataCreditsList(
            title: 'Creators',
            credits: presentation.creators,
            onValueTap: onFilterByValue,
          ),
        if (presentation.characters.isNotEmpty) ...[
          if (presentation.creators.isNotEmpty) const SizedBox(height: 8),
          LibraryInspectorChipWrap(
            label: 'Characters',
            values: presentation.characters,
            onValueTap: onFilterByValue,
          ),
        ],
        if (presentation.storyArcs.isNotEmpty) ...[
          if (presentation.creators.isNotEmpty ||
              presentation.characters.isNotEmpty)
            const SizedBox(height: 8),
          LibraryInspectorChipWrap(
            label: 'Story Arcs',
            values: presentation.storyArcs,
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
                  color: kClzTextMuted,
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
  });

  final LibraryTypeConfig type;
  final Color accent;

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
                  color: kClzTextMuted,
                  fontWeight: FontWeight.w700,
                ),
          ),
          for (final provider in type.supportedMetadataProviders)
            if (provider.usagePolicy != null) ...[
              const SizedBox(height: 8),
              Text(
                '${provider.label}: ${provider.usagePolicy!.summary}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kClzTextMuted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
        ],
      ],
    );
  }
}
