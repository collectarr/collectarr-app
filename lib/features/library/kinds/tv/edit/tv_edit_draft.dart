import 'package:collectarr_app/features/library/edit/draft/library_edit_form_fields.dart';
import 'package:collectarr_app/features/library/kinds/tv/catalog/tv_catalog_fields.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_library_entry_projection.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_release_media_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/tv/entries/tv_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/entries/tv_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft_contract.dart';

enum TvCanonicalEditField {
  title,
  displayTitle,
  sortTitle,
  originalTitle,
  localizedTitle,
  searchAliases,
  synopsis,
  coverImage,
  thumbnailImage
}

class TvEditDraft
    with
        LibraryCatalogItemEditSessionLinkDefaults,
        LibraryEntryEditSessionDefaults
    implements TvEditDraftContract {
  TvEditDraft({
    this.libraryEntry,
    required this.featuresController,
    required this.boxSetNameController,
    required this.regionController,
    required this.packagingController,
    required this.distributorController,
    required this.screenRatioController,
    required this.audioTracksController,
    required this.subtitlesController,
    required this.layersController,
    required this.colorController,
    required this.nrDiscsController,
    required this.hdrFormats,
    required this.seasonNumberController,
    required this.episodeNumberController,
    required this.episodeRatings,
    required this.tvEdit,
    required this.releaseMediaEdit,
  });

  final TvLibraryEntry? libraryEntry;

  @override
  final TextEditingController featuresController;
  @override
  final TextEditingController boxSetNameController;
  @override
  final TextEditingController regionController;
  @override
  final TextEditingController packagingController;
  @override
  final TextEditingController distributorController;
  @override
  final TextEditingController screenRatioController;
  @override
  final TextEditingController audioTracksController;
  @override
  final TextEditingController subtitlesController;
  @override
  final TextEditingController layersController;
  @override
  final TextEditingController colorController;
  @override
  final TextEditingController nrDiscsController;

  @override
  List<String> hdrFormats;
  final TextEditingController seasonNumberController;
  final TextEditingController episodeNumberController;
  final Map<String, int> episodeRatings;
  @override
  final TvEditController tvEdit;
  final TvReleaseMediaEditController releaseMediaEdit;

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
  void initializePersonalState(PersonalStateDraft personal) {
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
    required PersonalStateDraft personal,
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
    final aliases = fields
        .controller(TvCanonicalEditField.searchAliases)
        .text
        .split(RegExp(r'[,\r\n]+'))
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
    return selection.copyWith(
      kindItem: CatalogSearchCandidate.fromItem(
          selection.kindItem.kindCapability.mapTransport((transport) {
        final updated = transport.copyWith(
          title: fields.controller(TvCanonicalEditField.title).text.trim(),
          displayTitle: emptyToNull(
              fields.controller(TvCanonicalEditField.displayTitle).text),
          originalTitle: emptyToNull(
              fields.controller(TvCanonicalEditField.originalTitle).text),
          localizedTitle: emptyToNull(
              fields.controller(TvCanonicalEditField.localizedTitle).text),
          searchAliases: aliases.isEmpty ? null : aliases,
          synopsis: emptyToNull(
              fields.controller(TvCanonicalEditField.synopsis).text),
          coverImageUrl: emptyToNull(
              fields.controller(TvCanonicalEditField.coverImage).text),
          thumbnailImageUrl: emptyToNull(
              fields.controller(TvCanonicalEditField.thumbnailImage).text),
        );
        return _withTvSortKey(
          updated,
          emptyToNull(
            fields.controller(TvCanonicalEditField.sortTitle).text,
          ),
        );
      })),
    );
  }

  @override
  LibraryEditFormSchema buildCanonicalFormSchema(
    LibraryEditFormFields fields,
    CatalogSearchCandidate item,
  ) {
    final metadata = item.tvCatalogFields;
    fields.create(TvCanonicalEditField.title, initialValue: metadata.title);
    fields.create(TvCanonicalEditField.displayTitle,
        initialValue: metadata.displayTitle ?? '');
    fields.create(TvCanonicalEditField.sortTitle,
        initialValue: metadata.sortKey ?? '');
    fields.create(TvCanonicalEditField.originalTitle,
        initialValue: metadata.originalTitle ?? '');
    fields.create(TvCanonicalEditField.localizedTitle,
        initialValue: metadata.localizedTitle ?? '');
    fields.create(TvCanonicalEditField.searchAliases,
        initialValue: metadata.searchAliases.join(', '));
    fields.create(TvCanonicalEditField.synopsis,
        initialValue: metadata.synopsis ?? '');
    fields.create(TvCanonicalEditField.coverImage,
        initialValue: metadata.coverImageUrl ?? '');
    fields.create(TvCanonicalEditField.thumbnailImage,
        initialValue: metadata.thumbnailImageUrl ?? '');
    return LibraryEditFormSchema(
      fields: [
        LibraryEditFormFieldSpec(
          id: TvCanonicalEditField.title,
          section: LibraryEditFormSection.details,
          controller: fields.controller(TvCanonicalEditField.title),
          label: 'Title',
          required: true,
        ),
        LibraryEditFormFieldSpec(
          id: TvCanonicalEditField.sortTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(TvCanonicalEditField.sortTitle),
          label: 'Sort title',
        ),
        LibraryEditFormFieldSpec(
          id: TvCanonicalEditField.originalTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(TvCanonicalEditField.originalTitle),
          label: 'Original title',
        ),
        LibraryEditFormFieldSpec(
          id: TvCanonicalEditField.localizedTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(TvCanonicalEditField.localizedTitle),
          label: 'Localized title',
        ),
        LibraryEditFormFieldSpec(
          id: TvCanonicalEditField.displayTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(TvCanonicalEditField.displayTitle),
          label: 'Display title',
        ),
        LibraryEditFormFieldSpec(
          id: TvCanonicalEditField.searchAliases,
          section: LibraryEditFormSection.details,
          controller: fields.controller(TvCanonicalEditField.searchAliases),
          label: 'Search aliases',
          visible: false,
        ),
        LibraryEditFormFieldSpec(
          id: TvCanonicalEditField.thumbnailImage,
          section: LibraryEditFormSection.details,
          controller: fields.controller(TvCanonicalEditField.thumbnailImage),
          label: 'Thumbnail image URL',
          visible: false,
        ),
        LibraryEditFormFieldSpec(
          id: TvCanonicalEditField.coverImage,
          section: LibraryEditFormSection.artwork,
          controller: fields.controller(TvCanonicalEditField.coverImage),
          label: 'Cover Image URL',
        ),
        LibraryEditFormFieldSpec(
          id: TvCanonicalEditField.synopsis,
          section: LibraryEditFormSection.description,
          controller: fields.controller(TvCanonicalEditField.synopsis),
          label: 'Synopsis',
          maxLines: 8,
        ),
      ],
      sectionTitles: const {
        LibraryEditFormSection.details: 'Details',
        LibraryEditFormSection.artwork: 'Cover Image',
        LibraryEditFormSection.description: 'Synopsis',
      },
    );
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    var result = selection;
    final seasonNumber = int.tryParse(seasonNumberController.text);
    final episodeNumber = int.tryParse(episodeNumberController.text);
    final metadata = result.kindItem.kindCapability.mapTransport(
        (transport) => TvSeriesMetadata.fromJson(transport.kindData));
    final parsedGenres = tvEdit.genresEditController.text
        .split(RegExp(r'[,\r\n]+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    result = result.copyWith(
      kindItem: result.kindItem.kindCapability.mapTransport(
        (transport) => CatalogSearchCandidate.fromItem(
          transport.withKindData(
            metadata.copyWith(
              episodeRuntimeMinutes:
                  int.tryParse(tvEdit.runtimeController.text),
              genres: parsedGenres.isNotEmpty ? parsedGenres : metadata.genres,
              cast: tvEdit.castCredits
                  .map(_editedTvCredit)
                  .where((credit) => credit.name.isNotEmpty)
                  .toList(),
              crew: tvEdit.crewCredits
                  .map(_editedTvCredit)
                  .where((credit) => credit.name.isNotEmpty)
                  .toList(),
              contentRating: emptyToNull(tvEdit.ageRatingController.text),
              variant: emptyToNull(tvEdit.variantController.text),
              barcode: emptyToNull(tvEdit.barcodeController.text),
              physicalFormat: tvEdit.physicalFormatId,
              physicalFormatLabel:
                  emptyToNull(tvEdit.physicalFormatLabelController.text),
              publisher: emptyToNull(tvEdit.publisherController.text),
              country: emptyToNull(tvEdit.countryController.text) ??
                  metadata.country,
              originalLanguage: emptyToNull(tvEdit.languageController.text) ??
                  metadata.originalLanguage,
              firstAirDate: parseDate(tvEdit.releaseDateController.text),
              links: tvEdit.buildUpdatedTrailerUrls(metadata.links),
              seasonNumber: seasonNumber ?? metadata.seasonNumber,
              episodeNumber: episodeNumber ?? metadata.episodeNumber,
            ),
          ),
        ),
      ),
    );
    if (result.tracking != null) {
      final episodeRatings = this.episodeRatings.isEmpty
          ? null
          : Map<String, int>.unmodifiable(this.episodeRatings);
      result = result.copyWith(
        trackingKindPatch: TvTrackingCoordinatesPatch(
          seasonNumber: seasonNumber,
          episodeNumber: episodeNumber,
          episodeRatings: episodeRatings,
          setSeasonNumber: seasonNumber != null,
          setEpisodeNumber: episodeNumber != null,
          setEpisodeRatings: episodeRatings != null,
        ),
      );
    }
    return result;
  }

  @override
  TextEditingController get releaseDateController =>
      tvEdit.releaseDateController;

  @override
  TextEditingController get releaseYearController =>
      tvEdit.releaseYearController;

  void dispose() {
    seasonNumberController.dispose();
    episodeNumberController.dispose();
    tvEdit.dispose();
  }
}

CatalogItemDto _withTvSortKey(CatalogItemDto item, String? sortKey) {
  final kindData = Map<String, dynamic>.from(item.kindData)
    ..remove('sort_title');
  if (sortKey == null) {
    kindData.remove('sort_key');
  } else {
    kindData['sort_key'] = sortKey;
  }
  return item.withKindData(TvSeriesMetadata.fromJson(kindData));
}

LibraryEditSessionBundle createTvEditDraft({
  required CatalogSearchCandidate item,
  LibraryEntryDispatch? libraryEntryDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
}) {
  final entry = TvLibraryEntryProjection.fromDispatch(libraryEntryDispatch);
  final video = entry?.personal.details;
  final metadata = item.kindCapability.mapTransport(
      (transport) => TvSeriesMetadata.fromJson(transport.kindData));
  final tv = metadata;
  final tvEdit = TvEditController(
    itemId: item.reference.id,
    catalogRef: item.reference,
    initialRuntime: tv.episodeRuntimeMinutes?.toString() ?? '',
    initialAgeRating: tv.contentRating ?? '',
    initialGenres: tv.genres.join(', '),
    initialEditionTitle: (tv.titleExtension ?? tv.editionTitle)?.trim() ?? '',
    initialVariant: tv.variant ?? '',
    initialBarcode: tv.barcode ?? '',
    initialPhysicalFormatLabel: tv.physicalFormatLabel ?? tv.variant ?? '',
    initialPhysicalFormatId: tv.physicalFormat,
    initialPublisher: tv.publisher ?? tv.network ?? '',
    initialCountry: tv.country,
    initialLanguage: tv.originalLanguage,
    initialReleaseDate:
        tv.firstAirDate == null ? '' : formatDate(tv.firstAirDate!),
    initialReleaseYear: tv.firstAirDate?.year.toString() ?? '',
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
  final releaseMediaEdit = TvReleaseMediaEditController(
    item: item.kindCapability.mapTransport((transport) => transport),
    initialDiscCount: tv.media.length,
  );
  tvEdit.initializeTvEditors();

  final draft = TvEditDraft(
    libraryEntry: entry,
    featuresController: textControllers.create(text: video?.features ?? ''),
    boxSetNameController: textControllers.create(text: video?.boxSetName ?? ''),
    regionController: textControllers.create(text: video?.region ?? ''),
    packagingController: textControllers.create(text: video?.packaging ?? ''),
    distributorController:
        textControllers.create(text: video?.distributor ?? ''),
    screenRatioController: textControllers.create(text: ''),
    audioTracksController: textControllers.create(text: ''),
    subtitlesController: textControllers.create(text: ''),
    layersController: textControllers.create(text: ''),
    colorController: textControllers.create(text: ''),
    nrDiscsController: textControllers.create(text: ''),
    hdrFormats: List<String>.from(video?.hdrFormats ?? const <String>[]),
    seasonNumberController: TextEditingController(
      text: tv.seasonNumber?.toString() ?? '',
    ),
    episodeNumberController: TextEditingController(
      text: tv.episodeNumber?.toString() ?? '',
    ),
    episodeRatings: const <String, int>{},
    tvEdit: tvEdit,
    releaseMediaEdit: releaseMediaEdit,
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
