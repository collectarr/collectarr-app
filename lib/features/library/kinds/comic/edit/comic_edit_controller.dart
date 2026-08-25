import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

import 'comic_edit_models.dart';

class ComicEditController {
  ComicEditController({
    required this.item,
    required this.itemImages,
  })  : crossoverController = TextEditingController(text: item.crossover ?? ''),
        storyArcsController =
            TextEditingController(text: item.storyArcs.join(', ')),
        imprintController =
            TextEditingController(text: item.imprint ?? item.publishing?.imprint ?? ''),
        pageCountController = TextEditingController(
            text: (item.pageCount ?? item.publishing?.pageCount)?.toString() ?? ''),
        ageRatingController = TextEditingController(text: item.ageRating ?? ''),
        genresEditController =
            TextEditingController(text: item.genres.join(', ')),
        seriesGroupController = TextEditingController(),
        numberController = TextEditingController(
            text: item.issueNumber ?? ''),
        publisherController = TextEditingController(
            text: item.publisher ?? item.publishing?.originalPublisher ?? ''),
        editionTitleController =
            TextEditingController(text: item.editionTitle ?? ''),
        barcodeController = TextEditingController(text: item.barcode ?? ''),
        variantController = TextEditingController(text: item.variant ?? ''),
        physicalFormatLabelController = TextEditingController(
            text: item.physicalFormatLabel ?? item.variant ?? ''),
        physicalFormatId = item.physicalFormat,
        coverDateController = TextEditingController(
            text: item.coverDate == null ? '' : formatDate(item.coverDate!)),
        coverDateYearPartController = TextEditingController(
            text: item.coverDate?.year.toString() ?? ''),
        coverDateMonthPartController = TextEditingController(
            text: item.coverDate == null
                ? ''
                : item.coverDate!.month.toString().padLeft(2, '0')),
        coverDateDayPartController = TextEditingController(
            text: item.coverDate == null
                ? ''
                : item.coverDate!.day.toString().padLeft(2, '0')),
        languageController = TextEditingController(text: item.language),
        countryController = TextEditingController(text: item.country),
        seriesTitleController = TextEditingController(
            text: item.seriesTitle ?? item.series?.seriesTitle ?? item.title),
        seriesId = item.series?.seriesId;

  final ComicCatalogMetadata item;
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
  final TextEditingController coverDateYearPartController;
  final TextEditingController coverDateMonthPartController;
  final TextEditingController coverDateDayPartController;
  final TextEditingController languageController;
  final TextEditingController countryController;
  final TextEditingController seriesTitleController;
  String? seriesId;

  final List<EditableComicCreator> creators = [];
  final List<EditableComicCharacter> characters = [];
  final List<Map<String, TextEditingController>> links = [];
  final TextEditingController characterDraftController =
      TextEditingController();

  void initialize() {
    creators.addAll(initComicCreators(item));
    characters.addAll(initComicCharacters(item));
    for (final link in item.links.where((entry) => entry.isExternalLink)) {
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
    numberController.dispose();
    publisherController.dispose();
    editionTitleController.dispose();
    barcodeController.dispose();
    variantController.dispose();
    physicalFormatLabelController.dispose();
    coverDateController.dispose();
    coverDateYearPartController.dispose();
    coverDateMonthPartController.dispose();
    coverDateDayPartController.dispose();
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

    final currentMeta = selection.item.kindMetadata is ComicCatalogMetadata
        ? selection.item.kindMetadata as ComicCatalogMetadata
        : item;

    final updatedSeries = (currentMeta.series != null ||
            seriesId != null ||
            emptyToNull(seriesTitleController.text) != null)
        ? CatalogSeriesDetailsDto(
            seriesId: seriesId ?? currentMeta.series?.seriesId,
            seriesTitle: emptyToNull(seriesTitleController.text) ??
                currentMeta.series?.seriesTitle,
            volumeName: currentMeta.series?.volumeName,
            volumeNumber: currentMeta.series?.volumeNumber,
            volumeStartYear: currentMeta.series?.volumeStartYear,
          )
        : null;

    final updatedPublishing = (currentMeta.publishing != null ||
            emptyToNull(publisherController.text) != null ||
            emptyToNull(imprintController.text) != null ||
            int.tryParse(pageCountController.text) != null)
        ? CatalogPublishingDetailsDto(
            originalPublisher: emptyToNull(publisherController.text) ??
                currentMeta.publishing?.originalPublisher,
            imprint: emptyToNull(imprintController.text) ??
                currentMeta.publishing?.imprint,
            pageCount: int.tryParse(pageCountController.text) ??
                currentMeta.publishing?.pageCount,
          )
        : null;

    final updatedMeta = currentMeta.copyWith(
      crossover: emptyToNull(crossoverController.text),
      storyArcs: parsedStoryArcs.isNotEmpty
          ? parsedStoryArcs
          : currentMeta.storyArcs,
      ageRating: emptyToNull(ageRatingController.text),
      genres: parsedGenres.isNotEmpty ? parsedGenres : currentMeta.genres,
      imprint: emptyToNull(imprintController.text),
      pageCount: int.tryParse(pageCountController.text),
      issueNumber: emptyToNull(numberController.text),
      publisher: emptyToNull(publisherController.text),
      editionTitle: emptyToNull(editionTitleController.text),
      barcode: emptyToNull(barcodeController.text),
      variant: emptyToNull(variantController.text),
      physicalFormat: physicalFormatId,
      physicalFormatLabel: emptyToNull(physicalFormatLabelController.text) ??
          currentMeta.physicalFormatLabel ??
          currentMeta.variant,
      coverDate: parseDate(coverDateController.text),
      language: emptyToNull(languageController.text) ?? currentMeta.language,
      country: emptyToNull(countryController.text) ?? currentMeta.country,
      seriesTitle: emptyToNull(seriesTitleController.text),
      series: updatedSeries != null && updatedSeries.hasData ? updatedSeries : null,
      publishing: updatedPublishing != null && updatedPublishing.hasData ? updatedPublishing : null,
    );

    final updatedItem = selection.item.copyWith(
      kindMetadata: updatedMeta,
    );
    final withMetadata = selection.copyWith(item: updatedItem);
    return applyComicSelectionEdits(
      withMetadata,
      creators,
      characters,
      links,
    );
  }
}
