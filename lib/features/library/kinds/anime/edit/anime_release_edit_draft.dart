import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';

final class AnimeReleaseEditDraft {
  factory AnimeReleaseEditDraft.fromRelease(AnimeRelease release) {
    return AnimeReleaseEditDraft(
      original: release,
      titleController: TextEditingController(text: release.title),
      formatController: TextEditingController(text: release.format),
      regionController: TextEditingController(text: release.regionCode),
      languageController: TextEditingController(text: release.language),
      publisherController: TextEditingController(text: release.publisher),
      barcodeController: TextEditingController(text: release.barcode),
      mediaCountController:
          TextEditingController(text: release.mediaCount?.toString()),
      audioTracksController:
          TextEditingController(text: release.audioTracks.join(', ')),
      subtitlesController:
          TextEditingController(text: release.subtitles.join(', ')),
      descriptionController: TextEditingController(text: release.description),
      coverImageUrlController:
          TextEditingController(text: release.coverImageUrl),
      releaseDateController: TextEditingController(
        text: _formatDate(release.releaseDate),
      ),
    );
  }

  AnimeReleaseEditDraft({
    required this.original,
    required this.titleController,
    required this.formatController,
    required this.regionController,
    required this.languageController,
    required this.publisherController,
    required this.barcodeController,
    required this.mediaCountController,
    required this.audioTracksController,
    required this.subtitlesController,
    required this.descriptionController,
    required this.coverImageUrlController,
    required this.releaseDateController,
  });

  final AnimeRelease original;
  final TextEditingController titleController;
  final TextEditingController formatController;
  final TextEditingController regionController;
  final TextEditingController languageController;
  final TextEditingController publisherController;
  final TextEditingController barcodeController;
  final TextEditingController mediaCountController;
  final TextEditingController audioTracksController;
  final TextEditingController subtitlesController;
  final TextEditingController descriptionController;
  final TextEditingController coverImageUrlController;
  final TextEditingController releaseDateController;

  String get title => titleController.text;
  set title(String value) => titleController.text = value;
  String? get format => _emptyToNull(formatController.text);
  set format(String? value) => formatController.text = value ?? '';
  String? get region => _emptyToNull(regionController.text);
  set region(String? value) => regionController.text = value ?? '';
  String? get language => _emptyToNull(languageController.text);
  set language(String? value) => languageController.text = value ?? '';
  String? get publisher => _emptyToNull(publisherController.text);
  set publisher(String? value) => publisherController.text = value ?? '';
  String? get barcode => _emptyToNull(barcodeController.text);
  set barcode(String? value) => barcodeController.text = value ?? '';
  int? get mediaCount => int.tryParse(mediaCountController.text.trim());
  set mediaCount(int? value) =>
      mediaCountController.text = value?.toString() ?? '';
  List<String> get audioTracks => _split(audioTracksController.text);
  set audioTracks(List<String> value) =>
      audioTracksController.text = value.join(', ');
  List<String> get subtitles => _split(subtitlesController.text);
  set subtitles(List<String> value) =>
      subtitlesController.text = value.join(', ');
  String? get description => _emptyToNull(descriptionController.text);
  set description(String? value) => descriptionController.text = value ?? '';
  String? get coverImageUrl => _emptyToNull(coverImageUrlController.text);
  set coverImageUrl(String? value) =>
      coverImageUrlController.text = value ?? '';
  DateTime? get releaseDate =>
      DateTime.tryParse(releaseDateController.text.trim());
  set releaseDate(DateTime? value) =>
      releaseDateController.text = _formatDate(value);

  AnimeRelease toRelease() => AnimeRelease(
        id: original.id,
        title: title.trim(),
        seriesId: original.seriesId,
        coverImageKey: original.coverImageKey,
        coverImageUrl: coverImageUrl,
        description: description,
        format: format,
        language: language,
        regionCode: region,
        releaseDate: releaseDate,
        publisher: publisher,
        barcode: barcode,
        mediaCount: mediaCount,
        audioTracks: audioTracks,
        subtitles: subtitles,
        rawPayload: original.rawPayload,
      );

  void dispose() {
    titleController.dispose();
    formatController.dispose();
    regionController.dispose();
    languageController.dispose();
    publisherController.dispose();
    barcodeController.dispose();
    mediaCountController.dispose();
    audioTracksController.dispose();
    subtitlesController.dispose();
    descriptionController.dispose();
    coverImageUrlController.dispose();
    releaseDateController.dispose();
  }
}

String? _emptyToNull(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);

String _formatDate(DateTime? value) => value == null
    ? ''
    : '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
