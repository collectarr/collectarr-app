import 'package:collectarr_app/core/api/dto/catalog/catalog_common_dto.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/config/owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';

/// Abstract domain interface for kind-specific edit drafts.
abstract class LibraryEditKindDraft {
  const LibraryEditKindDraft();

  JsonEncodable toDetailsDraft();

  /// Seeds the shared edit shell from the concrete kind-owned aggregate.
  ///
  /// The generic shell owns controllers and layout only. Semantic Owned
  /// values are read by the concrete draft before the shell is rendered.
  void initializePersonalState(PersonalStateDraft personal) {}

  /// Builds the complete kind-owned Owned update payload from the edit form.
  ///
  /// The generic edit host supplies only structural form state. Each concrete
  /// kind translates its personal fields and details into its own payload.
  OwnedItemUpdatePayload<Object?> buildOwnedUpdatePayload({
    required String ownedItemId,
    required PersonalStateDraft personal,
  });

  /// Allows kind-specific drafts to enrich the emitted selection during submit if needed.
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) =>
      selection;

  /// Informs kind-specific draft of external links configured in UI.
  void setExternalLinks(List<TrailerLinkDto> links) {}

  /// Optional dispose callback for controllers owned by this draft.
  void dispose() {}
}
