import 'package:collectarr_app/core/api/dto/catalog/catalog_link_dto.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/owned_copy_projection.dart';
import 'package:collectarr_app/features/library/config/owned_item_update_payload.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_form_fields.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';

/// Kind-owned canonical edit operations for one Catalog Item.
abstract interface class LibraryCatalogItemEditSession {
  LibraryEditFormSchema buildCanonicalFormSchema(
    LibraryEditFormFields fields,
    CatalogSearchCandidate item,
  );

  LibraryEditSelection applyCanonicalEdits(
    LibraryEditSelection selection,
    LibraryEditFormFields fields,
  );

  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection);

  void setExternalLinks(List<TrailerLinkDto> links);
}

/// Kind-owned personal edit operations for one Owned Copy.
abstract interface class LibraryCopyEditSession {
  JsonEncodable toDetailsDraft();

  void initializePersonalState(PersonalStateDraft personal);

  OwnedItemUpdatePayload buildOwnedUpdatePayload({
    required OwnedCopyRef ownedRef,
    required PersonalStateDraft personal,
  });
}

/// Default external-link behavior for a kind without custom link editing.
mixin LibraryCatalogItemEditSessionLinkDefaults
    implements LibraryCatalogItemEditSession {
  @override
  void setExternalLinks(List<TrailerLinkDto> links) {}
}

/// Default copy initialization for a kind with no additional personal fields.
mixin LibraryCopyEditSessionDefaults implements LibraryCopyEditSession {
  @override
  void initializePersonalState(PersonalStateDraft personal) {}
}

/// The kind-owned edit composition returned to the generic UI shell.
final class LibraryEditSessionBundle {
  const LibraryEditSessionBundle({
    required this.catalogItemSession,
    required this.copySession,
    required this.disposeSession,
  });

  final LibraryCatalogItemEditSession catalogItemSession;
  final LibraryCopyEditSession copySession;
  final void Function() disposeSession;
}
