import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart'
    hide formatDate;
import 'package:collectarr_app/features/library/library_kind_registry.dart';

/// Owns the semantic mutation boundary for the edit shell.
///
/// The shell is responsible for rendering tabs and managing the form. This
/// controller is responsible for turning that form into domain selections and
/// kind-entry mutation commands. The kind owns one canonical Catalog Item
/// session and the local-entry edit session.
final class LibraryEditSessionController {
  const LibraryEditSessionController({
    required LibraryCatalogItemEditSession catalogItemSession,
    required LibraryEntryEditSession entrySession,
    required void Function() disposeSession,
  })  : _catalogItemSession = catalogItemSession,
        _entrySession = entrySession,
        _disposeSession = disposeSession;

  final LibraryCatalogItemEditSession _catalogItemSession;
  final LibraryEntryEditSession _entrySession;
  final void Function() _disposeSession;

  LibraryCatalogItemEditSession get catalogItemSession => _catalogItemSession;

  LibraryEntryEditSession get entrySession => _entrySession;

  void setExternalLinks(List<TrailerLinkDto> links) {
    catalogItemSession.setExternalLinks(links);
  }

  LibraryEditSelection save(
    LibraryEditShellState state, {
    LibraryEditSubmitAction submitAction = LibraryEditSubmitAction.save,
  }) {
    final existingLibraryEntry = state.libraryEntry;
    final entryRef =
        existingLibraryEntry?.ref ?? state.libraryEntryDispatch?.ref;
    final externalLinksChange = entryRef == null
        ? null
        : state.userExternalLinks.buildEditChange(entryRef);
    final baseSelection = LibraryEditSelection(
      kindItem: state.kindItem,
      scope: state.scope,
      wishlist: state.wishlistItem == null
          ? null
          : LibraryWishlistEditSelection(
              catalogRef: state.personal.selectedWishlistCatalogRef ??
                  state.kindItem.reference.toCatalogItemRef(),
              targetPriceCents: parseMoneyCents(
                state.personal.wishlistPriceController.text,
              ),
              currency: emptyToNull(
                state.personal.wishlistCurrencyController.text,
              ),
              notes: emptyToNull(
                state.personal.wishlistNotesController.text,
              ),
            ),
      tracking: !state.hasTrackingContext
          ? null
          : LibraryTrackingEditSelection(
              rating: parseInt(state.tracking.ratingController.text),
              readStatus: emptyToNull(state.tracking.trackingController.text),
              startedAt: state.tracking.startedAt,
              finishedAt: state.tracking.finishedAt,
              progressCurrent: parseInt(
                state.tracking.progressCurrentController.text,
              ),
              progressTotal: parseInt(
                state.tracking.progressTotalController.text,
              ),
              timesCompleted: parseInt(
                state.tracking.timesCompletedController.text,
              ),
              notes: emptyToNull(
                state.tracking.trackingNotesController.text,
              ),
            ),
      entryUpdatePayload: existingLibraryEntry == null
          ? null
          : entrySession.buildEntryUpdatePayload(
              libraryEntryRef: existingLibraryEntry.ref,
              personal: state.personal,
            ),
      customFieldEdits: state.customFieldEdits,
      itemImageEdits: state.itemImageEdits,
      localChanges: [
        if (externalLinksChange != null) externalLinksChange,
      ],
      submitAction: submitAction,
    );
    final canonical = buildCanonicalSelection(
      state,
      selection: baseSelection,
    );
    return applySelectionEdits(state, canonical);
  }

  LibraryEditSelection buildCanonicalSelection(
    LibraryEditShellState state, {
    LibraryEditSelection? selection,
  }) {
    final source = selection ??
        LibraryEditSelection(
          kindItem: state.kindItem,
          scope: state.scope,
        );
    return catalogItemSession.applyCanonicalEdits(source, state.formFields);
  }

  LibraryEditSelection buildCorrectionSelection(
    LibraryEditShellState state,
  ) {
    final canonical = buildCanonicalSelection(state);
    return applySelectionEdits(state, canonical);
  }

  LibraryEditSelection applySelectionEdits(
    LibraryEditShellState state,
    LibraryEditSelection selection,
  ) {
    return catalogItemSession.applySelectionEdits(selection);
  }

  LibraryAddCommonDraft buildCommonEntryDraft(LibraryEditShellState state) {
    return LibraryAddCommonDraft(
      condition: emptyToNull(state.personal.conditionController.text),
      purchaseDate: parseDate(state.personal.purchaseDateController.text),
      pricePaidCents: parseMoneyCents(state.personal.priceController.text),
      currency: emptyToNull(state.personal.currencyController.text),
      personalNotes: emptyToNull(state.personal.notesController.text),
      locationId: state.personal.selectedLocationId,
      purchaseStore: emptyToNull(
        state.personal.purchaseStoreController.text,
      ),
      collectionStatus: state.personal.collectionStatus,
      tags: emptyToNull(state.personal.tagsController.text),
    );
  }

  JsonEncodable buildEntryDetails(LibraryEditShellState state) {
    return entrySession.toDetailsDraft();
  }

  AddLibraryEntryCommand buildEntryAddCommand(LibraryEditShellState state) {
    return libraryAddForKind(state.type.kind).buildCommandFromDetails(
      state.kindItem,
      buildCommonEntryDraft(state),
      buildEntryDetails(state),
      kindValue: emptyToNull(state.personal.gradeController.text),
      tracking: LibraryAddTrackingDraft(
        readStatus: emptyToNull(state.tracking.trackingController.text),
        notes: emptyToNull(state.tracking.trackingNotesController.text),
        rating: parseInt(state.tracking.ratingController.text),
        startedAt: state.tracking.startedAt,
        finishedAt: state.tracking.finishedAt,
      ),
    );
  }

  LibraryEntryUpdateRequest buildEntryUpdateCommand(
    LibraryEditShellState state,
    LibraryEntryRef libraryEntryRef,
  ) {
    return UpdateLibraryEntryCommand(
      libraryEntryRef: libraryEntryRef,
      payload: entrySession.buildEntryUpdatePayload(
        libraryEntryRef: libraryEntryRef,
        personal: state.personal,
      ),
    );
  }

  void dispose() {
    _disposeSession();
  }
}
