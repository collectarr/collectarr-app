import 'package:collectarr_app/ui/clz_style.dart';
import 'package:collectarr_app/features/comics/shelf/comics_shelf_helpers.dart';
import 'package:collectarr_app/features/library/generic/generic_library_display.dart';
import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class GenericDetailMetadataSection extends StatelessWidget {
  const GenericDetailMetadataSection({
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
    final labels = libraryMediaFieldLabels(type);
    return LibraryInspectorSection(
      title: 'Catalog metadata',
      accentColor: accent,
      children: [
        LibraryInspectorFactGrid(
          facts: [
            LibraryInspectorFactData('Kind', type.singularLabel),
            LibraryInspectorFactData('ID', entry.id),
            LibraryInspectorFactData('Title', entry.title),
            LibraryInspectorFactData(
              labels.number,
              genericLibraryDash(entry.itemNumber),
            ),
            LibraryInspectorFactData(
              labels.publisher,
              genericLibraryDash(entry.publisher),
            ),
            LibraryInspectorFactData(
              'Released',
              genericLibraryDash(
                formatNullableComicDate(entry.releaseDate) ??
                    entry.releaseYear?.toString(),
              ),
            ),
            LibraryInspectorFactData(
              labels.variant,
              genericLibraryDash(entry.variant),
            ),
            LibraryInspectorFactData(
              labels.barcode,
              genericLibraryDash(entry.barcode),
            ),
          ],
        ),
      ],
    );
  }
}

class GenericDetailCoverStatusSection extends StatelessWidget {
  const GenericDetailCoverStatusSection({
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

class GenericDetailProviderSection extends StatelessWidget {
  const GenericDetailProviderSection({
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
