import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_edit_metadata.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_transport.dart';

/// Search result that can cross into a mixed/global UI while retaining the
/// selected catalog transport until a kind-owned boundary consumes it.
final class CatalogSearchCandidate {
  const CatalogSearchCandidate._({
    required CatalogItemDto? item,
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
        primaryLabel: item.resolvedDisplayTitle,
        imageUrl: item.displayCoverUrl,
      ),
    );
  }

  /// Creates a candidate from a minimal mixed-host projection.
  ///
  /// The optional transport is an opaque selected payload. Generic hosts only
  /// consume [summary]; kind-owned code may decode [transport] at the explicit
  /// catalog boundary.
  factory CatalogSearchCandidate.fromSummary({
    required CatalogDisplaySummary summary,
    CatalogItemDto? transport,
  }) {
    return CatalogSearchCandidate._(
      item: transport,
      summary: summary,
    );
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
      summary: CatalogDisplaySummary(
        ref: item.catalogRef,
        kind: item.mediaKind,
        primaryLabel: item.title,
        imageUrl: item.displayCoverUrl,
      ),
    );
  }

  final CatalogItemDto? _item;
  final CatalogDisplaySummary summary;

  String get id => summary.id;
  CatalogMediaKind get kind => summary.kind;
  CatalogMediaKind get mediaKind => summary.kind;
  LibraryItemIdentity get identity =>
      LibraryItemIdentity(id: id, mediaKind: mediaKind);
  String get primaryLabel => summary.primaryLabel;
  String? get subtitle => summary.subtitle;
  String? get imageUrl => summary.imageUrl;
  CatalogEntityRef get catalogRef => summary.ref;
  CatalogDisplaySummary get displaySummary => summary;

  /// Projects the common catalog columns consumed by kind-owned features.
  ///
  /// Shared hosts should use [summary] for display and keep this edit-shaped
  /// projection inside the selected kind's boundary.
  CatalogEditMetadata get editMetadata => CatalogEditMetadata(
        ref: catalogRef,
        title: primaryLabel,
        displayTitle: _item?.displayTitle,
        localizedTitle: _item?.localizedTitle,
        originalTitle: _item?.originalTitle,
        titleExtension: _item?.titleExtension,
        searchAliases: _item?.searchAliases ?? const [],
        sortKey: _item?.sortKey,
        synopsis: _item?.synopsis,
        coverImageUrl: _item?.coverImageUrl ?? imageUrl,
        thumbnailImageUrl: _item?.thumbnailImageUrl,
        coverImageData: _item?.coverImageData,
        releaseDate: _item?.releaseDate,
        releaseYear: _item?.releaseYear,
      );

  /// Kind-specific code may decode the provider/Core payload at this
  /// explicit transport boundary. Generic hosts should use [summary] and the
  /// structural getters above only.
  T mapTransport<T>(T Function(CatalogItemDto item) decoder) {
    final item = _item;
    if (item == null) {
      throw StateError(
        'Catalog candidate ${catalogRef.id} has no selected transport payload.',
      );
    }
    return decoder(item);
  }

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
  }) {
    return CatalogSearchCandidate.fromItem(
      mapTransport(
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
        ),
      ),
    );
  }

  CatalogSearchCandidate withKindMetadata(Object? metadata) {
    return CatalogSearchCandidate.fromItem(
      mapTransport((item) => item.withKindMetadata(metadata)),
    );
  }

  /// Serializes the selected catalog transport for sync/file orchestration.
  ///
  /// Callers outside this transport boundary do not need to know the generated
  /// DTO type; they can enqueue this schema-v1 payload and keep the DTO inside
  /// the catalog transport implementation.
  JsonMap toSyncPayload() => mapTransport((item) => item.toSyncPayload());

  CatalogItemDto toTransport() => mapTransport((item) => item);

  /// Captures this selected DTO as an explicit schema-v1 mutation transport.
  ///
  /// Generic mutation hosts accept this transport value, not the rich
  /// candidate wrapper. The conversion keeps the complete target reference
  /// and leaves DTO decoding at the catalog persistence boundary.
  CatalogImportTransport toImportTransport() =>
      CatalogImportTransport.fromItem(toTransport());
}

const Object _unset = Object();
