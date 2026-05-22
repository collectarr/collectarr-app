import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/config/presentation/game_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/config/presentation/music_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/config/presentation/video_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';

const genericLibraryMediaBuilder = DefaultLibraryMediaPresentationBuilder();
const comicsLibraryMediaBuilder =
    DefaultLibraryMediaPresentationBuilder(showSummary: true);
const mangaLibraryMediaBuilder = DefaultLibraryMediaPresentationBuilder(
  showSummary: true,
  showVolumeHierarchy: true,
);
const animeLibraryMediaBuilder = VideoLibraryMediaPresentationBuilder(
  showSummary: true,
  showSeasonHierarchy: true,
);
const booksLibraryMediaBuilder = DefaultLibraryMediaPresentationBuilder(
  showSummary: true,
  showVolumeHierarchy: true,
);
const gamesLibraryMediaBuilder = GameLibraryMediaPresentationBuilder();
const boardGamesLibraryMediaBuilder = DefaultLibraryMediaPresentationBuilder();
const moviesLibraryMediaBuilder = VideoLibraryMediaPresentationBuilder(
  showSummary: true,
);
const musicLibraryMediaBuilder = MusicLibraryMediaPresentationBuilder();
const tvLibraryMediaBuilder = VideoLibraryMediaPresentationBuilder(
  showSummary: true,
  showSeasonHierarchy: true,
);

const defaultPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Items',
);
const issuesPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Issues',
);
const volumesPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Volumes',
);
const seasonsPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Seasons',
);
const releasesPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Artist',
  itemCount: 'Releases',
);
const franchiseStatsLabels = LibraryMediaStatsLabels(
  topSeries: 'Top Franchises',
  topPublisher: 'Top Studios',
);
const musicStatsLabels = LibraryMediaStatsLabels(
  topSeries: 'Top Artists',
  topPublisher: 'Top Labels',
);
const gameStatsLabels = LibraryMediaStatsLabels(
  topSeries: 'Top Series',
  topPublisher: 'Top Publishers / Studios',
);
const issueVisibleColumns = {
  LibraryTableColumn.status,
  LibraryTableColumn.cover,
  LibraryTableColumn.title,
  LibraryTableColumn.issue,
  LibraryTableColumn.publisher,
  LibraryTableColumn.releaseDate,
  LibraryTableColumn.barcode,
  LibraryTableColumn.condition,
  LibraryTableColumn.price,
  LibraryTableColumn.storageBox,
  LibraryTableColumn.wishlist,
  LibraryTableColumn.updated,
};

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
  builder: genericLibraryMediaBuilder,
  previewLabels: defaultPreviewLabels,
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
  builder: comicsLibraryMediaBuilder,
  defaultVisibleColumns: issueVisibleColumns,
  previewLabels: issuesPreviewLabels,
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
  builder: mangaLibraryMediaBuilder,
  defaultVisibleColumns: issueVisibleColumns,
  previewLabels: volumesPreviewLabels,
  usesTreeProviderCandidates: true,
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
  builder: animeLibraryMediaBuilder,
  previewLabels: seasonsPreviewLabels,
  statsLabels: franchiseStatsLabels,
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
  builder: booksLibraryMediaBuilder,
  previewLabels: volumesPreviewLabels,
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
  builder: gamesLibraryMediaBuilder,
  previewLabels: defaultPreviewLabels,
  statsLabels: gameStatsLabels,
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
  builder: boardGamesLibraryMediaBuilder,
  previewLabels: defaultPreviewLabels,
  statsLabels: gameStatsLabels,
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
  builder: moviesLibraryMediaBuilder,
  previewLabels: defaultPreviewLabels,
  statsLabels: franchiseStatsLabels,
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
    queryHint: 'Enter album, artist, release, or label...',
    emptySearchMessage: 'Enter an album, artist, release, or label.',
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
  builder: musicLibraryMediaBuilder,
  previewLabels: releasesPreviewLabels,
  statsLabels: musicStatsLabels,
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
  builder: tvLibraryMediaBuilder,
  previewLabels: seasonsPreviewLabels,
  statsLabels: franchiseStatsLabels,
  groupModes: [
    LibraryGroupMode.series,
    LibraryGroupMode.year,
    LibraryGroupMode.publisher,
    LibraryGroupMode.title,
    LibraryGroupMode.ownership,
  ],
);