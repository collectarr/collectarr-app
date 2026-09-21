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

  /// Creates the mixed-host transport from a kind-owned semantic projection.
  ///
  /// The generic Add host receives only this summary-shaped candidate; the
  /// generated catalog DTO construction stays inside the catalog transport
  /// boundary instead of leaking into provider/kind adapters.
  factory CatalogSearchCandidate.fromKindProjection({
    required String id,
    required CatalogMediaKind kind,
    required String title,
    String? synopsis,
    String? coverImageUrl,
    DateTime? releaseDate,
    int? releaseYear,
    String? originalTitle,
    String? publisher,
    String? barcode,
    String? physicalFormat,
    String? physicalFormatLabel,
    String? editionTitle,
    String? itemNumber,
    String? variant,
    List<String>? searchAliases,
    Object? kindMetadata,
  }) {
    return CatalogSearchCandidate.fromItem(
      CatalogItemDto.raw(
        id: id,
        mediaKind: kind,
        common: CatalogCommonDto(
          title: title,
          originalTitle: originalTitle,
          synopsis: synopsis,
          coverImageUrl: coverImageUrl,
          releaseDate: releaseDate,
          releaseYear: releaseYear ?? releaseDate?.year,
          searchAliases: searchAliases,
        ),
        payload: {
          'title': title,
          if (originalTitle != null) 'original_title': originalTitle,
          if (synopsis != null) 'synopsis': synopsis,
          if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
          if (releaseDate != null)
            'release_date': releaseDate.toIso8601String(),
          if (releaseYear != null) 'release_year': releaseYear,
          if (searchAliases != null) 'search_aliases': searchAliases,
          if (publisher != null) 'publisher': publisher,
          if (barcode != null) 'barcode': barcode,
          if (physicalFormat != null) 'physical_format': physicalFormat,
          if (physicalFormatLabel != null)
            'physical_format_label': physicalFormatLabel,
          if (editionTitle != null) 'edition_title': editionTitle,
          if (itemNumber != null) 'item_number': itemNumber,
          if (variant != null) 'variant': variant,
        },
        kindMetadata: kindMetadata,
      ),
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
  String? get publisher => _item.publisher;
  String? get barcode => _item.barcode;
  String? get itemNumber => _item.itemNumber;
  String? get variant => _item.variant;
  String? get physicalFormat => _item.physicalFormat;
  String? get physicalFormatLabel => _item.physicalFormatLabel;
  String? get editionTitle => _item.editionTitle;
  String? get coverImageUrl => _item.coverImageUrl;
  String? get thumbnailImageUrl => _item.thumbnailImageUrl;
  String? get coverImageData => _item.coverImageData;
  DateTime? get releaseDate => _item.releaseDate;
  int? get releaseYear => _item.releaseYear;
  String get resolvedDisplayTitle => _item.resolvedDisplayTitle;
  String? get displayCoverUrl => _item.displayCoverUrl;
  CatalogEntityRef get catalogRef => _item.catalogRef;
  CatalogDisplaySummary get displaySummary => summary;

  /// Kind-owned semantic metadata retained across generic candidate updates.
  ///
  /// Generic hosts may read common presentation getters, but they must not
  /// rebuild this value from the DTO payload. The owning kind is responsible
  /// for interpreting the concrete object.
  Object? get kindMetadata => _item.kindMetadata;

  /// Projects only the common metadata required by the shared edit shell.
  ///
  /// Kind-owned edit drafts continue to consume this candidate at their own
  /// boundary for semantic metadata and release data.
  CatalogEditMetadata get editMetadata => CatalogEditMetadata(
        ref: catalogRef,
        title: title,
        displayTitle: displayTitle,
        localizedTitle: localizedTitle,
        originalTitle: originalTitle,
        titleExtension: titleExtension,
        searchAliases: searchAliases ?? const [],
        sortKey: sortKey,
        synopsis: synopsis,
        coverImageUrl: coverImageUrl,
        thumbnailImageUrl: thumbnailImageUrl,
        coverImageData: coverImageData,
        releaseDate: releaseDate,
        releaseYear: releaseYear,
      );

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

  /// Serializes the selected catalog transport for sync/file orchestration.
  ///
  /// Callers outside this transport boundary do not need to know the generated
  /// DTO type; they can enqueue this schema-v1 payload and keep the DTO inside
  /// the catalog transport implementation.
  JsonMap toSyncPayload() => _item.toSyncPayload();

  CatalogItemDto toTransport() => _item;

  /// Captures this selected DTO as an explicit schema-v1 mutation transport.
  ///
  /// Generic mutation hosts accept this transport value, not the rich
  /// candidate wrapper. The conversion keeps the complete target reference
  /// and leaves DTO decoding at the catalog persistence boundary.
  CatalogImportTransport toImportTransport() =>
      CatalogImportTransport.fromItem(_item);
}

const Object _unset = Object();
