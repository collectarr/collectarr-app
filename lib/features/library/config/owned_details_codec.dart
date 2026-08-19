import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';

abstract interface class LibraryOwnershipCapability<
    TDetails extends OwnedItemDetails> {
  OwnedDetailsDraft defaultDraft();
  OwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal);
}

abstract interface class OwnedDetailsCodec<TDetails extends OwnedItemDetails>
    implements LibraryOwnershipCapability<TDetails> {
  TDetails fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(TDetails details);
  Map<String, dynamic> toSyncPayload(TDetails details);
  TDetails defaultDetails();
}
