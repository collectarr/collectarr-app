import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_transport.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_summary_registry.dart';

/// Display fields for a selectable edit candidate, without implying that its
/// identity belongs to the Core catalog.
final class CatalogCandidateSummary {
  const CatalogCandidateSummary({
    required this.kind,
    required this.primaryLabel,
    this.subtitle,
    this.imageUrl,
  });

  factory CatalogCandidateSummary.fromDisplaySummary(
    CatalogDisplaySummary summary,
  ) =>
      CatalogCandidateSummary(
        kind: summary.kind,
        primaryLabel: summary.primaryLabel,
        subtitle: summary.subtitle,
        imageUrl: summary.imageUrl,
      );

  final CatalogMediaKind kind;
  final String primaryLabel;
  final String? subtitle;
  final String? imageUrl;
}

/// Structural search result passed through mixed Add/Edit hosts.
///
/// Hosts can read its reference and summary. Kind-specific transport stays
/// behind [kindCapability] and is accessed only through explicit operations.
final class CatalogSearchCandidate {
  CatalogSearchCandidate._({
    required this.summary,
    required CatalogItemRef? catalogRef,
    required LibraryEntryRef? libraryEntryRef,
    required CatalogItemDto item,
  })  : catalogRef = catalogRef,
        libraryEntryRef = libraryEntryRef,
        kindCapability = CatalogSearchCandidateKindCapability._(
          item: item,
          summary: summary,
          catalogRef: catalogRef,
          libraryEntryRef: libraryEntryRef,
        );

  factory CatalogSearchCandidate.fromTransport({
    required CatalogItemDto item,
    required CatalogDisplaySummary summary,
  }) {
    return CatalogSearchCandidate._(
      summary: CatalogCandidateSummary.fromDisplaySummary(summary),
      catalogRef: item.catalogItemRef,
      libraryEntryRef: null,
      item: item,
    );
  }

  /// Produces a small, transient display projection from a kind-entry flat
  /// payload. The projection is never cached or written back as catalog data.
  factory CatalogSearchCandidate.fromItem(
    CatalogItemDto item, {
    CatalogSearchCandidate? basedOn,
  }) {
    if (basedOn != null) {
      return basedOn.kindCapability.replacingTransport(item);
    }
    if (item.id.trim().isEmpty) {
      throw const FormatException(
        'A catalog candidate requires a Core Catalog Item ID.',
      );
    }
    final summary = summarizeCatalogTransportPayload(item);
    return CatalogSearchCandidate.fromTransport(
      item: item,
      summary: summary,
    );
  }

  /// Creates an edit-only metadata carrier for a local entry. It has no Core
  /// Catalog Item identity and cannot be serialized as a catalog import.
  factory CatalogSearchCandidate.fromLibraryEntry({
    required LibraryEntryRef ref,
    required Map<String, dynamic> kindData,
    required String primaryLabel,
    String? subtitle,
    String? imageUrl,
  }) {
    final item = CatalogItemDto.raw(
      id: '',
      mediaKind: ref.kind,
      kindData: kindData,
      origin: CatalogItemOrigin.privateLocal,
    );
    return CatalogSearchCandidate._(
      summary: CatalogCandidateSummary(
        kind: ref.kind,
        primaryLabel: primaryLabel,
        subtitle: subtitle,
        imageUrl: imageUrl,
      ),
      catalogRef: null,
      libraryEntryRef: ref,
      item: item,
    );
  }

  /// Creates a candidate from a structural summary and an optional selected
  /// transport retained by its kind capability.
  factory CatalogSearchCandidate.fromSummary({
    required CatalogDisplaySummary summary,
    CatalogItemDto? transport,
  }) {
    return CatalogSearchCandidate._(
      summary: CatalogCandidateSummary.fromDisplaySummary(summary),
      catalogRef: summary.ref,
      libraryEntryRef: null,
      item: transport ??
          CatalogItemDto.raw(
            id: summary.ref.id,
            mediaKind: summary.ref.kind,
          ),
    );
  }

  CatalogImportTransport toImportTransport() =>
      kindCapability.toImportTransport();

  /// Decodes a Core search response at the catalog transport boundary and
  /// immediately projects it to the small candidate shape used by mixed
  /// search/import hosts. The generated catalog DTO never leaves this
  /// transport object unless the user selects the candidate.
  factory CatalogSearchCandidate.fromApiJson({
    required Map<String, dynamic> json,
    JsonEncodable Function(JsonMap payload)? metadataDecoder,
    CatalogDisplaySummary Function(CatalogItemDto item)? summaryBuilder,
  }) {
    var item = CatalogItemDto.fromJson(json);
    if (metadataDecoder != null) {
      item = item.replacingKindData(metadataDecoder(item.payload));
    }
    return CatalogSearchCandidate.fromTransport(
      item: item,
      summary:
          summaryBuilder?.call(item) ?? summarizeCatalogTransportPayload(item),
    );
  }

  final CatalogItemRef? catalogRef;
  final LibraryEntryRef? libraryEntryRef;
  CatalogItemRef get reference =>
      catalogRef ??
      (throw StateError('A local entry candidate has no Catalog Item ref.'));
  final CatalogCandidateSummary summary;
  final CatalogSearchCandidateKindCapability kindCapability;
}

/// Kind-entry operations over the selected catalog transport.
///
/// The DTO stays private so mixed hosts can pass the capability without
/// interpreting kind metadata or generated fields.
final class CatalogSearchCandidateKindCapability {
  const CatalogSearchCandidateKindCapability._({
    required CatalogItemDto item,
    required this.summary,
    required this.catalogRef,
    required this.libraryEntryRef,
  }) : _item = item;

  final CatalogItemDto? _item;
  final CatalogCandidateSummary summary;
  final CatalogItemRef? catalogRef;
  final LibraryEntryRef? libraryEntryRef;

  bool get isPrivateLocal => _item?.origin == CatalogItemOrigin.privateLocal;

  T mapTransport<T>(T Function(CatalogItemDto item) decoder) {
    final item = _item;
    if (item == null) {
      throw StateError('The catalog candidate has no selected transport.');
    }
    return decoder(item);
  }

  CatalogSearchCandidate replacingKindData(JsonEncodable kindData) =>
      replacingTransport(
          mapTransport((item) => item.replacingKindData(kindData)));

  CatalogSearchCandidate replacingTransport(CatalogItemDto item) {
    final nextSummary = catalogRef == null
        ? summary
        : CatalogCandidateSummary.fromDisplaySummary(
            summarizeCatalogTransportPayload(item),
          );
    return CatalogSearchCandidate._(
      summary: nextSummary,
      catalogRef: catalogRef,
      libraryEntryRef: libraryEntryRef,
      item: item,
    );
  }

  CatalogImportTransport toImportTransport() {
    if (catalogRef == null) {
      throw StateError(
        'A local Library Entry cannot be serialized as a Catalog Item import.',
      );
    }
    return mapTransport(CatalogImportTransport.fromItem);
  }
}
