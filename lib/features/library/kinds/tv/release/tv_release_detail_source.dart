import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_variant_dto.dart';
import 'package:collectarr_app/features/library/release/library_release_detail_source.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_snapshot.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

const _tvReleaseSourceKey = 'release_source';
const _tvReleaseAnchorKindKey = 'release_anchor_kind';
const _tvReleaseAnchorVariantIdKey = 'release_anchor_variant_id';
const _tvReleaseAnchorBundleIdKey = 'release_anchor_bundle_id';

const _tvReleaseSourceCatalog = 'catalog';
const _tvReleaseSourceLocalAnchor = 'local_anchor';
const _tvReleaseSourceTitleSnapshot = 'title_snapshot';
const _tmdbLocalSyntheticItemPrefix = 'tmdb-local:';

class TvReleaseAnchor {
  const TvReleaseAnchor({
    this.editionId,
    this.variantId,
    this.bundleReleaseId,
  });

  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
}

List<CatalogEditionDto> resolveTvCatalogEditionsForCatalogItem(
  CatalogImportSnapshot item, {
  Iterable<OwnedItemSummary> ownedItems = const <OwnedItemSummary>[],
  Iterable<WishlistItem> wishlistItems = const <WishlistItem>[],
}) {
  final payload = item.mapTransport((transport) => transport.payload);
  final editionsPayload = payload['editions'] as List?;
  final rawEditions = editionsPayload != null
      ? editionsPayload
          .whereType<JsonMap>()
          .map((e) => CatalogEditionDto.fromJson(JsonMap.from(e)))
          .toList()
      : const <CatalogEditionDto>[];
  return _resolveTvCatalogEditions(
    _TvReleaseSeedInput(
      itemId: item.id,
      mediaType: 'tv',
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

TvReleaseAnchor tvReleaseAnchorForEdition(CatalogEditionDto edition) {
  final metadata = edition.metadata;
  final anchorKind = metadata?[_tvReleaseAnchorKindKey] as String?;
  final variantId = metadata?[_tvReleaseAnchorVariantIdKey] as String?;
  final bundleReleaseId = metadata?[_tvReleaseAnchorBundleIdKey] as String?;
  return switch (anchorKind) {
    'variant' => TvReleaseAnchor(variantId: variantId),
    'bundle_release' => TvReleaseAnchor(bundleReleaseId: bundleReleaseId),
    'item' => const TvReleaseAnchor(),
    _ => TvReleaseAnchor(editionId: edition.id),
  };
}

bool matchesTvReleaseAnchor(
  CatalogEditionDto edition, {
  String? editionId,
  String? variantId,
  String? bundleReleaseId,
}) {
  final anchor = tvReleaseAnchorForEdition(edition);
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

String tvReleaseSourceLabel(CatalogEditionDto edition) {
  final source = edition.metadata?[_tvReleaseSourceKey] as String?;
  return switch (source) {
    _tvReleaseSourceLocalAnchor => 'Collection anchors',
    _tvReleaseSourceTitleSnapshot => 'Title snapshot fallback',
    _ => 'Catalog edition',
  };
}

bool isCatalogTvRelease(CatalogEditionDto edition) {
  return (edition.metadata?[_tvReleaseSourceKey] as String?) ==
          _tvReleaseSourceCatalog ||
      edition.metadata?[_tvReleaseSourceKey] == null;
}

bool isLocalAnchorTvRelease(CatalogEditionDto edition) {
  return (edition.metadata?[_tvReleaseSourceKey] as String?) ==
      _tvReleaseSourceLocalAnchor;
}

bool isTitleSnapshotTvRelease(CatalogEditionDto edition) {
  return (edition.metadata?[_tvReleaseSourceKey] as String?) ==
      _tvReleaseSourceTitleSnapshot;
}

String? preferredTvEditionVariantId(CatalogEditionDto edition) {
  for (final variant in edition.variants) {
    if (variant.isPrimary) {
      return variant.id;
    }
  }
  return edition.variants.isEmpty ? null : edition.variants.first.id;
}

List<CatalogEditionDto> _resolveTvCatalogEditions(
  _TvReleaseSeedInput input,
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
    final anchor = _tvReleaseAnchorFromCatalogRef(item.catalogRef);
    _mergeAnchorSeed(
      seeds,
      input,
      editionId: anchor.editionId,
      variantId: anchor.variantId,
      bundleReleaseId: anchor.bundleReleaseId,
    );
  }

  if (seeds.isEmpty) {
    if (!_isLocalSyntheticTvItemId(input.itemId)) {
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

TvReleaseAnchor _tvReleaseAnchorFromCatalogRef(CatalogEntityRef ref) {
  return switch (ref.entityType.apiValue) {
    'edition' => TvReleaseAnchor(editionId: ref.id),
    'release' => TvReleaseAnchor(variantId: ref.id),
    'bundle_release' => TvReleaseAnchor(bundleReleaseId: ref.id),
    _ => const TvReleaseAnchor(),
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
  _TvReleaseSeedInput input, {
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

  final leftSource = left.metadata?[_tvReleaseSourceKey] as String?;
  final rightSource = right.metadata?[_tvReleaseSourceKey] as String?;
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
    _tvReleaseSourceCatalog => 0,
    _tvReleaseSourceLocalAnchor => 1,
    _tvReleaseSourceTitleSnapshot => 2,
    _ => 3,
  };
}

String? _normalized(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

String _titleSnapshotEditionId(String itemId) => 'tv:$itemId:title-snapshot';

String _variantSyntheticEditionId(String itemId, String variantId) =>
    'tv:$itemId:variant:$variantId';

String _bundleSyntheticEditionId(String itemId, String bundleReleaseId) =>
    'tv:$itemId:bundle:$bundleReleaseId';

bool _isLocalSyntheticTvItemId(String itemId) {
  return itemId.trim().toLowerCase().startsWith(_tmdbLocalSyntheticItemPrefix);
}

String _fallbackEditionTitle(_TvReleaseSeedInput input) {
  return _normalized(input.editionTitle) ??
      _normalized(input.formatLabel) ??
      'Standard release';
}

String _fallbackVariantName(_TvReleaseSeedInput input) {
  return _normalized(input.variant) ??
      _normalized(input.formatLabel) ??
      'Primary release';
}

class _TvReleaseSeedInput {
  const _TvReleaseSeedInput({
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
  })  : metadata = JsonMap.from({...?metadata, _tvReleaseSourceKey: source}),
        _variants = <String, CatalogVariantDto>{...?variants};

  factory _EditionSeed.localAnchor(
    _TvReleaseSeedInput input, {
    required String id,
    String? variantId,
    String? bundleReleaseId,
  }) {
    final metadata = JsonMap.from({
      _tvReleaseAnchorKindKey: variantId != null
          ? 'variant'
          : bundleReleaseId != null
              ? 'bundle_release'
              : 'edition',
      if (variantId != null) _tvReleaseAnchorVariantIdKey: variantId,
      if (bundleReleaseId != null) _tvReleaseAnchorBundleIdKey: bundleReleaseId,
    });
    final seed = _EditionSeed(
      id: id,
      title: _fallbackEditionTitle(input),
      source: _tvReleaseSourceLocalAnchor,
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
    _TvReleaseSeedInput input,
    String id,
  ) {
    return _EditionSeed(
      id: id,
      title: _fallbackEditionTitle(input),
      source: _tvReleaseSourceTitleSnapshot,
      distributor: _normalized(input.distributor),
      language: _normalized(input.language),
      regionTerritory: _normalized(input.country),
      releaseDate: input.releaseDate,
      physicalFormat: _normalized(input.physicalFormat),
      formatLabel: _normalized(input.formatLabel),
      metadata: JsonMap.from({
        _tvReleaseAnchorKindKey: 'item',
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
    _TvReleaseSeedInput input, {
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
            _tvReleaseAnchorBundleIdKey: normalizedBundleReleaseId,
        }),
      );
    }
    if (editionId == null &&
        normalizedVariantId == null &&
        normalizedBundleReleaseId != null) {
      metadata[_tvReleaseAnchorKindKey] = 'bundle_release';
      metadata[_tvReleaseAnchorBundleIdKey] = normalizedBundleReleaseId;
    }
  }

  CatalogEditionDto build(_TvReleaseSeedInput input) {
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
    _TvReleaseSeedInput input,
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

final class TvReleaseDetailSource implements LibraryReleaseDetailSource {
  const TvReleaseDetailSource();

  @override
  List<CatalogEditionDto> resolveCatalogData(
    LibraryWorkspaceCatalogData catalogData, {
    Iterable<OwnedItemSummary> ownedItems = const <OwnedItemSummary>[],
    Iterable<WishlistItem> wishlistItems = const <WishlistItem>[],
  }) {
    if (catalogData is! TvWorkspaceCatalogData) {
      throw ArgumentError.value(
        catalogData,
        'catalogData',
        'Expected TvWorkspaceCatalogData',
      );
    }
    return resolveTvCatalogEditionsForCatalogItem(
      CatalogImportSnapshot.fromItem(catalogData.releaseTransport),
      ownedItems: ownedItems,
      wishlistItems: wishlistItems,
    );
  }

  @override
  CatalogSearchCandidate candidateForCatalogData(
    LibraryWorkspaceCatalogData catalogData,
  ) {
    if (catalogData is! TvWorkspaceCatalogData) {
      throw ArgumentError.value(
        catalogData,
        'catalogData',
        'Expected TvWorkspaceCatalogData',
      );
    }
    return CatalogSearchCandidate.fromItem(catalogData.releaseTransport);
  }

  @override
  CatalogEntityRef targetRefForEdition(
    CatalogEntityRef rootRef,
    CatalogEditionDto edition,
  ) {
    final anchor = tvReleaseAnchorForEdition(edition);
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

  @override
  bool matchesTarget(CatalogEntityRef targetRef, CatalogEditionDto edition) {
    final anchor = _tvReleaseAnchorFromCatalogRef(targetRef);
    return matchesTvReleaseAnchor(
      edition,
      editionId: anchor.editionId,
      variantId: anchor.variantId,
      bundleReleaseId: anchor.bundleReleaseId,
    );
  }

  @override
  String sourceLabel(CatalogEditionDto edition) =>
      tvReleaseSourceLabel(edition);

  @override
  bool isCatalogRelease(CatalogEditionDto edition) =>
      isCatalogTvRelease(edition);

  @override
  bool isTitleSnapshotRelease(CatalogEditionDto edition) =>
      isTitleSnapshotTvRelease(edition);

  @override
  String? preferredVariantId(CatalogEditionDto edition) =>
      preferredTvEditionVariantId(edition);
}
