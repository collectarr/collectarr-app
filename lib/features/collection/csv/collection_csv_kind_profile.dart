import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_transport.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/entries/entry_import_transport.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';

/// Structural cells contributed by a kind to the collection CSV host.
///
/// The collection feature owns the CSV wire layout and file mechanics. A kind
/// owns the meaning of the cells it contributes. The lists are deliberately
/// positional because the format is a serialization boundary, not a domain
/// model shared by kinds.
abstract interface class CollectionCsvKindProfile {
  CatalogMediaKind get kind;

  String importDisplayTitle(List<String> catalogCells);

  String importDisplaySubtitle(List<String> catalogCells);

  /// Returns the kind-defined value used for title/identifier matching at the
  /// import boundary. The collection host does not call this field an issue,
  /// volume, edition or version because that meaning belongs to the kind.
  String? importPrimaryLookupValue(List<String> catalogCells);

  /// Returns the kind-defined barcode/ISBN/UPC value, when the kind supports
  /// one. The collection host only uses the normalized lookup value.
  String? importBarcode(List<String> catalogCells);

  CatalogImportTransport? catalogTransportFromImportCells(
    List<String> catalogCells,
  );

  /// Builds the kind-entry JSON payload at the CSV serialization boundary.
  ///
  /// Collection does not inspect this map. It passes it immediately to the
  /// generated kind persistence dispatcher, which decodes it into the
  /// concrete Entry aggregate and returns only a structural mutation result.
  EntryImportTransport libraryEntryImportTransport(
    CollectionCsvEntryImport input,
  );

  /// The complete CLZ header for a single-kind export.

  ///
  /// The complete schema-v1 header for this kind. The header is a
  /// wire-format concern, so owning it here keeps kind-specific labels and
  /// columns out of Collection.
  List<String> get v1Header;

  /// The complete CLZ-compatible header for this kind.
  List<String> get clzFriendlyHeader;

  List<String>? importCatalogCells({
    required List<String> header,
    required List<String> values,
  });

  List<String>? importEntryCells({
    required List<String> header,
    required List<String> values,
  });

  Map<String, List<String>> get columnAliases;

  List<String> catalogCells(LibraryWorkspaceContext entry);

  /// Serializes the owning kind's collection-value column at the CSV boundary.
  ///
  /// The collection row intentionally has no canonical grade field. A kind
  /// decides whether and how its Entry aggregate contributes this column.
  String? entryCollectionValue(LibraryWorkspaceContext entry);

  /// Schema-v1 personal cells whose meaning is entry by the selected kind.
  /// The Collection host only places these values in the wire row.
  String? entryCondition(LibraryWorkspaceContext entry);

  int? entryIndexNumber(LibraryWorkspaceContext entry);

  String? entryTags(LibraryWorkspaceContext entry);

  /// Kind-entry values positioned after price and before location in the
  /// CLZ-friendly layout, such as a Comic cover price.
  List<String> entryCellsBeforeLocation(
    LibraryWorkspaceContext entry, {
    required bool clzFriendly,
  });

  List<String> entryCellsAfterIndex(
    LibraryWorkspaceContext entry, {
    required bool clzFriendly,
  });
}

/// Values carried from the schema-v1 CSV boundary into one owning kind.
///
/// This is an import command, not a common Entry domain model. It contains
/// only transport columns shared by the file format; the owning projection
/// decides how they become its concrete Entry aggregate.
final class CollectionCsvEntryImport {
  const CollectionCsvEntryImport({
    required this.id,
    required this.kind,
    this.sourceCatalogItemRef,
    this.catalogData = const {},
    required this.now,
    required this.kindEntryCells,
    this.existingPayload,
    this.condition,
    this.purchaseDate,
    this.pricePaidCents,
    this.currency,
    this.personalNotes,
    this.locationId,
    this.indexNumber,
    this.tags,
    this.soldAt,
    this.sellPriceCents,
    this.soldTo,
    this.quantity,
  });

  final String id;
  final CatalogMediaKind kind;
  final CatalogItemRef? sourceCatalogItemRef;
  final JsonMap catalogData;
  final DateTime now;
  final JsonMap? existingPayload;
  final String? condition;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final String? locationId;
  final int? indexNumber;
  final String? tags;
  final DateTime? soldAt;
  final int? sellPriceCents;
  final String? soldTo;
  final int? quantity;
  final List<String> kindEntryCells;
}

/// Optional kind-entry decoder for the positional entry cells emitted by a
/// collection CSV projection.
///
/// The Collection host may carry these cells through its row model, but it
/// must not interpret their meaning. Kinds implement this contract next to
/// their CSV profile.
abstract interface class CollectionCsvEntryCellsDecoder {
  JsonEncodable? decodeEntryCells(List<String> cells);
}

/// Shared serialization-boundary mechanics for kind-entry CSV import.
///
/// The helper writes only schema-v1 personal columns. Concrete projections
/// still choose the final Entry type and decode their own kind cells.
mixin CollectionCsvKindEntryImportSupport {
  EntryImportTransport libraryEntryImportTransport(
    CollectionCsvEntryImport input,
  ) {
    final payload = collectionCsvKindEntryImportPayload(input);
    final details = decodeEntryCells(input.kindEntryCells);
    if (details != null) {
      final personal = Map<String, dynamic>.from(
        payload['personal_data'] as Map,
      )..addAll(details.toJson());
      payload['personal_data'] = personal;
    }
    return EntryImportTransport(
      ref: LibraryEntryRef(
        kind: input.kind,
        id: LibraryEntryId(input.id),
      ),
      payload: payload,
    );
  }

  JsonEncodable? decodeEntryCells(List<String> cells);
}

Map<String, dynamic> collectionCsvKindEntryImportPayload(
  CollectionCsvEntryImport input,
) {
  final existing = input.existingPayload == null
      ? null
      : LibraryEntryRecord.fromJson(input.existingPayload!);
  final personal =
      Map<String, dynamic>.from(existing?.personalData ?? const {});
  personal['created_at'] ??= input.now.toUtc().toIso8601String();
  if (input.condition != null) personal['condition'] = input.condition;
  if (input.purchaseDate != null) {
    personal['purchase_date'] = input.purchaseDate!.toUtc().toIso8601String();
  }
  if (input.pricePaidCents != null) {
    personal['price_paid_cents'] = input.pricePaidCents;
  }
  if (input.currency != null) personal['currency'] = input.currency;
  if (input.personalNotes != null) {
    personal['personal_notes'] = input.personalNotes;
  }
  if (input.locationId != null) personal['location_id'] = input.locationId;
  if (input.indexNumber != null) {
    personal['index_number'] = input.indexNumber;
  }
  if (input.tags != null) personal['tags'] = input.tags;
  if (input.soldAt != null) {
    personal['sold_at'] = input.soldAt!.toUtc().toIso8601String();
  }
  if (input.sellPriceCents != null) {
    personal['sell_price_cents'] = input.sellPriceCents;
  }
  if (input.soldTo != null) personal['sold_to'] = input.soldTo;
  if (input.quantity != null) personal['quantity'] = input.quantity;
  return {
    'id': input.id,
    'kind': input.kind.apiValue,
    'catalog_data': input.catalogData,
    'personal_data': personal,
    'source_catalog_ref':
        (existing?.sourceCatalogRef ?? input.sourceCatalogItemRef)?.toJson(),
    'updated_at': input.now.toUtc().toIso8601String(),
  };
}

const collectionCsvV1CatalogCellCount = 11;
const collectionCsvV1EntryCellCount = 9;
