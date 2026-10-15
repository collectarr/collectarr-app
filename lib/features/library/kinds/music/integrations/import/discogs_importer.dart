import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/collection/csv/csv_mechanics.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
import 'music_import_row.dart';

final class DiscogsImporter implements LibraryGuidedImporter {
  const DiscogsImporter();

  @override
  List<CollectionImportRow> parse(String source) {
    final List<List<String>> data;
    try {
      data = const CsvReader(strict: true).read(source);
    } on FormatException catch (error) {
      throw LibraryImportFormatException(error.message);
    }
    if (data.length < 2) {
      throw const LibraryImportFormatException(
          'Expected a Discogs Collection CSV header and at least one album.');
    }
    final headers = data.first.map((s) => s.trim().toLowerCase()).toList();
    if (headers.toSet().length != headers.length ||
        !['artist', 'title', 'release_id'].every(headers.contains)) {
      throw const LibraryImportFormatException(
          'Expected Artist, Title and release_id columns from a Discogs Collection export.');
    }
    final result = <CollectionImportRow>[];
    final copies = <int, int>{};
    for (var index = 1; index < data.length; index++) {
      final cells = data[index];
      if (cells.length != headers.length) {
        throw LibraryImportFormatException(
            'Record $index has ${cells.length} columns; expected ${headers.length}.');
      }
      String? value(String key) {
        final at = headers.indexOf(key);
        return at < 0 || cells[at].trim().isEmpty ? null : cells[at].trim();
      }

      final release = musicImportInt(value('release_id'), 'release_id', min: 1);
      if (release == null || value('title') == null) {
        throw LibraryImportFormatException(
            'Record $index requires a title and release_id.');
      }
      // A collection can contain multiple copies of the same Discogs release.
      final copy =
          copies.update(release, (value) => value + 1, ifAbsent: () => 1);
      final id = musicImportId('discogs', '$release/$copy');
      final rawFormat = value('format');
      final formatPart = rawFormat?.split(',').first.trim();
      final counted = RegExp(r'^(\d+)x\s*(.+)$', caseSensitive: false)
          .firstMatch(formatPart ?? '');
      final count = counted == null
          ? 1
          : musicImportInt(counted.group(1), 'disc count', min: 1, max: 100)!;
      final format = counted?.group(2) ?? formatPart;
      final rating = musicImportInt(value('rating'), 'rating', max: 5);
      result.add(musicImportRow(
          id: id,
          album: MusicAlbum(
            title: value('title')!,
            artist: value('artist'),
            publisher: value('label'),
            catalogNumber: value('catalog#'),
            releaseDateParts:
                musicImportDate(value('released'), field: 'Released'),
            discs: [
              if (format != null)
                for (var disc = 1; disc <= count; disc++)
                  musicImportDisc(id, disc, format)
            ],
          ),
          personal: MusicPersonalData(
            rating: rating == null ? null : rating * 2,
            mediaCondition: value('collection media condition'),
            personalNotes: value('collection notes'),
            collectionStatus: 'In Collection',
          )));
    }
    return List.unmodifiable(result);
  }
}
