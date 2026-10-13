import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';

CatalogSearchCandidate? buildTvManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! TvAddManualDraft || title.trim().isEmpty) return null;
  if (tvAddSchema.validate?.call(draft) != null) return null;

  final id = 'manual-tv-${DateTime.now().microsecondsSinceEpoch}';
  final credits = [...draft.castCredits, ...draft.crewCredits];
  final metadata = draft.metadata.copyWith(
    title: title.trim(),
    creators: [
      for (final credit in credits)
        if (credit.nameController.text.trim().isNotEmpty)
          credit.originalCredit?.withEditedIdentity(
                name: credit.nameController.text.trim(),
                role: credit.roleController.text.trim().isEmpty
                    ? null
                    : credit.roleController.text.trim(),
              ) ??
              TvPersonCredit(
                name: credit.nameController.text.trim(),
                role: credit.roleController.text.trim().isEmpty
                    ? null
                    : credit.roleController.text.trim(),
              ),
    ],
  );
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      ref: CatalogItemRef(kind: CatalogMediaKind.tv, id: id),
      kindData: metadata,
      origin: CatalogItemOrigin.privateLocal,
    ),
  );
}

/// Serializes TV's typed manual Catalog Item for Core review.
Map<String, Object?>? buildTvManualProposalData(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  final candidate = buildTvManualCandidate(draft, title: title);
  if (candidate == null) return null;
  return candidate.kindCapability.mapTransport(
    (item) => Map<String, Object?>.from(item.kindData),
  );
}
