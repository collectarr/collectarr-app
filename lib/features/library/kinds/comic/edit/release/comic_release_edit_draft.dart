import 'package:collectarr_app/core/api/dto/catalog/catalog_variant_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_release.dart';
import 'package:flutter/material.dart';

final class ComicReleaseEditDraft {
  factory ComicReleaseEditDraft.fromRelease(ComicRelease release) {
    return ComicReleaseEditDraft(
      id: release.id,
      titleController: TextEditingController(text: release.title),
      publisherController: TextEditingController(text: release.publisher),
      imprintController: TextEditingController(text: release.imprint),
      isbnController: TextEditingController(text: release.isbn),
      upcController: TextEditingController(text: release.upc),
      releaseDate: release.releaseDate,
      coverImageUrlController:
          TextEditingController(text: release.coverImageUrl),
      variants: release.variants,
    );
  }

  ComicReleaseEditDraft({
    required this.id,
    required this.titleController,
    required this.publisherController,
    required this.imprintController,
    required this.isbnController,
    required this.upcController,
    required this.releaseDate,
    required this.coverImageUrlController,
    List<CatalogVariantDto> variants = const [],
  }) : variants = List.of(variants);

  final String id;
  final TextEditingController titleController;
  final TextEditingController publisherController;
  final TextEditingController imprintController;
  final TextEditingController isbnController;
  final TextEditingController upcController;
  final TextEditingController coverImageUrlController;

  DateTime? releaseDate;
  final List<CatalogVariantDto> variants;

  String get title => titleController.text;
  set title(String value) => titleController.text = value;

  String? get publisher => _emptyToNull(publisherController.text);
  set publisher(String? value) => publisherController.text = value ?? '';

  String? get imprint => _emptyToNull(imprintController.text);
  set imprint(String? value) => imprintController.text = value ?? '';

  String? get isbn => _emptyToNull(isbnController.text);
  set isbn(String? value) => isbnController.text = value ?? '';

  String? get upc => _emptyToNull(upcController.text);
  set upc(String? value) => upcController.text = value ?? '';

  String? get coverImageUrl => _emptyToNull(coverImageUrlController.text);
  set coverImageUrl(String? value) =>
      coverImageUrlController.text = value ?? '';

  ComicRelease toRelease() {
    return ComicRelease(
      id: id,
      title: title,
      publisher: publisher,
      imprint: imprint,
      isbn: isbn,
      upc: upc,
      releaseDate: releaseDate,
      coverImageUrl: coverImageUrl,
      variants: List.unmodifiable(variants),
    );
  }

  void dispose() {
    titleController.dispose();
    publisherController.dispose();
    imprintController.dispose();
    isbnController.dispose();
    upcController.dispose();
    coverImageUrlController.dispose();
  }
}

String? _emptyToNull(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
