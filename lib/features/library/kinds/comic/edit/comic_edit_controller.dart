import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

import 'comic_edit_models.dart';

class ComicEditController {
  ComicEditController({
    required this.item,
    required this.itemImages,
  })  : crossoverController = TextEditingController(text: item.crossover ?? ''),
        storyArcsController = TextEditingController(
            text: (item.storyArcs ?? const <String>[]).join(', ')),
        imprintController =
            TextEditingController(text: item.publishing?.imprint ?? ''),
        pageCountController = TextEditingController(
            text: item.publishing?.pageCount?.toString() ?? ''),
        ageRatingController = TextEditingController(text: item.ageRating ?? ''),
        genresEditController =
            TextEditingController(text: item.genres?.join(', ') ?? ''),
        seriesGroupController =
            TextEditingController(text: item.publishing?.seriesGroup ?? '');

  final LibraryMetadataItem item;
  final List<ItemImage> itemImages;

  final TextEditingController crossoverController;
  final TextEditingController storyArcsController;
  final TextEditingController imprintController;
  final TextEditingController pageCountController;
  final TextEditingController ageRatingController;
  final TextEditingController genresEditController;
  final TextEditingController seriesGroupController;

  final List<EditableComicCreator> creators = [];
  final List<EditableComicCharacter> characters = [];
  final List<Map<String, TextEditingController>> links = [];
  final TextEditingController characterDraftController =
      TextEditingController();

  void initialize() {
    creators.addAll(initComicCreators(item));
    characters.addAll(initComicCharacters(item));
    for (final link
        in item.trailerUrls.where((entry) => entry.isExternalLink)) {
      links.add(createLinkControllers(
        title: link.title ?? link.description ?? '',
        url: link.url,
      ));
    }
  }

  Map<String, TextEditingController> createLinkControllers({
    String title = '',
    String url = '',
  }) {
    return <String, TextEditingController>{
      'title': TextEditingController(text: title),
      'url': TextEditingController(text: url),
    };
  }

  void dispose() {
    crossoverController.dispose();
    storyArcsController.dispose();
    imprintController.dispose();
    pageCountController.dispose();
    ageRatingController.dispose();
    genresEditController.dispose();
    seriesGroupController.dispose();
    characterDraftController.dispose();
    for (final creator in creators) {
      creator.dispose();
    }
    for (final character in characters) {
      character.dispose();
    }
    for (final link in links) {
      link['title']?.dispose();
      link['url']?.dispose();
    }
  }

  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    final parsedStoryArcs = storyArcsController.text
        .split(RegExp(r'[,\r\n]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final parsedGenres = genresEditController.text
        .split(RegExp(r'[,\r\n]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final existingPublishing =
        selection.item.publishing ?? const CatalogPublishingDetails();
    final updatedPublishing = CatalogPublishingDetails(
      pageCount: int.tryParse(pageCountController.text) ??
          existingPublishing.pageCount,
      coverPriceCents: existingPublishing.coverPriceCents,
      currency: existingPublishing.currency,
      imprint:
          emptyToNull(imprintController.text) ?? existingPublishing.imprint,
      subtitle: existingPublishing.subtitle,
      seriesGroup: emptyToNull(seriesGroupController.text) ??
          existingPublishing.seriesGroup,
      publicationPlace: existingPublishing.publicationPlace,
      originalCountry: existingPublishing.originalCountry,
      originalLanguage: existingPublishing.originalLanguage,
      originalPublicationDate: existingPublishing.originalPublicationDate,
      originalPublicationPlace: existingPublishing.originalPublicationPlace,
      originalPublisher: existingPublishing.originalPublisher,
      paperType: existingPublishing.paperType,
      printedBy: existingPublishing.printedBy,
      subjects: existingPublishing.subjects,
      dustJacketCondition: existingPublishing.dustJacketCondition,
      dustJacket: existingPublishing.dustJacket,
      audiobookAbridged: existingPublishing.audiobookAbridged,
      firstEdition: existingPublishing.firstEdition,
      dewey: existingPublishing.dewey,
    );
    final withMetadata = selection.copyWith(
      item: selection.item.copyWith(
        crossover: emptyToNull(crossoverController.text),
        storyArcs: parsedStoryArcs.isNotEmpty
            ? parsedStoryArcs
            : selection.item.storyArcs,
        ageRating: emptyToNull(ageRatingController.text),
        genres: parsedGenres.isNotEmpty ? parsedGenres : selection.item.genres,
        publishing: updatedPublishing.hasData
            ? updatedPublishing
            : selection.item.publishing,
      ),
    );
    return applyComicSelectionEdits(
      withMetadata,
      creators,
      characters,
      links,
    );
  }
}
