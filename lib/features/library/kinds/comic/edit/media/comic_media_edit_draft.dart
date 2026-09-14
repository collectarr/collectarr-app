import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_edit_models.dart';
import 'package:flutter/material.dart';

final class ComicMediaEditDraft {
  factory ComicMediaEditDraft.fromMedia(ComicMedia media) {
    final controller = ComicEditController(
      item: media,
      itemImages: const [],
    )..initialize();
    return ComicMediaEditDraft(controller);
  }

  ComicMediaEditDraft(this.controller);

  final ComicEditController controller;

  String get seriesTitle => seriesTitleController.text;
  set seriesTitle(String value) => seriesTitleController.text = value;

  String get number => numberController.text;
  set number(String value) => numberController.text = value;

  String get publisher => publisherController.text;
  set publisher(String value) => publisherController.text = value;

  String get imprint => imprintController.text;
  set imprint(String value) => imprintController.text = value;

  String get editionTitle => editionTitleController.text;
  set editionTitle(String value) => editionTitleController.text = value;

  String get barcode => barcodeController.text;
  set barcode(String value) => barcodeController.text = value;

  String get variant => variantController.text;
  set variant(String value) => variantController.text = value;

  String get physicalFormat => physicalFormatLabelController.text;
  set physicalFormat(String value) =>
      physicalFormatLabelController.text = value;

  int? get pageCount => int.tryParse(pageCountController.text);
  set pageCount(int? value) =>
      pageCountController.text = value?.toString() ?? '';

  String get ageRating => ageRatingController.text;
  set ageRating(String value) => ageRatingController.text = value;

  Set<String> get genres => _splitValues(genresController.text);
  set genres(Set<String> value) => genresController.text = value.join(', ');

  String get language => languageController.text;
  set language(String value) => languageController.text = value;

  String get country => countryController.text;
  set country(String value) => countryController.text = value;

  Set<String> get crossovers => _splitValues(crossoverController.text);
  set crossovers(Set<String> value) =>
      crossoverController.text = value.join(', ');

  Set<String> get storyArcs => _splitValues(storyArcsController.text);
  set storyArcs(Set<String> value) =>
      storyArcsController.text = value.join(', ');

  String get seriesGroup => seriesGroupController.text;
  set seriesGroup(String value) => seriesGroupController.text = value;

  TextEditingController get seriesTitleController =>
      controller.seriesTitleController;
  TextEditingController get numberController => controller.numberController;
  TextEditingController get publisherController =>
      controller.publisherController;
  TextEditingController get imprintController => controller.imprintController;
  TextEditingController get editionTitleController =>
      controller.editionTitleController;
  TextEditingController get barcodeController => controller.barcodeController;
  TextEditingController get variantController => controller.variantController;
  TextEditingController get physicalFormatLabelController =>
      controller.physicalFormatLabelController;
  TextEditingController get coverDateController =>
      controller.coverDateController;
  TextEditingController get releaseDateController =>
      controller.releaseDateController;
  TextEditingController get pageCountController =>
      controller.pageCountController;
  TextEditingController get ageRatingController =>
      controller.ageRatingController;
  TextEditingController get genresController => controller.genresEditController;
  TextEditingController get languageController => controller.languageController;
  TextEditingController get countryController => controller.countryController;
  TextEditingController get crossoverController =>
      controller.crossoverController;
  TextEditingController get storyArcsController =>
      controller.storyArcsController;
  TextEditingController get seriesGroupController =>
      controller.seriesGroupController;

  String? get physicalFormatId => controller.physicalFormatId;
  set physicalFormatId(String? value) => controller.physicalFormatId = value;

  List<EditableComicCreator> get creators => controller.creators;
  List<EditableComicCharacter> get characters => controller.characters;
  List<Map<String, TextEditingController>> get links => controller.links;
  List<ItemImage> get itemImages => controller.itemImages;

  DateTime? get coverDate => DateTime.tryParse(coverDateController.text);
  set coverDate(DateTime? value) =>
      coverDateController.text = _formatDate(value);

  DateTime? get releaseDate => DateTime.tryParse(releaseDateController.text);
  set releaseDate(DateTime? value) =>
      releaseDateController.text = _formatDate(value);

  void dispose() => controller.dispose();
}

Set<String> _splitValues(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet();

String _formatDate(DateTime? value) => value == null
    ? ''
    : '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
