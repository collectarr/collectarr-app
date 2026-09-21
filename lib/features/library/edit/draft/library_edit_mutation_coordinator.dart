import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart'
    hide formatDate;
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

/// Coordinates domain mutation assembly for the generic edit UI.
///
/// [LibraryEditShellState] owns controllers and transient UI state. This
/// object is the only shared place that composes that state into a selection,
/// Add command, or Owned update command. Kind sessions still own semantic
/// details and payload construction.
final class LibraryEditMutationCoordinator {
  const LibraryEditMutationCoordinator();

  void setExternalLinks({
    required LibraryEditShellState state,
    required List<TrailerLinkDto> links,
  }) {
    state.kindDetails.setExternalLinks(links);
  }

  LibraryEditSelection toSelection({
    required LibraryEditShellState state,
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
              currency: emptyToNull(
                state.personal.currencyController.text,
              ),
              personalNotes: emptyToNull(
                state.personal.notesController.text,
              ),
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
              readStatus: emptyToNull(
                state.tracking.trackingController.text,
              ),
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
          : state.kindDetails.buildOwnedUpdatePayload(
              ownedRef: existingOwnedItem.ref,
              personal: state.personal,
            ),
      customFieldEdits: state.customFieldEdits,
      itemImageEdits: state.itemImageEdits,
      submitAction: submitAction,
    );
    return state.kindDetails.applySelectionEdits(baseSelection);
  }

  LibraryAddCommonDraft buildCommonDraft(LibraryEditShellState state) {
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

  JsonEncodable buildDetailsDraft(LibraryEditShellState state) {
    return libraryEditSessionForKind(state.type.kind).buildDetails(
      state.kindDetails,
    );
  }

  AddOwnedItemCommand toAddOwnedItemCommand(LibraryEditShellState state) {
    return libraryAddForKind(state.type.kind).buildCommandFromDetails(
      state.kindItem,
      buildCommonDraft(state),
      buildDetailsDraft(state),
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

  OwnedItemUpdateRequest toUpdateOwnedItemCommand(
    LibraryEditShellState state,
    OwnedItemRef ownedRef,
  ) {
    return libraryEditSessionForKind(state.type.kind).buildUpdateCommand(
      personal: state.personal,
      ownedRef: ownedRef,
      session: state.kindDetails,
    );
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
