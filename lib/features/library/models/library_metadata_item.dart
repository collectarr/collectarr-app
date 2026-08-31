import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/models/library_common_metadata.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';

final class LibraryMetadataItem {
  const LibraryMetadataItem({
    required this.identity,
    required this.common,
    required this.kindMetadata,
  });

  final LibraryItemIdentity identity;
  final LibraryCommonMetadata common;
  final LibraryKindMetadataRuntime kindMetadata;

  String get id => identity.id;
  CatalogMediaKind get mediaKind => identity.mediaKind;
  String get kind => identity.kind;

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
  int? get releaseYear => common.releaseYear;
  List<CatalogEditionDto> get editions => common.editions;
  List<TrailerLinkDto> get trailerUrls => common.trailerUrls;

  String get resolvedDisplayTitle => common.resolvedDisplayTitle;
  String? get displayCoverUrl => common.displayCoverUrl;
  Map<String, dynamic> get payload => kindMetadata.toSyncPayload();

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
    switch (anchor.type) {
      case PersonalItemAnchorType.edition:
        return CatalogEntityRef(
          kind: kind,
          entityType: CatalogEntityType.edition,
          id: anchor.editionId ?? id,
        );
      case PersonalItemAnchorType.variant:
        return CatalogEntityRef(
          kind: kind,
          entityType: CatalogEntityType.release,
          id: anchor.variantId ?? anchor.editionId ?? id,
        );
      case PersonalItemAnchorType.bundleRelease:
        return CatalogEntityRef(
          kind: kind,
          entityType: CatalogEntityType.bundleRelease,
          id: anchor.bundleReleaseId ?? id,
        );
      default:
        return CatalogEntityRef(
          kind: kind,
          entityType: CatalogEntityType.work,
          id: id,
        );
    }
  }

  factory LibraryMetadataItem.fromCatalogItem(CatalogItem item) {
    final identity = LibraryItemIdentity(
      id: item.id,
      mediaKind: item.mediaKind,
    );
    final common = LibraryCommonMetadata(
      title: item.title,
      displayTitle: item.displayTitle,
      localizedTitle: item.localizedTitle,
      originalTitle: item.originalTitle,
      titleExtension: item.titleExtension,
      searchAliases: item.searchAliases,
      sortKey: item.sortKey,
      synopsis: item.synopsis,
      coverImageUrl: item.coverImageUrl,
      thumbnailImageUrl: item.thumbnailImageUrl,
      coverImageData: item.coverImageData,
      releaseDate: item.releaseDate,
      releaseYear: item.releaseYear,
      editions: item.editions,
      trailerUrls: item.trailerUrls,
    );
    final kindMetadata = LibraryKindMetadataDecoders.decode(
      item.mediaKind,
      item.toSyncPayload(),
    );
    return LibraryMetadataItem(
      identity: identity,
      common: common,
      kindMetadata: kindMetadata,
    );
  }

  factory LibraryMetadataItem.fromMetadataMap(Map<String, dynamic> json) {
    final envelope = CatalogItemEnvelopeDto.fromJson(json);
    final identity = LibraryItemIdentity(
      id: envelope.id,
      mediaKind: envelope.kind,
    );
    final common = LibraryCommonMetadata(
      title: envelope.common.title,
      displayTitle: envelope.common.displayTitle,
      localizedTitle: envelope.common.localizedTitle,
      originalTitle: envelope.common.originalTitle,
      titleExtension: envelope.common.titleExtension,
      searchAliases: envelope.common.searchAliases,
      sortKey: envelope.common.sortKey,
      synopsis: envelope.common.synopsis,
      coverImageUrl: envelope.common.coverImageUrl,
      thumbnailImageUrl: envelope.common.thumbnailImageUrl,
      coverImageData: envelope.common.coverImageData,
      releaseDate: envelope.common.releaseDate,
      releaseYear: envelope.common.releaseYear,
      editions: envelope.common.editions,
      trailerUrls: envelope.common.trailerUrls,
    );
    final kindMetadata = LibraryKindMetadataDecoders.decode(
      envelope.kind,
      json,
    );
    return LibraryMetadataItem(
      identity: identity,
      common: common,
      kindMetadata: kindMetadata,
    );
  }

  LibraryMetadataItem copyWith({
    LibraryItemIdentity? identity,
    LibraryCommonMetadata? common,
    LibraryKindMetadataRuntime? kindMetadata,
  }) {
    return LibraryMetadataItem(
      identity: identity ?? this.identity,
      common: common ?? this.common,
      kindMetadata: kindMetadata ?? this.kindMetadata,
    );
  }

  CatalogItem toCatalogItem() {
    final payload = kindMetadata.toSyncPayload();
    return CatalogItem.fromJson({
      'id': id,
      'kind': kind,
      'title': title,
      'display_title': displayTitle,
      'localized_title': localizedTitle,
      'original_title': originalTitle,
      'search_aliases': searchAliases,
      'sort_key': sortKey,
      'synopsis': synopsis,
      'cover_image_url': coverImageUrl,
      'thumbnail_image_url': thumbnailImageUrl,
      if (coverImageData != null) 'cover_image_data': coverImageData,
      'release_date': releaseDate?.toIso8601String(),
      'release_year': releaseYear,
      ...payload,
    });
  }

  Map<String, dynamic> toSyncPayload() {
    final payload = kindMetadata.toSyncPayload();
    return {
      'snapshot_version': 1,
      'id': id,
      'kind': kind,
      'title': title,
      'display_title': displayTitle,
      'localized_title': localizedTitle,
      'original_title': originalTitle,
      'search_aliases': searchAliases,
      'sort_key': sortKey,
      'synopsis': synopsis,
      'cover_image_url': coverImageUrl,
      'thumbnail_image_url': thumbnailImageUrl,
      if (coverImageData != null) 'cover_image_data': coverImageData,
      'release_date': releaseDate?.toIso8601String(),
      'release_year': releaseYear,
      ...payload,
    };
  }
}
