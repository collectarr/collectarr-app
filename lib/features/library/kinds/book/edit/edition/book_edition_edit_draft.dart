import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';
import 'package:flutter/material.dart';

final class BookEditionEditDraft {
  BookEditionEditDraft({
    required this.original,
    required this.titleController,
    required this.bindingController,
    required this.formatController,
    required this.publisherController,
    required this.distributorController,
    required this.isbnController,
    required this.upcController,
    required this.imprintController,
    required this.languageController,
    required this.regionController,
    required this.statusController,
    required this.editionStatementController,
    required this.descriptionController,
    required this.dimensionsController,
    required this.pageCountController,
    required this.audioLengthController,
    required this.releaseDateController,
    required this.firstEdition,
  });

  factory BookEditionEditDraft.fromRelease(BookRelease release) {
    return BookEditionEditDraft(
      original: release,
      titleController: TextEditingController(text: release.title),
      bindingController: TextEditingController(text: release.binding ?? ''),
      formatController: TextEditingController(
        text: release.physicalFormatLabel ?? release.physicalFormat ?? '',
      ),
      publisherController: TextEditingController(text: release.publisher ?? ''),
      distributorController:
          TextEditingController(text: release.distributor ?? ''),
      isbnController: TextEditingController(text: release.isbn ?? ''),
      upcController: TextEditingController(text: release.upc ?? ''),
      imprintController: TextEditingController(text: release.imprint ?? ''),
      languageController: TextEditingController(text: release.language ?? ''),
      regionController: TextEditingController(text: release.region ?? ''),
      statusController:
          TextEditingController(text: release.releaseStatus ?? ''),
      editionStatementController:
          TextEditingController(text: release.editionStatement ?? ''),
      descriptionController:
          TextEditingController(text: release.description ?? ''),
      dimensionsController:
          TextEditingController(text: release.dimensions ?? ''),
      pageCountController: TextEditingController(
        text: release.pageCount?.toString() ?? '',
      ),
      audioLengthController: TextEditingController(
        text: release.audioLengthMinutes?.toString() ?? '',
      ),
      releaseDateController: TextEditingController(
        text: release.releaseDate == null
            ? ''
            : _formatDate(release.releaseDate!),
      ),
      firstEdition: release.firstEdition ?? false,
    );
  }

  final BookRelease original;
  final TextEditingController titleController;
  final TextEditingController bindingController;
  final TextEditingController formatController;
  final TextEditingController publisherController;
  final TextEditingController distributorController;
  final TextEditingController isbnController;
  final TextEditingController upcController;
  final TextEditingController imprintController;
  final TextEditingController languageController;
  final TextEditingController regionController;
  final TextEditingController statusController;
  final TextEditingController editionStatementController;
  final TextEditingController descriptionController;
  final TextEditingController dimensionsController;
  final TextEditingController pageCountController;
  final TextEditingController audioLengthController;
  final TextEditingController releaseDateController;
  bool firstEdition;

  BookRelease toRelease() => BookRelease(
        id: original.id,
        title: _text(titleController) ?? original.title,
        workId: original.workId,
        titleValue: _text(titleController),
        displayTitle: _text(titleController),
        ageRating: original.ageRating,
        audioLengthMinutes: int.tryParse(audioLengthController.text),
        binding: _text(bindingController),
        contributors: original.contributors,
        coverImageKey: original.coverImageKey,
        publisher: _text(publisherController),
        distributor: _text(distributorController),
        description: _text(descriptionController),
        editionStatement: _text(editionStatementController),
        isbn: _text(isbnController),
        identifiers: original.identifiers,
        imprint: _text(imprintController),
        upc: _text(upcController),
        pageCount: int.tryParse(pageCountController.text),
        language: _text(languageController),
        region: _text(regionController),
        releaseDate: DateTime.tryParse(releaseDateController.text.trim()),
        releaseStatus: _text(statusController),
        physicalFormat: _text(formatController),
        physicalFormatLabel: _text(formatController),
        coverImageUrl: original.coverImageUrl,
        thumbnailImageUrl: original.thumbnailImageUrl,
        dimensions: _text(dimensionsController),
        firstEdition: firstEdition,
        variants: original.variants,
      );

  void dispose() {
    titleController.dispose();
    bindingController.dispose();
    formatController.dispose();
    publisherController.dispose();
    distributorController.dispose();
    isbnController.dispose();
    upcController.dispose();
    imprintController.dispose();
    languageController.dispose();
    regionController.dispose();
    statusController.dispose();
    editionStatementController.dispose();
    descriptionController.dispose();
    dimensionsController.dispose();
    pageCountController.dispose();
    audioLengthController.dispose();
    releaseDateController.dispose();
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
