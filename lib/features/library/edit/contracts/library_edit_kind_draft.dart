import 'package:collectarr_app/core/api/dto/catalog/catalog_common_dto.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/config/owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';

/// Work-facing semantic edit operations used by the shared shell.
abstract interface class LibraryWorkEditSession {
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection);

  void setExternalLinks(List<TrailerLinkDto> links);
}

/// Copy-facing semantic edit operations used by the shared shell.
abstract interface class LibraryCopyEditSession {
  JsonEncodable toDetailsDraft();

  void initializePersonalState(PersonalStateDraft personal);

  OwnedItemUpdatePayload buildOwnedUpdatePayload({
    required OwnedItemRef ownedRef,
    required PersonalStateDraft personal,
  });
}

/// Kind-owned edit session used by the generic shell's Work and Copy flows.
///
/// The public mutation surface is split into [LibraryWorkEditSession] and
/// [LibraryCopyEditSession]. A concrete kind may compose those into separate
/// Work/Release/Copy sessions; the generic shell only receives the narrow
/// operations it needs for the current flow.
abstract class LibraryEditSession
    implements LibraryWorkEditSession, LibraryCopyEditSession {
  const LibraryEditSession();

  @override
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
  @override
  OwnedItemUpdatePayload buildOwnedUpdatePayload({
    required OwnedItemRef ownedRef,
    required PersonalStateDraft personal,
  });

  /// Allows kind-specific drafts to enrich the emitted selection during submit if needed.
  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) =>
      selection;

  /// Informs kind-specific draft of external links configured in UI.
  @override
  void setExternalLinks(List<TrailerLinkDto> links) {}

  /// Optional dispose callback for controllers owned by this draft.
  void dispose() {}
}
