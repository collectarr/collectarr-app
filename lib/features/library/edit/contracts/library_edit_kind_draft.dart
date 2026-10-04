import 'package:collectarr_app/core/api/dto/catalog/catalog_link_dto.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/library_entry_update_payload.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_form_fields.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';

/// Kind-entry canonical edit operations for one Catalog Item.
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

/// Kind-entry personal edit operations for one Collection Item.
abstract interface class LibraryEntryEditSession {
  JsonEncodable toDetailsDraft();

  void initializePersonalState(PersonalStateDraft personal);

  LibraryEntryUpdatePayload buildEntryUpdatePayload({
    required LibraryEntryRef libraryEntryRef,
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
mixin LibraryEntryEditSessionDefaults implements LibraryEntryEditSession {
  @override
  void initializePersonalState(PersonalStateDraft personal) {}
}

/// The kind-entry edit composition returned to the generic UI shell.
final class LibraryEditSessionBundle {
  const LibraryEditSessionBundle({
    required this.catalogItemSession,
    required this.entrySession,
    this.disposeSession = _disposeNothing,
  });

  final LibraryCatalogItemEditSession catalogItemSession;
  final LibraryEntryEditSession entrySession;
  final void Function() disposeSession;
}

void _disposeNothing() {}
