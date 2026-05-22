import 'package:collectarr_app/features/library/generic/library_display.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_media_sections.dart';
import 'package:collectarr_app/features/library/seasons_section.dart';
import 'package:collectarr_app/features/library/volumes_section.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class LibraryMediaFieldLabels {
  const LibraryMediaFieldLabels({
    required this.number,
    required this.publisher,
    required this.variant,
    required this.barcode,
  });

  final String number;
  final String publisher;
  final String variant;
  final String barcode;
}

class LibraryMediaSearchFieldLabels {
  const LibraryMediaSearchFieldLabels({
    required this.queryHint,
    required this.emptySearchMessage,
    required this.seriesHint,
    required this.numberHint,
    required this.publisherHint,
  });

  final String queryHint;
  final String emptySearchMessage;
  final String seriesHint;
  final String numberHint;
  final String publisherHint;
}

class LibraryMediaFilterLabels {
  const LibraryMediaFilterLabels({
    required this.series,
    required this.anySeries,
    required this.publisher,
    required this.anyPublisher,
    this.year = 'Year',
    this.anyYear = 'Any year',
  });

  final String series;
  final String anySeries;
  final String publisher;
  final String anyPublisher;
  final String year;
  final String anyYear;
}

class LibraryMediaGroupLabels {
  const LibraryMediaGroupLabels({
    required this.series,
    required this.seriesPlural,
    required this.unknownSeries,
    required this.publisher,
    required this.publisherPlural,
    required this.unknownPublisher,
  });

  final String series;
  final String seriesPlural;
  final String unknownSeries;
  final String publisher;
  final String publisherPlural;
  final String unknownPublisher;
}

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

typedef LibraryMetadataFactTapResolver = VoidCallback? Function(String? value);
typedef LibraryMetadataPresentationBuilder = LibraryMetadataPresentation
    Function({
      required String singularLabel,
      required LibraryMediaFieldLabels labels,
      required LibraryWorkspaceEntry entry,
      required bool includeIdentityFacts,
      required LibraryMetadataFactTapResolver tapFor,
    });
typedef LibraryInspectorSupplementalSectionsBuilder = List<Widget> Function({
  required BuildContext context,
  required LibraryWorkspaceEntry entry,
  required Color accent,
});

class LibraryMediaPresentation {
  const LibraryMediaPresentation({
    required this.fieldLabels,
    required this.searchFieldLabels,
    required this.filterLabels,
    required this.groupLabels,
    this.metadataBuilder = buildDefaultMetadataPresentation,
    this.inspectorSectionsBuilder = buildNoSupplementalInspectorSections,
    this.groupModes = const [
      LibraryGroupMode.series,
      LibraryGroupMode.title,
      LibraryGroupMode.publisher,
      LibraryGroupMode.year,
      LibraryGroupMode.ownership,
    ],
  });

  final LibraryMediaFieldLabels fieldLabels;
  final LibraryMediaSearchFieldLabels searchFieldLabels;
  final LibraryMediaFilterLabels filterLabels;
  final LibraryMediaGroupLabels groupLabels;
  final LibraryMetadataPresentationBuilder metadataBuilder;
  final LibraryInspectorSupplementalSectionsBuilder inspectorSectionsBuilder;
  final List<LibraryGroupMode> groupModes;
}

const genericLibraryMediaPresentation = LibraryMediaPresentation(
  fieldLabels: LibraryMediaFieldLabels(
    number: 'No. / Vol.',
    publisher: 'Publisher / Studio / Creator',
    variant: 'Edition / Variant / Format',
    barcode: 'Barcode / UPC / ISBN',
  ),
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'No. / Vol....',
    publisherHint: 'Publisher / Studio / Creator...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Publisher',
    anyPublisher: 'Any publisher',
  ),
  groupLabels: LibraryMediaGroupLabels(
    series: 'Series',
    seriesPlural: 'Series',
    unknownSeries: 'Unknown series',
    publisher: 'Publisher',
    publisherPlural: 'Publishers',
    unknownPublisher: 'Unknown publisher',
  ),
);

const comicsLibraryMediaPresentation = LibraryMediaPresentation(
  fieldLabels: LibraryMediaFieldLabels(
    number: 'No. / Vol.',
    publisher: 'Publisher / Studio / Creator',
    variant: 'Edition / Variant / Format',
    barcode: 'Barcode / UPC / ISBN',
  ),
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'No. / Vol....',
    publisherHint: 'Publisher / Studio / Creator...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Publisher',
    anyPublisher: 'Any publisher',
  ),
  groupLabels: LibraryMediaGroupLabels(
    series: 'Series',
    seriesPlural: 'Series',
    unknownSeries: 'Unknown series',
    publisher: 'Publisher',
    publisherPlural: 'Publishers',
    unknownPublisher: 'Unknown publisher',
  ),
  inspectorSectionsBuilder: buildSummaryInspectorSections,
  groupModes: [
    LibraryGroupMode.series,
    LibraryGroupMode.storyArc,
    LibraryGroupMode.character,
    LibraryGroupMode.publisher,
    LibraryGroupMode.year,
    LibraryGroupMode.grade,
    LibraryGroupMode.condition,
    LibraryGroupMode.title,
    LibraryGroupMode.ownership,
  ],
);

const mangaLibraryMediaPresentation = LibraryMediaPresentation(
  fieldLabels: LibraryMediaFieldLabels(
    number: 'Volume / Chapter',
    publisher: 'Publisher',
    variant: 'Edition / Variant',
    barcode: 'ISBN / Barcode',
  ),
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Volume / Chapter...',
    publisherHint: 'Publisher...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Publisher',
    anyPublisher: 'Any publisher',
  ),
  groupLabels: LibraryMediaGroupLabels(
    series: 'Series',
    seriesPlural: 'Series',
    unknownSeries: 'Unknown series',
    publisher: 'Publisher',
    publisherPlural: 'Publishers',
    unknownPublisher: 'Unknown publisher',
  ),
  inspectorSectionsBuilder: buildVolumeSummaryInspectorSections,
  groupModes: [
    LibraryGroupMode.series,
    LibraryGroupMode.publisher,
    LibraryGroupMode.year,
    LibraryGroupMode.title,
    LibraryGroupMode.ownership,
  ],
);

const animeLibraryMediaPresentation = LibraryMediaPresentation(
  fieldLabels: LibraryMediaFieldLabels(
    number: 'Season / Volume',
    publisher: 'Studio / Publisher',
    variant: 'Format / Edition',
    barcode: 'UPC / Barcode',
  ),
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Season / Volume...',
    publisherHint: 'Studio / Publisher...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Studio / Publisher',
    anyPublisher: 'Any studio / publisher',
  ),
  groupLabels: LibraryMediaGroupLabels(
    series: 'Series',
    seriesPlural: 'Series',
    unknownSeries: 'Unknown series',
    publisher: 'Studio / Publisher',
    publisherPlural: 'Studios / Publishers',
    unknownPublisher: 'Unknown studio / publisher',
  ),
  metadataBuilder: buildVideoMetadataPresentation,
  inspectorSectionsBuilder: buildSeasonSummaryInspectorSections,
  groupModes: [
    LibraryGroupMode.series,
    LibraryGroupMode.year,
    LibraryGroupMode.publisher,
    LibraryGroupMode.title,
    LibraryGroupMode.ownership,
  ],
);

const booksLibraryMediaPresentation = LibraryMediaPresentation(
  fieldLabels: LibraryMediaFieldLabels(
    number: 'Volume',
    publisher: 'Publisher',
    variant: 'Edition / Binding',
    barcode: 'ISBN / Barcode',
  ),
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Volume...',
    publisherHint: 'Publisher...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Publisher',
    anyPublisher: 'Any publisher',
  ),
  groupLabels: LibraryMediaGroupLabels(
    series: 'Series',
    seriesPlural: 'Series',
    unknownSeries: 'Unknown series',
    publisher: 'Publisher',
    publisherPlural: 'Publishers',
    unknownPublisher: 'Unknown publisher',
  ),
  inspectorSectionsBuilder: buildVolumeSummaryInspectorSections,
  groupModes: [
    LibraryGroupMode.publisher,
    LibraryGroupMode.series,
    LibraryGroupMode.year,
    LibraryGroupMode.title,
    LibraryGroupMode.ownership,
  ],
);

const gamesLibraryMediaPresentation = LibraryMediaPresentation(
  fieldLabels: LibraryMediaFieldLabels(
    number: 'Version',
    publisher: 'Publisher / Studio',
    variant: 'Platform / Edition',
    barcode: 'UPC / Barcode',
  ),
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Version...',
    publisherHint: 'Publisher / Studio...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Publisher / Studio',
    anyPublisher: 'Any publisher / studio',
  ),
  groupLabels: LibraryMediaGroupLabels(
    series: 'Series',
    seriesPlural: 'Series',
    unknownSeries: 'Unknown series',
    publisher: 'Publisher / Studio',
    publisherPlural: 'Publishers / Studios',
    unknownPublisher: 'Unknown publisher / studio',
  ),
  metadataBuilder: buildGameMetadataPresentation,
  groupModes: [
    LibraryGroupMode.publisher,
    LibraryGroupMode.series,
    LibraryGroupMode.year,
    LibraryGroupMode.title,
    LibraryGroupMode.ownership,
  ],
);

const boardGamesLibraryMediaPresentation = LibraryMediaPresentation(
  fieldLabels: LibraryMediaFieldLabels(
    number: 'Edition',
    publisher: 'Publisher / Designer',
    variant: 'Expansion / Edition',
    barcode: 'Barcode',
  ),
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Edition...',
    publisherHint: 'Publisher / Designer...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Publisher / Designer',
    anyPublisher: 'Any publisher / designer',
  ),
  groupLabels: LibraryMediaGroupLabels(
    series: 'Series',
    seriesPlural: 'Series',
    unknownSeries: 'Unknown series',
    publisher: 'Publisher / Designer',
    publisherPlural: 'Publishers / Designers',
    unknownPublisher: 'Unknown publisher / designer',
  ),
  groupModes: [
    LibraryGroupMode.publisher,
    LibraryGroupMode.series,
    LibraryGroupMode.year,
    LibraryGroupMode.title,
    LibraryGroupMode.ownership,
  ],
);

const moviesLibraryMediaPresentation = LibraryMediaPresentation(
  fieldLabels: LibraryMediaFieldLabels(
    number: 'Edition no.',
    publisher: 'Studio',
    variant: 'Format / Edition',
    barcode: 'UPC / Barcode',
  ),
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Edition no....',
    publisherHint: 'Studio...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Studio',
    anyPublisher: 'Any studio',
  ),
  groupLabels: LibraryMediaGroupLabels(
    series: 'Series',
    seriesPlural: 'Series',
    unknownSeries: 'Unknown series',
    publisher: 'Studio',
    publisherPlural: 'Studios',
    unknownPublisher: 'Unknown studio',
  ),
  metadataBuilder: buildVideoMetadataPresentation,
  inspectorSectionsBuilder: buildSummaryInspectorSections,
  groupModes: [
    LibraryGroupMode.year,
    LibraryGroupMode.series,
    LibraryGroupMode.publisher,
    LibraryGroupMode.title,
    LibraryGroupMode.ownership,
  ],
);

const musicLibraryMediaPresentation = LibraryMediaPresentation(
  fieldLabels: LibraryMediaFieldLabels(
    number: 'Disc / Volume',
    publisher: 'Label / Artist',
    variant: 'Format / Edition',
    barcode: 'Barcode / Catalog no.',
  ),
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, artist, creator, or keyword...',
    emptySearchMessage: 'Enter a title, artist, creator, or keyword.',
    seriesHint: 'Artist...',
    numberHint: 'Album / Release...',
    publisherHint: 'Label...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Artist',
    anySeries: 'Any artist',
    publisher: 'Label',
    anyPublisher: 'Any label',
  ),
  groupLabels: LibraryMediaGroupLabels(
    series: 'Artist',
    seriesPlural: 'Artists',
    unknownSeries: 'Unknown artist',
    publisher: 'Label',
    publisherPlural: 'Labels',
    unknownPublisher: 'Unknown label',
  ),
  metadataBuilder: buildMusicMetadataPresentation,
  inspectorSectionsBuilder: buildMusicInspectorSections,
  groupModes: [
    LibraryGroupMode.series,
    LibraryGroupMode.publisher,
    LibraryGroupMode.year,
    LibraryGroupMode.title,
    LibraryGroupMode.ownership,
  ],
);

const tvLibraryMediaPresentation = LibraryMediaPresentation(
  fieldLabels: LibraryMediaFieldLabels(
    number: 'Season / Volume',
    publisher: 'Network / Studio',
    variant: 'Format / Edition',
    barcode: 'UPC / Barcode',
  ),
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Season / Volume...',
    publisherHint: 'Network / Studio...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Network / Studio',
    anyPublisher: 'Any network / studio',
  ),
  groupLabels: LibraryMediaGroupLabels(
    series: 'Series',
    seriesPlural: 'Series',
    unknownSeries: 'Unknown series',
    publisher: 'Network / Studio',
    publisherPlural: 'Networks / Studios',
    unknownPublisher: 'Unknown network / studio',
  ),
  metadataBuilder: buildVideoMetadataPresentation,
  inspectorSectionsBuilder: buildSeasonSummaryInspectorSections,
  groupModes: [
    LibraryGroupMode.series,
    LibraryGroupMode.year,
    LibraryGroupMode.publisher,
    LibraryGroupMode.title,
    LibraryGroupMode.ownership,
  ],
);

LibraryMetadataPresentation buildDefaultMetadataPresentation({
  required String singularLabel,
  required LibraryMediaFieldLabels labels,
  required LibraryWorkspaceEntry entry,
  required bool includeIdentityFacts,
  required LibraryMetadataFactTapResolver tapFor,
}) {
  final hasVolume = entry.volumeName != null || entry.volumeNumber != null;
  final hasSeason = entry.seasonNumber != null;
  final hasEpisode = entry.episodeNumber != null;
  return LibraryMetadataPresentation(
    identityFacts: [
      if (includeIdentityFacts) ...[
        LibraryInspectorFactData('Kind', singularLabel),
        LibraryInspectorFactData('ID', entry.id),
        LibraryInspectorFactData('Title', entry.title),
      ],
      if (entry.seriesTitle != null)
        LibraryInspectorFactData(
          'Series',
          entry.seriesTitle!,
          onTap: tapFor(entry.seriesTitle),
        ),
      if (hasVolume && !hasSeason)
        LibraryInspectorFactData(
          'Volume',
          entry.volumeName ?? 'Vol. ${entry.volumeNumber}',
        ),
      if (hasSeason && hasEpisode)
        LibraryInspectorFactData(
          'Season / Episode',
          'Season ${entry.seasonNumber}, Ep. ${entry.episodeNumber}',
        ),
      if (hasSeason && !hasEpisode)
        LibraryInspectorFactData('Season', 'Season ${entry.seasonNumber}'),
      if (hasEpisode && !hasSeason)
        LibraryInspectorFactData('Episode', 'Ep. ${entry.episodeNumber}'),
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
          _formatNullableDate(entry.releaseDate) ?? entry.releaseYear?.toString(),
        ),
      ),
      if (entry.pageCount != null)
        LibraryInspectorFactData('Pages', entry.pageCount.toString()),
      if (entry.catalogNumber != null)
        LibraryInspectorFactData('Catalog No.', entry.catalogNumber!),
      if (entry.coverPriceCents != null)
        LibraryInspectorFactData(
          'Cover Price',
          _formatMoney(entry.coverPriceCents, entry.catalogCurrency),
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
      if (entry.releaseStatus != null)
        LibraryInspectorFactData('Release Status', entry.releaseStatus!),
      if (entry.language != null)
        LibraryInspectorFactData('Language', entry.language!),
      if (entry.ageRating != null)
        LibraryInspectorFactData('Age Rating', entry.ageRating!),
      if (entry.platforms != null && entry.platforms!.isNotEmpty)
        LibraryInspectorFactData('Platforms', entry.platforms!.join(', ')),
      LibraryInspectorFactData('Cover', entry.hasMissingCover ? 'Missing' : 'Ready'),
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

LibraryMetadataPresentation buildVideoMetadataPresentation({
  required String singularLabel,
  required LibraryMediaFieldLabels labels,
  required LibraryWorkspaceEntry entry,
  required bool includeIdentityFacts,
  required LibraryMetadataFactTapResolver tapFor,
}) {
  final hasVolume = entry.volumeName != null || entry.volumeNumber != null;
  final hasSeason = entry.seasonNumber != null;
  final hasEpisode = entry.episodeNumber != null;
  return LibraryMetadataPresentation(
    identityFacts: [
      if (includeIdentityFacts) ...[
        LibraryInspectorFactData('Kind', singularLabel),
        LibraryInspectorFactData('ID', entry.id),
        LibraryInspectorFactData('Title', entry.title),
      ],
      if (entry.seriesTitle != null)
        LibraryInspectorFactData(
          'Series',
          entry.seriesTitle!,
          onTap: tapFor(entry.seriesTitle),
        ),
      if (hasSeason && hasEpisode)
        LibraryInspectorFactData(
          'Season / Episode',
          'Season ${entry.seasonNumber}, Ep. ${entry.episodeNumber}',
        ),
      if (hasSeason && !hasEpisode)
        LibraryInspectorFactData('Season', 'Season ${entry.seasonNumber}'),
      if (!hasSeason && hasEpisode)
        LibraryInspectorFactData('Episode', 'Ep. ${entry.episodeNumber}'),
      if (hasVolume && !hasSeason)
        LibraryInspectorFactData(
          'Volume',
          entry.volumeName ?? 'Vol. ${entry.volumeNumber}',
        ),
      if (entry.variant != null)
        LibraryInspectorFactData(
          labels.variant,
          entry.variant!,
          onTap: tapFor(entry.variant),
        ),
      if (entry.barcode != null)
        LibraryInspectorFactData(labels.barcode, entry.barcode!),
    ],
    contextFacts: [
      if (entry.publisher != null)
        LibraryInspectorFactData(
          labels.publisher,
          entry.publisher!,
          onTap: tapFor(entry.publisher),
        ),
      LibraryInspectorFactData(
        'Released',
        genericLibraryDash(
          _formatNullableDate(entry.releaseDate) ?? entry.releaseYear?.toString(),
        ),
      ),
      if (entry.runtimeMinutes != null)
        LibraryInspectorFactData('Runtime', '${entry.runtimeMinutes} min'),
      if (entry.country != null)
        LibraryInspectorFactData('Country', entry.country!),
      if (entry.language != null)
        LibraryInspectorFactData('Language', entry.language!),
      if (entry.ageRating != null)
        LibraryInspectorFactData('Age Rating', entry.ageRating!),
      if (entry.subtitle != null)
        LibraryInspectorFactData('Subtitle', entry.subtitle!),
      LibraryInspectorFactData('Cover', entry.hasMissingCover ? 'Missing' : 'Ready'),
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

LibraryMetadataPresentation buildGameMetadataPresentation({
  required String singularLabel,
  required LibraryMediaFieldLabels labels,
  required LibraryWorkspaceEntry entry,
  required bool includeIdentityFacts,
  required LibraryMetadataFactTapResolver tapFor,
}) {
  return LibraryMetadataPresentation(
    identityFacts: [
      if (includeIdentityFacts) ...[
        LibraryInspectorFactData('Kind', singularLabel),
        LibraryInspectorFactData('ID', entry.id),
        LibraryInspectorFactData('Title', entry.title),
      ],
      if (entry.variant != null)
        LibraryInspectorFactData(
          labels.variant,
          entry.variant!,
          onTap: tapFor(entry.variant),
        ),
      if (entry.barcode != null)
        LibraryInspectorFactData(labels.barcode, entry.barcode!),
      if (entry.ageRating != null)
        LibraryInspectorFactData('Age Rating', entry.ageRating!),
    ],
    contextFacts: [
      if (entry.platforms != null && entry.platforms!.isNotEmpty)
        LibraryInspectorFactData('Platforms', entry.platforms!.join(', ')),
      if (entry.publisher != null)
        LibraryInspectorFactData(
          labels.publisher,
          entry.publisher!,
          onTap: tapFor(entry.publisher),
        ),
      LibraryInspectorFactData(
        'Released',
        genericLibraryDash(
          _formatNullableDate(entry.releaseDate) ?? entry.releaseYear?.toString(),
        ),
      ),
      if (entry.country != null)
        LibraryInspectorFactData('Country', entry.country!),
      if (entry.language != null)
        LibraryInspectorFactData('Language', entry.language!),
      LibraryInspectorFactData('Cover', entry.hasMissingCover ? 'Missing' : 'Ready'),
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

LibraryMetadataPresentation buildMusicMetadataPresentation({
  required String singularLabel,
  required LibraryMediaFieldLabels labels,
  required LibraryWorkspaceEntry entry,
  required bool includeIdentityFacts,
  required LibraryMetadataFactTapResolver tapFor,
}) {
  return LibraryMetadataPresentation(
    identityFacts: [
      if (includeIdentityFacts) ...[
        LibraryInspectorFactData('Kind', singularLabel),
        LibraryInspectorFactData('ID', entry.id),
        LibraryInspectorFactData('Title', entry.title),
      ],
      if (entry.seriesTitle != null)
        LibraryInspectorFactData(
          'Artist',
          entry.seriesTitle!,
          onTap: tapFor(entry.seriesTitle),
        ),
      if (entry.volumeName != null || entry.volumeNumber != null)
        LibraryInspectorFactData(
          'Disc',
          entry.volumeName ?? 'Disc ${entry.volumeNumber}',
        ),
      if (entry.variant != null)
        LibraryInspectorFactData(
          labels.variant,
          entry.variant!,
          onTap: tapFor(entry.variant),
        ),
      if (entry.barcode != null)
        LibraryInspectorFactData(labels.barcode, entry.barcode!),
    ],
    contextFacts: [
      if (entry.publisher != null)
        LibraryInspectorFactData(
          labels.publisher,
          entry.publisher!,
          onTap: tapFor(entry.publisher),
        ),
      LibraryInspectorFactData(
        'Released',
        genericLibraryDash(
          _formatNullableDate(entry.releaseDate) ?? entry.releaseYear?.toString(),
        ),
      ),
      if (entry.trackCount != null)
        LibraryInspectorFactData('Tracks', entry.trackCount.toString()),
      if (entry.catalogNumber != null)
        LibraryInspectorFactData('Catalog No.', entry.catalogNumber!),
      if (entry.releaseStatus != null)
        LibraryInspectorFactData('Release Status', entry.releaseStatus!),
      if (entry.country != null)
        LibraryInspectorFactData('Country', entry.country!),
      if (entry.language != null)
        LibraryInspectorFactData('Language', entry.language!),
      LibraryInspectorFactData('Cover', entry.hasMissingCover ? 'Missing' : 'Ready'),
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

List<Widget> buildNoSupplementalInspectorSections({
  required BuildContext context,
  required LibraryWorkspaceEntry entry,
  required Color accent,
}) {
  return const [];
}

List<Widget> buildSummaryInspectorSections({
  required BuildContext context,
  required LibraryWorkspaceEntry entry,
  required Color accent,
}) {
  if (entry.synopsis == null || entry.synopsis!.trim().isEmpty) {
    return const [];
  }
  return [
    LibraryInspectorSection(
      title: 'Summary',
      accentColor: accent,
      children: [
        Text(
          entry.synopsis!,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  ];
}

List<Widget> buildSeasonSummaryInspectorSections({
  required BuildContext context,
  required LibraryWorkspaceEntry entry,
  required Color accent,
}) {
  return [
    SeasonsSection(itemId: entry.id),
    ...buildSummaryInspectorSections(
      context: context,
      entry: entry,
      accent: accent,
    ),
  ];
}

List<Widget> buildVolumeSummaryInspectorSections({
  required BuildContext context,
  required LibraryWorkspaceEntry entry,
  required Color accent,
}) {
  return [
    VolumesSection(itemId: entry.id),
    ...buildSummaryInspectorSections(
      context: context,
      entry: entry,
      accent: accent,
    ),
  ];
}

List<Widget> buildMusicInspectorSections({
  required BuildContext context,
  required LibraryWorkspaceEntry entry,
  required Color accent,
}) {
  final sections = <Widget>[];
  if (entry.tracks != null && entry.tracks!.isNotEmpty) {
    sections.add(
      InspectorTrackList(
        tracks: entry.tracks!,
        trackCount: entry.trackCount,
        accent: accent,
        coverUrl: entry.displayCoverUrl,
        title: entry.title,
      ),
    );
  } else if (entry.trackCount != null) {
    sections.add(
      InspectorTrackListUnavailable(
        trackCount: entry.trackCount!,
        accent: accent,
      ),
    );
  }
  return sections;
}

String _formatMoney(int? cents, String? currency) {
  if (cents == null) {
    return '';
  }
  final sign = cents < 0 ? '-' : '';
  final absolute = cents.abs();
  final whole = absolute ~/ 100;
  final fraction = (absolute % 100).toString().padLeft(2, '0');
  final prefix = currency == null || currency.isEmpty ? '' : '$currency ';
  return '$prefix$sign$whole.$fraction';
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

String? _formatNullableDate(DateTime? value) {
  return value == null ? null : _formatDate(value);
}