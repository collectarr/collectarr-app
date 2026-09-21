import 'package:collectarr_app/features/library/release/library_release_detail_source.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';
import 'package:collectarr_app/features/library/release/library_release_detail_option.dart';

const _animeReleaseSourceKey = 'release_source';
const _animeReleaseAnchorKindKey = 'release_anchor_kind';
const _animeReleaseAnchorVariantIdKey = 'release_anchor_variant_id';
const _animeReleaseAnchorBundleIdKey = 'release_anchor_bundle_id';

const _animeReleaseSourceCatalog = 'catalog';
const _animeReleaseSourceLocalAnchor = 'local_anchor';
const _animeReleaseSourceTitleSnapshot = 'title_snapshot';
const _tmdbLocalSyntheticItemPrefix = 'tmdb-local:';

class AnimeReleaseAnchor {
  const AnimeReleaseAnchor({
    this.editionId,
    this.variantId,
    this.bundleReleaseId,
  });

  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
}

/// Adapts the canonical Core Anime release graph to the shared release
/// summary contract without inventing an identity or a fallback release.
List<CatalogEditionDto> canonicalAnimeReleaseEditions(AnimeMedia media) => [
      for (final release in media.releases) _canonicalEditionFor(release),
    ];

CatalogEditionDto _canonicalEditionFor(AnimeRelease release) {
  final raw = Map<String, dynamic>.from(release.rawPayload);
  final metadata = <String, dynamic>{
    ...raw,
    _animeReleaseSourceKey: _animeReleaseSourceCatalog,
    if (release.media.isNotEmpty)
      'media': release.media.map((entry) => entry.toJson()).toList(),
    if (release.episodeMappings.isNotEmpty)
      'episode_mappings':
          release.episodeMappings.map((entry) => entry.toJson()).toList(),
  };
  return CatalogEditionDto(
    id: release.id.value,
    title: release.title,
    format: release.format,
    publisher: release.publisher,
    distributor: release.distributor,
    upc: release.barcode,
    language: release.audioTracks.firstOrNull,
    region: release.regionCode,
    releaseDate: release.releaseDate,
    physicalFormat: release.format,
    physicalFormatLabel: release.format,
    metadata: metadata,
    discs: [
      for (final media in release.media)
        CatalogDiscDto(
          discNumber: media.mediaNumber,
          name: media.title ?? media.mediaType,
        ),
    ],
  );
}

List<CatalogEditionDto> resolveAnimeCatalogEditionsForCatalogItem(
  CatalogItemDto item, {
  Iterable<OwnedItemSummary> ownedItems = const <OwnedItemSummary>[],
  Iterable<WishlistItem> wishlistItems = const <WishlistItem>[],
}) {
  final payload = item.payload;
  final editionsPayload = payload['editions'] as List?;
  final rawEditions = editionsPayload != null
      ? editionsPayload
          .whereType<JsonMap>()
          .map((e) => CatalogEditionDto.fromJson(JsonMap.from(e)))
          .toList()
      : const <CatalogEditionDto>[];
  return _resolveAnimeCatalogEditions(
    _AnimeReleaseSeedInput(
      itemId: item.id,
      mediaType: 'anime',
      resolvedTitle: item.resolvedDisplayTitle,
      editionTitle: payload['edition_title'] as String?,
      distributor: (payload['publisher'] as String?) ??
          ((payload['publishing'] as Map?)?['original_publisher'] as String?),
      releaseDate: item.releaseDate,
      releaseYear: item.releaseYear ?? item.releaseDate?.year,
      physicalFormat: payload['physical_format'] as String?,
      formatLabel: payload['physical_format_label'] as String?,
      variant: payload['variant'] as String?,
      language: payload['language'] as String?,
      country: payload['country'] as String?,
      barcodeValue: payload['barcode'] as String?,
      coverImageUrl: item.coverImageUrl,
      thumbnailImageUrl: item.thumbnailImageUrl,
    ),
    rawEditions,
    ownedItems: ownedItems,
    wishlistItems: wishlistItems,
  );
}

AnimeReleaseAnchor animeReleaseAnchorForEdition(CatalogEditionDto edition) {
  final metadata = edition.metadata;
  final anchorKind = metadata?[_animeReleaseAnchorKindKey] as String?;
  final variantId = metadata?[_animeReleaseAnchorVariantIdKey] as String?;
  final bundleReleaseId = metadata?[_animeReleaseAnchorBundleIdKey] as String?;
  return switch (anchorKind) {
    'variant' => AnimeReleaseAnchor(variantId: variantId),
    'bundle_release' => AnimeReleaseAnchor(bundleReleaseId: bundleReleaseId),
    'item' => const AnimeReleaseAnchor(),
    _ => AnimeReleaseAnchor(editionId: edition.id),
  };
}

bool matchesAnimeReleaseAnchor(
  CatalogEditionDto edition, {
  String? editionId,
  String? variantId,
  String? bundleReleaseId,
}) {
  final anchor = animeReleaseAnchorForEdition(edition);
  final normalizedEditionId = _normalized(editionId);
  final normalizedVariantId = _normalized(variantId);
  final normalizedBundleReleaseId = _normalized(bundleReleaseId);
  if (anchor.editionId != null && anchor.editionId == normalizedEditionId) {
    return true;
  }
  if (anchor.variantId != null) {
    return anchor.variantId == normalizedVariantId ||
        edition.id == normalizedEditionId;
  }
  if (anchor.bundleReleaseId != null) {
    return anchor.bundleReleaseId == normalizedBundleReleaseId ||
        edition.id == normalizedEditionId;
  }
  return normalizedEditionId == null &&
      normalizedVariantId == null &&
      normalizedBundleReleaseId == null;
}

String animeReleaseSourceLabel(CatalogEditionDto edition) {
  final source = edition.metadata?[_animeReleaseSourceKey] as String?;
  return switch (source) {
    _animeReleaseSourceLocalAnchor => 'Collection anchors',
    _animeReleaseSourceTitleSnapshot => 'Title snapshot fallback',
    _ => 'Catalog edition',
  };
}

bool isCatalogAnimeRelease(CatalogEditionDto edition) {
  return (edition.metadata?[_animeReleaseSourceKey] as String?) ==
          _animeReleaseSourceCatalog ||
      edition.metadata?[_animeReleaseSourceKey] == null;
}

bool isLocalAnchorAnimeRelease(CatalogEditionDto edition) {
  return (edition.metadata?[_animeReleaseSourceKey] as String?) ==
      _animeReleaseSourceLocalAnchor;
}

bool isTitleSnapshotAnimeRelease(CatalogEditionDto edition) {
  return (edition.metadata?[_animeReleaseSourceKey] as String?) ==
      _animeReleaseSourceTitleSnapshot;
}

String? preferredAnimeEditionVariantId(CatalogEditionDto edition) {
  for (final variant in edition.variants) {
    if (variant.isPrimary) {
      return variant.id;
    }
  }
  return edition.variants.isEmpty ? null : edition.variants.first.id;
}

List<CatalogEditionDto> _resolveAnimeCatalogEditions(
  _AnimeReleaseSeedInput input,
  List<CatalogEditionDto> existingEditions, {
  required Iterable<OwnedItemSummary> ownedItems,
  required Iterable<WishlistItem> wishlistItems,
}) {
  if (existingEditions.isNotEmpty) {
    return existingEditions;
  }

  final seeds = <String, _EditionSeed>{};

  for (final copy in ownedItems) {
    if (copy.isDeleted) {
      continue;
    }
    _mergeAnchorSeed(
      seeds,
      input,
      editionId: _catalogRefEditionId(copy.targetRef),
      variantId: _catalogRefVariantId(copy.targetRef),
      bundleReleaseId: _catalogRefBundleReleaseId(copy.targetRef),
    );
  }

  for (final item in wishlistItems) {
    if (item.isDeleted) {
      continue;
    }
    final anchor = _animeReleaseAnchorFromCatalogRef(item.catalogRef);
    _mergeAnchorSeed(
      seeds,
      input,
      editionId: anchor.editionId,
      variantId: anchor.variantId,
      bundleReleaseId: anchor.bundleReleaseId,
    );
  }

  if (seeds.isEmpty) {
    if (!_isLocalSyntheticAnimeItemId(input.itemId)) {
      return const <CatalogEditionDto>[];
    }
    final editionId = _titleSnapshotEditionId(input.itemId);
    seeds[editionId] = _EditionSeed.titleSnapshot(input, editionId);
  }

  final editions = [
    for (final seed in seeds.values) seed.build(input),
  ];
  editions.sort(_compareCatalogEditions);
  return editions;
}

AnimeReleaseAnchor _animeReleaseAnchorFromCatalogRef(CatalogEntityRef ref) {
  return switch (ref.entityType.apiValue) {
    'edition' => AnimeReleaseAnchor(editionId: ref.id),
    'release' => AnimeReleaseAnchor(variantId: ref.id),
    'bundle_release' => AnimeReleaseAnchor(bundleReleaseId: ref.id),
    _ => const AnimeReleaseAnchor(),
  };
}

String? _catalogRefEditionId(CatalogEntityRef? ref) {
  return switch (ref?.entityType.apiValue) {
    'edition' => ref?.id,
    'release' => ref?.parentId,
    _ => null,
  };
}

String? _catalogRefVariantId(CatalogEntityRef? ref) {
  return ref?.entityType.apiValue == 'release' ? ref?.id : null;
}

String? _catalogRefBundleReleaseId(CatalogEntityRef? ref) {
  return ref?.entityType.apiValue == 'bundle_release' ? ref?.id : null;
}

void _mergeAnchorSeed(
  Map<String, _EditionSeed> seeds,
  _AnimeReleaseSeedInput input, {
  String? editionId,
  String? variantId,
  String? bundleReleaseId,
}) {
  final normalizedEditionId = _normalized(editionId);
  final normalizedVariantId = _normalized(variantId);
  final normalizedBundleReleaseId = _normalized(bundleReleaseId);
  if (normalizedEditionId == null &&
      normalizedVariantId == null &&
      normalizedBundleReleaseId == null) {
    return;
  }
  final id = normalizedEditionId ??
      (normalizedVariantId != null
          ? _variantSyntheticEditionId(input.itemId, normalizedVariantId)
          : _bundleSyntheticEditionId(
              input.itemId, normalizedBundleReleaseId!));
  final seed = seeds.putIfAbsent(
    id,
    () => _EditionSeed.localAnchor(
      input,
      id: id,
      variantId: normalizedVariantId,
      bundleReleaseId: normalizedBundleReleaseId,
    ),
  );
  seed.absorbAnchor(
    input,
    editionId: normalizedEditionId,
    variantId: normalizedVariantId,
    bundleReleaseId: normalizedBundleReleaseId,
  );
}

int _compareCatalogEditions(CatalogEditionDto left, CatalogEditionDto right) {
  final leftDate = left.releaseDate;
  final rightDate = right.releaseDate;
  if (leftDate != null && rightDate != null) {
    final byDate = rightDate.compareTo(leftDate);
    if (byDate != 0) {
      return byDate;
    }
  } else if (rightDate != null) {
    return 1;
  } else if (leftDate != null) {
    return -1;
  }

  final leftSource = left.metadata?[_animeReleaseSourceKey] as String?;
  final rightSource = right.metadata?[_animeReleaseSourceKey] as String?;
  final bySource =
      _sourcePriority(leftSource).compareTo(_sourcePriority(rightSource));
  if (bySource != 0) {
    return bySource;
  }
  final leftTitle = left.title;
  final rightTitle = right.title;
  return leftTitle.toLowerCase().compareTo(rightTitle.toLowerCase());
}

int _sourcePriority(String? value) {
  return switch (value) {
    _animeReleaseSourceCatalog => 0,
    _animeReleaseSourceLocalAnchor => 1,
    _animeReleaseSourceTitleSnapshot => 2,
    _ => 3,
  };
}

String? _normalized(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

String _titleSnapshotEditionId(String itemId) => 'anime:$itemId:title-snapshot';

String _variantSyntheticEditionId(String itemId, String variantId) =>
    'anime:$itemId:variant:$variantId';

String _bundleSyntheticEditionId(String itemId, String bundleReleaseId) =>
    'anime:$itemId:bundle:$bundleReleaseId';

bool _isLocalSyntheticAnimeItemId(String itemId) {
  return itemId.trim().toLowerCase().startsWith(_tmdbLocalSyntheticItemPrefix);
}

String _fallbackEditionTitle(_AnimeReleaseSeedInput input) {
  return _normalized(input.editionTitle) ??
      _normalized(input.formatLabel) ??
      'Standard release';
}

String _fallbackVariantName(_AnimeReleaseSeedInput input) {
  return _normalized(input.variant) ??
      _normalized(input.formatLabel) ??
      'Primary release';
}

class _AnimeReleaseSeedInput {
  const _AnimeReleaseSeedInput({
    required this.itemId,
    required this.mediaType,
    required this.resolvedTitle,
    this.editionTitle,
    this.distributor,
    this.releaseDate,
    this.releaseYear,
    this.physicalFormat,
    this.formatLabel,
    this.variant,
    this.language,
    this.country,
    this.barcodeValue,
    this.coverImageUrl,
    this.thumbnailImageUrl,
  });

  final String itemId;
  final String mediaType;
  final String resolvedTitle;
  final String? editionTitle;
  final String? distributor;
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? physicalFormat;
  final String? formatLabel;
  final String? variant;
  final String? language;
  final String? country;
  final String? barcodeValue;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
}

class _EditionSeed {
  _EditionSeed({
    required this.id,
    required this.title,
    required this.source,
    this.distributor,
    this.language,
    this.regionTerritory,
    this.releaseDate,
    this.physicalFormat,
    this.formatLabel,
    JsonMap? metadata,
    Map<String, CatalogVariantDto>? variants,
  })  : metadata = JsonMap.from({...?metadata, _animeReleaseSourceKey: source}),
        _variants = <String, CatalogVariantDto>{...?variants};

  factory _EditionSeed.localAnchor(
    _AnimeReleaseSeedInput input, {
    required String id,
    String? variantId,
    String? bundleReleaseId,
  }) {
    final metadata = JsonMap.from({
      _animeReleaseAnchorKindKey: variantId != null
          ? 'variant'
          : bundleReleaseId != null
              ? 'bundle_release'
              : 'edition',
      if (variantId != null) _animeReleaseAnchorVariantIdKey: variantId,
      if (bundleReleaseId != null)
        _animeReleaseAnchorBundleIdKey: bundleReleaseId,
    });
    final seed = _EditionSeed(
      id: id,
      title: _fallbackEditionTitle(input),
      source: _animeReleaseSourceLocalAnchor,
      distributor: _normalized(input.distributor),
      language: _normalized(input.language),
      regionTerritory: _normalized(input.country),
      releaseDate: input.releaseDate,
      physicalFormat: _normalized(input.physicalFormat),
      formatLabel: _normalized(input.formatLabel),
      metadata: metadata,
    );
    if (variantId != null) {
      seed._variants[variantId] = CatalogVariantDto(
        id: variantId,
        name: _fallbackVariantName(input),
        barcode: input.barcodeValue,
        coverImageUrl: input.coverImageUrl,
        thumbnailImageUrl: input.thumbnailImageUrl,
        physicalFormat: input.physicalFormat,
        physicalFormatLabel: input.formatLabel,
        isPrimary: true,
      );
    }
    return seed;
  }

  factory _EditionSeed.titleSnapshot(
    _AnimeReleaseSeedInput input,
    String id,
  ) {
    return _EditionSeed(
      id: id,
      title: _fallbackEditionTitle(input),
      source: _animeReleaseSourceTitleSnapshot,
      distributor: _normalized(input.distributor),
      language: _normalized(input.language),
      regionTerritory: _normalized(input.country),
      releaseDate: input.releaseDate,
      physicalFormat: _normalized(input.physicalFormat),
      formatLabel: _normalized(input.formatLabel),
      metadata: JsonMap.from({
        _animeReleaseAnchorKindKey: 'item',
      }),
    );
  }

  final String id;
  final String title;
  final String source;
  final String? distributor;
  final String? language;
  final String? regionTerritory;
  final DateTime? releaseDate;
  final String? physicalFormat;
  final String? formatLabel;
  final JsonMap metadata;
  final Map<String, CatalogVariantDto> _variants;

  void absorbAnchor(
    _AnimeReleaseSeedInput input, {
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
  }) {
    final normalizedVariantId = _normalized(variantId);
    final normalizedBundleReleaseId = _normalized(bundleReleaseId);
    if (normalizedVariantId != null &&
        !_variants.containsKey(normalizedVariantId)) {
      _variants[normalizedVariantId] = CatalogVariantDto(
        id: normalizedVariantId,
        name: _fallbackVariantName(input),
        barcode: input.barcodeValue,
        coverImageUrl: input.coverImageUrl,
        thumbnailImageUrl: input.thumbnailImageUrl,
        physicalFormat: input.physicalFormat,
        physicalFormatLabel: input.formatLabel,
        isPrimary: true,
        metadata: JsonMap.from({
          if (normalizedBundleReleaseId != null)
            _animeReleaseAnchorBundleIdKey: normalizedBundleReleaseId,
        }),
      );
    }
    if (editionId == null &&
        normalizedVariantId == null &&
        normalizedBundleReleaseId != null) {
      metadata[_animeReleaseAnchorKindKey] = 'bundle_release';
      metadata[_animeReleaseAnchorBundleIdKey] = normalizedBundleReleaseId;
    }
  }

  CatalogEditionDto build(_AnimeReleaseSeedInput input) {
    final variants = [
      for (final variant in _variants.values) _enrichVariant(variant, input),
    ];
    if (variants.isEmpty) {
      variants.add(
        CatalogVariantDto(
          id: '$id:primary',
          name: _fallbackVariantName(input),
          barcode: input.barcodeValue,
          coverImageUrl: input.coverImageUrl,
          thumbnailImageUrl: input.thumbnailImageUrl,
          physicalFormat: input.physicalFormat,
          physicalFormatLabel: input.formatLabel,
          isPrimary: true,
        ),
      );
    }
    if (!variants.any((variant) => variant.isPrimary)) {
      final first = variants.first;
      variants[0] = CatalogVariantDto(
        id: first.id,
        name: first.name,
        variantType: first.variantType,
        sku: first.sku,
        barcode: first.barcode,
        isbn: first.isbn,
        region: first.region,
        platform: first.platform,
        coverPriceCents: first.coverPriceCents,
        currency: first.currency,
        coverImageUrl: first.coverImageUrl,
        thumbnailImageUrl: first.thumbnailImageUrl,
        description: first.description,
        physicalFormat: first.physicalFormat,
        physicalFormatLabel: first.physicalFormatLabel,
        metadata: first.metadata,
        isPrimary: true,
      );
    }
    return CatalogEditionDto(
      id: id,
      title: title,
      publisher: distributor,
      language: language,
      region: regionTerritory,
      releaseDate: releaseDate,
      physicalFormat: physicalFormat,
      physicalFormatLabel: formatLabel,
      metadata: metadata,
      variants: variants,
    );
  }

  CatalogVariantDto _enrichVariant(
    CatalogVariantDto variant,
    _AnimeReleaseSeedInput input,
  ) {
    return CatalogVariantDto(
      id: variant.id,
      name: _normalized(variant.name) ?? _fallbackVariantName(input),
      variantType: variant.variantType,
      sku: variant.sku,
      barcode: _normalized(variant.barcode) ?? _normalized(input.barcodeValue),
      isbn: variant.isbn,
      region: _normalized(variant.region) ?? _normalized(input.country),
      platform: variant.platform,
      coverPriceCents: variant.coverPriceCents,
      currency: variant.currency,
      coverImageUrl: _normalized(variant.coverImageUrl) ??
          _normalized(input.coverImageUrl),
      thumbnailImageUrl: _normalized(variant.thumbnailImageUrl) ??
          _normalized(variant.coverImageUrl) ??
          _normalized(input.thumbnailImageUrl) ??
          _normalized(input.coverImageUrl),
      description: variant.description,
      physicalFormat: _normalized(variant.physicalFormat) ??
          _normalized(input.physicalFormat),
      physicalFormatLabel: _normalized(variant.physicalFormatLabel) ??
          _normalized(input.formatLabel),
      metadata: variant.metadata,
      isPrimary: variant.isPrimary,
    );
  }
}

final class AnimeReleaseDetailSource implements LibraryReleaseDetailSource {
  const AnimeReleaseDetailSource();

  List<CatalogEditionDto> resolveCatalogData(
    LibraryWorkspaceCatalogData catalogData, {
    Iterable<OwnedItemSummary> ownedItems = const <OwnedItemSummary>[],
    Iterable<WishlistItem> wishlistItems = const <WishlistItem>[],
  }) {
    if (catalogData is! AnimeWorkspaceCatalogData) {
      throw ArgumentError.value(
        catalogData,
        'catalogData',
        'Expected AnimeWorkspaceCatalogData',
      );
    }
    final canonical = canonicalAnimeReleaseEditions(catalogData.media);
    if (canonical.isEmpty) return const <CatalogEditionDto>[];
    return canonical;
  }

  @override
  CatalogSearchCandidate candidateForCatalogData(
    LibraryWorkspaceCatalogData catalogData,
  ) {
    if (catalogData is! AnimeWorkspaceCatalogData) {
      throw ArgumentError.value(
        catalogData,
        'catalogData',
        'Expected AnimeWorkspaceCatalogData',
      );
    }
    return CatalogSearchCandidate.fromItem(catalogData.releaseTransport);
  }

  CatalogEntityRef targetRefForEdition(
    CatalogEntityRef rootRef,
    CatalogEditionDto edition,
  ) {
    final anchor = animeReleaseAnchorForEdition(edition);
    if (anchor.bundleReleaseId != null) {
      return CatalogEntityRef(
        kind: rootRef.kind,
        entityType: const CatalogEntityTypeId('bundle_release'),
        id: anchor.bundleReleaseId!,
        rootId: rootRef.id,
      );
    }
    if (anchor.variantId != null) {
      return CatalogEntityRef(
        kind: rootRef.kind,
        entityType: const CatalogEntityTypeId('release'),
        id: anchor.variantId!,
        rootId: rootRef.id,
        parentId: anchor.editionId,
      );
    }
    if (anchor.editionId != null) {
      return CatalogEntityRef(
        kind: rootRef.kind,
        entityType: const CatalogEntityTypeId('edition'),
        id: anchor.editionId!,
        rootId: rootRef.id,
      );
    }
    return rootRef;
  }

  bool matchesTarget(CatalogEntityRef targetRef, CatalogEditionDto edition) {
    final anchor = _animeReleaseAnchorFromCatalogRef(targetRef);
    return matchesAnimeReleaseAnchor(
      edition,
      editionId: anchor.editionId,
      variantId: anchor.variantId,
      bundleReleaseId: anchor.bundleReleaseId,
    );
  }

  String sourceLabel(CatalogEditionDto edition) =>
      animeReleaseSourceLabel(edition);

  bool isCatalogRelease(CatalogEditionDto edition) =>
      isCatalogAnimeRelease(edition);

  bool isTitleSnapshotRelease(CatalogEditionDto edition) =>
      isTitleSnapshotAnimeRelease(edition);

  String? preferredVariantId(CatalogEditionDto edition) =>
      preferredAnimeEditionVariantId(edition);

  LibraryWorkspaceReleaseSummary workspaceSummaryForEdition(
    CatalogEditionDto edition,
  ) {
    return LibraryWorkspaceReleaseSummary(
      id: edition.id,
      title: edition.title,
      formatLabel: edition.format ?? edition.physicalFormatLabel,
      releaseDate: edition.releaseDate,
      variantCount: edition.variants.length,
      variants: [
        for (final variant in edition.variants)
          LibraryWorkspaceVariantSummary(
            id: variant.id,
            name: variant.name,
            coverImageUrl: variant.coverImageUrl,
            thumbnailImageUrl: variant.thumbnailImageUrl,
            formatLabel: variant.physicalFormatLabel ?? variant.physicalFormat,
            sku: variant.sku,
            isPrimary: variant.isPrimary,
          ),
      ],
    );
  }

  @override
  List<LibraryReleaseDetailOption> detailOptionsForCatalogData(
    LibraryWorkspaceCatalogData catalogData,
    CatalogEntityRef rootRef, {
    Iterable<OwnedItemSummary> ownedItems = const <OwnedItemSummary>[],
    Iterable<WishlistItem> wishlistItems = const <WishlistItem>[],
  }) {
    final editions = resolveCatalogData(
      catalogData,
      ownedItems: ownedItems,
      wishlistItems: wishlistItems,
    );
    return [
      for (final edition in editions)
        LibraryReleaseDetailOption(
          targetRef: targetRefForEdition(rootRef, edition),
          summary: workspaceSummaryForEdition(edition),
          sourceLabel: sourceLabel(edition),
          isCatalogRelease: isCatalogRelease(edition),
          isTitleSnapshotRelease: isTitleSnapshotRelease(edition),
        ),
    ];
  }
}
