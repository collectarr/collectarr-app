import 'package:collectarr_app/features/library/edit/draft/library_edit_form_fields.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_library_entry_projection.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_external_links_edit_session.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_credit_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_catalog_form_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_media_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/tv/entries/tv_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/entries/tv_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_personal_bindings.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

class TvEditDraft
    with
        LibraryCatalogItemEditSessionLinkDefaults,
        LibraryEntryEditSessionDefaults
    implements LibraryEntryExternalLinksSource, TvCatalogFormDraft {
  TvEditDraft({
    this.libraryEntry,
    required this.metadata,
    required this.catalogTitle,
    required this.featuresController,
    required this.boxSetNameController,
    required this.regionController,
    required this.packagingController,
    required this.distributorController,
    required this.hdrFormats,
    required this.tvEdit,
    required this.mediaEdit,
  });

  final TvLibraryEntry? libraryEntry;

  @override
  TvMetadata metadata;

  @override
  String catalogTitle;

  final TextEditingController featuresController;
  final TextEditingController boxSetNameController;
  final TextEditingController regionController;
  final TextEditingController packagingController;
  final TextEditingController distributorController;
  List<String> hdrFormats;
  final TvEditController tvEdit;

  @override
  Iterable<TrailerLinkDto> get legacyManualExternalLinks =>
      tvEdit.initialTrailerLinks;
  final TvMediaEditController mediaEdit;

  @override
  JsonEncodable toDetailsDraft() => TvEntryDetailsDraft(
        features: emptyToNull(featuresController.text),
        hdrFormats: hdrFormats,
        boxSetName: emptyToNull(boxSetNameController.text),
        region: emptyToNull(regionController.text),
        packaging: emptyToNull(packagingController.text),
        distributor: emptyToNull(distributorController.text),
      );

  @override
  void initializePersonalState(LibraryEntryPersonalBindings personal) {
    final item = libraryEntry;
    if (item == null) return;
    personal.ownerLabelController.text = item.personal.ownerLabel ?? '';
    personal.conditionController.text = item.personal.condition ?? '';
    personal.gradeController.text = item.personal.grade ?? '';
    personal.purchaseDateController.text = item.personal.purchaseDate == null
        ? ''
        : formatDate(item.personal.purchaseDate!);
    personal.priceController.text = item.personal.pricePaidCents == null
        ? ''
        : (item.personal.pricePaidCents! / 100).toStringAsFixed(2);
    personal.currencyController.text = item.personal.currency ?? '';
    personal.indexNumberController.text =
        item.personal.indexNumber?.toString() ?? '';
    personal.notesController.text = item.personal.personalNotes ?? '';
    personal.tagsController.text = item.personal.tags ?? '';
    personal.sellPriceController.text = item.personal.sellPriceCents == null
        ? ''
        : (item.personal.sellPriceCents! / 100).toStringAsFixed(2);
    personal.soldToController.text = item.personal.soldTo ?? '';
    personal.purchaseStoreController.text = item.personal.purchaseStore ?? '';
    personal.marketValueController.text = item.personal.marketValueCents == null
        ? ''
        : (item.personal.marketValueCents! / 100).toStringAsFixed(2);
    personal.selectedLocationId = item.personal.locationId;
    personal.soldAt = item.personal.soldAt;
    personal.collectionStatus = item.personal.collectionStatus;
  }

  @override
  TvLibraryEntryUpdatePayload buildEntryUpdatePayload({
    required LibraryEntryRef libraryEntryRef,
    required LibraryEntryPersonalBindings personal,
  }) {
    return TvLibraryEntryUpdatePayload(
      isDigital: const Patch.unchanged(),
      marketValueCents: const Patch.unchanged(),
      indexNumber: const Patch.unchanged(),
      condition: personal.conditionController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.conditionController.text.trim()),
      grade: personal.gradeController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.gradeController.text.trim()),
      purchaseDate: personal.purchaseDateController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseDate(personal.purchaseDateController.text)),
      pricePaidCents: personal.priceController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseMoneyCents(personal.priceController.text)),
      currency: personal.currencyController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.currencyController.text.trim()),
      personalNotes: personal.notesController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.notesController.text.trim()),
      locationId: personal.selectedLocationId != null
          ? Patch.set(personal.selectedLocationId)
          : const Patch.clear(),
      purchaseStore: personal.purchaseStoreController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.purchaseStoreController.text.trim()),
      collectionStatus: personal.collectionStatus != null
          ? Patch.set(personal.collectionStatus)
          : const Patch.clear(),
      tags: personal.tagsController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.tagsController.text.trim()),
      soldAt: personal.soldAt != null
          ? Patch.set(personal.soldAt)
          : const Patch.clear(),
      sellPriceCents: personal.sellPriceController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseMoneyCents(personal.sellPriceController.text)),
      soldTo: personal.soldToController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.soldToController.text.trim()),
      details: Patch.set(toDetailsDraft() as TvEntryDetailsDraft),
    );
  }

  @override
  LibraryEditSelection applyCanonicalEdits(
    LibraryEditSelection selection,
    LibraryEditFormFields fields,
  ) {
    return selection.copyWith(
      kindItem: CatalogSearchCandidate.fromItem(
        selection.kindItem.kindCapability.mapTransport((transport) {
          return transport.replacingKindData(
            mediaEdit.applyEpisodeMediaAssignments(
              metadata.copyWith(title: catalogTitle.trim()),
            ),
          );
        }),
        basedOn: selection.kindItem,
      ),
    );
  }

  @override
  LibraryEditFormSchema buildCanonicalFormSchema(
    LibraryEditFormFields fields,
    CatalogSearchCandidate item,
  ) =>
      LibraryEditFormSchema.empty;

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    final metadata = selection.kindItem.kindCapability
        .mapTransport((transport) => TvMetadata.fromJson(transport.kindData));
    return selection.copyWith(
      kindItem: selection.kindItem.kindCapability.mapTransport(
        (transport) => CatalogSearchCandidate.fromItem(
          transport.replacingKindData(
            metadata.copyWith(
              cast: tvEdit.castCredits
                  .map(_editedTvCredit)
                  .where((credit) => credit.name.isNotEmpty)
                  .toList(),
              crew: tvEdit.crewCredits
                  .map(_editedTvCredit)
                  .where((credit) => credit.name.isNotEmpty)
                  .toList(),
              links: tvEdit.buildUpdatedTrailerUrls(
                metadata.links,
                preserveManualLinks: libraryEntry == null,
              ),
            ),
          ),
          basedOn: selection.kindItem,
        ),
      ),
    );
  }

  void dispose() {
    tvEdit.dispose();
  }
}

LibraryEditSessionBundle createTvEditDraft({
  required CatalogSearchCandidate item,
  LibraryEntryDispatch? libraryEntryDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
}) {
  final entry = TvLibraryEntryProjection.fromDispatch(libraryEntryDispatch);
  final video = entry?.personal.details;
  final metadata = item.kindCapability
      .mapTransport((transport) => TvMetadata.fromJson(transport.kindData));
  final tv = metadata;
  final tvEdit = TvEditController(
    initialCreators: [
      for (final creator in tv.creators)
        TvCreditInput(
          name: creator.name,
          role: creator.role,
          originalCredit: creator,
        ),
    ],
    initialTrailerLinks: tv.links,
  );
  final mediaEdit = TvMediaEditController(
    item: item.kindCapability.mapTransport((transport) => transport),
    initialDiscCount: tv.media.length,
  );
  tvEdit.initializeTvEditors();

  final draft = TvEditDraft(
    libraryEntry: entry,
    metadata: tv,
    catalogTitle: tv.title,
    featuresController: textControllers.create(text: video?.features ?? ''),
    boxSetNameController: textControllers.create(text: video?.boxSetName ?? ''),
    regionController: textControllers.create(text: video?.region ?? ''),
    packagingController: textControllers.create(text: video?.packaging ?? ''),
    distributorController:
        textControllers.create(text: video?.distributor ?? ''),
    hdrFormats: List<String>.from(video?.hdrFormats ?? const <String>[]),
    tvEdit: tvEdit,
    mediaEdit: mediaEdit,
  );
  return LibraryEditSessionBundle(
    catalogItemSession: draft,
    entrySession: draft,
    disposeSession: draft.dispose,
  );
}

TvPersonCredit _editedTvCredit(EditableTvCredit credit) {
  final name = credit.nameController.text.trim();
  final role = emptyToNull(credit.roleController.text.trim());
  return credit.originalCredit?.withEditedIdentity(name: name, role: role) ??
      TvPersonCredit(name: name, role: role);
}
