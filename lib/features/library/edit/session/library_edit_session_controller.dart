import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_copy_projection.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart'
    hide formatDate;
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';

/// Owns the semantic mutation boundary for the edit shell.
///
/// The shell is responsible for rendering tabs and managing the form. This
/// controller is responsible for turning that form into domain selections and
/// kind-owned mutation commands. The kind owns one canonical Catalog Item
/// session and one separate Owned Copy session.
final class LibraryEditSessionController {
  const LibraryEditSessionController({
    required LibraryCatalogItemEditSession catalogItemSession,
    required LibraryCopyEditSession copySession,
    required void Function() disposeSession,
  })  : _catalogItemSession = catalogItemSession,
        _copySession = copySession,
        _disposeSession = disposeSession;

  final LibraryCatalogItemEditSession _catalogItemSession;
  final LibraryCopyEditSession _copySession;
  final void Function() _disposeSession;

  LibraryCatalogItemEditSession get catalogItemSession => _catalogItemSession;

  LibraryCopyEditSession get copySession => _copySession;

  void setExternalLinks(List<TrailerLinkDto> links) {
    catalogItemSession.setExternalLinks(links);
  }

  LibraryEditSelection save(
    LibraryEditShellState state, {
    LibraryEditSubmitAction submitAction = LibraryEditSubmitAction.save,
  }) {
    final existingOwnedItem = state.ownedItem;
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
              targetRef:
                  state.tracking.selectedTargetRef ?? state.kindItem.reference,
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
      ownedUpdatePayload: existingOwnedItem == null
          ? null
          : copySession.buildOwnedUpdatePayload(
              ownedRef: existingOwnedItem.ref,
              personal: state.personal,
            ),
      customFieldEdits: state.customFieldEdits,
      itemImageEdits: state.itemImageEdits,
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
    if (state.scope == LibraryEntityScope.copy) return source;
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
    if (state.scope == LibraryEntityScope.copy) return selection;
    return catalogItemSession.applySelectionEdits(selection);
  }

  LibraryAddCommonDraft buildCommonCopyDraft(LibraryEditShellState state) {
    return LibraryAddCommonDraft(
      quantity: parseInt(state.personal.quantityController.text) ?? 1,
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

  JsonEncodable buildCopyDetails(LibraryEditShellState state) {
    return copySession.toDetailsDraft();
  }

  AddOwnedItemCommand buildCopyAddCommand(LibraryEditShellState state) {
    return libraryAddForKind(state.type.kind).buildCommandFromDetails(
      state.kindItem,
      buildCommonCopyDraft(state),
      buildCopyDetails(state),
      targetRef:
          state.personal.selectedOwnedTargetRef ?? state.kindItem.reference,
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

  OwnedItemUpdateRequest buildCopyUpdateCommand(
    LibraryEditShellState state,
    OwnedCopyRef ownedRef,
  ) {
    return UpdateOwnedItemCommand(
      ownedRef: ownedRef,
      payload: copySession.buildOwnedUpdatePayload(
        ownedRef: ownedRef,
        personal: state.personal,
      ),
    );
  }

  void dispose() {
    _disposeSession();
  }
}
