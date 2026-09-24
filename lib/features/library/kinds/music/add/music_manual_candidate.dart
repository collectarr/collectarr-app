import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_release_form_values.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_release_group_form_values.dart';

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
  final releaseDate = draft.release.releaseDate ?? _yearDate(draft.year);
  final groupId = MusicReleaseGroupId(
    'manual-music-${DateTime.now().microsecondsSinceEpoch}',
  );
  final releaseId = MusicReleaseId('${groupId.value}-release');
  final groupValues = MusicReleaseGroupFormValues(
    title: normalizedTitle,
    artist: draft.releaseGroup.artist,
    originalReleaseDate: releaseDate,
    genres: draft.releaseGroup.genres,
    coverImageUrl: draft.releaseGroup.coverImageUrl,
  );
  final releaseValues = MusicReleaseFormValues(
    title: _textOrNull(draft.release.title) ?? normalizedTitle,
    publisher: draft.release.publisher,
    catalogNumber: draft.release.catalogNumber,
    barcode: draft.release.barcode,
    physicalFormat: draft.release.physicalFormat,
    physicalFormatLabel: draft.release.physicalFormatLabel,
    packaging: draft.release.packaging,
    countryCode: draft.release.countryCode,
    language: draft.release.language,
    releaseDate: releaseDate,
  );
  final mediumType = _textOrNull(
    releaseValues.physicalFormatLabel.isNotEmpty
        ? releaseValues.physicalFormatLabel
        : releaseValues.physicalFormat,
  );
  final release = MusicReleaseFormAdapter.create(
    releaseValues,
    id: releaseId,
    releaseGroupId: groupId,
    mediums: mediumType == null
        ? const []
        : [
            MusicMedium(
              id: MusicMediumId('${releaseId.value}:medium:1'),
              releaseId: releaseId,
              mediumNumber: 1,
              mediumType: mediumType,
            ),
          ],
  );
  final group = MusicReleaseGroupFormAdapter.create(
    groupValues,
    id: groupId,
    releases: [release],
  );
  final item = CatalogItemDto.raw(
    id: groupId.value,
    mediaKind: CatalogMediaKind.music,
    common: CatalogCommonDto(
      title: normalizedTitle,
      coverImageUrl: group.coverImageUrl,
      releaseDate: releaseDate,
      releaseYear: releaseDate?.year,
    ),
    kindMetadata: group,
  );
  return CatalogSearchCandidate.fromItem(item);
}

DateTime? _yearDate(int? year) =>
    year == null || year < 1 ? null : DateTime.utc(year);

String? _textOrNull(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}
