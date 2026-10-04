import 'package:collectarr_app/features/library/edit/draft/library_edit_form_fields.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_library_entry_projection.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_external_links_edit_session.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/forms/anime_credit_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata_children.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/anime/entries/anime_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/entries/anime_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_draft_contract.dart';

enum AnimeCanonicalEditField {
  title,
  displayTitle,
  sortTitle,
  originalTitle,
  localizedTitle,
  searchAliases,
  synopsis,
  coverImage,
  thumbnailImage,
  episodeRuntime,
  genres,
  editionTitle,
  variant,
  barcode,
  physicalFormatLabel,
  publisher,
  country,
  language,
  releaseDate,
  releaseYear,
  ageRating,
  audienceRating,
}

class AnimeEditDraft
    with
        LibraryCatalogItemEditSessionLinkDefaults,
        LibraryEntryEditSessionDefaults
    implements AnimeEditDraftContract, LibraryEntryExternalLinksSource {
  AnimeEditDraft({
    this.libraryEntry,
    required this.metadata,
    required this.catalogTitle,
    List<AnimeCharacterMetadata>? characterBaseline,
    required this.featuresController,
    required this.boxSetNameController,
    required this.regionController,
    required this.packagingController,
    required this.distributorController,
    required this.hdrFormats,
    required this.seasonNumberController,
    required this.episodeNumberController,
    required this.episodeRatings,
    required this.animeEdit,
    this.physicalFormatId,
  }) : characterBaseline =
            characterBaseline ?? List.unmodifiable(metadata.characters);

  final AnimeLibraryEntry? libraryEntry;

  @override
  AnimeMetadata metadata;

  @override
  final List<AnimeCharacterMetadata> characterBaseline;

  @override
  String catalogTitle;

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
  List<String> hdrFormats;
  final TextEditingController seasonNumberController;
  final TextEditingController episodeNumberController;
  final Map<String, int> episodeRatings;
  @override
  final AnimeEditController animeEdit;

  @override
  Iterable<TrailerLinkDto> get legacyManualExternalLinks =>
      animeEdit.initialTrailerLinks;
  @override
  String? physicalFormatId;

  @override
  JsonEncodable toDetailsDraft() => AnimeEntryDetailsDraft(
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
  AnimeLibraryEntryUpdatePayload buildEntryUpdatePayload({
    required LibraryEntryRef libraryEntryRef,
    required PersonalStateDraft personal,
  }) {
    return AnimeLibraryEntryUpdatePayload(
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
      details: Patch.set(toDetailsDraft() as AnimeEntryDetailsDraft),
    );
  }

  @override
  LibraryEditSelection applyCanonicalEdits(
    LibraryEditSelection selection,
    LibraryEditFormFields _,
  ) {
    // Anime Add and Edit share kind-owned schema fields. Their typed metadata
    // draft is the only source of truth for all metadata controls.
    final metadata = this.metadata;
    final aliases = metadata.searchAliases;
    final characters = metadata.characters;
    return selection.copyWith(
      kindItem: CatalogSearchCandidate.fromItem(
          selection.kindItem.kindCapability.mapTransport((transport) {
        final edited = metadata.copyWith(
          title: catalogTitle.trim(),
          physicalFormat: physicalFormatId,
          creators: animeEdit.buildUpdatedCreators(),
          characters: characters,
          links: animeEdit.buildUpdatedTrailerUrls(
            metadata.links,
            preserveManualLinks: libraryEntry == null,
          ),
        );
        final updated = AnimeMetadata.fromJson(applyJsonFieldPatch(edited, {
          'display_title': metadata.displayTitle,
          'original_title': metadata.originalTitle,
          'localized_title': metadata.localizedTitle,
          'search_aliases': aliases,
          'synopsis': metadata.synopsis,
          'cover_image_url': metadata.coverImageUrl,
          'thumbnail_image_url': metadata.thumbnailImageUrl,
          'sort_key': metadata.sortKey,
          'episode_runtime_minutes': metadata.episodeRuntimeMinutes,
          'genres': metadata.genres,
          'themes': metadata.themes,
          'format': metadata.format.name,
          'season': metadata.season?.name,
          'source_material': metadata.sourceMaterial.name,
          'airing_status': metadata.airingStatus.name,
          'season_year': metadata.seasonYear,
          'episode_count': metadata.episodeCount,
          'start_date': metadata.startDate?.toIso8601String(),
          'end_date': metadata.endDate?.toIso8601String(),
          'studios': metadata.studios,
          'producers': metadata.producers,
          'licensors': metadata.licensors,
          'country': metadata.country,
          'language': metadata.language,
          'alternate_titles': metadata.alternateTitles,
          'native_title': metadata.nativeTitle,
          'romaji_title': metadata.romajiTitle,
          'english_title': metadata.englishTitle,
          'characters':
              characters.map((character) => character.toJsonValue()).toList(),
          'edition_title': metadata.editionTitle,
          'variant_name': metadata.variant,
          'barcode': metadata.barcode,
          'physical_format': physicalFormatId,
          'physical_format_label': metadata.physicalFormatLabel,
          'publisher': metadata.publisher,
          'release_date_parts': metadata.releaseDateParts?.toJson(),
          'release_year': metadata.releaseYear,
          'age_rating': metadata.ageRating,
          'audience_rating': metadata.audienceRating,
          'audio_tracks': metadata.audioTracks,
          'subtitles': metadata.subtitles,
          'screen_ratio': metadata.screenRatio,
          'layers': metadata.layers,
          'color': metadata.color,
          'nr_discs': metadata.nrDiscs,
        }));
        return transport.replacingKindData(updated);
      })),
    );
  }

  @override
  LibraryEditFormSchema buildCanonicalFormSchema(
    LibraryEditFormFields fields,
    CatalogSearchCandidate item,
  ) {
    final metadata = item.kindCapability.mapTransport(
        (transport) => AnimeMetadata.fromJson(transport.kindData));
    fields.create(AnimeCanonicalEditField.title, initialValue: metadata.title);
    fields.create(AnimeCanonicalEditField.displayTitle,
        initialValue: metadata.displayTitle ?? '');
    fields.create(AnimeCanonicalEditField.sortTitle,
        initialValue: metadata.sortKey ?? '');
    fields.create(AnimeCanonicalEditField.originalTitle,
        initialValue: metadata.originalTitle ?? '');
    fields.create(AnimeCanonicalEditField.localizedTitle,
        initialValue: metadata.localizedTitle ?? '');
    fields.create(AnimeCanonicalEditField.searchAliases,
        initialValue: metadata.searchAliases.join(', '));
    fields.create(AnimeCanonicalEditField.synopsis,
        initialValue: metadata.synopsis ?? '');
    fields.create(AnimeCanonicalEditField.coverImage,
        initialValue: metadata.coverImageUrl ?? '');
    fields.create(AnimeCanonicalEditField.thumbnailImage,
        initialValue: metadata.thumbnailImageUrl ?? '');
    fields.create(
      AnimeCanonicalEditField.episodeRuntime,
      initialValue: metadata.episodeRuntimeMinutes?.toString() ?? '',
    );
    fields.create(
      AnimeCanonicalEditField.genres,
      initialValue: metadata.genres.join(', '),
    );
    fields.create(
      AnimeCanonicalEditField.editionTitle,
      initialValue: metadata.editionTitle ?? metadata.titleExtension ?? '',
    );
    fields.create(
      AnimeCanonicalEditField.variant,
      initialValue: metadata.variant ?? '',
    );
    fields.create(
      AnimeCanonicalEditField.barcode,
      initialValue: metadata.barcode ?? '',
    );
    fields.create(
      AnimeCanonicalEditField.physicalFormatLabel,
      initialValue: metadata.physicalFormatLabel ?? metadata.variant ?? '',
    );
    fields.create(
      AnimeCanonicalEditField.publisher,
      initialValue: metadata.publisher ?? '',
    );
    fields.create(
      AnimeCanonicalEditField.country,
      initialValue: metadata.country,
    );
    fields.create(
      AnimeCanonicalEditField.language,
      initialValue: metadata.language,
    );
    fields.create(
      AnimeCanonicalEditField.releaseDate,
      initialValue:
          metadata.startDate == null ? '' : formatDate(metadata.startDate!),
    );
    fields.create(
      AnimeCanonicalEditField.releaseYear,
      initialValue: (metadata.releaseYear ?? metadata.seasonYear)?.toString() ??
          metadata.startDate?.year.toString() ??
          '',
    );
    fields.create(
      AnimeCanonicalEditField.ageRating,
      initialValue: metadata.ageRating ?? '',
    );
    fields.create(
      AnimeCanonicalEditField.audienceRating,
      initialValue: metadata.audienceRating ?? '',
    );
    physicalFormatId = metadata.physicalFormat;
    return LibraryEditFormSchema(
      fields: [
        LibraryEditFormFieldSpec(
          id: AnimeCanonicalEditField.title,
          section: LibraryEditFormSection.details,
          controller: fields.controller(AnimeCanonicalEditField.title),
          label: 'Title',
          required: true,
        ),
        LibraryEditFormFieldSpec(
          id: AnimeCanonicalEditField.sortTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(AnimeCanonicalEditField.sortTitle),
          label: 'Sort Title',
        ),
        LibraryEditFormFieldSpec(
          id: AnimeCanonicalEditField.originalTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(AnimeCanonicalEditField.originalTitle),
          label: 'Original Title',
        ),
        LibraryEditFormFieldSpec(
          id: AnimeCanonicalEditField.localizedTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(AnimeCanonicalEditField.localizedTitle),
          label: 'Localized title',
        ),
        LibraryEditFormFieldSpec(
          id: AnimeCanonicalEditField.displayTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(AnimeCanonicalEditField.displayTitle),
          label: 'Display Title',
        ),
        LibraryEditFormFieldSpec(
          id: AnimeCanonicalEditField.searchAliases,
          section: LibraryEditFormSection.details,
          controller: fields.controller(AnimeCanonicalEditField.searchAliases),
          label: 'Search Aliases',
          visible: false,
        ),
        LibraryEditFormFieldSpec(
          id: AnimeCanonicalEditField.thumbnailImage,
          section: LibraryEditFormSection.details,
          controller: fields.controller(AnimeCanonicalEditField.thumbnailImage),
          label: 'Thumbnail image URL',
          visible: false,
        ),
        LibraryEditFormFieldSpec(
          id: AnimeCanonicalEditField.coverImage,
          section: LibraryEditFormSection.artwork,
          controller: fields.controller(AnimeCanonicalEditField.coverImage),
          label: 'Cover Image URL',
        ),
        LibraryEditFormFieldSpec(
          id: AnimeCanonicalEditField.synopsis,
          section: LibraryEditFormSection.description,
          controller: fields.controller(AnimeCanonicalEditField.synopsis),
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
    if (result.tracking != null) {
      final seasonNumber = int.tryParse(seasonNumberController.text);
      final episodeNumber = int.tryParse(episodeNumberController.text);
      final episodeRatings = this.episodeRatings.isEmpty
          ? null
          : Map<String, int>.unmodifiable(this.episodeRatings);
      result = result.copyWith(
        trackingKindPatch: AnimeTrackingCoordinatesPatch(
          seasonNumber: seasonNumber,
          episodeNumber: episodeNumber?.toDouble(),
          episodeRatings: episodeRatings,
          setSeasonNumber: seasonNumber != null,
          setEpisodeNumber: episodeNumber != null,
          setEpisodeRatings: episodeRatings != null,
        ),
      );
    }
    return result;
  }

  void dispose() {
    seasonNumberController.dispose();
    episodeNumberController.dispose();
    animeEdit.dispose();
  }
}

LibraryEditSessionBundle createAnimeEditDraft({
  required CatalogSearchCandidate item,
  LibraryEntryDispatch? libraryEntryDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
}) {
  final entry = AnimeLibraryEntryProjection.fromDispatch(libraryEntryDispatch);
  final video = entry?.personal.details;
  final metadata = item.kindCapability
      .mapTransport((transport) => AnimeMetadata.fromJson(transport.kindData));
  final animeEdit = AnimeEditController(
    initialCreators: [
      for (var index = 0; index < metadata.creators.length; index++)
        AnimeCreditInput(
          name: metadata.creators[index].name,
          role: metadata.creators[index].role,
          source: metadata.creators[index],
          originalIndex: index,
        ),
    ],
    initialTrailerLinks: metadata.links,
  );
  animeEdit.initializeAnimeEditors();

  final draft = AnimeEditDraft(
    libraryEntry: entry,
    metadata: metadata,
    catalogTitle: metadata.title,
    featuresController: textControllers.create(text: video?.features ?? ''),
    boxSetNameController: textControllers.create(text: video?.boxSetName ?? ''),
    regionController: textControllers.create(text: video?.region ?? ''),
    packagingController: textControllers.create(text: video?.packaging ?? ''),
    distributorController:
        textControllers.create(text: video?.distributor ?? ''),
    hdrFormats: List<String>.from(video?.hdrFormats ?? const <String>[]),
    seasonNumberController: TextEditingController(),
    episodeNumberController: TextEditingController(
      text: metadata.episodeCount?.toString() ?? '',
    ),
    episodeRatings: const <String, int>{},
    animeEdit: animeEdit,
  );
  return LibraryEditSessionBundle(
    catalogItemSession: draft,
    entrySession: draft,
    disposeSession: draft.dispose,
  );
}
