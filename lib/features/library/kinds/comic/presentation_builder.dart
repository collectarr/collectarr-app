import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_group_mode_categories.dart';
import 'package:collectarr_app/features/library/config/library_group_mode_category_models.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';

class ComicLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const ComicLibraryMediaPresentationBuilder({
    this.showSummary = false,
    this.metadataLabels = const LibraryMetadataLabels(),
  });

  final bool showSummary;
  final LibraryMetadataLabels metadataLabels;

  @override
  List<LibraryDuplicateCandidate> buildDuplicateCandidates(
    LibraryWorkspaceSource entry,
  ) {
    final item = entry.catalogTransport;
    if (item == null) return const [];
    final candidates = <LibraryDuplicateCandidate>[];
    final entryLabel = [
      item.title,
      if (item.itemNumber?.trim() case final value? when value.isNotEmpty)
        '#$value',
    ].join(' ');
    final identifier = normalizeLibraryDuplicateIdentifier(item.identifierCode);
    if (identifier != null) {
      candidates.add(
        LibraryDuplicateCandidate(
          key: 'barcode:$identifier',
          label: 'Barcode ${item.identifierCode!.trim()}',
          reason: 'Same barcode',
          confidenceScore: 78,
          entryLabel: entryLabel,
        ),
      );
    }
    final title = normalizeLibraryDuplicateToken(item.title);
    final issue = normalizeLibraryDuplicateToken(item.itemNumber);
    if (title == null || issue == null) return candidates;
    final publisher = normalizeLibraryDuplicateToken(item.publisher) ?? '';
    final year = (item.releaseYear ?? item.releaseDate?.year)?.toString() ?? '';
    final variant = normalizeLibraryDuplicateToken(item.variant) ?? '';
    final labelParts = [
      item.title,
      '#${item.itemNumber!.trim()}',
      if (item.publisher?.trim() case final value? when value.isNotEmpty) value,
      if (year.isNotEmpty) year,
      if (item.variant?.trim() case final value? when value.isNotEmpty) value,
    ];
    var confidenceScore = 52;
    if (publisher.isNotEmpty) confidenceScore += 4;
    if (year.isNotEmpty) confidenceScore += 3;
    if (variant.isNotEmpty) confidenceScore += 2;
    candidates.add(
      LibraryDuplicateCandidate(
        key: 'issue:$title|$issue|$publisher|$year|$variant',
        label: labelParts.join(' - '),
        reason: 'Same issue metadata',
        confidenceScore: confidenceScore,
        entryLabel: entryLabel,
      ),
    );
    return candidates;
  }

  @override
  List<CatalogEditionDto> buildReleaseEditions({
    required LibraryAddCatalogTransport item,
  }) {
    return item.editions;
  }

  @override
  LibraryAddSearchResultDisplay? buildSearchResultDisplay({
    required LibraryAddCatalogTransport item,
  }) =>
      _buildComicSearchResultDisplay(item);

  @override
  List<(String, String?)> buildAddPreviewMetadataRows({
    required LibraryAddCatalogTransport item,
    required LibraryMediaPreviewLabels previewLabels,
  }) {
    final releaseDate = item.releaseDate;
    return [
      (
        previewLabels.labelFor('publisher', fallback: 'Publisher'),
        item.publisher
      ),
      (
        'Released',
        releaseDate == null
            ? item.releaseYear?.toString()
            : '${releaseDate.year}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}',
      ),
      if (item.itemNumber != null)
        (
          previewLabels.labelFor('item_number', fallback: 'Number'),
          item.itemNumber
        ),
      if (item.variant != null)
        (previewLabels.labelFor('variant', fallback: 'Variant'), item.variant),
      (
        previewLabels.labelFor('barcode', fallback: 'Barcode'),
        item.identifierCode
      ),
    ];
  }

  @override
  List<LibraryGroupModeCategory> buildGroupModeCategories(
    List<String> modes,
  ) {
    return buildComicGroupModeCategories(modes);
  }

  @override
  @override
  List<(String, String?)> buildAddPreviewMetadataRowsForCandidate({
    required ProviderCandidate candidate,
    required LibraryMediaPreviewLabels previewLabels,
  }) {
    return [
      if (candidate.series?.seriesTitle != null)
        (
          previewLabels.labelFor('series', fallback: 'Series'),
          candidate.series!.seriesTitle
        ),
      if (candidate.issueNumber != null)
        (
          previewLabels.labelFor('item_number', fallback: 'Number'),
          candidate.issueNumber
        ),
      if (candidate.publisher != null)
        (
          previewLabels.labelFor('publisher', fallback: 'Publisher'),
          candidate.publisher
        ),
      if (candidate.series?.volumeStartYear != null)
        ('Year', candidate.series!.volumeStartYear.toString()),
      if (candidate.variantName != null)
        (
          previewLabels.labelFor('variant', fallback: 'Variant'),
          candidate.variantName
        ),
      if (candidate.issueCount != null)
        (
          previewLabels.labelFor('item_count', fallback: 'Items'),
          candidate.issueCount.toString()
        ),
    ];
  }

  @override
  List<(String, String?)> buildAddPreviewMetadataRowsForFullPreview({
    required AdminProviderPreview preview,
    required LibraryMediaPreviewLabels previewLabels,
  }) {
    final series = preview.series;
    final publishing = preview.publishing;
    final music = preview.music;
    final video = preview.video;
    final game = preview.game;
    final releaseDate = preview.releaseDate;
    final releaseDateText = releaseDate == null
        ? null
        : '${releaseDate.year}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}';
    final musicCatalogNumber = (music?['catalog_number'] as String?)?.trim();
    final musicReleaseStatus = (music?['release_status'] as String?)?.trim();
    final gamePlatforms = (game?['platforms'] as List<dynamic>?)
        ?.map((value) => value.toString().trim())
        .where((value) => value.isNotEmpty)
        .toList();
    final runtimeMinutes = (video?['runtime_minutes'] as num?)?.toInt();
    final pageCount = publishing?.pageCount?.toString();
    final seriesGroup = publishing?.seriesGroup?.trim();
    return [
      if (series?.seriesTitle != null)
        (
          previewLabels.labelFor('series', fallback: 'Series'),
          series!.seriesTitle
        ),
      if (preview.publisher != null)
        (
          previewLabels.labelFor('publisher', fallback: 'Publisher'),
          preview.publisher
        ),
      if (releaseDateText != null) ('Released', releaseDateText),
      if (series?.volumeStartYear != null)
        ('Year', series!.volumeStartYear.toString()),
      if (preview.itemNumber != null)
        (
          previewLabels.labelFor('item_number', fallback: 'Number'),
          preview.itemNumber
        ),
      if (preview.identifierCode != null)
        (
          previewLabels.labelFor('barcode', fallback: 'Barcode'),
          preview.identifierCode,
        ),
      if (preview.isbn != null) ('ISBN', preview.isbn),
      if (preview.country != null) ('Country', preview.country),
      if (preview.language != null) ('Language', preview.language),
      if (preview.physicalFormatLabel != null)
        ('Format', preview.physicalFormatLabel),
      if (preview.variantName != null)
        (
          previewLabels.labelFor('variant', fallback: 'Variant'),
          preview.variantName
        ),
      if (musicCatalogNumber != null && musicCatalogNumber.isNotEmpty)
        ('Catalog No.', musicCatalogNumber),
      if (gamePlatforms != null && gamePlatforms.isNotEmpty)
        ('Platforms', gamePlatforms.join(', ')),
      if (runtimeMinutes != null) ('Runtime', '${runtimeMinutes} min'),
      if (pageCount != null) ('Pages', pageCount),
      if (musicReleaseStatus != null && musicReleaseStatus.isNotEmpty)
        ('Release Status', musicReleaseStatus),
      if (seriesGroup != null && seriesGroup.isNotEmpty)
        ('Series Group', seriesGroup),
    ];
  }

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required LibraryProjectionView item,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final workspace = item.dto;
    if (workspace is! ComicWorkspaceDto) {
      throw StateError('Expected ComicWorkspaceDto for comic presentation');
    }
    final dto = workspace;
    final metadata = dto.comic;
    final series = metadata.series;
    final publishing = metadata.publishing;
    final referenceRelease = resolveLibraryEntryReferenceRelease(item);
    final referenceVariant = referenceRelease.variant;
    final hasVolume = series?.hasVolume ?? false;
    final hasSeason = series?.hasSeason ?? false;
    final hasEpisode = series?.hasEpisode ?? false;
    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.titleItemId),
          LibraryDetailField(label: 'Title', value: metadata.title),
        ],
        if (series?.seriesTitle != null)
          LibraryDetailField(
              label: 'Series',
              value: series!.seriesTitle!,
              onTap: tapFor(series.seriesTitle)),
        if (hasVolume && !hasSeason)
          LibraryDetailField(
              label: 'Volume',
              value: series!.volumeName ?? (series.volumeNumber ?? '')),
        if (hasSeason && hasEpisode)
          LibraryDetailField(
              label: 'Season / Episode',
              value:
                  'Season ${series!.seasonNumber}, Ep. ${series.episodeNumber}'),
        if (hasSeason && !hasEpisode)
          LibraryDetailField(
              label: 'Season', value: 'Season ${series!.seasonNumber}'),
        if (hasEpisode && !hasSeason)
          LibraryDetailField(
              label: 'Episode', value: 'Ep. ${series!.episodeNumber}'),
        LibraryDetailField(
            label: 'No. / Vol.',
            value: genericLibraryDash(metadata.issueNumber),
            onTap: tapFor(metadata.issueNumber)),
        LibraryDetailField(
            label: 'Edition / Variant / Format',
            value: genericLibraryDash(metadata.variant),
            onTap: tapFor(metadata.variant)),
        LibraryDetailField(
            label: 'Barcode / UPC / ISBN',
            value: genericLibraryDash(metadata.barcode)),
      ],
      contextFacts: [
        LibraryDetailField(
            label: 'Publisher / Studio / Creator',
            value: genericLibraryDash(metadata.publisher),
            onTap: tapFor(metadata.publisher)),
        LibraryDetailField(
            label: 'Released',
            value: genericLibraryDash(
              formatPresentationNullableDate(metadata.releaseDate) ??
                  metadata.releaseDate?.year.toString(),
            )),
        if (publishing?.pageCount != null)
          LibraryDetailField(
              label: 'Pages', value: publishing!.pageCount.toString()),
        if (publishing?.coverPriceCents != null)
          LibraryDetailField(
              label: 'Cover Price',
              value: formatPresentationMoney(
                publishing!.coverPriceCents,
                publishing.currency,
              )),
        if (publishing?.imprint != null)
          LibraryDetailField(
              label: 'Imprint',
              value: publishing!.imprint!,
              onTap: tapFor(publishing.imprint)),
        if (publishing?.subtitle != null)
          LibraryDetailField(label: 'Subtitle', value: publishing!.subtitle!),
        LibraryDetailField(label: 'Country', value: metadata.country),
        LibraryDetailField(label: 'Language', value: metadata.language),
        if (metadata.ageRating != null)
          LibraryDetailField(label: 'Age Rating', value: metadata.ageRating!),
        if (referenceVariant?.variantType case final variantType?
            when variantType.trim().isNotEmpty)
          LibraryDetailField(label: 'Variant Type', value: variantType.trim()),
        if (referenceVariant?.sku case final sku? when sku.trim().isNotEmpty)
          LibraryDetailField(label: 'SKU', value: sku.trim()),
        if (referenceRelease.edition != null)
          LibraryDetailField(
              label: 'Primary release',
              value: [
                referenceRelease.edition!.title,
                if (referenceVariant?.name.trim().isNotEmpty == true)
                  referenceVariant!.name.trim(),
              ].join(' · ')),
        LibraryDetailField(
            label: 'Cover',
            value: metadata.releases.isEmpty ? 'Missing' : 'Ready'),
        LibraryDetailField(
            label: 'Metadata',
            value: metadata.publisher == null || metadata.publisher!.isEmpty
                ? 'Missing'
                : 'Ready'),
      ],
      sections: {
        'creators': LibraryMetadataSection(
          values: metadata.creators,
          placement: LibraryMetadataSectionPlacement.credits,
          renderer: LibraryMetadataSectionRenderer.credits,
          completenessWeight: 12,
        ),
        'characters': LibraryMetadataSection(
          values: metadata.characters,
          placement: LibraryMetadataSectionPlacement.credits,
          completenessWeight: 6,
        ),
        'story_arcs': LibraryMetadataSection(
          values: metadata.storyArcs,
          placement: LibraryMetadataSectionPlacement.credits,
          inlineLabelKey: 'story_arcs_inline',
        ),
        'genres': LibraryMetadataSection(
          values: metadata.genres,
        ),
      },
    );
  }

  @override
  List<Widget> buildInspectorSections({
    required BuildContext context,
    required LibraryProjectionView item,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    final workspace = item.dto;
    if (workspace is! ComicWorkspaceDto) {
      return const [];
    }
    final dto = workspace;
    final synopsis = dto.comic.synopsis;
    if (!showSummary || synopsis == null || synopsis.trim().isEmpty) {
      return const [];
    }
    return [
      LibraryDetailSection(
        title: 'Summary',
        accentColor: accent,
        children: [
          Text(
            synopsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ];
  }
}

LibraryAddSearchResultDisplay _buildComicSearchResultDisplay(
  LibraryAddCatalogTransport item,
) {
  final itemNumber = item.itemNumber?.trim();
  final subtitle = [
    if (item.publisher?.trim() case final value? when value.isNotEmpty) value,
    if ((item.releaseYear ?? item.releaseDate?.year) case final year?)
      year.toString(),
    if (item.physicalFormatLabel?.trim() case final value?
        when value.isNotEmpty)
      value,
    if (item.identifierCode?.trim() case final value? when value.isNotEmpty)
      value,
  ].join(' | ');
  return LibraryAddSearchResultDisplay(
    title: itemNumber == null || itemNumber.isEmpty
        ? item.title
        : '${item.title} #$itemNumber',
    secondaryLine: subtitle.isEmpty ? null : subtitle,
    detailLine: null,
  );
}
