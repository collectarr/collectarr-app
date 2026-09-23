import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_transport.dart';

/// Structural search result passed through mixed Add/Edit hosts.
///
/// Hosts can read its reference and summary. Kind-specific transport stays
/// behind [kindCapability] and is accessed only through explicit operations.
final class CatalogSearchCandidate {
  CatalogSearchCandidate._({
    required this.summary,
    required this.kindCapability,
  }) : reference = summary.ref;

  factory CatalogSearchCandidate.fromTransport({
    required CatalogItemDto item,
    required CatalogDisplaySummary summary,
  }) {
    return CatalogSearchCandidate._(
      summary: summary,
      kindCapability: CatalogSearchCandidateKindCapability._(item),
    );
  }

  factory CatalogSearchCandidate.fromItem(CatalogItemDto item) {
    return CatalogSearchCandidate._(
      summary: CatalogDisplaySummary(
        ref: item.catalogRef,
        kind: item.mediaKind,
        primaryLabel: item.resolvedDisplayTitle,
        imageUrl: item.displayCoverUrl,
      ),
      kindCapability: CatalogSearchCandidateKindCapability._(item),
    );
  }

  /// Creates a candidate from a structural summary and an optional selected
  /// transport retained by its kind capability.
  factory CatalogSearchCandidate.fromSummary({
    required CatalogDisplaySummary summary,
    CatalogItemDto? transport,
  }) {
    return CatalogSearchCandidate._(
      summary: summary,
      kindCapability: CatalogSearchCandidateKindCapability._(transport),
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
    return CatalogSearchCandidate.fromTransport(
      item: item,
      summary: CatalogDisplaySummary(
        ref: item.catalogRef,
        kind: item.mediaKind,
        primaryLabel: item.title,
        imageUrl: item.displayCoverUrl,
      ),
    );
  }

  final CatalogEntityRef reference;
  final CatalogDisplaySummary summary;
  final CatalogSearchCandidateKindCapability kindCapability;
}

/// Kind-owned operations over the selected catalog transport.
///
/// The DTO stays private so mixed hosts can pass the capability without
/// interpreting kind metadata or generated fields.
final class CatalogSearchCandidateKindCapability {
  const CatalogSearchCandidateKindCapability._(this._item);

  final CatalogItemDto? _item;

  T mapTransport<T>(T Function(CatalogItemDto item) decoder) {
    final item = _item;
    if (item == null) {
      throw StateError('The catalog candidate has no selected transport.');
    }
    return decoder(item);
  }

  CatalogSearchCandidate withKindMetadata(Object? metadata) {
    return CatalogSearchCandidate.fromItem(
      mapTransport((item) => item.withKindMetadata(metadata)),
    );
  }

  JsonMap toSyncPayload() => mapTransport((item) => item.toSyncPayload());

  CatalogImportTransport toImportTransport() =>
      mapTransport(CatalogImportTransport.fromItem);
}
