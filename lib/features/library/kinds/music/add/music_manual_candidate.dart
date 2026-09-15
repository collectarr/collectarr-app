import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_release_group_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';

/// Builds the typed catalog candidate used by Music's manual Add flow.
///
/// The shared Add host only asks the registered kind capability for this
/// candidate; it does not interpret Music fields or construct a Music graph.
CatalogSearchCandidate? buildMusicManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! MusicAddManualDraft) return null;
  if (title.trim().isEmpty || musicAddSchema.validate!(draft) != null) {
    return null;
  }

  final normalizedTitle = title.trim();
  final releaseDate = _manualReleaseDate(draft.releaseDateController.text) ??
      _manualYearDate(draft.yearController.text);
  final groupId = MusicReleaseGroupId(
    'manual-music-${DateTime.now().microsecondsSinceEpoch}',
  );
  final group = MusicReleaseGroupAddDraft(
    title: normalizedTitle,
    releaseTitle: _textOrNull(draft.editionTitleController.text),
    artist: _textOrNull(draft.creatorsController.text),
    publisher: _textOrNull(draft.publisherController.text),
    catalogNumber: _textOrNull(draft.numberController.text),
    barcode: _textOrNull(draft.barcodeController.text),
    mediumType: _textOrNull(draft.physicalFormatLabelController.text),
    packaging: _textOrNull(draft.packagingController.text),
    countryCode: _textOrNull(draft.countryController.text),
    language: _textOrNull(draft.languageController.text),
    releaseDate: releaseDate,
    genres: _splitValues(draft.genresEditController.text),
    synopsis: _textOrNull(draft.synopsisController.text),
    coverImageUrl: _textOrNull(draft.coverController.text),
  ).toReleaseGroup(
    groupId: groupId,
    releaseId: MusicReleaseId('${groupId.value}-release'),
  );
  final item = CatalogItemDto.raw(
    id: groupId.value,
    mediaKind: CatalogMediaKind.music,
    common: CatalogCommonDto(
      title: normalizedTitle,
      synopsis: group.synopsis,
      coverImageUrl: group.coverImageUrl,
      releaseDate: releaseDate,
      releaseYear: releaseDate?.year,
    ),
    kindMetadata: group,
  );
  return CatalogSearchCandidate.fromItem(item);
}

DateTime? _manualYearDate(String value) {
  final year = int.tryParse(value.trim());
  if (year == null || year < 1) return null;
  return DateTime.utc(year);
}

DateTime? _manualReleaseDate(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return null;
  final parsed = DateTime.tryParse(normalized);
  if (parsed == null) return null;
  if (!normalized.contains('T') && !normalized.contains(' ')) {
    return DateTime.utc(parsed.year, parsed.month, parsed.day);
  }
  return parsed;
}

List<String> _splitValues(String value) => [
      for (final part in value.split(','))
        if (_textOrNull(part) case final text?) text,
    ];

String? _textOrNull(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}
