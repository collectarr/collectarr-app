import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

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

List<CatalogEdition> resolveVideoCatalogEditionsForCatalogItem(
  LibraryMetadataItem item, {
  Iterable<OwnedItem> ownedItems = const <OwnedItem>[],
  Iterable<WishlistItem> wishlistItems = const <WishlistItem>[],
}) {
  if (!_isVideoKind(item.kind)) {
    return item.editions;
  }
  return _resolveVideoCatalogEditions(
    _VideoReleaseSeedInput(
      itemId: item.id,
      mediaType: item.kind,
      resolvedTitle: item.resolvedDisplayTitle,
      editionTitle: item.editionTitle,
      publisher: item.publisher,
      releaseDate: item.releaseDate,
      releaseYear: item.releaseYear,
      physicalFormat: item.physicalFormat,
      physicalFormatLabel: item.physicalFormatLabel,
      variant: item.variant,
      language: item.language,
      country: item.country,
      barcode: item.barcode,
      coverImageUrl: item.coverImageUrl,
      thumbnailImageUrl: item.thumbnailImageUrl,
    ),
    item.editions,
    ownedItems: ownedItems,
    wishlistItems: wishlistItems,
  );
}

List<CatalogEdition> resolveVideoCatalogEditionsForEntry(
  LibraryWorkspaceEntry entry, {
  Iterable<OwnedItem> ownedItems = const <OwnedItem>[],
  Iterable<WishlistItem> wishlistItems = const <WishlistItem>[],
}) {
  if (!_isVideoKind(entry.mediaType)) {
    return entry.editions;
  }
  return _resolveVideoCatalogEditions(
    _VideoReleaseSeedInput(
      itemId: entry.titleItemId ?? entry.id,
      mediaType: entry.mediaType,
      resolvedTitle: entry.resolvedTitle,
      editionTitle: entry.variant,
      publisher: entry.publisher,
      releaseDate: entry.releaseDate,
      releaseYear: entry.releaseYear,
      physicalFormatLabel: entry.referenceFormatLabel,
      variant: entry.variant,
      language: entry.language,
      country: entry.country,
      barcode: entry.barcode,
      coverImageUrl: entry.coverImageUrl,
      thumbnailImageUrl: entry.thumbnailImageUrl,
    ),
    entry.editions,
    ownedItems: ownedItems,
    wishlistItems: wishlistItems,
  );
}

VideoReleaseAnchor videoReleaseAnchorForEdition(CatalogEdition edition) {
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
  CatalogEdition edition, {
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

String videoReleaseSourceLabel(CatalogEdition edition) {
  final source = edition.metadata?[_videoReleaseSourceKey] as String?;
  return switch (source) {
    _videoReleaseSourceLocalAnchor => 'Collection anchors',
    _videoReleaseSourceTitleSnapshot => 'Title snapshot fallback',
    _ => 'Catalog edition',
  };
}

bool isCatalogVideoRelease(CatalogEdition edition) {
  return (edition.metadata?[_videoReleaseSourceKey] as String?) ==
          _videoReleaseSourceCatalog ||
      edition.metadata?[_videoReleaseSourceKey] == null;
}

bool isLocalAnchorVideoRelease(CatalogEdition edition) {
  return (edition.metadata?[_videoReleaseSourceKey] as String?) ==
      _videoReleaseSourceLocalAnchor;
}

bool isTitleSnapshotVideoRelease(CatalogEdition edition) {
  return (edition.metadata?[_videoReleaseSourceKey] as String?) ==
      _videoReleaseSourceTitleSnapshot;
}

String? preferredVideoEditionVariantId(CatalogEdition edition) {
  for (final variant in edition.variants) {
    if (variant.isPrimary) {
      return variant.id;
    }
  }
  return edition.variants.isEmpty ? null : edition.variants.first.id;
}

List<CatalogEdition> _resolveVideoCatalogEditions(
  _VideoReleaseSeedInput input,
  List<CatalogEdition> existingEditions, {
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
      editionId: copy.editionId,
      variantId: copy.variantId,
      bundleReleaseId: copy.bundleReleaseId,
    );
  }

  for (final item in wishlistItems) {
    if (item.isDeleted) {
      continue;
    }
    _mergeAnchorSeed(
      seeds,
      input,
      editionId: item.editionId,
      variantId: item.variantId,
      bundleReleaseId: item.bundleReleaseId,
    );
  }

  if (seeds.isEmpty) {
    if (!_isLocalSyntheticVideoItemId(input.itemId)) {
      return const <CatalogEdition>[];
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
          : _bundleSyntheticEditionId(input.itemId, normalizedBundleReleaseId!));
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

int _compareCatalogEditions(CatalogEdition left, CatalogEdition right) {
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
  final bySource = _sourcePriority(leftSource).compareTo(_sourcePriority(rightSource));
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
  return catalogMediaKindFromValue(mediaType).isVideoLibraryKind;
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
      _normalized(input.physicalFormatLabel) ??
      'Standard release';
}

String _fallbackVariantName(_VideoReleaseSeedInput input) {
  return _normalized(input.variant) ??
      _normalized(input.physicalFormatLabel) ??
      'Primary release';
}

class _VideoReleaseSeedInput {
  const _VideoReleaseSeedInput({
    required this.itemId,
    required this.mediaType,
    required this.resolvedTitle,
    this.editionTitle,
    this.publisher,
    this.releaseDate,
    this.releaseYear,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.variant,
    this.language,
    this.country,
    this.barcode,
    this.coverImageUrl,
    this.thumbnailImageUrl,
  });

  final String itemId;
  final String mediaType;
  final String resolvedTitle;
  final String? editionTitle;
  final String? publisher;
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? variant;
  final String? language;
  final String? country;
  final String? barcode;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
}

class _EditionSeed {
  _EditionSeed({
    required this.id,
    required this.title,
    required this.source,
    this.publisher,
    this.language,
    this.region,
    this.releaseDate,
    this.physicalFormat,
    this.physicalFormatLabel,
    Map<String, dynamic>? metadata,
    Map<String, CatalogVariant>? variants,
  })  : metadata = <String, dynamic>{...?metadata, _videoReleaseSourceKey: source},
        _variants = <String, CatalogVariant>{...?variants};

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
      if (bundleReleaseId != null) _videoReleaseAnchorBundleIdKey: bundleReleaseId,
    };
    final seed = _EditionSeed(
      id: id,
      title: _fallbackEditionTitle(input),
      source: _videoReleaseSourceLocalAnchor,
      publisher: _normalized(input.publisher),
      language: _normalized(input.language),
      region: _normalized(input.country),
      releaseDate: input.releaseDate,
      physicalFormat: _normalized(input.physicalFormat),
      physicalFormatLabel: _normalized(input.physicalFormatLabel),
      metadata: metadata,
    );
    if (variantId != null) {
      seed._variants[variantId] = CatalogVariant(
        id: variantId,
        name: _fallbackVariantName(input),
        barcode: input.barcode,
        coverImageUrl: input.coverImageUrl,
        thumbnailImageUrl: input.thumbnailImageUrl,
        physicalFormat: input.physicalFormat,
        physicalFormatLabel: input.physicalFormatLabel,
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
      publisher: _normalized(input.publisher),
      language: _normalized(input.language),
      region: _normalized(input.country),
      releaseDate: input.releaseDate,
      physicalFormat: _normalized(input.physicalFormat),
      physicalFormatLabel: _normalized(input.physicalFormatLabel),
      metadata: const <String, dynamic>{
        _videoReleaseAnchorKindKey: 'item',
      },
    );
  }

  final String id;
  final String title;
  final String source;
  final String? publisher;
  final String? language;
  final String? region;
  final DateTime? releaseDate;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final Map<String, dynamic> metadata;
  final Map<String, CatalogVariant> _variants;

  void absorbAnchor(
    _VideoReleaseSeedInput input, {
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
  }) {
    final normalizedVariantId = _normalized(variantId);
    final normalizedBundleReleaseId = _normalized(bundleReleaseId);
    if (normalizedVariantId != null && !_variants.containsKey(normalizedVariantId)) {
      _variants[normalizedVariantId] = CatalogVariant(
        id: normalizedVariantId,
        name: _fallbackVariantName(input),
        barcode: input.barcode,
        coverImageUrl: input.coverImageUrl,
        thumbnailImageUrl: input.thumbnailImageUrl,
        physicalFormat: input.physicalFormat,
        physicalFormatLabel: input.physicalFormatLabel,
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

  CatalogEdition build(_VideoReleaseSeedInput input) {
    final variants = [
      for (final variant in _variants.values) _enrichVariant(variant, input),
    ];
    if (variants.isEmpty) {
      variants.add(
        CatalogVariant(
          id: '$id:primary',
          name: _fallbackVariantName(input),
          barcode: input.barcode,
          coverImageUrl: input.coverImageUrl,
          thumbnailImageUrl: input.thumbnailImageUrl,
          physicalFormat: input.physicalFormat,
          physicalFormatLabel: input.physicalFormatLabel,
          isPrimary: true,
        ),
      );
    }
    if (!variants.any((variant) => variant.isPrimary)) {
      final first = variants.first;
      variants[0] = CatalogVariant(
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
    return CatalogEdition(
      id: id,
      title: title,
      publisher: publisher,
      language: language,
      region: region,
      releaseDate: releaseDate,
      physicalFormat: physicalFormat,
      physicalFormatLabel: physicalFormatLabel,
      metadata: metadata,
      variants: variants,
    );
  }

  CatalogVariant _enrichVariant(
    CatalogVariant variant,
    _VideoReleaseSeedInput input,
  ) {
    return CatalogVariant(
      id: variant.id,
      name: _normalized(variant.name) ?? _fallbackVariantName(input),
      variantType: variant.variantType,
      sku: variant.sku,
      barcode: _normalized(variant.barcode) ?? _normalized(input.barcode),
      isbn: variant.isbn,
      region: _normalized(variant.region) ?? _normalized(input.country),
      platform: variant.platform,
      coverPriceCents: variant.coverPriceCents,
      currency: variant.currency,
      coverImageUrl: _normalized(variant.coverImageUrl) ?? _normalized(input.coverImageUrl),
      thumbnailImageUrl: _normalized(variant.thumbnailImageUrl) ??
          _normalized(variant.coverImageUrl) ??
          _normalized(input.thumbnailImageUrl) ??
          _normalized(input.coverImageUrl),
      description: variant.description,
      physicalFormat: _normalized(variant.physicalFormat) ?? _normalized(input.physicalFormat),
      physicalFormatLabel: _normalized(variant.physicalFormatLabel) ??
          _normalized(input.physicalFormatLabel),
      metadata: variant.metadata,
      isPrimary: variant.isPrimary,
    );
  }
}