import 'package:collectarr_app/features/library/edit/draft/library_edit_form_fields.dart';
import 'package:collectarr_app/features/library/kinds/movie/catalog/movie_catalog_fields.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_library_entry_projection.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_external_links_edit_session.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_credit_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_format_value.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_personal_bindings.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_draft_contract.dart';

List<String> _splitValues(String value) => value
    .split(RegExp(r'[,;\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);

String? _joinValues(List<String> values) {
  final normalized = values
      .map((entry) => entry.trim())
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
  return normalized.isEmpty ? null : normalized.join(', ');
}

class MovieEditDraft
    with
        LibraryCatalogItemEditSessionLinkDefaults,
        LibraryEntryEditSessionDefaults
    implements MovieEditDraftContract {
  MovieEditDraft({
    this.libraryEntry,
    required this.catalogValues,
    required this.featuresController,
    required this.boxSetNameController,
    required this.regionController,
    required this.packagingController,
    required this.distributorController,
    required this.hdrFormats,
    required this.movieEdit,
  });

  final MovieLibraryEntry? libraryEntry;

  @override
  final MovieCatalogFormValues catalogValues;

  final TextEditingController featuresController;
  final TextEditingController boxSetNameController;
  final TextEditingController regionController;
  final TextEditingController packagingController;
  final TextEditingController distributorController;

  List<String> hdrFormats;
  @override
  final MovieEditController movieEdit;

  @override
  JsonEncodable toDetailsDraft() => MovieEntryDetailsDraft(
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
  MovieLibraryEntryUpdatePayload buildEntryUpdatePayload({
    required LibraryEntryRef libraryEntryRef,
    required LibraryEntryPersonalBindings personal,
  }) {
    return MovieLibraryEntryUpdatePayload(
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
      details: Patch.set(toDetailsDraft() as MovieEntryDetailsDraft),
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
    final meta = selection.kindItem.kindCapability.mapTransport(
        (transport) => MovieCatalogMetadata.fromJson(transport.kindData));
    final values = catalogValues;
    final releaseDateParts = values.releaseDateParts;
    final aliases = _splitValues(values.searchAliases);
    final contributors = [
      for (final credit in [
        ...movieEdit.castCredits,
        ...movieEdit.crewCredits,
      ])
        if (credit.nameController.text.trim().isNotEmpty)
          MoviePersonCredit(
            name: credit.nameController.text.trim(),
            role: emptyToNull(credit.roleController.text.trim()),
          ),
    ];
    final format = moviePhysicalFormatId(values.format);
    final updatedMeta = MovieCatalogMetadata.fromJson(applyJsonFieldPatch(
      meta.copyWith(
        title: values.title.trim(),
        displayTitle: emptyToNull(values.displayTitle),
        sortTitle: emptyToNull(values.sortTitle),
        originalTitle: emptyToNull(values.originalTitle),
        localizedTitle: emptyToNull(values.localizedTitle),
        searchAliases: aliases,
        synopsis: emptyToNull(values.synopsis),
        coverImageUrl: emptyToNull(values.coverImageUrl),
        genres: List<String>.unmodifiable(values.genres),
        runtimeMinutes: values.runtimeMinutes,
        ageRating: emptyToNull(values.ageRating),
        audienceRating: emptyToNull(values.audienceRating),
        country: emptyToNull(values.region),
        originalLanguage: emptyToNull(values.originalLanguage),
        language: emptyToNull(values.language),
        releaseDate: releaseDateParts?.asDateTime,
        releaseDateParts: releaseDateParts,
        subtitle: emptyToNull(values.subtitle),
        editionTitle: emptyToNull(values.editionTitle),
        barcode: emptyToNull(values.barcode),
        physicalFormat: format,
        publisher: emptyToNull(values.distributor),
        studio: emptyToNull(values.distributor),
        variant: emptyToNull(values.variant),
        itemNumber: emptyToNull(values.itemNumber),
        audioTracks: _joinValues(values.audioTracks),
        subtitles: _joinValues(values.subtitles),
        color: emptyToNull(values.color),
        nrDiscs: values.nrDiscs,
        screenRatio: emptyToNull(values.screenRatio),
        layers: emptyToNull(values.layers),
        characters: List<MovieCharacter>.unmodifiable(values.characters),
        creators: const [],
        contributors: contributors,
        links: movieEdit.buildUpdatedTrailerUrls(
          meta.links,
          preserveManualLinks: libraryEntry == null,
        ),
      ),
      {
        'title': values.title.trim(),
        'display_title': emptyToNull(values.displayTitle),
        'sort_key': emptyToNull(values.sortTitle),
        'original_title': emptyToNull(values.originalTitle),
        'localized_title': emptyToNull(values.localizedTitle),
        'search_aliases': aliases,
        'synopsis': emptyToNull(values.synopsis),
        'cover_image_url': emptyToNull(values.coverImageUrl),
        'genres': List<String>.of(values.genres),
        'runtime_minutes': values.runtimeMinutes,
        'age_rating': emptyToNull(values.ageRating),
        'audience_rating': emptyToNull(values.audienceRating),
        'country': emptyToNull(values.region),
        'original_language': emptyToNull(values.originalLanguage),
        'language': emptyToNull(values.language),
        'release_date': releaseDateParts?.isoString,
        'release_date_parts': releaseDateParts?.toJson(),
        'subtitle': emptyToNull(values.subtitle),
        'edition_title': emptyToNull(values.editionTitle),
        'barcode': emptyToNull(values.barcode),
        'physical_format': format,
        'publisher': emptyToNull(values.distributor),
        'studio': emptyToNull(values.distributor),
        'variant_name': emptyToNull(values.variant),
        'item_number': emptyToNull(values.itemNumber),
        'audio_tracks': _joinValues(values.audioTracks),
        'subtitles': _joinValues(values.subtitles),
        'color': emptyToNull(values.color),
        'nr_discs': values.nrDiscs,
        'screen_ratio': emptyToNull(values.screenRatio),
        'layers': emptyToNull(values.layers),
        'characters': [
          for (final character in values.characters)
            if (character.name.trim().isNotEmpty) character.toJsonValue(),
        ],
      },
    ));
    return selection.copyWith(
      kindItem: selection.kindItem.kindCapability.mapTransport(
        (transport) => CatalogSearchCandidate.fromItem(
          transport.replacingKindData(updatedMeta),
          basedOn: selection.kindItem,
        ),
      ),
    );
  }

  void dispose() {
    movieEdit.dispose();
  }
}

LibraryEditSessionBundle createMovieEditDraft({
  required CatalogSearchCandidate item,
  LibraryEntryDispatch? libraryEntryDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
}) {
  final entry = MovieLibraryEntryProjection.fromDispatch(libraryEntryDispatch);
  final video = entry?.personal.details;
  final metadata = item.kindCapability.mapTransport(
      (transport) => MovieCatalogMetadata.fromJson(transport.kindData));
  final movie = metadata;
  final catalogValues = MovieCatalogFormValues.fromMetadata(movie);
  if (catalogValues.editionTitle.trim().isEmpty) {
    catalogValues.editionTitle = (item.movieCatalogFields.titleExtension ??
                item.movieCatalogFields.metadata?.editionTitle)
            ?.trim() ??
        '';
  }
  final movieEdit = MovieEditController(
    initialCreators: [
      for (final creator in movie.allPeople)
        MovieCreditInput(
          name: creator.name,
          role: creator.role,
        ),
    ],
    initialTrailerLinks: movie.links,
  );

  final draft = MovieEditDraft(
    libraryEntry: entry,
    catalogValues: catalogValues,
    featuresController: textControllers.create(text: video?.features ?? ''),
    boxSetNameController: textControllers.create(text: video?.boxSetName ?? ''),
    regionController: textControllers.create(text: video?.region ?? ''),
    packagingController: textControllers.create(text: video?.packaging ?? ''),
    distributorController:
        textControllers.create(text: video?.distributor ?? ''),
    hdrFormats: List<String>.from(video?.hdrFormats ?? const <String>[]),
    movieEdit: movieEdit,
  );
  return LibraryEditSessionBundle(
    catalogItemSession: draft,
    entrySession: draft,
    disposeSession: draft.dispose,
  );
}
