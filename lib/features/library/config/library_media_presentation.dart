import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';

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

class LibraryMediaPresentation {
  const LibraryMediaPresentation({
    required this.fieldLabels,
    required this.searchFieldLabels,
    required this.filterLabels,
    required this.groupLabels,
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
  groupModes: [
    LibraryGroupMode.series,
    LibraryGroupMode.year,
    LibraryGroupMode.publisher,
    LibraryGroupMode.title,
    LibraryGroupMode.ownership,
  ],
);