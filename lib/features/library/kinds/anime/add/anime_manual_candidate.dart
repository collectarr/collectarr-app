import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_schema.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';

CatalogSearchCandidate? buildAnimeManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! AnimeAddManualDraft || title.trim().isEmpty) return null;
  if (animeAddSchema.validate?.call(draft) != null) return null;

  final id = 'manual-anime-${DateTime.now().microsecondsSinceEpoch}';
  final credits = [...draft.castCredits, ...draft.crewCredits];
  final metadata = draft.metadata.copyWith(
    title: title.trim(),
    creators: [
      for (var index = 0; index < credits.length; index++)
        if (credits[index].nameController.text.trim().isNotEmpty)
          credits[index].toMetadata(newSequence: index),
    ],
  );

  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      identity: LibraryItemIdentity(id: id, mediaKind: CatalogMediaKind.anime),
      kindData: metadata,
      origin: CatalogItemOrigin.privateLocal,
    ),
  );
}

/// Serializes this kind's typed manual catalog model for Core review.
///
/// Core projects the supplied object onto the recognized flattened fields for
/// this kind, so this mapper does not maintain a second field denylist.
Map<String, Object?>? buildAnimeManualProposalData(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  final candidate = buildAnimeManualCandidate(draft, title: title);
  if (candidate == null) return null;
  return candidate.kindCapability.mapTransport(
    (item) => Map<String, Object?>.from(item.kindData),
  );
}
