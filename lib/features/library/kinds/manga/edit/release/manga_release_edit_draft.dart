import 'package:flutter/material.dart';

import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';

final class MangaReleaseEditDraft {
  factory MangaReleaseEditDraft.fromRelease(CatalogEditionDto release) {
    final metadata = release.metadata ?? const <String, dynamic>{};
    return MangaReleaseEditDraft(
      original: release,
      titleController: TextEditingController(text: release.title),
      formatController: TextEditingController(
        text: release.format ?? release.physicalFormat,
      ),
      publisherController: TextEditingController(text: release.publisher),
      distributorController: TextEditingController(text: release.distributor),
      isbnController: TextEditingController(text: release.isbn),
      barcodeController: TextEditingController(text: release.upc),
      languageController: TextEditingController(text: release.language),
      regionController: TextEditingController(text: release.region),
      releaseDateController: TextEditingController(
        text: _formatDate(release.releaseDate),
      ),
      bindingController: TextEditingController(
        text: release.physicalFormatLabel ?? metadata['binding']?.toString(),
      ),
      imprintController: TextEditingController(
        text: metadata['imprint']?.toString(),
      ),
      pageCountController: TextEditingController(
        text: metadata['page_count']?.toString(),
      ),
      descriptionController: TextEditingController(
        text: metadata['description']?.toString(),
      ),
      coverImageUrlController: TextEditingController(
        text: metadata['cover_image_url']?.toString(),
      ),
    );
  }

  MangaReleaseEditDraft({
    required this.original,
    required this.titleController,
    required this.formatController,
    required this.publisherController,
    required this.distributorController,
    required this.isbnController,
    required this.barcodeController,
    required this.languageController,
    required this.regionController,
    required this.releaseDateController,
    required this.bindingController,
    required this.imprintController,
    required this.pageCountController,
    required this.descriptionController,
    required this.coverImageUrlController,
  });

  final CatalogEditionDto original;
  final TextEditingController titleController;
  final TextEditingController formatController;
  final TextEditingController publisherController;
  final TextEditingController distributorController;
  final TextEditingController isbnController;
  final TextEditingController barcodeController;
  final TextEditingController languageController;
  final TextEditingController regionController;
  final TextEditingController releaseDateController;
  final TextEditingController bindingController;
  final TextEditingController imprintController;
  final TextEditingController pageCountController;
  final TextEditingController descriptionController;
  final TextEditingController coverImageUrlController;

  String get title => titleController.text;
  set title(String value) => titleController.text = value;
  String? get format => _emptyToNull(formatController.text);
  set format(String? value) => formatController.text = value ?? '';
  String? get publisher => _emptyToNull(publisherController.text);
  set publisher(String? value) => publisherController.text = value ?? '';
  String? get distributor => _emptyToNull(distributorController.text);
  set distributor(String? value) => distributorController.text = value ?? '';
  String? get isbn => _emptyToNull(isbnController.text);
  set isbn(String? value) => isbnController.text = value ?? '';
  String? get barcode => _emptyToNull(barcodeController.text);
  set barcode(String? value) => barcodeController.text = value ?? '';
  String? get language => _emptyToNull(languageController.text);
  set language(String? value) => languageController.text = value ?? '';
  String? get region => _emptyToNull(regionController.text);
  set region(String? value) => regionController.text = value ?? '';
  DateTime? get releaseDate =>
      DateTime.tryParse(releaseDateController.text.trim());
  set releaseDate(DateTime? value) =>
      releaseDateController.text = _formatDate(value);
  String? get binding => _emptyToNull(bindingController.text);
  set binding(String? value) => bindingController.text = value ?? '';
  String? get imprint => _emptyToNull(imprintController.text);
  set imprint(String? value) => imprintController.text = value ?? '';
  int? get pageCount => int.tryParse(pageCountController.text.trim());
  set pageCount(int? value) =>
      pageCountController.text = value?.toString() ?? '';
  String? get description => _emptyToNull(descriptionController.text);
  set description(String? value) => descriptionController.text = value ?? '';
  String? get coverImageUrl => _emptyToNull(coverImageUrlController.text);
  set coverImageUrl(String? value) =>
      coverImageUrlController.text = value ?? '';

  CatalogEditionDto toRelease() {
    final metadata = <String, dynamic>{...?original.metadata};
    _writeOptional(metadata, 'imprint', imprint);
    _writeOptional(metadata, 'binding', binding);
    _writeOptional(metadata, 'page_count', pageCount);
    _writeOptional(metadata, 'description', description);
    _writeOptional(metadata, 'cover_image_url', coverImageUrl);
    return CatalogEditionDto(
      id: original.id,
      title: title.trim(),
      format: format,
      publisher: publisher,
      distributor: distributor,
      isbn: isbn,
      upc: barcode,
      language: language,
      region: region,
      releaseDate: releaseDate,
      physicalFormat: format,
      physicalFormatLabel: binding,
      metadata: metadata.isEmpty ? null : metadata,
      variants: original.variants,
      discs: original.discs,
    );
  }

  void dispose() {
    titleController.dispose();
    formatController.dispose();
    publisherController.dispose();
    distributorController.dispose();
    isbnController.dispose();
    barcodeController.dispose();
    languageController.dispose();
    regionController.dispose();
    releaseDateController.dispose();
    bindingController.dispose();
    imprintController.dispose();
    pageCountController.dispose();
    descriptionController.dispose();
    coverImageUrlController.dispose();
  }
}

void _writeOptional(Map<String, dynamic> metadata, String key, Object? value) {
  if (value == null || (value is String && value.trim().isEmpty)) {
    metadata.remove(key);
  } else {
    metadata[key] = value;
  }
}

String? _emptyToNull(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

String _formatDate(DateTime? value) => value == null
    ? ''
    : '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
