import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
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
/// kind-owned mutation commands. Kind-specific details remain in the
/// registered [LibraryEditSession]; this class only composes the common
/// Work/Release/Copy boundary around it.
final class LibraryEditSessionController {
  const LibraryEditSessionController({required LibraryEditSession kindSession})
      : _kindSession = kindSession;

  final LibraryEditSession _kindSession;

  LibraryWorkEditSession get workSession => _kindSession;

  LibraryCopyEditSession get copySession => _kindSession;

  void setExternalLinks(List<TrailerLinkDto> links) {
    workSession.setExternalLinks(links);
  }

  LibraryEditSelection saveWork(
    LibraryEditShellState state, {
    LibraryEditSubmitAction submitAction = LibraryEditSubmitAction.save,
  }) {
    final existingOwnedItem = state.ownedItem;
    final baseItem = state.kindItem.copyWith(
      title: state.metadata.titleController.text.trim(),
      sortKey: emptyToNull(state.metadata.sortKeyController.text),
      originalTitle: emptyToNull(state.metadata.originalTitleController.text),
      displayTitle: emptyToNull(state.metadata.displayTitleController.text),
      localizedTitle: emptyToNull(state.metadata.localizedTitleController.text),
      searchAliases: _splitList(state.metadata.searchAliasesController.text),
      synopsis: emptyToNull(state.metadata.synopsisController.text),
      coverImageUrl: emptyToNull(state.metadata.coverController.text),
      thumbnailImageUrl: emptyToNull(
        state.metadata.thumbnailController.text,
      ),
    );
    final baseSelection = LibraryEditSelection(
      item: baseItem.editMetadata,
      kindItem: baseItem,
      personal: existingOwnedItem == null
          ? null
          : LibraryPersonalEditSelection(
              targetRef: state.personal.selectedOwnedTargetRef,
              condition: state.showPhysicalOwnedFields
                  ? emptyToNull(state.personal.conditionController.text)
                  : null,
              purchaseDate:
                  parseDate(state.personal.purchaseDateController.text),
              pricePaidCents:
                  parseMoneyCents(state.personal.priceController.text),
              currency: emptyToNull(state.personal.currencyController.text),
              personalNotes: emptyToNull(state.personal.notesController.text),
              quantity: parseInt(state.personal.quantityController.text) ?? 1,
              indexNumber: parseInt(
                state.personal.indexNumberController.text,
              ),
              locationId: state.showPhysicalOwnedFields
                  ? state.personal.selectedLocationId
                  : null,
              locationChanged: state.showPhysicalOwnedFields
                  ? state.personal.locationChanged
                  : false,
              tags: emptyToNull(state.personal.tagsController.text),
              soldAt: state.personal.soldAt,
              sellPriceCents:
                  parseMoneyCents(state.personal.sellPriceController.text),
              soldTo: emptyToNull(state.personal.soldToController.text),
              purchaseStore: emptyToNull(
                    state.personal.purchaseStoreController.text,
                  ) ??
                  existingOwnedItem.purchaseStore,
              collectionStatus: state.personal.collectionStatus,
              marketValueCents: parseMoneyCents(
                    state.personal.marketValueController.text,
                  ) ??
                  existingOwnedItem.marketValueCents,
              ownerLabel: emptyToNull(
                    state.personal.ownerLabelController.text,
                  ) ??
                  existingOwnedItem.ownerLabel,
            ),
      wishlist: state.wishlistItem == null
          ? null
          : LibraryWishlistEditSelection(
              catalogRef:
                  state.personal.selectedWishlistCatalogRef ?? state.item.ref,
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
              targetRef: state.tracking.selectedTargetRef ?? state.item.ref,
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
    return workSession.applySelectionEdits(baseSelection);
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
      targetRef: state.personal.selectedOwnedTargetRef ?? state.item.ref,
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
    OwnedItemRef ownedRef,
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
    _kindSession.dispose();
  }

  List<String>? _splitList(String value) {
    final entries = value
        .split(RegExp(r'[,\r\n]+'))
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
    return entries.isEmpty ? null : entries;
  }
}
