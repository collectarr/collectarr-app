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

/// Release-facing semantic edit operations. Work and Release currently share
/// the same selection mutation shape, but remain separate contracts so the
/// generic shell cannot accidentally treat a release as a work aggregate.
abstract interface class LibraryReleaseEditSession
    implements LibraryWorkEditSession {}

/// Copy-facing semantic edit operations used by the shared shell.
abstract interface class LibraryCopyEditSession {
  JsonEncodable toDetailsDraft();

  void initializePersonalState(PersonalStateDraft personal);

  OwnedItemUpdatePayload buildOwnedUpdatePayload({
    required OwnedItemRef ownedRef,
    required PersonalStateDraft personal,
  });
}

/// Default Work/Release behavior for a kind-owned session that does not need
/// extra selection or external-link handling.
mixin LibraryWorkEditSessionDefaults implements LibraryWorkEditSession {
  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) =>
      selection;

  @override
  void setExternalLinks(List<TrailerLinkDto> links) {}
}

/// Default Copy initialization for a kind-owned session with no personal
/// details beyond the shared form state.
mixin LibraryCopyEditSessionDefaults implements LibraryCopyEditSession {
  @override
  void initializePersonalState(PersonalStateDraft personal) {}
}

/// The kind-owned edit composition returned to the generic UI shell.
///
/// The implementations may currently be backed by one concrete object, but
/// the public contract is explicitly split by entity scope. The generic shell
/// never receives a semantic aggregate session.
final class LibraryEditSessionBundle {
  const LibraryEditSessionBundle({
    required this.workSession,
    required this.releaseSession,
    required this.copySession,
    required this.disposeSession,
  });

  final LibraryWorkEditSession workSession;
  final LibraryReleaseEditSession releaseSession;
  final LibraryCopyEditSession copySession;
  final void Function() disposeSession;
}
