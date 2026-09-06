import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/hierarchy/ui/hierarchy_children_section.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BookLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const BookLibraryMediaPresentationBuilder({
    this.showSummary = false,
    this.showVolumeHierarchy = false,
    this.metadataLabels = const LibraryMetadataLabels(),
  });

  final bool showSummary;
  final bool showVolumeHierarchy;
  final LibraryMetadataLabels metadataLabels;

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required LibraryProjectionRuntime item,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final dto = item.dto;
    final adapter = dto is WorkspaceDtoAdapter ? dto : null;
    final itemNumber = adapter?.itemNumber;
    final variant = adapter?.variant;
    final barcode = adapter?.barcode;
    final publisher = adapter?.publisher;
    final releaseDate = adapter?.releaseDate;
    final country = adapter?.country;
    final language = adapter?.language;

    final metadata = _bookMetadata(item);
    final series = metadata?.series;
    final publishing = metadata?.publishing;
    final referenceRelease = resolveLibraryEntryReferenceRelease(item);
    final referenceVariant = referenceRelease.variant;
    final referencePlatforms = libraryReferencePlatforms(item);
    final hasVolume = series?.hasVolume ?? false;
    final hasSeason = series?.hasSeason ?? false;
    final hasEpisode = series?.hasEpisode ?? false;
    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.titleItemId),
          LibraryDetailField(label: 'Title', value: dto.title),
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
            label: 'Volume',
            value: genericLibraryDash(itemNumber),
            onTap: tapFor(itemNumber)),
        LibraryDetailField(
            label: 'Edition / Binding',
            value: genericLibraryDash(variant),
            onTap: tapFor(variant)),
        LibraryDetailField(
            label: 'ISBN / Barcode', value: genericLibraryDash(barcode)),
      ],
      contextFacts: [
        LibraryDetailField(
            label: 'Publisher',
            value: genericLibraryDash(publisher),
            onTap: tapFor(publisher)),
        LibraryDetailField(
            label: 'Released',
            value: genericLibraryDash(
              formatPresentationNullableDate(releaseDate) ??
                  releaseDate?.year.toString(),
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
        if (publishing?.seriesGroup != null)
          LibraryDetailField(
              label: 'Series Group',
              value: publishing!.seriesGroup!,
              onTap: tapFor(publishing.seriesGroup)),
        if (publishing?.subtitle != null)
          LibraryDetailField(label: 'Subtitle', value: publishing!.subtitle!),
        if (country != null)
          LibraryDetailField(label: 'Country', value: country),
        if (language != null)
          LibraryDetailField(label: 'Language', value: language),
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
        if (referencePlatforms.isNotEmpty)
          LibraryDetailField(
              label: referencePlatforms.length == 1 ? 'Platform' : 'Platforms',
              value: referencePlatforms.join(', ')),
        LibraryDetailField(
            label: 'Cover',
            value: dto.coverImageUrl == null || dto.coverImageUrl!.isEmpty
                ? 'Missing'
                : 'Ready'),
        LibraryDetailField(
            label: 'Metadata',
            value:
                publisher == null || publisher.isEmpty ? 'Missing' : 'Ready'),
      ],
      sections: {
        'creators': LibraryMetadataSection(
          values: metadata?.creators ?? const <Map<String, dynamic>>[],
          placement: LibraryMetadataSectionPlacement.credits,
          renderer: LibraryMetadataSectionRenderer.credits,
          completenessWeight: 12,
        ),
        'genres': LibraryMetadataSection(
          values: metadata?.genres ?? const <String>[],
        ),
      },
    );
  }

  @override
  List<Widget> buildInspectorSections({
    required BuildContext context,
    required LibraryProjectionRuntime item,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    final sections = <Widget>[];
    if (showVolumeHierarchy) {
      sections.add(
        HierarchyChildrenSection(
          itemId: item.node.titleItemId,
          canHydrateFromCore: true,
          kind: CatalogMediaKind.book,
        ),
      );
    }
    final dto = item.dto;
    final metadata = _bookMetadata(item);
    final series = metadata?.series;
    final sectionSpecs = <LibraryDetailSectionSpec>[];

    final originalFacts = <LibraryDetailField>[
      if (series?.seriesTitle?.trim().isNotEmpty == true)
        LibraryDetailField(label: 'Series', value: series!.seriesTitle!.trim()),
      if (metadata?.synopsis != null && metadata!.synopsis!.trim().isNotEmpty)
        LibraryDetailField(label: 'Summary', value: metadata.synopsis!.trim()),
    ];
    if (originalFacts.isNotEmpty) {
      sectionSpecs.add(
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.identity,
          title: 'Original Details',
          children: [LibraryDetailFieldTable(fields: originalFacts)],
        ),
      );
    }

    final adapter = dto is WorkspaceDtoAdapter ? dto : null;
    final productFacts = <LibraryDetailField>[
      if (adapter?.referenceFormatLabel?.trim().isNotEmpty == true)
        LibraryDetailField(
            label: 'Format', value: adapter!.referenceFormatLabel!.trim()),
      if (adapter?.publisher?.trim().isNotEmpty == true)
        LibraryDetailField(
            label: 'Publisher', value: adapter!.publisher!.trim()),
      if (adapter?.barcode?.trim().isNotEmpty == true)
        LibraryDetailField(
            label: 'ISBN / Barcode', value: adapter!.barcode!.trim()),
      if (adapter?.country?.trim().isNotEmpty == true)
        LibraryDetailField(label: 'Country', value: adapter!.country!.trim()),
      if (adapter?.language?.trim().isNotEmpty == true)
        LibraryDetailField(label: 'Language', value: adapter!.language!.trim()),
    ];
    if (productFacts.isNotEmpty) {
      sectionSpecs.add(
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.metadata,
          title: 'Product Details',
          children: [LibraryDetailFieldTable(fields: productFacts)],
        ),
      );
    }

    final creatorNames = <String>[
      for (final creator
          in metadata?.creators ?? const <Map<String, dynamic>>[])
        if (creator['name']?.toString().trim().isNotEmpty == true)
          creator['name']!.toString().trim(),
    ];
    sectionSpecs.add(
      LibraryDetailSectionSpec(
        slot: LibraryDetailSectionSlot.relations,
        title: 'Contributors',
        chips: [
          LibraryDetailChipGroup(
            values: creatorNames,
            onValueTap: onFilterByValue,
          ),
        ],
      ),
    );

    final imageFacts = <LibraryDetailField>[
      if (dto.coverImageUrl?.trim().isNotEmpty == true)
        LibraryDetailField(label: 'Cover', value: dto.coverImageUrl!.trim()),
    ];
    if (imageFacts.isNotEmpty) {
      sectionSpecs.add(
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.media,
          title: 'Images',
          children: [LibraryDetailFieldTable(fields: imageFacts)],
        ),
      );
    }

    final identifierValues = <String>[
      if (adapter?.barcode?.trim().isNotEmpty == true) adapter!.barcode!.trim(),
    ];
    if (identifierValues.isNotEmpty) {
      sectionSpecs.add(
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.source,
          title: 'Identifiers',
          chips: [
            LibraryDetailChipGroup(
              values: identifierValues,
              onValueTap: onFilterByValue,
            ),
          ],
        ),
      );
    }

    final source = item.source;
    final rating = source.trackingEntry == null
        ? source.ownedItem?.rating
        : source.trackingEntry?.rating;
    final personalFacts = <LibraryDetailField>[
      if (source.condition?.trim().isNotEmpty == true)
        LibraryDetailField(label: 'Condition', value: source.condition!.trim()),
      if (source.grade?.trim().isNotEmpty == true)
        LibraryDetailField(label: 'Grade', value: source.grade!.trim()),
      if (source.ownedItem?.collectionStatus?.trim().isNotEmpty == true)
        LibraryDetailField(
            label: 'Collection Status',
            value: source.ownedItem!.collectionStatus!.trim()),
      if (rating != null)
        LibraryDetailField(label: 'Rating', value: rating.toString()),
      if (source.locationPath?.trim().isNotEmpty == true)
        LibraryDetailField(
            label: 'Location', value: source.locationPath!.trim()),
      if (source.pricePaidCents != null)
        LibraryDetailField(
            label: 'Price Paid', value: source.pricePaidCents!.toString()),
      if (source.personalNotes?.trim().isNotEmpty == true)
        LibraryDetailField(label: 'Notes', value: source.personalNotes!.trim()),
      if (source.tags?.trim().isNotEmpty == true)
        LibraryDetailField(label: 'Tags', value: source.tags!.trim()),
    ];
    if (personalFacts.isNotEmpty) {
      sectionSpecs.add(
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.personal,
          title: 'Personal Details',
          children: [LibraryDetailFieldTable(fields: personalFacts)],
        ),
      );
    }

    for (final spec in sectionSpecs) {
      sections.add(
        LibraryDetailSection(
          title: spec.title,
          accentColor: accent,
          children: spec.children,
        ),
      );
    }
    return sections;
  }

  @override
  Widget? buildAddPreviewPane({
    required BuildContext context,
    required Color accent,
    required String singularLabel,
    required LibraryMediaPreviewLabels previewLabels,
    required CatalogItem? item,
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
    final coverUrl =
        item?.displayCoverUrl ?? preview?.coverImageUrl ?? candidate?.imageUrl;
    final itemNumber = _bookMetadataItem(item)?.itemNumber ??
        preview?.itemNumber ??
        candidate?.issueNumber;
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
            kAppCanvas,
            Color.alphaBlend(accent.withValues(alpha: 0.22), kAppCanvas),
            kAppCanvas,
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
                      if (creatorLine != null &&
                          creatorLine!.trim().isNotEmpty) ...[
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
                        if (synopsis != null &&
                            synopsis!.trim().isNotEmpty) ...[
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
                          Row(
                            children: [
                              const SizedBox.square(
                                dimension: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Fetching full metadata...',
                                style: TextStyle(
                                  color: appPalette(context).textMuted,
                                ),
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
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color:
                                  appPalette(context).surfaceSubtle.withValues(
                                        alpha: 0.82,
                                      ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Center(
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
                                  TextSpan(
                                    text: 'Pages ',
                                    style: TextStyle(
                                      color: appPalette(context).textMuted,
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
    final hasFacts = (publisherYearLine?.trim().isNotEmpty ?? false) ||
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
              if (publisherYearLine != null &&
                  publisherYearLine!.trim().isNotEmpty)
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
  required CatalogItem? item,
  required ProviderCandidate? candidate,
  required AdminProviderPreview? preview,
}) {
  final subtitle = _bookMetadataItem(item)?.publishing?.subtitle ??
      preview?.publishing?.subtitle;
  if (subtitle != null &&
      subtitle.trim().isNotEmpty &&
      subtitle.trim() != title.trim()) {
    return subtitle.trim();
  }

  final seriesTitle = _bookMetadataItem(item)?.series?.seriesTitle ??
      preview?.series?.seriesTitle ??
      candidate?.series?.seriesTitle;
  final number = _bookMetadataItem(item)?.itemNumber ??
      preview?.itemNumber ??
      candidate?.issueNumber;
  if (seriesTitle != null &&
      seriesTitle.trim().isNotEmpty &&
      seriesTitle.trim() != title.trim()) {
    if (number != null && number.trim().isNotEmpty) {
      return '$seriesTitle, Book $number';
    }
    return seriesTitle.trim();
  }

  final edition = _bookMetadataItem(item)?.editionTitle ??
      _bookMetadataItem(item)?.physicalFormatLabel ??
      preview?.physicalFormatLabel ??
      preview?.editionTitle;
  return edition?.trim().isEmpty ?? true ? null : edition!.trim();
}

String? _bookCreatorLineForSelection({
  required CatalogItem? item,
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

  for (final credit
      in _bookMetadataItem(item)?.creators ?? const <Map<String, dynamic>>[]) {
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
  required CatalogItem? item,
  required ProviderCandidate? candidate,
  required AdminProviderPreview? preview,
}) {
  final publisher = _bookMetadataItem(item)?.publisher ??
      _bookMetadataItem(item)?.publishing?.originalPublisher ??
      preview?.publisher ??
      candidate?.publisher;
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
  required CatalogItem? item,
  required AdminProviderPreview? preview,
}) {
  final meta = _bookMetadataItem(item);
  final displayEditionLabel = meta?.editionTitle ?? meta?.physicalFormatLabel;
  final values = <String>[
    if (displayEditionLabel != null && displayEditionLabel.trim().isNotEmpty)
      displayEditionLabel.trim()
    else if (preview?.physicalFormatLabel != null &&
        preview!.physicalFormatLabel!.trim().isNotEmpty)
      preview.physicalFormatLabel!.trim(),
    if (meta?.language != null && meta!.language!.trim().isNotEmpty)
      meta.language!.trim()
    else if (preview?.language != null && preview!.language!.trim().isNotEmpty)
      preview.language!.trim(),
  ];
  return values.isEmpty ? null : values.join(' / ');
}

String? _bookIsbnForSelection({
  required CatalogItem? item,
  required AdminProviderPreview? preview,
}) {
  final meta = _bookMetadataItem(item);
  final isbn = preview?.isbn ?? meta?.barcode;
  return isbn?.trim().isEmpty ?? true ? null : isbn!.trim();
}

int? _bookPageCountForSelection({
  required CatalogItem? item,
  required AdminProviderPreview? preview,
}) {
  return _bookMetadataItem(item)?.publishing?.pageCount ??
      preview?.publishing?.pageCount;
}

List<String> _bookDiscoveryTagsForSelection({
  required CatalogItem? item,
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

  final meta = _bookMetadataItem(item);
  addAll(meta?.genres ?? preview?.genres ?? const <String>[]);
  addAll(meta?.series?.tags?.split(', ') ??
      (preview?.series?.tags != null
          ? [preview!.series!.tags!]
          : const <String>[]));
  return tags;
}

BookCatalogMetadata? _bookMetadata(LibraryProjectionRuntime item) {
  final metadata = item.source.catalogItem?.kindMetadata;
  if (metadata is BookCatalogMetadata) return metadata;
  final payload = item.source.catalogItem?.payload;
  return payload == null ? null : BookCatalogMetadata.fromJson(payload);
}

BookCatalogMetadata? _bookMetadataItem(CatalogItem? item) {
  final metadata = item?.kindMetadata;
  if (metadata is BookCatalogMetadata) return metadata;
  final payload = item?.payload;
  return payload == null ? null : BookCatalogMetadata.fromJson(payload);
}
