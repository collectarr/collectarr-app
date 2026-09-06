import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/config/owned_details_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';

abstract interface class LibraryOwnershipCapability<
    TDetails extends OwnedItemDetails, TDraft extends OwnedDetailsDraft> {
  TDraft defaultDraft();
  TDraft buildDraft(LibraryPersonalEditSelection personal);
  TDraft draftFromDetails(TDetails details);
}

/// Serialization-only boundary used by generic persistence and sync hosts.
///
/// The concrete codec remains owned by a kind. This erased surface is allowed
/// only because JSON decoding/default construction is a serialization
/// boundary; it does not expose any kind-specific fields or domain behavior.
abstract interface class OwnedDetailsPersistenceCodec {
  OwnedItemDetails fromJson(Map<String, dynamic> json);
  OwnedItemDetails defaultDetails();
}

abstract interface class OwnedDetailsCodec<TDetails extends OwnedItemDetails,
        TDraft extends OwnedDetailsDraft>
    implements
        LibraryOwnershipCapability<TDetails, TDraft>,
        OwnedDetailsPersistenceCodec {
  @override
  TDetails fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson(TDetails details);
  Map<String, dynamic> toSyncPayload(TDetails details);

  @override
  TDetails defaultDetails();
}
