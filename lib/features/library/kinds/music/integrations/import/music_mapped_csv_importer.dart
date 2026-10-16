import 'package:collectarr_app/core/utils/sort_title.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/collection/csv/csv_mechanics.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
import 'music_import_row.dart';

final class MusicMappedCsvImporter implements LibraryMappedCsvImporter {
  const MusicMappedCsvImporter();
  @override
  List<CollectionImportRow> parse(
    List<List<String>> rows, {
    required Map<int, String> mappings,
    required String multiValueDelimiter,
  }) {
    if (rows.isEmpty) {
      throw const LibraryImportFormatException('The file has no data rows.');
    }
    if (!mappings.values.contains('title')) {
      throw const LibraryImportFormatException(
          'Map a column to Title before importing.');
    }
    if (mappings.values.toSet().length != mappings.length) {
      throw const LibraryImportFormatException(
          'Map each destination field only once.');
    }
    final result = <CollectionImportRow>[];
    for (var index = 0; index < rows.length; index++) {
      final raw = rows[index];
      final values = <String, String>{};
      for (final mapping in mappings.entries) {
        if (mapping.key < 0 || mapping.key >= raw.length) {
          throw LibraryImportFormatException(
              'Record ${index + 1} is missing a mapped column.');
        }
        values[mapping.value] = raw[mapping.key].trim();
      }
      String? value(String key) =>
          values[key]?.isEmpty ?? true ? null : values[key];
      final id =
          musicImportId('csv', '${const CsvWriter().write([raw])}/$index');
      final purchase =
          musicImportDate(value('purchase_date'), field: 'Purchase Date');
      final format = value('format');
      final count =
          musicImportInt(value('disc_count'), 'Disc Count', min: 1, max: 100) ??
              (format == null ? 0 : 1);
      result.add(musicImportRow(
          id: id,
          album: MusicAlbum(
            title: value('title') ?? '',
            sortTitle:
                resolveSortTitle(value('title') ?? '', value('sort_title')),
            artist: value('artist'),
            publisher: value('label'),
            catalogNumber: value('catalog_no'),
            barcode: value('barcode'),
            countryCode: value('country'),
            releaseDateParts:
                musicImportDate(value('release_year'), field: 'Release Year'),
            genres: value('genre')
                    ?.split(multiValueDelimiter)
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList() ??
                [],
            discs: [
              for (var disc = 1; disc <= count; disc++)
                musicImportDisc(id, disc, format)
            ],
          ),
          personal: MusicPersonalData(
            rating: musicImportInt(value('rating'), 'My Rating', max: 10),
            mediaCondition: value('condition'),
            personalNotes: value('notes'),
            purchaseDateParts: purchase,
            purchaseDate: purchase?.asDateTime,
            pricePaidCents: musicImportMoney(value('price_paid')),
            tags: value('tags'),
            collectionStatus: 'In Collection',
          )));
    }
    return List.unmodifiable(result);
  }
}
