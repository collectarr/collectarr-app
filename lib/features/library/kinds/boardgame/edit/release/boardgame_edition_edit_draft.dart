import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_edition.dart';
import 'package:flutter/material.dart';

final class BoardGameEditionEditDraft {
  BoardGameEditionEditDraft({
    required this.original,
    required this.titleController,
    required this.editionTitleController,
    required this.ageRatingController,
    required this.audienceRatingController,
    required this.barcodeController,
    required this.catalogNumberController,
    required this.countryController,
    required this.coverImageUrlController,
    required this.descriptionController,
    required this.formatController,
    required this.languageController,
    required this.maxPlayersController,
    required this.minAgeController,
    required this.minPlayersController,
    required this.playingTimeController,
    required this.publisherController,
    required this.releaseDateController,
    required this.releaseStatusController,
  });

  factory BoardGameEditionEditDraft.fromRelease(BoardGameEdition release) {
    return BoardGameEditionEditDraft(
      original: release,
      titleController: TextEditingController(text: release.title),
      editionTitleController:
          TextEditingController(text: release.editionTitle ?? ''),
      ageRatingController: TextEditingController(text: release.ageRating ?? ''),
      audienceRatingController:
          TextEditingController(text: release.audienceRating ?? ''),
      barcodeController: TextEditingController(text: release.barcode ?? ''),
      catalogNumberController:
          TextEditingController(text: release.catalogNumber ?? ''),
      countryController: TextEditingController(text: release.country ?? ''),
      coverImageUrlController:
          TextEditingController(text: release.coverImageUrl ?? ''),
      descriptionController:
          TextEditingController(text: release.description ?? ''),
      formatController: TextEditingController(text: release.format ?? ''),
      languageController: TextEditingController(text: release.language ?? ''),
      maxPlayersController:
          TextEditingController(text: release.maxPlayers?.toString() ?? ''),
      minAgeController:
          TextEditingController(text: release.minAge?.toString() ?? ''),
      minPlayersController:
          TextEditingController(text: release.minPlayers?.toString() ?? ''),
      playingTimeController: TextEditingController(
        text: release.playingTimeMinutes?.toString() ?? '',
      ),
      publisherController: TextEditingController(text: release.publisher ?? ''),
      releaseDateController: TextEditingController(
        text: release.releaseDate == null
            ? ''
            : _formatDate(release.releaseDate!),
      ),
      releaseStatusController:
          TextEditingController(text: release.releaseStatus ?? ''),
    );
  }

  final BoardGameEdition original;
  final TextEditingController titleController;
  final TextEditingController editionTitleController;
  final TextEditingController ageRatingController;
  final TextEditingController audienceRatingController;
  final TextEditingController barcodeController;
  final TextEditingController catalogNumberController;
  final TextEditingController countryController;
  final TextEditingController coverImageUrlController;
  final TextEditingController descriptionController;
  final TextEditingController formatController;
  final TextEditingController languageController;
  final TextEditingController maxPlayersController;
  final TextEditingController minAgeController;
  final TextEditingController minPlayersController;
  final TextEditingController playingTimeController;
  final TextEditingController publisherController;
  final TextEditingController releaseDateController;
  final TextEditingController releaseStatusController;

  BoardGameEdition toRelease() {
    final title = _text(titleController) ?? original.title;
    return BoardGameEdition(
      id: original.id,
      title: title,
      titleValue: _text(titleController),
      workId: original.workId,
      editionTitle: _text(editionTitleController),
      ageRating: _text(ageRatingController),
      audienceRating: _text(audienceRatingController),
      barcode: _text(barcodeController),
      catalogNumber: _text(catalogNumberController),
      country: _text(countryController),
      coverImageUrl: _text(coverImageUrlController),
      description: _text(descriptionController),
      format: _text(formatController),
      language: _text(languageController),
      maxPlayers: int.tryParse(maxPlayersController.text.trim()),
      minAge: int.tryParse(minAgeController.text.trim()),
      minPlayers: int.tryParse(minPlayersController.text.trim()),
      playingTimeMinutes: int.tryParse(playingTimeController.text.trim()),
      publisher: _text(publisherController),
      releaseDate: DateTime.tryParse(releaseDateController.text.trim()),
      releaseStatus: _text(releaseStatusController),
      rawPayload: _withoutEditedFields(original.rawPayload),
    );
  }

  void dispose() {
    titleController.dispose();
    editionTitleController.dispose();
    ageRatingController.dispose();
    audienceRatingController.dispose();
    barcodeController.dispose();
    catalogNumberController.dispose();
    countryController.dispose();
    coverImageUrlController.dispose();
    descriptionController.dispose();
    formatController.dispose();
    languageController.dispose();
    maxPlayersController.dispose();
    minAgeController.dispose();
    minPlayersController.dispose();
    playingTimeController.dispose();
    publisherController.dispose();
    releaseDateController.dispose();
    releaseStatusController.dispose();
  }
}

String? _text(TextEditingController controller) {
  final value = controller.text.trim();
  return value.isEmpty ? null : value;
}

Map<String, dynamic> _withoutEditedFields(Map<String, dynamic> rawPayload) {
  final cleaned = Map<String, dynamic>.from(rawPayload);
  for (final key in [
    'title',
    'title_value',
    'edition_title',
    'age_rating',
    'audience_rating',
    'barcode',
    'upc',
    'isbn',
    'catalog_number',
    'country',
    'region',
    'cover_image_url',
    'description',
    'synopsis',
    'format',
    'physical_format',
    'language',
    'max_players',
    'min_age',
    'minimum_age',
    'min_players',
    'playing_time_minutes',
    'publisher',
    'release_date',
    'release_status',
  ]) {
    cleaned.remove(key);
  }
  return cleaned;
}

String _formatDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
