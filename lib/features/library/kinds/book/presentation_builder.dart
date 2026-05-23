import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BookLibraryMediaPresentationBuilder
    extends DefaultLibraryMediaPresentationBuilder {
  const BookLibraryMediaPresentationBuilder({
    super.showSummary,
    super.showVolumeHierarchy,
    super.showSeasonHierarchy,
  });

  @override
  Widget? buildAddPreviewPane({
    required BuildContext context,
    required Color accent,
    required String singularLabel,
    required LibraryMediaFieldLabels labels,
    required LibraryMediaPreviewLabels previewLabels,
    required LibraryMetadataItem? item,
    required ProviderCandidate? candidate,
    required AdminProviderPreview? preview,
    required bool isFetchingPreview,
    required String providerLabel,
  }) {
    final title = item?.title ?? candidate?.title ?? preview?.title;
    if (title == null || title.trim().isEmpty) {
      return null;
    }
    final synopsis = item?.synopsis ?? preview?.synopsis ?? candidate?.summary;
    final coverUrl = item?.displayCoverUrl ?? preview?.coverImageUrl ?? candidate?.imageUrl;
    final itemNumber = item?.itemNumber ?? preview?.itemNumber ?? candidate?.issueNumber;
    return _BookAddPreviewPane(
      accent: accent,
      title: title,
      subtitle: _bookSubtitleForSelection(
        title: title,
        item: item,
        candidate: candidate,
        preview: preview,
      ),
      creatorLine: _bookCreatorLineForSelection(item: item, preview: preview),
      providerLabel: item == null ? providerLabel : singularLabel,
      publisherYearLine: _bookPublisherYearLineForSelection(
        item: item,
        candidate: candidate,
        preview: preview,
      ),
      formatLanguageLine: _bookFormatLanguageLineForSelection(
        item: item,
        preview: preview,
      ),
      isbn: _bookIsbnForSelection(item: item, preview: preview),
      synopsis: synopsis,
      coverUrl: coverUrl,
      itemNumber: itemNumber,
      pageCount: _bookPageCountForSelection(item: item, preview: preview),
      discoveryTags: _bookDiscoveryTagsForSelection(
        item: item,
        candidate: candidate,
        preview: preview,
      ),
      isFetchingPreview: isFetchingPreview,
    );
  }
}

class _BookAddPreviewPane extends StatelessWidget {
  const _BookAddPreviewPane({
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.creatorLine,
    required this.providerLabel,
    required this.publisherYearLine,
    required this.formatLanguageLine,
    required this.isbn,
    required this.synopsis,
    required this.coverUrl,
    required this.itemNumber,
    required this.pageCount,
    required this.discoveryTags,
    required this.isFetchingPreview,
  });

  final Color accent;
  final String title;
  final String? subtitle;
  final String? creatorLine;
  final String providerLabel;
  final String? publisherYearLine;
  final String? formatLanguageLine;
  final String? isbn;
  final String? synopsis;
  final String? coverUrl;
  final String? itemNumber;
  final int? pageCount;
  final List<String> discoveryTags;
  final bool isFetchingPreview;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF020202),
            Color.alphaBlend(accent.withValues(alpha: 0.22), kAppCanvas),
            const Color(0xFF050505),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemNumber == null ? title : '$title #$itemNumber',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: accent,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          height: 1.02,
                        ),
                      ),
                      if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (creatorLine != null && creatorLine!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          creatorLine!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                LibraryAddResultBadge(providerLabel),
              ],
            ),
            Divider(height: 22, color: accent.withValues(alpha: 0.42)),
            _BookAddPreviewTopFacts(
              publisherYearLine: publisherYearLine,
              formatLanguageLine: formatLanguageLine,
              isbn: isbn,
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        if (synopsis != null && synopsis!.trim().isNotEmpty) ...[
                          Text('Plot', style: TextStyle(color: accent)),
                          const SizedBox(height: 6),
                          Text(synopsis!),
                        ],
                        if (discoveryTags.isNotEmpty) ...[
                          if (synopsis != null && synopsis!.trim().isNotEmpty)
                            const SizedBox(height: 22),
                          Text(
                            discoveryTags.join(' / '),
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (isFetchingPreview) ...[
                          const SizedBox(height: 16),
                          const Row(
                            children: [
                              SizedBox.square(
                                dimension: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Fetching full metadata...',
                                style: TextStyle(color: kAppTextMuted),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0x12000000),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: AspectRatio(
                              aspectRatio: 2 / 3,
                              child: LibraryInteractiveCover(
                                title: title,
                                itemNumber: itemNumber,
                                imageUrl: coverUrl,
                                accentColor: accent,
                                borderRadius: 6,
                              ),
                            ),
                          ),
                        ),
                        if (pageCount != null) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  const TextSpan(
                                    text: 'Pages ',
                                    style: TextStyle(
                                      color: kAppTextMuted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '$pageCount',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookAddPreviewTopFacts extends StatelessWidget {
  const _BookAddPreviewTopFacts({
    required this.publisherYearLine,
    required this.formatLanguageLine,
    required this.isbn,
  });

  final String? publisherYearLine;
  final String? formatLanguageLine;
  final String? isbn;

  @override
  Widget build(BuildContext context) {
    final hasFacts =
        (publisherYearLine?.trim().isNotEmpty ?? false) ||
        (formatLanguageLine?.trim().isNotEmpty ?? false) ||
        (isbn?.trim().isNotEmpty ?? false);
    if (!hasFacts) {
      return const SizedBox.shrink();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (publisherYearLine != null && publisherYearLine!.trim().isNotEmpty)
                Text(
                  publisherYearLine!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (formatLanguageLine != null &&
                  formatLanguageLine!.trim().isNotEmpty) ...[
                if (publisherYearLine != null &&
                    publisherYearLine!.trim().isNotEmpty)
                  const SizedBox(height: 6),
                Text(
                  formatLanguageLine!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isbn != null && isbn!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              isbn!,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

String? _bookSubtitleForSelection({
  required String title,
  required LibraryMetadataItem? item,
  required ProviderCandidate? candidate,
  required AdminProviderPreview? preview,
}) {
  final subtitle = item?.publishing?.subtitle ?? preview?.publishing?.subtitle;
  if (subtitle != null &&
      subtitle.trim().isNotEmpty &&
      subtitle.trim() != title.trim()) {
    return subtitle.trim();
  }

  final seriesTitle =
      item?.series?.seriesTitle ??
      preview?.series?.seriesTitle ??
      candidate?.series?.seriesTitle;
  final number = item?.itemNumber ?? preview?.itemNumber ?? candidate?.issueNumber;
  if (seriesTitle != null &&
      seriesTitle.trim().isNotEmpty &&
      seriesTitle.trim() != title.trim()) {
    if (number != null && number.trim().isNotEmpty) {
      return '$seriesTitle, Book $number';
    }
    return seriesTitle.trim();
  }

  final edition =
      item?.displayEditionLabel ?? preview?.physicalFormatLabel ?? preview?.editionTitle;
  return edition?.trim().isEmpty ?? true ? null : edition!.trim();
}

String? _bookCreatorLineForSelection({
  required LibraryMetadataItem? item,
  required AdminProviderPreview? preview,
}) {
  final preferred = <String>[];
  final secondary = <String>[];
  final seen = <String>{};

  void addName(String? name, String? role) {
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return;
    }
    final key = trimmed.toLowerCase();
    if (!seen.add(key)) {
      return;
    }
    if (_isPrimaryBookCreatorRole(role)) {
      preferred.add(trimmed);
    } else {
      secondary.add(trimmed);
    }
  }

  for (final credit in item?.creators ?? const <Map<String, dynamic>>[]) {
    addName(credit['name']?.toString(), credit['role']?.toString());
  }
  for (final credit in preview?.creators ?? const <ProviderPreviewCredit>[]) {
    addName(credit.name, credit.role);
  }

  final names = preferred.isNotEmpty ? preferred : secondary;
  if (names.isEmpty) {
    return null;
  }
  return names.take(3).join(', ');
}

bool _isPrimaryBookCreatorRole(String? role) {
  final normalized = role?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) {
    return false;
  }
  return normalized.contains('author') ||
      normalized.contains('writer') ||
      normalized.contains('novelist');
}

String? _bookPublisherYearLineForSelection({
  required LibraryMetadataItem? item,
  required ProviderCandidate? candidate,
  required AdminProviderPreview? preview,
}) {
  final publisher = item?.publisher ?? preview?.publisher ?? candidate?.publisher;
  final year = item?.releaseDate?.year ??
      preview?.releaseDate?.year ??
      item?.releaseYear ??
      preview?.series?.volumeStartYear ??
      candidate?.series?.volumeStartYear;
  if (publisher == null || publisher.trim().isEmpty) {
    return year == null ? null : '$year';
  }
  return year == null ? publisher : '$publisher ($year)';
}

String? _bookFormatLanguageLineForSelection({
  required LibraryMetadataItem? item,
  required AdminProviderPreview? preview,
}) {
  final values = <String>[
    if (item?.displayEditionLabel != null && item!.displayEditionLabel!.trim().isNotEmpty)
      item.displayEditionLabel!.trim()
    else if (preview?.physicalFormatLabel != null &&
        preview!.physicalFormatLabel!.trim().isNotEmpty)
      preview.physicalFormatLabel!.trim(),
    if (item?.language != null && item!.language!.trim().isNotEmpty)
      item.language!.trim()
    else if (preview?.language != null && preview!.language!.trim().isNotEmpty)
      preview.language!.trim(),
  ];
  return values.isEmpty ? null : values.join(' / ');
}

String? _bookIsbnForSelection({
  required LibraryMetadataItem? item,
  required AdminProviderPreview? preview,
}) {
  final isbn = preview?.isbn ?? item?.barcode;
  return isbn?.trim().isEmpty ?? true ? null : isbn!.trim();
}

int? _bookPageCountForSelection({
  required LibraryMetadataItem? item,
  required AdminProviderPreview? preview,
}) {
  return item?.publishing?.pageCount ?? preview?.publishing?.pageCount;
}

List<String> _bookDiscoveryTagsForSelection({
  required LibraryMetadataItem? item,
  required ProviderCandidate? candidate,
  required AdminProviderPreview? preview,
}) {
  final seen = <String>{};
  final tags = <String>[];

  void addAll(Iterable<String> values) {
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final key = trimmed.toLowerCase();
      if (seen.add(key)) {
        tags.add(trimmed);
      }
    }
  }

  addAll(item?.genres ?? preview?.genres ?? const <String>[]);
  addAll(
    item?.characters ??
        preview?.characters ??
        candidate?.characterPreview ??
        const <String>[],
  );
  addAll(
    item?.storyArcs ??
        preview?.storyArcs ??
        candidate?.storyArcPreview ??
        const <String>[],
  );
  return tags;
}
