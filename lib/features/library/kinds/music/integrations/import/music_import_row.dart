import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_format_presets.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'package:uuid/uuid.dart';

String musicImportId(String source, String identity) => const Uuid()
    .v5(Namespace.url.value, 'collectarr/import/music/$source/$identity');

CollectionImportRow musicImportRow({
  required String id,
  required MusicAlbum album,
  MusicPersonalData personal = const MusicPersonalData(),
}) {
  if (album.title.trim().isEmpty) {
    throw const LibraryImportFormatException(
        'An album has no title. Export the Title field and try again.');
  }
  final catalog = Map<String, dynamic>.from(album.toJson())
    ..remove('id')
    ..remove('kind');
  try {
    MusicAlbum.fromJson(catalog);
  } on FormatException catch (error) {
    throw LibraryImportFormatException(error.message);
  }
  final record = LibraryEntryRecord(
      id: id,
      kind: CatalogMediaKind.music,
      catalogData: catalog,
      personalData: personal.toJson(),
      updatedAt: DateTime.utc(1970));
  return CollectionImportRow(
      itemId: id,
      status: 'entry',
      mediaKind: CatalogMediaKind.music,
      title: album.title,
      kindIdentifier: album.barcode,
      fullEntryPayload: record.toJson());
}

MusicDisc musicImportDisc(String entryId, int number, String? format) =>
    MusicDisc(
        id: MusicDiscId(musicImportId(entryId, 'disc/$number')),
        discNumber: number,
        format: format,
        formatFamily: musicImportFormatFamily(format));

PartialDate? musicImportDate(String? value, {String field = 'date'}) {
  if (value == null || value.trim().isEmpty) return null;
  final match =
      RegExp(r'^(\d{4})(?:-(\d{2})(?:-(\d{2}))?)?$').firstMatch(value.trim());
  if (match == null) {
    throw LibraryImportFormatException(
        'Invalid $field "$value". Use YYYY, YYYY-MM or YYYY-MM-DD.');
  }
  final year = int.parse(match[1]!);
  final month = match[2] == null ? null : int.parse(match[2]!);
  final day = match[3] == null ? null : int.parse(match[3]!);
  if (year < 1 ||
      year > 9999 ||
      (month != null && (month < 1 || month > 12)) ||
      (day != null &&
          (day < 1 || day > DateTime.utc(year, month! + 1, 0).day))) {
    throw LibraryImportFormatException('Invalid $field "$value".');
  }
  return PartialDate(year: year, month: month, day: day);
}

int? musicImportInt(String? value, String field, {int min = 0, int? max}) {
  if (value == null || value.trim().isEmpty) return null;
  final result = int.tryParse(value.trim());
  if (result == null || result < min || (max != null && result > max)) {
    throw LibraryImportFormatException('Invalid $field "$value".');
  }
  return result;
}

int? musicImportMoney(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final number = value.trim().replaceFirst(RegExp(r'^[\$\u20ac\u00a3]\s*'), '');
  final match = RegExp(r'^(\d+)(?:[.,](\d{1,2}))?$').firstMatch(number);
  if (match == null) {
    throw LibraryImportFormatException('Invalid purchase price "$value".');
  }
  return int.parse(match[1]!) * 100 +
      int.parse((match[2] ?? '').padRight(2, '0'));
}

MusicDiscFormatFamily? musicImportFormatFamily(String? format) {
  if (format == null) return null;
  final family = musicFormatPresetFamily(format);
  if (family == null) {
    throw LibraryImportFormatException(
        'Unrecognized disc format "$format". Select a known Music format in the export before importing; a family will not be guessed.');
  }
  return family;
}
