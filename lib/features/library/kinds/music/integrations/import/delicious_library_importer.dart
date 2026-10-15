import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
import 'package:xml/xml.dart';
import 'music_import_row.dart';

/// Delicious Library 2 XML property-list export. Other export layouts are not
/// guessed from arbitrary title tags or CSV column positions.
final class DeliciousLibraryImporter implements LibraryGuidedImporter {
  const DeliciousLibraryImporter();
  @override
  List<CollectionImportRow> parse(String source) {
    final XmlDocument document;
    try {
      document = XmlDocument.parse(
          source.replaceAll('\r\n', '\n').replaceAll('\r', '\n'));
    } on XmlException catch (error) {
      throw LibraryImportFormatException('Malformed XML: ${error.message}');
    }
    final root = document.rootElement;
    if (root.name.local != 'plist' || root.getElement('array') == null) {
      throw const LibraryImportFormatException(
          'Expected a Delicious Library XML property-list export.');
    }
    final rows = <CollectionImportRow>[];
    final seen = <String>{};
    for (final record in root.getElement('array')!.childElements) {
      if (record.name.local != 'dict') {
        throw const LibraryImportFormatException(
            'Expected a property-list dictionary per item.');
      }
      final elements = record.childElements.toList();
      final fields = <String, String>{};
      if (elements.length.isOdd) {
        throw const LibraryImportFormatException(
            'Incomplete property-list record.');
      }
      for (var i = 0; i < elements.length; i += 2) {
        if (elements[i].name.local != 'key' ||
            fields.containsKey(elements[i].innerText)) {
          throw const LibraryImportFormatException(
              'Invalid or duplicate property-list key.');
        }
        fields[elements[i].innerText] = elements[i + 1].innerText;
      }
      String? value(String key) =>
          fields[key]?.trim().isEmpty ?? true ? null : fields[key]!.trim();
      final type = value('type');
      if (type == null) {
        throw const LibraryImportFormatException(
            'An item is missing its Delicious Library type.');
      }
      if (type != 'Music') continue;
      final external = value('uuidString');
      if (external == null || !seen.add(external)) {
        throw const LibraryImportFormatException(
            'Missing or duplicate Delicious Library item UUID.');
      }
      final id = musicImportId('delicious', external);
      final date = value('publishDate')?.split('T').first;
      final purchase = musicImportDate(value('purchaseDate')?.split('T').first);
      final count = musicImportInt(value('numberOfMedia'), 'numberOfMedia',
              min: 1, max: 100) ??
          1;
      final format = value('formatSingularString');
      rows.add(musicImportRow(
          id: id,
          album: MusicAlbum(
            title: value('title') ?? '',
            artist: value('actorsCompositeString'),
            publisher: value('publishersCompositeString'),
            barcode: value('ean'),
            countryCode: value('countryCode'),
            releaseDateParts: musicImportDate(date),
            genres: value('genresCompositeString')
                    ?.split('\n')
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
              personalNotes: value('notes'),
              pricePaidCents: musicImportMoney(value('price')),
              purchaseDateParts: purchase,
              purchaseDate: purchase?.asDateTime,
              collectionStatus: 'In Collection')));
    }
    if (rows.isEmpty) {
      throw const LibraryImportFormatException(
          'No Music items found in the Delicious Library export.');
    }
    return List.unmodifiable(rows);
  }
}
