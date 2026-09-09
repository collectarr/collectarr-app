import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_variant_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';

const _videoReleaseSourceKey = 'release_source';
const _videoReleaseAnchorKindKey = 'release_anchor_kind';
const _videoReleaseAnchorVariantIdKey = 'release_anchor_variant_id';
const _videoReleaseAnchorBundleIdKey = 'release_anchor_bundle_id';

const _videoReleaseSourceCatalog = 'catalog';
const _videoReleaseSourceLocalAnchor = 'local_anchor';
const _videoReleaseSourceTitleSnapshot = 'title_snapshot';
const _tmdbLocalSyntheticItemPrefix = 'tmdb-local:';

class VideoReleaseAnchor {
  const VideoReleaseAnchor({
    this.editionId,
    this.variantId,
    this.bundleReleaseId,
  });

  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
}

List<CatalogEditionDto> resolveVideoCatalogEditionsForCatalogItem(
  dynamic item, {
  Iterable<OwnedItem> ownedItems = const <OwnedItem>[],
  Iterable<WishlistItem> wishlistItems = const <WishlistItem>[],
}) {
  final payload = item.payload;
  final editionsPayload = payload['editions'] as List?;
  final rawEditions = editionsPayload != null
      ? editionsPayload
          .whereType<Map<String, dynamic>>()
          .map((e) => CatalogEditionDto.fromJson(Map<String, dynamic>.from(e)))
          .toList()
      : const <CatalogEditionDto>[];
  if (!_isVideoKind(item.kind as String)) {
    return rawEditions;
  }
  return _resolveVideoCatalogEditions(
    _VideoReleaseSeedInput(
      itemId: item.id as String,
      mediaType: item.kind as String,
      resolvedTitle: item.resolvedDisplayTitle as String,
      editionTitle: payload['edition_title'] as String?,
      distributor: (payload['publisher'] as String?) ??
          ((payload['publishing'] as Map?)?['original_publisher'] as String?),
      releaseDate: item.releaseDate as DateTime?,
      releaseYear: (item.releaseYear ?? item.releaseDate?.year) as int?,
      physicalFormat: payload['physical_format'] as String?,
      formatLabel: payload['physical_format_label'] as String?,
      variant: payload['variant'] as String?,
      language: payload['language'] as String?,
      country: payload['country'] as String?,
      barcodeValue: payload['barcode'] as String?,
      coverImageUrl: item.coverImageUrl as String?,
      thumbnailImageUrl: item.thumbnailImageUrl as String?,
    ),
    rawEditions,
    ownedItems: ownedItems,
    wishlistItems: wishlistItems,
  );
}

List<CatalogEditionDto> resolveVideoCatalogEditionsForShelf(
  ShelfEntry source, {
  Iterable<OwnedItem> ownedItems = const <OwnedItem>[],
  Iterable<WishlistItem> wishlistItems = const <WishlistItem>[],
}) {
  final item = source.catalogItem;
  if (item == null) {
    return const [];
  }
  return resolveVideoCatalogEditionsForCatalogItem(
    item,
    ownedItems: ownedItems,
    wishlistItems: wishlistItems,
  );
}

VideoReleaseAnchor videoReleaseAnchorForEdition(CatalogEditionDto edition) {
  final metadata = edition.metadata;
  final anchorKind = metadata?[_videoReleaseAnchorKindKey] as String?;
  final variantId = metadata?[_videoReleaseAnchorVariantIdKey] as String?;
  final bundleReleaseId = metadata?[_videoReleaseAnchorBundleIdKey] as String?;
  return switch (anchorKind) {
    'variant' => VideoReleaseAnchor(variantId: variantId),
    'bundle_release' => VideoReleaseAnchor(bundleReleaseId: bundleReleaseId),
    'item' => const VideoReleaseAnchor(),
    _ => VideoReleaseAnchor(editionId: edition.id),
  };
}

bool matchesVideoReleaseAnchor(
  CatalogEditionDto edition, {
  String? editionId,
  String? variantId,
  String? bundleReleaseId,
}) {
  final anchor = videoReleaseAnchorForEdition(edition);
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

String videoReleaseSourceLabel(CatalogEditionDto edition) {
  final source = edition.metadata?[_videoReleaseSourceKey] as String?;
  return switch (source) {
    _videoReleaseSourceLocalAnchor => 'Collection anchors',
    _videoReleaseSourceTitleSnapshot => 'Title snapshot fallback',
    _ => 'Catalog edition',
  };
}

bool isCatalogVideoRelease(CatalogEditionDto edition) {
  return (edition.metadata?[_videoReleaseSourceKey] as String?) ==
          _videoReleaseSourceCatalog ||
      edition.metadata?[_videoReleaseSourceKey] == null;
}

bool isLocalAnchorVideoRelease(CatalogEditionDto edition) {
  return (edition.metadata?[_videoReleaseSourceKey] as String?) ==
      _videoReleaseSourceLocalAnchor;
}

bool isTitleSnapshotVideoRelease(CatalogEditionDto edition) {
  return (edition.metadata?[_videoReleaseSourceKey] as String?) ==
      _videoReleaseSourceTitleSnapshot;
}

String? preferredVideoEditionVariantId(CatalogEditionDto edition) {
  for (final variant in edition.variants) {
    if (variant.isPrimary) {
      return variant.id;
    }
  }
  return edition.variants.isEmpty ? null : edition.variants.first.id;
}

List<CatalogEditionDto> _resolveVideoCatalogEditions(
  _VideoReleaseSeedInput input,
  List<CatalogEditionDto> existingEditions, {
  required Iterable<OwnedItem> ownedItems,
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
      editionId: copy.anchor?.editionId,
      variantId: copy.anchor?.variantId,
      bundleReleaseId: copy.anchor?.bundleReleaseId,
    );
  }

  for (final item in wishlistItems) {
    if (item.isDeleted) {
      continue;
    }
    final anchor = _videoReleaseAnchorFromCatalogRef(item.catalogRef);
    _mergeAnchorSeed(
      seeds,
      input,
      editionId: anchor.editionId,
      variantId: anchor.variantId,
      bundleReleaseId: anchor.bundleReleaseId,
    );
  }

  if (seeds.isEmpty) {
    if (!_isLocalSyntheticVideoItemId(input.itemId)) {
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

VideoReleaseAnchor _videoReleaseAnchorFromCatalogRef(CatalogEntityRef ref) {
  return switch (ref.entityType.apiValue) {
    'edition' => VideoReleaseAnchor(editionId: ref.id),
    'release' => VideoReleaseAnchor(variantId: ref.id),
    'bundle_release' => VideoReleaseAnchor(bundleReleaseId: ref.id),
    _ => const VideoReleaseAnchor(),
  };
}

void _mergeAnchorSeed(
  Map<String, _EditionSeed> seeds,
  _VideoReleaseSeedInput input, {
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

  final leftSource = left.metadata?[_videoReleaseSourceKey] as String?;
  final rightSource = right.metadata?[_videoReleaseSourceKey] as String?;
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
    _videoReleaseSourceCatalog => 0,
    _videoReleaseSourceLocalAnchor => 1,
    _videoReleaseSourceTitleSnapshot => 2,
    _ => 3,
  };
}

bool _isVideoKind(String mediaType) {
  return catalogMediaKindFromApiValue(mediaType).isVideoLibraryKind;
}

String? _normalized(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

String _titleSnapshotEditionId(String itemId) => 'video:$itemId:title-snapshot';

String _variantSyntheticEditionId(String itemId, String variantId) =>
    'video:$itemId:variant:$variantId';

String _bundleSyntheticEditionId(String itemId, String bundleReleaseId) =>
    'video:$itemId:bundle:$bundleReleaseId';

bool _isLocalSyntheticVideoItemId(String itemId) {
  return itemId.trim().toLowerCase().startsWith(_tmdbLocalSyntheticItemPrefix);
}

String _fallbackEditionTitle(_VideoReleaseSeedInput input) {
  return _normalized(input.editionTitle) ??
      _normalized(input.formatLabel) ??
      'Standard release';
}

String _fallbackVariantName(_VideoReleaseSeedInput input) {
  return _normalized(input.variant) ??
      _normalized(input.formatLabel) ??
      'Primary release';
}

class _VideoReleaseSeedInput {
  const _VideoReleaseSeedInput({
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
    Map<String, dynamic>? metadata,
    Map<String, CatalogVariantDto>? variants,
  })  : metadata = <String, dynamic>{
          ...?metadata,
          _videoReleaseSourceKey: source
        },
        _variants = <String, CatalogVariantDto>{...?variants};

  factory _EditionSeed.localAnchor(
    _VideoReleaseSeedInput input, {
    required String id,
    String? variantId,
    String? bundleReleaseId,
  }) {
    final metadata = <String, dynamic>{
      _videoReleaseAnchorKindKey: variantId != null
          ? 'variant'
          : bundleReleaseId != null
              ? 'bundle_release'
              : 'edition',
      if (variantId != null) _videoReleaseAnchorVariantIdKey: variantId,
      if (bundleReleaseId != null)
        _videoReleaseAnchorBundleIdKey: bundleReleaseId,
    };
    final seed = _EditionSeed(
      id: id,
      title: _fallbackEditionTitle(input),
      source: _videoReleaseSourceLocalAnchor,
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
    _VideoReleaseSeedInput input,
    String id,
  ) {
    return _EditionSeed(
      id: id,
      title: _fallbackEditionTitle(input),
      source: _videoReleaseSourceTitleSnapshot,
      distributor: _normalized(input.distributor),
      language: _normalized(input.language),
      regionTerritory: _normalized(input.country),
      releaseDate: input.releaseDate,
      physicalFormat: _normalized(input.physicalFormat),
      formatLabel: _normalized(input.formatLabel),
      metadata: const <String, dynamic>{
        _videoReleaseAnchorKindKey: 'item',
      },
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
  final Map<String, dynamic> metadata;
  final Map<String, CatalogVariantDto> _variants;

  void absorbAnchor(
    _VideoReleaseSeedInput input, {
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
        metadata: <String, dynamic>{
          if (normalizedBundleReleaseId != null)
            _videoReleaseAnchorBundleIdKey: normalizedBundleReleaseId,
        },
      );
    }
    if (editionId == null &&
        normalizedVariantId == null &&
        normalizedBundleReleaseId != null) {
      metadata[_videoReleaseAnchorKindKey] = 'bundle_release';
      metadata[_videoReleaseAnchorBundleIdKey] = normalizedBundleReleaseId;
    }
  }

  CatalogEditionDto build(_VideoReleaseSeedInput input) {
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
    _VideoReleaseSeedInput input,
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
