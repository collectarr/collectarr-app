import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';

final class TvReleaseEditDraft {
  factory TvReleaseEditDraft.fromRelease(TvRelease release) {
    return TvReleaseEditDraft(
      original: release,
      titleController: TextEditingController(text: release.title),
      sortTitleController: TextEditingController(text: release.sortTitle),
      formatController: TextEditingController(text: release.format),
      regionController: TextEditingController(text: release.regionCode),
      publisherController: TextEditingController(text: release.publisher),
      skuController: TextEditingController(text: release.sku),
      caseTypeController: TextEditingController(text: release.caseType),
      descriptionController: TextEditingController(text: release.description),
      contentRatingController:
          TextEditingController(text: release.contentRating),
      languageAudioController:
          TextEditingController(text: release.languageAudio.join(', ')),
      languageSubtitlesController: TextEditingController(
        text: release.languageSubtitles.join(', '),
      ),
      coverImageUrlController:
          TextEditingController(text: release.coverImageUrl),
      releaseDateController: TextEditingController(
        text: _formatDate(release.releaseDate),
      ),
    );
  }

  TvReleaseEditDraft({
    required this.original,
    required this.titleController,
    required this.sortTitleController,
    required this.formatController,
    required this.regionController,
    required this.publisherController,
    required this.skuController,
    required this.caseTypeController,
    required this.descriptionController,
    required this.contentRatingController,
    required this.languageAudioController,
    required this.languageSubtitlesController,
    required this.coverImageUrlController,
    required this.releaseDateController,
  });

  final TvRelease original;
  final TextEditingController titleController;
  final TextEditingController sortTitleController;
  final TextEditingController formatController;
  final TextEditingController regionController;
  final TextEditingController publisherController;
  final TextEditingController skuController;
  final TextEditingController caseTypeController;
  final TextEditingController descriptionController;
  final TextEditingController contentRatingController;
  final TextEditingController languageAudioController;
  final TextEditingController languageSubtitlesController;
  final TextEditingController coverImageUrlController;
  final TextEditingController releaseDateController;

  String get title => titleController.text;
  set title(String value) => titleController.text = value;
  String get sortTitle => sortTitleController.text;
  set sortTitle(String value) => sortTitleController.text = value;
  String? get format => _emptyToNull(formatController.text);
  set format(String? value) => formatController.text = value ?? '';
  String? get region => _emptyToNull(regionController.text);
  set region(String? value) => regionController.text = value ?? '';
  String? get publisher => _emptyToNull(publisherController.text);
  set publisher(String? value) => publisherController.text = value ?? '';
  String? get sku => _emptyToNull(skuController.text);
  set sku(String? value) => skuController.text = value ?? '';
  String? get caseType => _emptyToNull(caseTypeController.text);
  set caseType(String? value) => caseTypeController.text = value ?? '';
  String? get description => _emptyToNull(descriptionController.text);
  set description(String? value) => descriptionController.text = value ?? '';
  String? get contentRating => _emptyToNull(contentRatingController.text);
  set contentRating(String? value) =>
      contentRatingController.text = value ?? '';
  List<String> get languageAudio => _split(languageAudioController.text);
  set languageAudio(List<String> value) =>
      languageAudioController.text = value.join(', ');
  List<String> get languageSubtitles =>
      _split(languageSubtitlesController.text);
  set languageSubtitles(List<String> value) =>
      languageSubtitlesController.text = value.join(', ');
  String? get coverImageUrl => _emptyToNull(coverImageUrlController.text);
  set coverImageUrl(String? value) =>
      coverImageUrlController.text = value ?? '';
  DateTime? get releaseDate => DateTime.tryParse(
        releaseDateController.text.trim(),
      );
  set releaseDate(DateTime? value) =>
      releaseDateController.text = _formatDate(value);

  TvRelease toRelease() => TvRelease(
        id: original.id,
        seriesId: original.seriesId,
        title: title.trim(),
        sortTitle: _emptyToNull(sortTitle),
        description: description,
        mediaCount: original.mediaCount,
        format: format,
        regionCode: region,
        releaseDate: releaseDate,
        publisher: publisher,
        sku: sku,
        caseType: caseType,
        episodeCount: original.episodeCount,
        seasonCount: original.seasonCount,
        runtimeMinutes: original.runtimeMinutes,
        languageAudio: languageAudio,
        languageSubtitles: languageSubtitles,
        contentRating: contentRating,
        coverImageUrl: coverImageUrl,
        coverImageKey: original.coverImageKey,
        media: original.media,
        episodeMappings: original.episodeMappings,
        rawPayload: original.rawPayload,
      );

  void dispose() {
    titleController.dispose();
    sortTitleController.dispose();
    formatController.dispose();
    regionController.dispose();
    publisherController.dispose();
    skuController.dispose();
    caseTypeController.dispose();
    descriptionController.dispose();
    contentRatingController.dispose();
    languageAudioController.dispose();
    languageSubtitlesController.dispose();
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
