import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
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

  String get resolvedDisplayTitle => common.resolvedDisplayTitle;
  String? get displayCoverUrl => common.displayCoverUrl;

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
    return LibraryMetadataItem.fromCatalogItem(CatalogItem.fromJson(json));
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
