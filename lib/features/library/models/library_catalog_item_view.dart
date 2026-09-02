import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';

final class LibraryCatalogItemView {
  const LibraryCatalogItemView({
    required LibraryItemIdentity identity,
    required LibraryKindMetadataRuntime kindMetadata,
  })  : _identity = identity,
        _kindMetadata = kindMetadata;

  LibraryCatalogItemView._raw(
    this._identity,
    this._kindMetadata,
  );

  final LibraryItemIdentity _identity;
  final LibraryKindMetadataRuntime _kindMetadata;

  LibraryItemIdentity get identity => _identity;
  String get id => _identity.id;
  CatalogMediaKind get mediaKind => _identity.mediaKind;
  String get kind => _identity.kind;
  CatalogCommonDto get common => CatalogCommonDto.fromJson(payload);
  LibraryKindMetadataRuntime get kindMetadata => _kindMetadata;

  String get title => common.title;
  String? get displayTitle => common.displayTitle;
  String? get localizedTitle => common.localizedTitle;
  String? get originalTitle => common.originalTitle;
  String? get titleExtension => common.titleExtension;
  List<String>? get searchAliases => common.searchAliases;
  String? get sortKey => common.sortKey;
  String? get synopsis => common.synopsis;
  String? get coverImageUrl => common.coverImageUrl;
  String? get thumbnailImageUrl => common.thumbnailImageUrl;
  String? get coverImageData => common.coverImageData;
  DateTime? get releaseDate => common.releaseDate;
  int? get releaseYear =>
      common.releaseYear ??
      (payload['volume_start_year'] as num?)?.toInt() ??
      (payload['year'] as num?)?.toInt();
  List<CatalogEditionDto> get editions => common.editions;
  List<TrailerLinkDto> get trailerUrls => common.trailerUrls;
  String? get physicalFormat => _valueFromPayload('physical_format');
  String? get physicalFormatLabel => _valueFromPayload('physical_format_label');
  String get resolvedDisplayTitle => common.resolvedDisplayTitle;
  String? get displayCoverUrl => common.displayCoverUrl;
  Map<String, dynamic> get payload => kindMetadata.toSyncPayload();

  String? _valueFromPayload(String key) {
    return (_kindMetadata.toSyncPayload()[key] ?? '').toString().trim().isEmpty
        ? null
        : _kindMetadata.toSyncPayload()[key]?.toString();
  }

  factory LibraryCatalogItemView.fromCatalogItem(CatalogItem item) {
    return LibraryCatalogItemView._raw(
      LibraryItemIdentity(id: item.id, mediaKind: item.mediaKind),
      LibraryKindMetadataDecoders.decode(item.mediaKind, item.toSyncPayload()),
    );
  }

  factory LibraryCatalogItemView.fromMetadataMap(Map<String, dynamic> json) {
    final item = CatalogItemDto.fromJson(json);
    return LibraryCatalogItemView._raw(
      LibraryItemIdentity(id: item.id, mediaKind: item.mediaKind),
      LibraryKindMetadataDecoders.decode(item.mediaKind, json),
    );
  }

  CatalogItem toCatalogItem() {
    return CatalogItemDto.raw(
      id: id,
      mediaKind: mediaKind,
      common: common,
      payload: payload,
    );
  }

  Map<String, dynamic> toSyncPayload() {
    return {
      'snapshot_version': 1,
      'id': id,
      'kind': kind,
      ...payload,
    };
  }

  CatalogEntityRef get catalogRef => catalogRefForAnchor();

  CatalogEntityRef catalogRefForAnchor({
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
  }) {
    final anchor = PersonalItemAnchor.fromRaw(
      anchorType: anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    );
    if (anchor == null || anchor.type == PersonalItemAnchorType.item) {
      return CatalogEntityRef(
        kind: kind,
        entityType: CatalogEntityType.work,
        id: id,
      );
    }
    return switch (anchor.type) {
      PersonalItemAnchorType.edition => CatalogEntityRef(
          kind: kind,
          entityType: CatalogEntityType.edition,
          id: anchor.editionId ?? id,
        ),
      PersonalItemAnchorType.variant => CatalogEntityRef(
          kind: kind,
          entityType: CatalogEntityType.release,
          id: anchor.variantId ?? anchor.editionId ?? id,
        ),
      PersonalItemAnchorType.bundleRelease => CatalogEntityRef(
          kind: kind,
          entityType: CatalogEntityType.bundleRelease,
          id: anchor.bundleReleaseId ?? id,
        ),
      PersonalItemAnchorType.item => CatalogEntityRef(
          kind: kind,
          entityType: CatalogEntityType.work,
          id: id,
        ),
    };
  }

  LibraryCatalogItemView copyWith({
    LibraryItemIdentity? identity,
    String? title,
    Object? displayTitle = _unset,
    Object? localizedTitle = _unset,
    Object? originalTitle = _unset,
    Object? titleExtension = _unset,
    Object? searchAliases = _unset,
    Object? sortKey = _unset,
    Object? synopsis = _unset,
    Object? coverImageUrl = _unset,
    Object? thumbnailImageUrl = _unset,
    Object? coverImageData = _unset,
    Object? releaseDate = _unset,
    Object? releaseYear = _unset,
    List<CatalogEditionDto>? editions,
    List<TrailerLinkDto>? trailerUrls,
    Object? physicalFormat = _unset,
    Object? physicalFormatLabel = _unset,
    LibraryKindMetadataRuntime? kindMetadata,
  }) {
    final json = <String, dynamic>{
      ...payload,
      ...common.toJson(),
      'title': title ?? this.title,
      if (!identical(displayTitle, _unset)) 'display_title': displayTitle,
      if (!identical(localizedTitle, _unset)) 'localized_title': localizedTitle,
      if (!identical(originalTitle, _unset)) 'original_title': originalTitle,
      if (!identical(titleExtension, _unset)) 'title_extension': titleExtension,
      if (!identical(searchAliases, _unset)) 'search_aliases': searchAliases,
      if (!identical(sortKey, _unset)) 'sort_key': sortKey,
      if (!identical(synopsis, _unset)) 'synopsis': synopsis,
      if (!identical(coverImageUrl, _unset)) 'cover_image_url': coverImageUrl,
      if (!identical(thumbnailImageUrl, _unset))
        'thumbnail_image_url': thumbnailImageUrl,
      if (!identical(coverImageData, _unset))
        'cover_image_data': coverImageData,
      if (!identical(releaseDate, _unset))
        'release_date': (releaseDate as DateTime?)?.toIso8601String(),
      if (!identical(releaseYear, _unset)) 'release_year': releaseYear,
      if (editions != null)
        'editions': [for (final edition in editions) edition.toJson()],
      if (trailerUrls != null)
        'trailer_urls': [for (final link in trailerUrls) link.toJson()],
      if (!identical(physicalFormat, _unset)) 'physical_format': physicalFormat,
      if (!identical(physicalFormatLabel, _unset))
        'physical_format_label': physicalFormatLabel,
    };
    final updatedIdentity = identity ?? _identity;
    return LibraryCatalogItemView._raw(
      updatedIdentity,
      kindMetadata ?? LibraryKindMetadataDecoders.decode(mediaKind, json),
    );
  }
}

const _unset = Object();
