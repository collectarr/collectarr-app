import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/movie/domain/movie_release.dart';

final class MovieReleaseEditDraft {
  factory MovieReleaseEditDraft.fromRelease(MovieRelease release) {
    return MovieReleaseEditDraft(
      original: release,
      titleController: TextEditingController(text: release.title),
      formatController: TextEditingController(text: release.format),
      languageController: TextEditingController(text: release.language),
      regionController: TextEditingController(text: release.region),
      distributorController: TextEditingController(text: release.distributor),
      descriptionController: TextEditingController(text: release.description),
      coverImageUrlController:
          TextEditingController(text: release.coverImageUrl),
      releaseDateController: TextEditingController(
        text: release.releaseDate == null
            ? ''
            : _formatDate(release.releaseDate!),
      ),
    );
  }

  MovieReleaseEditDraft({
    required this.original,
    required this.titleController,
    required this.formatController,
    required this.languageController,
    required this.regionController,
    required this.distributorController,
    required this.descriptionController,
    required this.coverImageUrlController,
    required this.releaseDateController,
  });

  final MovieRelease original;
  final TextEditingController titleController;
  final TextEditingController formatController;
  final TextEditingController languageController;
  final TextEditingController regionController;
  final TextEditingController distributorController;
  final TextEditingController descriptionController;
  final TextEditingController coverImageUrlController;
  final TextEditingController releaseDateController;

  String get title => titleController.text;
  set title(String value) => titleController.text = value;
  String? get format => _emptyToNull(formatController.text);
  set format(String? value) => formatController.text = value ?? '';
  String? get language => _emptyToNull(languageController.text);
  set language(String? value) => languageController.text = value ?? '';
  String? get region => _emptyToNull(regionController.text);
  set region(String? value) => regionController.text = value ?? '';
  String? get distributor => _emptyToNull(distributorController.text);
  set distributor(String? value) => distributorController.text = value ?? '';
  String? get description => _emptyToNull(descriptionController.text);
  set description(String? value) => descriptionController.text = value ?? '';
  String? get coverImageUrl => _emptyToNull(coverImageUrlController.text);
  set coverImageUrl(String? value) =>
      coverImageUrlController.text = value ?? '';
  DateTime? get releaseDate => DateTime.tryParse(releaseDateController.text);
  set releaseDate(DateTime? value) =>
      releaseDateController.text = value == null ? '' : _formatDate(value);

  MovieRelease toRelease() => MovieRelease(
        id: original.id,
        title: title.trim(),
        workId: original.workId,
        coverImageKey: original.coverImageKey,
        coverImageUrl: coverImageUrl,
        description: description,
        distributor: distributor,
        externalLinks: original.externalLinks,
        format: format,
        language: language,
        media: original.media,
        region: region,
        releaseDate: releaseDate,
        trailerUrls: original.trailerUrls,
        rawPayload: original.rawPayload,
      );

  void dispose() {
    titleController.dispose();
    formatController.dispose();
    languageController.dispose();
    regionController.dispose();
    distributorController.dispose();
    descriptionController.dispose();
    coverImageUrlController.dispose();
    releaseDateController.dispose();
  }
}

String? _emptyToNull(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

String _formatDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
