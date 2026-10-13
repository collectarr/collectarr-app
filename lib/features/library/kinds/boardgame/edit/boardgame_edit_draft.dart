import 'package:collectarr_app/features/library/edit/draft/library_edit_form_fields.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_link_dto.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_library_entry_projection.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_personal_bindings.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

class BoardGameEditDraft
    with
        LibraryCatalogItemEditSessionLinkDefaults,
        LibraryEntryEditSessionDefaults
    implements
        LibraryCatalogItemEditSession,
        LibraryEntryEditSession,
        BoardGameCatalogFormDraft {
  BoardGameEditDraft({
    this.libraryEntry,
    this.editionLanguage,
    this.editionRegion,
    this.componentCondition,
    this.componentCompleteness,
    this.missingPiecesNotes,
    this.isSleeved = false,
    this.hasCustomInsert = false,
    this.hasPaintedMiniatures = false,
    this.storageNotes,
    required this.values,
    required this.catalogTitle,
    required this.externalLinks,
    required this.originalExternalLinks,
  });

  final BoardGameLibraryEntry? libraryEntry;

  @override
  final BoardGameCatalogFormValues values;

  @override
  String catalogTitle;

  String? editionLanguage;
  String? editionRegion;
  String? componentCondition;
  String? componentCompleteness;
  String? missingPiecesNotes;
  bool isSleeved;
  bool hasCustomInsert;
  bool hasPaintedMiniatures;
  String? storageNotes;
  final List<LibraryExternalLinkDraftRow> externalLinks;
  final Map<LibraryExternalLinkDraftRow, BoardGameLink> originalExternalLinks;
  bool _externalLinksEdited = false;

  void markExternalLinksEdited() => _externalLinksEdited = true;

  BoardGameLink _boardGameLinkFromDraft(
    LibraryExternalLinkDraftRow row,
    int position,
  ) {
    final original = originalExternalLinks[row];
    final title = _boardGameOptional(row.titleController.text);
    return BoardGameLink(
      url: row.urlController.text.trim(),
      id: original?.id,
      label: title,
      title: title,
      site: original?.site,
      name: original?.name,
      kind: original?.kind,
      description: _boardGameOptional(row.descriptionController.text),
      position: position,
      linkType: original?.linkType,
    );
  }

  void dispose() {
    for (final link in externalLinks) {
      link.dispose();
    }
  }

  @override
  void setExternalLinks(List<TrailerLinkDto> links) {
    for (final row in externalLinks) {
      row.dispose();
    }
    externalLinks.clear();
    originalExternalLinks.clear();
    for (final link in links) {
      final row = LibraryExternalLinkDraftRow(
        title: link.title ?? '',
        url: link.url,
        description: link.description ?? '',
      );
      externalLinks.add(row);
      originalExternalLinks[row] = BoardGameLink(
        url: link.url,
        title: link.title,
        label: link.title,
        description: link.description,
        kind: link.kind,
      );
    }
    _externalLinksEdited = true;
  }

  @override
  JsonEncodable toDetailsDraft() => BoardgameEntryDetailsDraft(
        editionLanguage: editionLanguage,
        editionRegion: editionRegion,
        componentCondition: componentCondition,
        componentCompleteness: componentCompleteness,
        missingPiecesNotes: missingPiecesNotes,
        isSleeved: isSleeved,
        hasCustomInsert: hasCustomInsert,
        hasPaintedMiniatures: hasPaintedMiniatures,
        storageNotes: storageNotes,
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
  BoardgameLibraryEntryUpdatePayload buildEntryUpdatePayload({
    required LibraryEntryRef libraryEntryRef,
    required LibraryEntryPersonalBindings personal,
  }) {
    return BoardgameLibraryEntryUpdatePayload(
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
      details: Patch.set(toDetailsDraft() as BoardgameEntryDetailsDraft),
    );
  }

  @override
  LibraryEditSelection applyCanonicalEdits(
    LibraryEditSelection selection,
    LibraryEditFormFields fields,
  ) =>
      selection;

  @override
  LibraryEditFormSchema buildCanonicalFormSchema(
    LibraryEditFormFields fields,
    CatalogSearchCandidate item,
  ) =>
      LibraryEditFormSchema.empty;

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    final metadata = _boardGameMetadataFor(selection.kindItem);
    if (metadata == null) return selection;
    var updated = applyBoardGameCatalogFormValues(
      current: metadata,
      values: values,
      title: catalogTitle,
    );
    if (_externalLinksEdited) {
      updated = BoardGameMetadata.fromJson({
        ...updated.toJson(),
        'external_links': [
          for (final (index, row) in externalLinks
              .where((row) => row.urlController.text.trim().isNotEmpty)
              .indexed)
            _boardGameLinkFromDraft(row, index + 1).toJson(),
        ],
      });
    }
    return selection.copyWith(
      kindItem: selection.kindItem.kindCapability.mapTransport(
        (transport) => CatalogSearchCandidate.fromItem(
          transport.replacingKindData(updated),
          basedOn: selection.kindItem,
        ),
      ),
    );
  }
}

BoardGameMetadata? _boardGameMetadataFor(CatalogSearchCandidate item) {
  if (item.summary.kind != CatalogMediaKind.boardgame) return null;
  return item.kindCapability.mapTransport(
    (transport) => BoardGameMetadata.fromJson(transport.kindData),
  );
}

LibraryEditSessionBundle createBoardGameEditDraft({
  required CatalogSearchCandidate item,
  LibraryEntryDispatch? libraryEntryDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
}) {
  final entry =
      BoardGameLibraryEntryProjection.fromDispatch(libraryEntryDispatch);
  final boardGame = _boardGameMetadataFor(item);
  if (boardGame == null) {
    throw StateError('Expected a Board Game catalog item for its edit draft.');
  }
  final entryDetails = entry?.personal.details;
  final linkRows = <LibraryExternalLinkDraftRow>[];
  final originalLinks = <LibraryExternalLinkDraftRow, BoardGameLink>{};
  for (final link in boardGame.externalLinks) {
    final row = _boardGameLinkDraftRow(link);
    linkRows.add(row);
    originalLinks[row] = link;
  }
  final draft = BoardGameEditDraft(
    libraryEntry: entry,
    editionLanguage: entryDetails?.editionLanguage,
    editionRegion: entryDetails?.editionRegion,
    componentCondition: entryDetails?.componentCondition,
    componentCompleteness: entryDetails?.componentCompleteness,
    missingPiecesNotes: entryDetails?.missingPiecesNotes,
    isSleeved: entryDetails?.isSleeved ?? false,
    hasCustomInsert: entryDetails?.hasCustomInsert ?? false,
    hasPaintedMiniatures: entryDetails?.hasPaintedMiniatures ?? false,
    storageNotes: entryDetails?.storageNotes,
    values: boardGameCatalogFormValuesFromMetadata(boardGame),
    catalogTitle: boardGame.title,
    externalLinks: linkRows,
    originalExternalLinks: originalLinks,
  );
  return LibraryEditSessionBundle(
    catalogItemSession: draft,
    entrySession: draft,
    disposeSession: draft.dispose,
  );
}

LibraryExternalLinkDraftRow _boardGameLinkDraftRow(BoardGameLink link) =>
    LibraryExternalLinkDraftRow(
      title: link.title ?? link.label ?? link.name ?? '',
      url: link.url,
      description: link.description ?? '',
    );

String? _boardGameOptional(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
