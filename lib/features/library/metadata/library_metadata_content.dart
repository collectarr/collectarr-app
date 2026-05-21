import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/library_display.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class LibraryMetadataPresentation {
  const LibraryMetadataPresentation({
    required this.identityFacts,
    required this.contextFacts,
    required this.creators,
    required this.characters,
    required this.storyArcs,
    required this.genres,
  });

  final List<LibraryInspectorFactData> identityFacts;
  final List<LibraryInspectorFactData> contextFacts;
  final List<Map<String, dynamic>> creators;
  final List<String> characters;
  final List<String> storyArcs;
  final List<String> genres;

  List<LibraryInspectorFactData> get allFacts => [
        ...identityFacts,
        ...contextFacts,
      ];

  bool get hasCredits =>
      creators.isNotEmpty || characters.isNotEmpty || storyArcs.isNotEmpty;
}

LibraryMetadataPresentation buildLibraryMetadataPresentation({
  required LibraryTypeConfig type,
  required LibraryWorkspaceEntry entry,
  ValueChanged<String>? onFilterByValue,
  bool includeIdentityFacts = false,
}) {
  final labels = libraryMediaFieldLabels(type);

  VoidCallback? tapFor(String? value) {
    if (onFilterByValue == null || value == null || value.trim().isEmpty) {
      return null;
    }
    return () => onFilterByValue(value.trim());
  }

  return LibraryMetadataPresentation(
    identityFacts: [
      if (includeIdentityFacts) ...[
        LibraryInspectorFactData('Kind', type.singularLabel),
        LibraryInspectorFactData('ID', entry.id),
        LibraryInspectorFactData('Title', entry.title),
      ],
      if (entry.seriesTitle != null)
        LibraryInspectorFactData(
          'Series',
          entry.seriesTitle!,
          onTap: tapFor(entry.seriesTitle),
        ),
      if (entry.volumeName != null || entry.volumeNumber != null)
        LibraryInspectorFactData(
          'Volume',
          entry.volumeName ?? 'Vol. ${entry.volumeNumber}',
        ),
      if (entry.seasonNumber != null)
        LibraryInspectorFactData(
          'Season',
          'Season ${entry.seasonNumber}',
        ),
      if (entry.episodeNumber != null)
        LibraryInspectorFactData(
          'Episode',
          'Ep. ${entry.episodeNumber}',
        ),
      LibraryInspectorFactData(
        labels.number,
        genericLibraryDash(entry.itemNumber),
        onTap: tapFor(entry.itemNumber),
      ),
      LibraryInspectorFactData(
        labels.variant,
        genericLibraryDash(entry.variant),
        onTap: tapFor(entry.variant),
      ),
      LibraryInspectorFactData(
        labels.barcode,
        genericLibraryDash(entry.barcode),
      ),
    ],
    contextFacts: [
      LibraryInspectorFactData(
        labels.publisher,
        genericLibraryDash(entry.publisher),
        onTap: tapFor(entry.publisher),
      ),
      LibraryInspectorFactData(
        'Released',
        genericLibraryDash(
          formatNullableDate(entry.releaseDate) ?? entry.releaseYear?.toString(),
        ),
      ),
      if (entry.pageCount != null)
        LibraryInspectorFactData(
          'Pages',
          entry.pageCount.toString(),
        ),
      if (entry.coverPriceCents != null)
        LibraryInspectorFactData(
          'Cover Price',
          formatMoney(entry.coverPriceCents, entry.catalogCurrency),
        ),
      if (entry.imprint != null)
        LibraryInspectorFactData(
          'Imprint',
          entry.imprint!,
          onTap: tapFor(entry.imprint),
        ),
      if (entry.seriesGroup != null)
        LibraryInspectorFactData(
          'Series Group',
          entry.seriesGroup!,
          onTap: tapFor(entry.seriesGroup),
        ),
      if (entry.subtitle != null)
        LibraryInspectorFactData('Subtitle', entry.subtitle!),
      if (entry.country != null)
        LibraryInspectorFactData('Country', entry.country!),
      if (entry.language != null)
        LibraryInspectorFactData('Language', entry.language!),
      if (entry.ageRating != null)
        LibraryInspectorFactData('Age Rating', entry.ageRating!),
      LibraryInspectorFactData(
        'Cover',
        entry.hasMissingCover ? 'Missing' : 'Ready',
      ),
      LibraryInspectorFactData(
        'Metadata',
        entry.hasMissingMetadata ? 'Missing' : 'Ready',
      ),
    ],
    creators: entry.creators ?? const <Map<String, dynamic>>[],
    characters: entry.characters ?? const <String>[],
    storyArcs: entry.storyArcs ?? const <String>[],
    genres: entry.genres ?? const <String>[],
  );
}

class LibraryMetadataContent extends StatelessWidget {
  const LibraryMetadataContent({
    super.key,
    required this.type,
    required this.entry,
    this.onFilterByValue,
    this.includeIdentityFacts = false,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final ValueChanged<String>? onFilterByValue;
  final bool includeIdentityFacts;

  VoidCallback? _tapFor(String? value) {
    if (onFilterByValue == null || value == null || value.trim().isEmpty) {
      return null;
    }
    return () => onFilterByValue!(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final presentation = buildLibraryMetadataPresentation(
      type: type,
      entry: entry,
      onFilterByValue: onFilterByValue,
      includeIdentityFacts: includeIdentityFacts,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LibraryInspectorFactGrid(facts: presentation.allFacts),
        if (presentation.creators.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryMetadataCreditsList(
            title: 'Creators',
            credits: presentation.creators,
            onValueTap: onFilterByValue,
          ),
        ],
        if (presentation.characters.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorChipWrap(
            label: 'Characters',
            values: presentation.characters,
            onValueTap: onFilterByValue,
          ),
        ],
        if (presentation.storyArcs.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorChipWrap(
            label: 'Story Arcs',
            values: presentation.storyArcs,
            onValueTap: onFilterByValue,
          ),
        ],
        if (presentation.genres.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            presentation.genres.join(', '),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }
}

class LibraryMetadataCreditsList extends StatelessWidget {
  const LibraryMetadataCreditsList({
    super.key,
    required this.title,
    required this.credits,
    this.onValueTap,
  });

  final String title;
  final List<Map<String, dynamic>> credits;
  final ValueChanged<String>? onValueTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.labelSmall?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 4),
        for (final credit in credits)
          _LibraryMetadataCreditRow(
            credit: credit,
            onTap: onValueTap == null ||
                    (credit['name']?.toString().trim().isEmpty ?? true)
                ? null
                : () => onValueTap!(credit['name'].toString().trim()),
          ),
      ],
    );
  }
}

class _LibraryMetadataCreditRow extends StatelessWidget {
  const _LibraryMetadataCreditRow({
    required this.credit,
    this.onTap,
  });

  final Map<String, dynamic> credit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final content = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: credit['name']?.toString() ?? '?',
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              decoration: onTap == null ? null : TextDecoration.underline,
              decorationColor: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          if (credit['role'] != null)
            TextSpan(
              text: '  ${credit['role']}',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white54,
              ),
            ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(4),
              child: content,
            ),
    );
  }
}