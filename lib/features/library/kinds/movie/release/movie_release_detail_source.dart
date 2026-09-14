import 'package:collectarr_app/features/library/release/library_release_detail_source.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';
import 'package:collectarr_app/features/library/release/library_release_detail_option.dart';

const _movieReleaseSourceKey = 'release_source';
const _movieReleaseAnchorKindKey = 'release_anchor_kind';
const _movieReleaseAnchorVariantIdKey = 'release_anchor_variant_id';
const _movieReleaseAnchorBundleIdKey = 'release_anchor_bundle_id';

const _movieReleaseSourceCatalog = 'catalog';
const _movieReleaseSourceLocalAnchor = 'local_anchor';
const _movieReleaseSourceTitleSnapshot = 'title_snapshot';
const _tmdbLocalSyntheticItemPrefix = 'tmdb-local:';

class MovieReleaseAnchor {
  const MovieReleaseAnchor({
    this.editionId,
    this.variantId,
    this.bundleReleaseId,
  });

  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
}

List<CatalogEditionDto> resolveMovieCatalogEditionsForCatalogItem(
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
  return _resolveMovieCatalogEditions(
    _MovieReleaseSeedInput(
      itemId: item.id,
      mediaType: 'movie',
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

MovieReleaseAnchor movieReleaseAnchorForEdition(CatalogEditionDto edition) {
  final metadata = edition.metadata;
  final anchorKind = metadata?[_movieReleaseAnchorKindKey] as String?;
  final variantId = metadata?[_movieReleaseAnchorVariantIdKey] as String?;
  final bundleReleaseId = metadata?[_movieReleaseAnchorBundleIdKey] as String?;
  return switch (anchorKind) {
    'variant' => MovieReleaseAnchor(variantId: variantId),
    'bundle_release' => MovieReleaseAnchor(bundleReleaseId: bundleReleaseId),
    'item' => const MovieReleaseAnchor(),
    _ => MovieReleaseAnchor(editionId: edition.id),
  };
}

bool matchesMovieReleaseAnchor(
  CatalogEditionDto edition, {
  String? editionId,
  String? variantId,
  String? bundleReleaseId,
}) {
  final anchor = movieReleaseAnchorForEdition(edition);
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

String movieReleaseSourceLabel(CatalogEditionDto edition) {
  final source = edition.metadata?[_movieReleaseSourceKey] as String?;
  return switch (source) {
    _movieReleaseSourceLocalAnchor => 'Collection anchors',
    _movieReleaseSourceTitleSnapshot => 'Title snapshot fallback',
    _ => 'Catalog edition',
  };
}

bool isCatalogMovieRelease(CatalogEditionDto edition) {
  return (edition.metadata?[_movieReleaseSourceKey] as String?) ==
          _movieReleaseSourceCatalog ||
      edition.metadata?[_movieReleaseSourceKey] == null;
}

bool isLocalAnchorMovieRelease(CatalogEditionDto edition) {
  return (edition.metadata?[_movieReleaseSourceKey] as String?) ==
      _movieReleaseSourceLocalAnchor;
}

bool isTitleSnapshotMovieRelease(CatalogEditionDto edition) {
  return (edition.metadata?[_movieReleaseSourceKey] as String?) ==
      _movieReleaseSourceTitleSnapshot;
}

String? preferredMovieEditionVariantId(CatalogEditionDto edition) {
  for (final variant in edition.variants) {
    if (variant.isPrimary) {
      return variant.id;
    }
  }
  return edition.variants.isEmpty ? null : edition.variants.first.id;
}

List<CatalogEditionDto> _resolveMovieCatalogEditions(
  _MovieReleaseSeedInput input,
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
    final anchor = _movieReleaseAnchorFromCatalogRef(item.catalogRef);
    _mergeAnchorSeed(
      seeds,
      input,
      editionId: anchor.editionId,
      variantId: anchor.variantId,
      bundleReleaseId: anchor.bundleReleaseId,
    );
  }

  if (seeds.isEmpty) {
    if (!_isLocalSyntheticMovieItemId(input.itemId)) {
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

MovieReleaseAnchor _movieReleaseAnchorFromCatalogRef(CatalogEntityRef ref) {
  return switch (ref.entityType.apiValue) {
    'edition' => MovieReleaseAnchor(editionId: ref.id),
    'release' => MovieReleaseAnchor(variantId: ref.id),
    'bundle_release' => MovieReleaseAnchor(bundleReleaseId: ref.id),
    _ => const MovieReleaseAnchor(),
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
  _MovieReleaseSeedInput input, {
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

  final leftSource = left.metadata?[_movieReleaseSourceKey] as String?;
  final rightSource = right.metadata?[_movieReleaseSourceKey] as String?;
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
    _movieReleaseSourceCatalog => 0,
    _movieReleaseSourceLocalAnchor => 1,
    _movieReleaseSourceTitleSnapshot => 2,
    _ => 3,
  };
}

String? _normalized(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

String _titleSnapshotEditionId(String itemId) => 'movie:$itemId:title-snapshot';

String _variantSyntheticEditionId(String itemId, String variantId) =>
    'movie:$itemId:variant:$variantId';

String _bundleSyntheticEditionId(String itemId, String bundleReleaseId) =>
    'movie:$itemId:bundle:$bundleReleaseId';

bool _isLocalSyntheticMovieItemId(String itemId) {
  return itemId.trim().toLowerCase().startsWith(_tmdbLocalSyntheticItemPrefix);
}

String _fallbackEditionTitle(_MovieReleaseSeedInput input) {
  return _normalized(input.editionTitle) ??
      _normalized(input.formatLabel) ??
      'Standard release';
}

String _fallbackVariantName(_MovieReleaseSeedInput input) {
  return _normalized(input.variant) ??
      _normalized(input.formatLabel) ??
      'Primary release';
}

class _MovieReleaseSeedInput {
  const _MovieReleaseSeedInput({
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
  })  : metadata = JsonMap.from({...?metadata, _movieReleaseSourceKey: source}),
        _variants = <String, CatalogVariantDto>{...?variants};

  factory _EditionSeed.localAnchor(
    _MovieReleaseSeedInput input, {
    required String id,
    String? variantId,
    String? bundleReleaseId,
  }) {
    final metadata = JsonMap.from({
      _movieReleaseAnchorKindKey: variantId != null
          ? 'variant'
          : bundleReleaseId != null
              ? 'bundle_release'
              : 'edition',
      if (variantId != null) _movieReleaseAnchorVariantIdKey: variantId,
      if (bundleReleaseId != null)
        _movieReleaseAnchorBundleIdKey: bundleReleaseId,
    });
    final seed = _EditionSeed(
      id: id,
      title: _fallbackEditionTitle(input),
      source: _movieReleaseSourceLocalAnchor,
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
    _MovieReleaseSeedInput input,
    String id,
  ) {
    return _EditionSeed(
      id: id,
      title: _fallbackEditionTitle(input),
      source: _movieReleaseSourceTitleSnapshot,
      distributor: _normalized(input.distributor),
      language: _normalized(input.language),
      regionTerritory: _normalized(input.country),
      releaseDate: input.releaseDate,
      physicalFormat: _normalized(input.physicalFormat),
      formatLabel: _normalized(input.formatLabel),
      metadata: JsonMap.from({
        _movieReleaseAnchorKindKey: 'item',
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
    _MovieReleaseSeedInput input, {
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
            _movieReleaseAnchorBundleIdKey: normalizedBundleReleaseId,
        }),
      );
    }
    if (editionId == null &&
        normalizedVariantId == null &&
        normalizedBundleReleaseId != null) {
      metadata[_movieReleaseAnchorKindKey] = 'bundle_release';
      metadata[_movieReleaseAnchorBundleIdKey] = normalizedBundleReleaseId;
    }
  }

  CatalogEditionDto build(_MovieReleaseSeedInput input) {
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
    _MovieReleaseSeedInput input,
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

final class MovieReleaseDetailSource implements LibraryReleaseDetailSource {
  const MovieReleaseDetailSource();

  List<CatalogEditionDto> resolveCatalogData(
    LibraryWorkspaceCatalogData catalogData, {
    Iterable<OwnedItemSummary> ownedItems = const <OwnedItemSummary>[],
    Iterable<WishlistItem> wishlistItems = const <WishlistItem>[],
  }) {
    if (catalogData is! MovieWorkspaceCatalogData) {
      throw ArgumentError.value(
        catalogData,
        'catalogData',
        'Expected MovieWorkspaceCatalogData',
      );
    }
    return resolveMovieCatalogEditionsForCatalogItem(
      catalogData.releaseTransport,
      ownedItems: ownedItems,
      wishlistItems: wishlistItems,
    );
  }

  @override
  CatalogSearchCandidate candidateForCatalogData(
    LibraryWorkspaceCatalogData catalogData,
  ) {
    if (catalogData is! MovieWorkspaceCatalogData) {
      throw ArgumentError.value(
        catalogData,
        'catalogData',
        'Expected MovieWorkspaceCatalogData',
      );
    }
    return CatalogSearchCandidate.fromItem(catalogData.releaseTransport);
  }

  CatalogEntityRef targetRefForEdition(
    CatalogEntityRef rootRef,
    CatalogEditionDto edition,
  ) {
    final anchor = movieReleaseAnchorForEdition(edition);
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
    final anchor = _movieReleaseAnchorFromCatalogRef(targetRef);
    return matchesMovieReleaseAnchor(
      edition,
      editionId: anchor.editionId,
      variantId: anchor.variantId,
      bundleReleaseId: anchor.bundleReleaseId,
    );
  }

  String sourceLabel(CatalogEditionDto edition) =>
      movieReleaseSourceLabel(edition);

  bool isCatalogRelease(CatalogEditionDto edition) =>
      isCatalogMovieRelease(edition);

  bool isTitleSnapshotRelease(CatalogEditionDto edition) =>
      isTitleSnapshotMovieRelease(edition);

  String? preferredVariantId(CatalogEditionDto edition) =>
      preferredMovieEditionVariantId(edition);

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
