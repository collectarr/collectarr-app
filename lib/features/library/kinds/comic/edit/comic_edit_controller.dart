import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_link.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_person_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:flutter/material.dart';

import 'comic_edit_models.dart';

class ComicEditController {
  ComicEditController({
    required this.item,
    required this.itemImages,
  })  : crossoverController = TextEditingController(text: item.crossover ?? ''),
        storyArcsController = TextEditingController(
          text: item.storyArcs
              .map((arc) => arc.name)
              .whereType<String>()
              .join(', '),
        ),
        imprintController = TextEditingController(text: item.imprint ?? ''),
        pageCountController =
            TextEditingController(text: item.pageCount?.toString() ?? ''),
        ageRatingController = TextEditingController(text: item.ageRating ?? ''),
        genresEditController =
            TextEditingController(text: item.genres.join(', ')),
        seriesGroupController =
            TextEditingController(text: item.seriesGroup ?? ''),
        numberController = TextEditingController(text: item.issueNumber ?? ''),
        publisherController = TextEditingController(text: item.publisher ?? ''),
        editionTitleController =
            TextEditingController(text: item.editionTitle ?? ''),
        barcodeController = TextEditingController(text: item.barcode ?? ''),
        variantController = TextEditingController(text: item.variant ?? ''),
        physicalFormatLabelController = TextEditingController(
            text: item.physicalFormat ?? item.variant ?? ''),
        physicalFormatId = item.physicalFormat,
        coverDateController = TextEditingController(
            text: item.coverDate == null ? '' : formatDate(item.coverDate!)),
        languageController = TextEditingController(text: item.language),
        countryController = TextEditingController(text: item.country),
        seriesTitleController =
            TextEditingController(text: item.seriesTitle ?? item.title),
        seriesId = item.seriesId,
        releaseDateController = TextEditingController(
            text:
                item.releaseDate == null ? '' : formatDate(item.releaseDate!)),
        releaseYearController = TextEditingController(
            text: item.releaseDate?.year.toString() ?? '');

  final ComicCatalogItem item;
  final List<ItemImage> itemImages;

  final TextEditingController crossoverController;
  final TextEditingController storyArcsController;
  final TextEditingController imprintController;
  final TextEditingController pageCountController;
  final TextEditingController ageRatingController;
  final TextEditingController genresEditController;
  final TextEditingController seriesGroupController;

  final TextEditingController numberController;
  final TextEditingController publisherController;
  final TextEditingController editionTitleController;
  final TextEditingController barcodeController;
  final TextEditingController variantController;
  final TextEditingController physicalFormatLabelController;
  String? physicalFormatId;
  final TextEditingController coverDateController;
  final TextEditingController releaseDateController;
  final TextEditingController releaseYearController;
  final TextEditingController languageController;
  final TextEditingController countryController;
  final TextEditingController seriesTitleController;
  String? seriesId;

  final List<EditableComicCreator> creators = [];
  final List<EditableComicCharacter> characters = [];
  final List<LibraryExternalLinkDraftRow> links = [];
  final Map<LibraryExternalLinkDraftRow, ComicLink> originalLinks = {};

  void initialize() {
    creators.addAll(initComicCreators(item));
    characters.addAll(initComicCharacters(item));
    for (final link in item.links.where((entry) => entry.isExternalLink)) {
      final row = createLinkDraft(
        title: link.title ?? link.description ?? '',
        url: link.url,
        description: link.description ?? '',
      );
      links.add(row);
      originalLinks[row] = link;
    }
  }

  LibraryExternalLinkDraftRow createLinkDraft({
    String title = '',
    String url = '',
    String description = '',
  }) {
    return LibraryExternalLinkDraftRow(
      title: title,
      url: url,
      description: description,
    );
  }

  void dispose() {
    crossoverController.dispose();
    storyArcsController.dispose();
    imprintController.dispose();
    pageCountController.dispose();
    ageRatingController.dispose();
    genresEditController.dispose();
    seriesGroupController.dispose();
    numberController.dispose();
    publisherController.dispose();
    editionTitleController.dispose();
    barcodeController.dispose();
    variantController.dispose();
    physicalFormatLabelController.dispose();
    coverDateController.dispose();
    releaseDateController.dispose();
    releaseYearController.dispose();
    languageController.dispose();
    countryController.dispose();
    seriesTitleController.dispose();
    for (final creator in creators) {
      creator.dispose();
    }
    for (final character in characters) {
      character.dispose();
    }
    for (final link in links) {
      link.dispose();
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

    final currentMeta = selection.kindItem.kindCapability.mapTransport(
      (transport) => ComicCatalogItem.fromJson(transport.kindData),
    );

    final updatedMeta = currentMeta.copyWith(
      title: emptyToNull(seriesTitleController.text) ?? currentMeta.title,
      crossover: emptyToNull(crossoverController.text),
      storyArcs: _replaceStoryArcs(currentMeta.storyArcs, parsedStoryArcs),
      ageRating: emptyToNull(ageRatingController.text),
      genres: parsedGenres,
      imprint: emptyToNull(imprintController.text),
      pageCount: int.tryParse(pageCountController.text),
      issueNumber: emptyToNull(numberController.text),
      publisher: emptyToNull(publisherController.text),
      editionTitle: emptyToNull(editionTitleController.text),
      barcode: emptyToNull(barcodeController.text),
      variant: emptyToNull(variantController.text),
      physicalFormat: physicalFormatId,
      coverDate: parseDate(coverDateController.text),
      releaseDate: parseDate(releaseDateController.text),
      language: emptyToNull(languageController.text) ?? currentMeta.language,
      country: emptyToNull(countryController.text) ?? currentMeta.country,
      seriesTitle: emptyToNull(seriesTitleController.text),
      seriesId: seriesId ?? currentMeta.seriesId,
      seriesGroup: emptyToNull(seriesGroupController.text),
    );

    final updatedItem = selection.kindItem.kindCapability.mapTransport(
      (transport) => CatalogSearchCandidate.fromItem(
        transport.replacingKindData(updatedMeta),
        basedOn: selection.kindItem,
      ),
    );
    final withMetadata = selection.copyWith(kindItem: updatedItem);
    return applyComicSelectionEdits(
      withMetadata,
      creators,
      characters,
      links,
      originalExternalLinks: originalLinks,
    );
  }
}

List<ComicStoryArc> _replaceStoryArcs(
  List<ComicStoryArc> original,
  List<String> values,
) {
  final existing = {
    for (final arc in original)
      if (arc.name?.trim().isNotEmpty == true)
        arc.name!.trim().toLowerCase(): arc,
  };
  return [
    for (final value in values)
      (existing[value.toLowerCase()] ?? const ComicStoryArc())
          .copyWith(name: value),
  ];
}
