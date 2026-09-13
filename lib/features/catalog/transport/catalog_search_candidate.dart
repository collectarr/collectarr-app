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
    required CatalogImportSnapshot snapshot,
    required this.summary,
  }) : _snapshot = snapshot;

  factory CatalogSearchCandidate.fromTransport({
    required CatalogItemDto item,
    required CatalogDisplaySummary summary,
  }) {
    return CatalogSearchCandidate._(
      snapshot: CatalogImportSnapshot.fromItem(item),
      summary: summary,
    );
  }

  factory CatalogSearchCandidate.fromItem(CatalogItemDto item) {
    return CatalogSearchCandidate.fromSnapshot(
      CatalogImportSnapshot.fromItem(item),
    );
  }

  factory CatalogSearchCandidate.fromSnapshot(
    CatalogImportSnapshot snapshot,
  ) {
    return CatalogSearchCandidate._(
      snapshot: snapshot,
      summary: CatalogDisplaySummary(
        ref: snapshot.catalogRef,
        kind: snapshot.mediaKind,
        title: snapshot.resolvedDisplayTitle,
        imageUrl: snapshot.displayCoverUrl,
      ),
    );
  }

  factory CatalogSearchCandidate.fromJson(Map<String, dynamic> json) {
    return CatalogSearchCandidate.fromSnapshot(
      CatalogImportSnapshot.fromJson(json),
    );
  }

  /// Decodes a Core search response at the catalog transport boundary and
  /// immediately projects it to the small candidate shape used by mixed
  /// search/import hosts. The generated catalog DTO never leaves this
  /// transport object unless the user selects the candidate.
  factory CatalogSearchCandidate.fromApiJson({
    required Map<String, dynamic> json,
    JsonEncodable Function(JsonMap payload)? metadataDecoder,
  }) {
    var snapshot = CatalogImportSnapshot.fromJson(json);
    if (metadataDecoder != null) {
      snapshot = snapshot.mapTransport(
        (item) => CatalogImportSnapshot.fromItem(
          item.withKindMetadata(metadataDecoder(item.payload)),
        ),
      );
    }
    return CatalogSearchCandidate._(
      snapshot: snapshot,
      summary: CatalogDisplaySummary.work(
        kind: snapshot.mediaKind,
        id: snapshot.id,
        title: snapshot.title,
        imageUrl: snapshot.displayCoverUrl,
      ),
    );
  }

  final CatalogImportSnapshot _snapshot;
  final CatalogDisplaySummary summary;

  String get id => summary.id;
  CatalogMediaKind get kind => summary.kind;
  CatalogMediaKind get mediaKind => summary.kind;
  LibraryItemIdentity get identity =>
      LibraryItemIdentity(id: id, mediaKind: mediaKind);
  String get title => summary.title;
  String? get displayTitle => _snapshot.displayTitle;
  String? get localizedTitle => _snapshot.localizedTitle;
  String? get originalTitle => _snapshot.originalTitle;
  String? get titleExtension => _snapshot.titleExtension;
  String? get subtitle => summary.subtitle;
  String? get imageUrl => summary.imageUrl;
  List<String>? get searchAliases => _snapshot.searchAliases;
  String? get sortKey => _snapshot.sortKey;
  String? get synopsis => _snapshot.synopsis;
  String? get coverImageUrl => _snapshot.coverImageUrl;
  String? get thumbnailImageUrl => _snapshot.thumbnailImageUrl;
  String? get coverImageData => _snapshot.coverImageData;
  DateTime? get releaseDate => _snapshot.releaseDate;
  int? get releaseYear => _snapshot.releaseYear;
  String get resolvedDisplayTitle => _snapshot.resolvedDisplayTitle;
  String? get displayCoverUrl => _snapshot.displayCoverUrl;
  CatalogEntityRef get catalogRef => _snapshot.catalogRef;
  CatalogDisplaySummary get displaySummary => summary;

  /// Kind-specific code may decode the provider/Core payload at this
  /// explicit transport boundary. Generic hosts should use [summary] and the
  /// structural getters above only.
  T mapTransport<T>(T Function(CatalogItemDto item) decoder) =>
      _snapshot.mapTransport(decoder);

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
      _snapshot.mapTransport(
        (item) => item.copyWith(
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
      ),
    );
  }

  CatalogSearchCandidate withKindMetadata(Object? metadata) {
    return _snapshot.mapTransport(
      (item) =>
          CatalogSearchCandidate.fromItem(item.withKindMetadata(metadata)),
    );
  }

  CatalogImportSnapshot toImportSnapshot() => _snapshot;
}

const Object _unset = Object();
