import 'package:collectarr_app/features/library/edit/draft/library_edit_form_fields.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_library_entry_projection.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
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
    implements AnimeEditDraftContract {
  AnimeEditDraft({
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
    required this.animeEdit,
    this.physicalFormatId,
  });

  final AnimeLibraryEntry? libraryEntry;

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
  final AnimeEditController animeEdit;
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
    LibraryEditFormFields fields,
  ) {
    final aliases = fields
        .controller(AnimeCanonicalEditField.searchAliases)
        .text
        .split(RegExp(r'[,\r\n]+'))
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
    final genreText = fields.controller(AnimeCanonicalEditField.genres).text;
    final genres = genreText
        .split(RegExp(r'[,\r\n]+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final characters = _editedAnimeCharacters(
      animeEdit.charactersController.text,
      selection.kindItem.kindCapability.mapTransport(
        (transport) => AnimeMetadata.fromJson(transport.kindData).characters,
      ),
    );
    return selection.copyWith(
      kindItem: CatalogSearchCandidate.fromItem(
          selection.kindItem.kindCapability.mapTransport((transport) {
        final metadata = AnimeMetadata.fromJson(transport.kindData);
        final edited = metadata.copyWith(
          title: fields.controller(AnimeCanonicalEditField.title).text.trim(),
          displayTitle: emptyToNull(
              fields.controller(AnimeCanonicalEditField.displayTitle).text),
          originalTitle: emptyToNull(
              fields.controller(AnimeCanonicalEditField.originalTitle).text),
          localizedTitle: emptyToNull(
              fields.controller(AnimeCanonicalEditField.localizedTitle).text),
          searchAliases: aliases.isEmpty ? null : aliases,
          synopsis: emptyToNull(
              fields.controller(AnimeCanonicalEditField.synopsis).text),
          coverImageUrl: emptyToNull(
              fields.controller(AnimeCanonicalEditField.coverImage).text),
          thumbnailImageUrl: emptyToNull(
              fields.controller(AnimeCanonicalEditField.thumbnailImage).text),
          sortKey: emptyToNull(
            fields.controller(AnimeCanonicalEditField.sortTitle).text,
          ),
          episodeRuntimeMinutes: int.tryParse(
            fields.controller(AnimeCanonicalEditField.episodeRuntime).text,
          ),
          genres: genres,
          editionTitle: emptyToNull(
            fields.controller(AnimeCanonicalEditField.editionTitle).text,
          ),
          variant: emptyToNull(
            fields.controller(AnimeCanonicalEditField.variant).text,
          ),
          barcode: emptyToNull(
            fields.controller(AnimeCanonicalEditField.barcode).text,
          ),
          physicalFormat: physicalFormatId,
          physicalFormatLabel: emptyToNull(
            fields.controller(AnimeCanonicalEditField.physicalFormatLabel).text,
          ),
          publisher: emptyToNull(
            fields.controller(AnimeCanonicalEditField.publisher).text,
          ),
          country: emptyToNull(
                fields.controller(AnimeCanonicalEditField.country).text,
              ) ??
              'JP',
          language: emptyToNull(
                fields.controller(AnimeCanonicalEditField.language).text,
              ) ??
              'ja',
          startDate: parseDate(
            fields.controller(AnimeCanonicalEditField.releaseDate).text,
          ),
          releaseYear: int.tryParse(
            fields.controller(AnimeCanonicalEditField.releaseYear).text,
          ),
          ageRating: emptyToNull(
            fields.controller(AnimeCanonicalEditField.ageRating).text,
          ),
          audienceRating: emptyToNull(
            fields.controller(AnimeCanonicalEditField.audienceRating).text,
          ),
          creators: animeEdit.buildUpdatedCreators(),
          characters: characters,
          links: animeEdit.buildUpdatedTrailerUrls(metadata.links),
        );
        final updated = AnimeMetadata.fromJson(applyJsonFieldPatch(edited, {
          'display_title': emptyToNull(
            fields.controller(AnimeCanonicalEditField.displayTitle).text,
          ),
          'original_title': emptyToNull(
            fields.controller(AnimeCanonicalEditField.originalTitle).text,
          ),
          'localized_title': emptyToNull(
            fields.controller(AnimeCanonicalEditField.localizedTitle).text,
          ),
          'search_aliases': aliases,
          'synopsis': emptyToNull(
            fields.controller(AnimeCanonicalEditField.synopsis).text,
          ),
          'cover_image_url': emptyToNull(
            fields.controller(AnimeCanonicalEditField.coverImage).text,
          ),
          'thumbnail_image_url': emptyToNull(
            fields.controller(AnimeCanonicalEditField.thumbnailImage).text,
          ),
          'sort_key': emptyToNull(
            fields.controller(AnimeCanonicalEditField.sortTitle).text,
          ),
          'episode_runtime_minutes': int.tryParse(
            fields.controller(AnimeCanonicalEditField.episodeRuntime).text,
          ),
          'genres': genres,
          'characters':
              characters.map((character) => character.toJsonValue()).toList(),
          'edition_title': emptyToNull(
            fields.controller(AnimeCanonicalEditField.editionTitle).text,
          ),
          'variant_name': emptyToNull(
            fields.controller(AnimeCanonicalEditField.variant).text,
          ),
          'barcode': emptyToNull(
            fields.controller(AnimeCanonicalEditField.barcode).text,
          ),
          'physical_format': physicalFormatId,
          'physical_format_label': emptyToNull(
            fields.controller(AnimeCanonicalEditField.physicalFormatLabel).text,
          ),
          'publisher': emptyToNull(
            fields.controller(AnimeCanonicalEditField.publisher).text,
          ),
          'country': emptyToNull(
            fields.controller(AnimeCanonicalEditField.country).text,
          ),
          'language': emptyToNull(
            fields.controller(AnimeCanonicalEditField.language).text,
          ),
          'start_date': parseDate(
            fields.controller(AnimeCanonicalEditField.releaseDate).text,
          )?.toIso8601String(),
          'release_year': int.tryParse(
            fields.controller(AnimeCanonicalEditField.releaseYear).text,
          ),
          'age_rating': emptyToNull(
            fields.controller(AnimeCanonicalEditField.ageRating).text,
          ),
          'audience_rating': emptyToNull(
            fields.controller(AnimeCanonicalEditField.audienceRating).text,
          ),
          'audio_tracks': emptyToNull(audioTracksController.text),
          'subtitles': emptyToNull(subtitlesController.text),
          'screen_ratio': emptyToNull(screenRatioController.text),
          'layers': emptyToNull(layersController.text),
          'color': emptyToNull(colorController.text),
          'nr_discs': int.tryParse(nrDiscsController.text.trim()),
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
    itemId: item.reference.id,
    catalogRef: item.reference,
    initialCharacters:
        metadata.characters.map((character) => character.name).join(', '),
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
    featuresController: textControllers.create(text: video?.features ?? ''),
    boxSetNameController: textControllers.create(text: video?.boxSetName ?? ''),
    regionController: textControllers.create(text: video?.region ?? ''),
    packagingController: textControllers.create(text: video?.packaging ?? ''),
    distributorController:
        textControllers.create(text: video?.distributor ?? ''),
    screenRatioController:
        textControllers.create(text: metadata.screenRatio ?? ''),
    audioTracksController:
        textControllers.create(text: metadata.audioTracks ?? ''),
    subtitlesController: textControllers.create(text: metadata.subtitles ?? ''),
    layersController: textControllers.create(text: metadata.layers ?? ''),
    colorController: textControllers.create(text: metadata.color ?? ''),
    nrDiscsController:
        textControllers.create(text: metadata.nrDiscs?.toString() ?? ''),
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

List<AnimeCharacterMetadata> _editedAnimeCharacters(
  String value,
  List<AnimeCharacterMetadata> original,
) {
  final previousByName = {
    for (final character in original)
      character.name.trim().toLowerCase(): character,
  };
  final edited = <AnimeCharacterMetadata>[];
  for (final rawName in value.split(RegExp(r'[,\r\n]+'))) {
    final name = rawName.trim();
    if (name.isEmpty) continue;
    final previous = previousByName.remove(name.toLowerCase());
    edited.add(
      AnimeCharacterMetadata(
        name: name,
        id: previous?.id,
        characterId: previous?.characterId,
        aliases: previous?.aliases ?? const [],
        role: previous?.role,
        description: previous?.description,
        imageUrl: previous?.imageUrl,
        stringValue: previous?.stringValue ?? false,
      ),
    );
  }
  return edited;
}
