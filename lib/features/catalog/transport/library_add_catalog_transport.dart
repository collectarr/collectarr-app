import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';

import 'catalog_import_snapshot.dart';

/// Opaque catalog transport item used by the Add host.
///
/// Add UI and orchestration can carry a selected result without making the
/// Core catalog DTO its application-domain model. The owning kind receives
/// this boundary value through its Add capability and the transport DTO is
/// unwrapped only when persistence or an HTTP mutation is required.
final class LibraryAddCatalogTransport {
  const LibraryAddCatalogTransport._(this._item);

  factory LibraryAddCatalogTransport.fromItem(CatalogItemDto item) {
    return LibraryAddCatalogTransport._(item);
  }

  factory LibraryAddCatalogTransport.fromSnapshot(
    CatalogImportSnapshot snapshot,
  ) {
    return LibraryAddCatalogTransport._(
      snapshot.mapTransport((transport) => transport),
    );
  }

  factory LibraryAddCatalogTransport.fromJson(Map<String, dynamic> json) {
    return LibraryAddCatalogTransport._(CatalogItemDto.fromJson(json));
  }

  final CatalogItemDto _item;

  /// Lets an owning kind decode this transport boundary into its concrete
  /// domain without exposing the Core DTO to generic Library hosts.
  T mapTransport<T>(T Function(CatalogItemDto item) decoder) => decoder(_item);

  String get id => _item.id;
  CatalogMediaKind get mediaKind => _item.mediaKind;
  LibraryItemIdentity get identity => _item.identity;
  String get title => _item.title;
  String? get displayTitle => _item.displayTitle;
  String? get localizedTitle => _item.localizedTitle;
  String? get originalTitle => _item.originalTitle;
  String? get titleExtension => _item.titleExtension;
  List<String>? get searchAliases => _item.searchAliases;
  String? get sortKey => _item.sortKey;
  String? get synopsis => _item.synopsis;
  String? get coverImageUrl => _item.coverImageUrl;
  String? get thumbnailImageUrl => _item.thumbnailImageUrl;
  String? get coverImageData => _item.coverImageData;
  DateTime? get releaseDate => _item.releaseDate;
  int? get releaseYear => _item.releaseYear;
  String get resolvedDisplayTitle => _item.resolvedDisplayTitle;
  String? get displayCoverUrl => _item.displayCoverUrl;
  CatalogEntityRef get catalogRef => _item.catalogRef;
  CatalogDisplaySummary get displaySummary => CatalogDisplaySummary(
        ref: catalogRef,
        kind: mediaKind,
        title: resolvedDisplayTitle,
        imageUrl: displayCoverUrl,
      );
  LibraryAddCatalogTransport copyWith({
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
  }) {
    return LibraryAddCatalogTransport._(
      _item.copyWith(
        identity: identity,
        title: title,
        displayTitle: displayTitle,
        localizedTitle: localizedTitle,
        originalTitle: originalTitle,
        titleExtension: titleExtension,
        searchAliases: searchAliases,
        sortKey: sortKey,
        synopsis: synopsis,
        coverImageUrl: coverImageUrl,
        thumbnailImageUrl: thumbnailImageUrl,
        coverImageData: coverImageData,
        releaseDate: releaseDate,
        releaseYear: releaseYear,
        editions: editions,
        trailerUrls: trailerUrls,
        physicalFormat: physicalFormat,
        physicalFormatLabel: physicalFormatLabel,
      ),
    );
  }

  LibraryAddCatalogTransport withKindMetadata(Object? kindMetadata) {
    return LibraryAddCatalogTransport._(_item.withKindMetadata(kindMetadata));
  }

  CatalogImportSnapshot toImportSnapshot() =>
      CatalogImportSnapshot.fromItem(_item);
}

const _unset = Object();
