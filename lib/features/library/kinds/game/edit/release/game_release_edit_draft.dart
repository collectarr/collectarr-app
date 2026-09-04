import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
import 'package:flutter/material.dart';

final class GameReleaseEditDraft {
  GameReleaseEditDraft({
    required this.original,
    required this.titleController,
    required this.platformController,
    required this.releaseDateController,
    required this.regionController,
    required this.formatController,
    required this.publisherController,
    required this.catalogNumberController,
    required this.releaseStatusController,
    required this.languageController,
    required this.barcodeController,
    required this.coverImageUrlController,
  });

  factory GameReleaseEditDraft.fromRelease(GameRelease release) {
    return GameReleaseEditDraft(
      original: release,
      titleController: TextEditingController(text: release.title),
      platformController: TextEditingController(text: release.platform ?? ''),
      releaseDateController: TextEditingController(
        text: release.releaseDate == null
            ? ''
            : _formatDate(release.releaseDate!),
      ),
      regionController: TextEditingController(text: release.regionCode ?? ''),
      formatController: TextEditingController(text: release.format ?? ''),
      publisherController: TextEditingController(text: release.publisher ?? ''),
      catalogNumberController:
          TextEditingController(text: release.catalogNumber ?? ''),
      releaseStatusController:
          TextEditingController(text: release.releaseStatus ?? ''),
      languageController: TextEditingController(text: release.language ?? ''),
      barcodeController: TextEditingController(text: release.barcode ?? ''),
      coverImageUrlController:
          TextEditingController(text: release.coverImageUrl ?? ''),
    );
  }

  final GameRelease original;
  final TextEditingController titleController;
  final TextEditingController platformController;
  final TextEditingController releaseDateController;
  final TextEditingController regionController;
  final TextEditingController formatController;
  final TextEditingController publisherController;
  final TextEditingController catalogNumberController;
  final TextEditingController releaseStatusController;
  final TextEditingController languageController;
  final TextEditingController barcodeController;
  final TextEditingController coverImageUrlController;

  GameRelease toRelease() => GameRelease(
        id: original.id,
        title: _text(titleController) ?? original.title,
        workId: original.workId,
        platform: _text(platformController),
        releaseDate: DateTime.tryParse(releaseDateController.text.trim()),
        regionCode: _text(regionController),
        format: _text(formatController),
        publisher: _text(publisherController),
        catalogNumber: _text(catalogNumberController),
        releaseStatus: _text(releaseStatusController),
        language: _text(languageController),
        barcode: _text(barcodeController),
        coverImageUrl: _text(coverImageUrlController),
        rawPayload: original.rawPayload,
      );

  void dispose() {
    titleController.dispose();
    platformController.dispose();
    releaseDateController.dispose();
    regionController.dispose();
    formatController.dispose();
    publisherController.dispose();
    catalogNumberController.dispose();
    releaseStatusController.dispose();
    languageController.dispose();
    barcodeController.dispose();
    coverImageUrlController.dispose();
  }
}

String? _text(TextEditingController controller) {
  final value = controller.text.trim();
  return value.isEmpty ? null : value;
}

String _formatDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
