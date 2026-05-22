import 'package:collectarr_app/features/library/config/library_type_config.dart';

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

LibraryMediaFieldLabels libraryMediaFieldLabels(LibraryTypeConfig type) {
  return switch (type.workspace.kind) {
    'movie' => const LibraryMediaFieldLabels(
        number: 'Edition no.',
        publisher: 'Studio',
        variant: 'Format / Edition',
        barcode: 'UPC / Barcode',
      ),
    'tv' => const LibraryMediaFieldLabels(
        number: 'Season / Volume',
        publisher: 'Network / Studio',
        variant: 'Format / Edition',
        barcode: 'UPC / Barcode',
      ),
    'anime' => const LibraryMediaFieldLabels(
        number: 'Season / Volume',
        publisher: 'Studio / Publisher',
        variant: 'Format / Edition',
        barcode: 'UPC / Barcode',
      ),
    'game' => const LibraryMediaFieldLabels(
        number: 'Version',
        publisher: 'Publisher / Studio',
        variant: 'Platform / Edition',
        barcode: 'UPC / Barcode',
      ),
    'boardgame' => const LibraryMediaFieldLabels(
        number: 'Edition',
        publisher: 'Publisher / Designer',
        variant: 'Expansion / Edition',
        barcode: 'Barcode',
      ),
    'book' => const LibraryMediaFieldLabels(
        number: 'Volume',
        publisher: 'Publisher',
        variant: 'Edition / Binding',
        barcode: 'ISBN / Barcode',
      ),
    'manga' => const LibraryMediaFieldLabels(
        number: 'Volume / Chapter',
        publisher: 'Publisher',
        variant: 'Edition / Variant',
        barcode: 'ISBN / Barcode',
      ),
    'music' => const LibraryMediaFieldLabels(
        number: 'Disc / Volume',
        publisher: 'Label / Artist',
        variant: 'Format / Edition',
        barcode: 'Barcode / Catalog no.',
      ),
    _ => const LibraryMediaFieldLabels(
        number: 'No. / Vol.',
        publisher: 'Publisher / Studio / Creator',
        variant: 'Edition / Variant / Format',
        barcode: 'Barcode / UPC / ISBN',
      ),
  };
}

LibraryMediaSearchFieldLabels libraryMediaSearchFieldLabels(
  LibraryTypeConfig type,
) {
  final labels = libraryMediaFieldLabels(type);
  return switch (type.workspace.kind) {
    'music' => const LibraryMediaSearchFieldLabels(
        queryHint: 'Enter title, artist, creator, or keyword...',
        emptySearchMessage: 'Enter a title, artist, creator, or keyword.',
        seriesHint: 'Artist...',
        numberHint: 'Album / Release...',
        publisherHint: 'Label...',
      ),
    _ => LibraryMediaSearchFieldLabels(
        queryHint: 'Enter title, creator, or keyword...',
        emptySearchMessage: 'Enter a title, creator, series, or keyword.',
        seriesHint: 'Series...',
        numberHint: '${labels.number}...',
        publisherHint: '${labels.publisher}...',
      ),
  };
}

LibraryMediaFilterLabels libraryMediaFilterLabels(LibraryTypeConfig type) {
  return switch (type.workspace.kind) {
    'music' => const LibraryMediaFilterLabels(
        series: 'Artist',
        anySeries: 'Any artist',
        publisher: 'Label',
        anyPublisher: 'Any label',
      ),
    'movie' => const LibraryMediaFilterLabels(
        series: 'Series',
        anySeries: 'Any series',
        publisher: 'Studio',
        anyPublisher: 'Any studio',
      ),
    'tv' => const LibraryMediaFilterLabels(
        series: 'Series',
        anySeries: 'Any series',
        publisher: 'Network / Studio',
        anyPublisher: 'Any network / studio',
      ),
    'anime' => const LibraryMediaFilterLabels(
        series: 'Series',
        anySeries: 'Any series',
        publisher: 'Studio / Publisher',
        anyPublisher: 'Any studio / publisher',
      ),
    'game' => const LibraryMediaFilterLabels(
        series: 'Series',
        anySeries: 'Any series',
        publisher: 'Publisher / Studio',
        anyPublisher: 'Any publisher / studio',
      ),
    'boardgame' => const LibraryMediaFilterLabels(
        series: 'Series',
        anySeries: 'Any series',
        publisher: 'Publisher / Designer',
        anyPublisher: 'Any publisher / designer',
      ),
    _ => const LibraryMediaFilterLabels(
        series: 'Series',
        anySeries: 'Any series',
        publisher: 'Publisher',
        anyPublisher: 'Any publisher',
      ),
  };
}

LibraryMediaGroupLabels libraryMediaGroupLabels(LibraryTypeConfig type) {
  return switch (type.workspace.kind) {
    'music' => const LibraryMediaGroupLabels(
        series: 'Artist',
        seriesPlural: 'Artists',
        unknownSeries: 'Unknown artist',
        publisher: 'Label',
        publisherPlural: 'Labels',
        unknownPublisher: 'Unknown label',
      ),
    'movie' => const LibraryMediaGroupLabels(
        series: 'Series',
        seriesPlural: 'Series',
        unknownSeries: 'Unknown series',
        publisher: 'Studio',
        publisherPlural: 'Studios',
        unknownPublisher: 'Unknown studio',
      ),
    'tv' => const LibraryMediaGroupLabels(
        series: 'Series',
        seriesPlural: 'Series',
        unknownSeries: 'Unknown series',
        publisher: 'Network / Studio',
        publisherPlural: 'Networks / Studios',
        unknownPublisher: 'Unknown network / studio',
      ),
    'anime' => const LibraryMediaGroupLabels(
        series: 'Series',
        seriesPlural: 'Series',
        unknownSeries: 'Unknown series',
        publisher: 'Studio / Publisher',
        publisherPlural: 'Studios / Publishers',
        unknownPublisher: 'Unknown studio / publisher',
      ),
    'game' => const LibraryMediaGroupLabels(
        series: 'Series',
        seriesPlural: 'Series',
        unknownSeries: 'Unknown series',
        publisher: 'Publisher / Studio',
        publisherPlural: 'Publishers / Studios',
        unknownPublisher: 'Unknown publisher / studio',
      ),
    'boardgame' => const LibraryMediaGroupLabels(
        series: 'Series',
        seriesPlural: 'Series',
        unknownSeries: 'Unknown series',
        publisher: 'Publisher / Designer',
        publisherPlural: 'Publishers / Designers',
        unknownPublisher: 'Unknown publisher / designer',
      ),
    _ => const LibraryMediaGroupLabels(
        series: 'Series',
        seriesPlural: 'Series',
        unknownSeries: 'Unknown series',
        publisher: 'Publisher',
        publisherPlural: 'Publishers',
        unknownPublisher: 'Unknown publisher',
      ),
  };
}
