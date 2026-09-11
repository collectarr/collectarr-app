import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';

import 'catalog_import_snapshot.dart';

/// Search result that can cross into a mixed/global UI without exposing the
/// canonical catalog DTO. The DTO remains opaque until the catalog transport
/// repository persists the selected result.
final class CatalogSearchCandidate {
  const CatalogSearchCandidate._({
    required CatalogItemDto item,
    required this.summary,
  }) : _item = item;

  factory CatalogSearchCandidate.fromTransport({
    required CatalogItemDto item,
    required CatalogDisplaySummary summary,
  }) {
    return CatalogSearchCandidate._(
      item: item,
      summary: summary,
    );
  }

  factory CatalogSearchCandidate.fromItem(CatalogItemDto item) {
    return CatalogSearchCandidate._(
      item: item,
      summary: CatalogDisplaySummary(
        ref: item.catalogRef,
        kind: item.mediaKind,
        title: item.resolvedDisplayTitle,
        imageUrl: item.displayCoverUrl,
      ),
    );
  }

  factory CatalogSearchCandidate.fromSnapshot(
    CatalogImportSnapshot snapshot,
  ) {
    return snapshot.mapTransport(CatalogSearchCandidate.fromItem);
  }

  factory CatalogSearchCandidate.fromJson(Map<String, dynamic> json) {
    return CatalogSearchCandidate.fromItem(CatalogItemDto.fromJson(json));
  }

  /// Decodes a Core search response at the catalog transport boundary and
  /// immediately projects it to the small candidate shape used by mixed
  /// search/import hosts. The generated catalog DTO never leaves this
  /// transport object unless the user selects the candidate.
  factory CatalogSearchCandidate.fromApiJson({
    required Map<String, dynamic> json,
    JsonEncodable Function(JsonMap payload)? metadataDecoder,
  }) {
    var item = CatalogItemDto.fromJson(json);
    if (metadataDecoder != null) {
      item = item.withKindMetadata(metadataDecoder(item.payload));
    }
    return CatalogSearchCandidate._(
      item: item,
      summary: CatalogDisplaySummary.work(
        kind: item.mediaKind,
        id: item.id,
        title: item.title,
        imageUrl: item.displayCoverUrl,
      ),
    );
  }

  final CatalogItemDto _item;
  final CatalogDisplaySummary summary;

  String get id => summary.id;
  CatalogMediaKind get kind => summary.kind;
  CatalogMediaKind get mediaKind => summary.kind;
  LibraryItemIdentity get identity =>
      LibraryItemIdentity(id: id, mediaKind: mediaKind);
  String get title => summary.title;
  String? get displayTitle => _item.displayTitle;
  String? get localizedTitle => _item.localizedTitle;
  String? get originalTitle => _item.originalTitle;
  String? get titleExtension => _item.titleExtension;
  String? get subtitle => summary.subtitle;
  String? get imageUrl => summary.imageUrl;
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
  CatalogDisplaySummary get displaySummary => summary;

  /// Kind-specific code may decode the provider/Core payload at this
  /// explicit transport boundary. Generic hosts should use [summary] and the
  /// structural getters above only.
  T mapTransport<T>(T Function(CatalogItemDto item) decoder) => decoder(_item);

  CatalogSearchCandidate copyWith({
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
    return CatalogSearchCandidate.fromItem(
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

  CatalogSearchCandidate withKindMetadata(Object? metadata) {
    return CatalogSearchCandidate.fromItem(_item.withKindMetadata(metadata));
  }

  CatalogImportSnapshot toImportSnapshot() =>
      CatalogImportSnapshot.fromItem(_item);
}

const Object _unset = Object();
