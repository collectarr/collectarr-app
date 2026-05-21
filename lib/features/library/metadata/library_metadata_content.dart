import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/library_display.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

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
    final labels = libraryMediaFieldLabels(type);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LibraryInspectorFactGrid(facts: _facts(labels)),
        if (entry.creators != null && entry.creators!.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryMetadataCreditsList(
            title: 'Creators',
            credits: entry.creators!,
          ),
        ],
        if (entry.characters != null && entry.characters!.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorChipWrap(
            label: 'Characters',
            values: entry.characters!,
          ),
        ],
        if (entry.storyArcs != null && entry.storyArcs!.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorChipWrap(
            label: 'Story Arcs',
            values: entry.storyArcs!,
          ),
        ],
        if (entry.genres != null && entry.genres!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            entry.genres!.join(', '),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }

  List<LibraryInspectorFactData> _facts(LibraryMediaFieldLabels labels) {
    return [
      if (includeIdentityFacts) ...[
        LibraryInspectorFactData('Kind', type.singularLabel),
        LibraryInspectorFactData('ID', entry.id),
        LibraryInspectorFactData('Title', entry.title),
      ],
      if (entry.seriesTitle != null)
        LibraryInspectorFactData(
          'Series',
          entry.seriesTitle!,
          onTap: _tapFor(entry.seriesTitle),
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
        labels.publisher,
        genericLibraryDash(entry.publisher),
        onTap: _tapFor(entry.publisher),
      ),
      LibraryInspectorFactData(
        'Released',
        genericLibraryDash(
          formatNullableDate(entry.releaseDate) ?? entry.releaseYear?.toString(),
        ),
      ),
      LibraryInspectorFactData(
        labels.number,
        genericLibraryDash(entry.itemNumber),
        onTap: _tapFor(entry.itemNumber),
      ),
      LibraryInspectorFactData(
        labels.variant,
        genericLibraryDash(entry.variant),
        onTap: _tapFor(entry.variant),
      ),
      LibraryInspectorFactData(
        labels.barcode,
        genericLibraryDash(entry.barcode),
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
          onTap: _tapFor(entry.imprint),
        ),
      if (entry.seriesGroup != null)
        LibraryInspectorFactData(
          'Series Group',
          entry.seriesGroup!,
          onTap: _tapFor(entry.seriesGroup),
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
    ];
  }
}

class LibraryMetadataCreditsList extends StatelessWidget {
  const LibraryMetadataCreditsList({
    super.key,
    required this.title,
    required this.credits,
  });

  final String title;
  final List<Map<String, dynamic>> credits;

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
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: credit['name']?.toString() ?? '?',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
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
            ),
          ),
      ],
    );
  }
}