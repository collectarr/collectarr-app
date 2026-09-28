import 'dart:collection';
import 'dart:convert';

import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/csv/csv_mechanics.dart';
import 'package:collectarr_app/features/library/data/owned_copy_v1_repository.dart';
import 'package:collectarr_app/features/library/domain/catalog_item_v1_schema.dart';
import 'package:collectarr_app/features/library/domain/owned_copy_v1.dart';
import 'package:dio/dio.dart';

/// Imports the stable Catalog Item v1 CSV format and writes App-owned copies.
/// Existing Core items are reused by ID. Missing items are created from the
/// catalog fields in the row, which requires Catalog Item write permission.
final class CatalogItemV1CsvImporter {
  CatalogItemV1CsvImporter({
    required ApiClient api,
    required OwnedCopyV1Repository ownedCopies,
  })  : _api = api,
        _ownedCopies = ownedCopies;

  final ApiClient _api;
  final OwnedCopyV1Repository _ownedCopies;

  List<CatalogItemV1CsvImportRow> parse(String content) {
    final matrix = const CsvReader().read(content);
    if (matrix.isEmpty) {
      throw const FormatException('The CSV file is empty.');
    }
    final headers = matrix.first.map((value) => value.trim()).toList();
    final positions = <String, int>{};
    for (var index = 0; index < headers.length; index++) {
      final header = headers[index];
      if (header.isEmpty || positions.containsKey(header)) {
        throw FormatException('Invalid or duplicate CSV header "$header".');
      }
      if (header != 'schema_version' &&
          header != 'catalog_item_id' &&
          header != 'kind' &&
          !header.startsWith('catalog.') &&
          !header.startsWith('copy.')) {
        throw FormatException(
            'Unsupported Catalog Item v1 CSV column "$header".');
      }
      positions[header] = index;
    }
    for (final required in const [
      'schema_version',
      'catalog_item_id',
      'kind',
      'copy.id',
      'copy.status'
    ]) {
      if (!positions.containsKey(required)) {
        throw FormatException(
          'This is not a Catalog Item v1 CSV: missing "$required".',
        );
      }
    }

    final result = <CatalogItemV1CsvImportRow>[];
    for (var index = 1; index < matrix.length; index++) {
      final cells = matrix[index];
      if (cells.every((value) => value.trim().isEmpty)) continue;
      if (cells.length > headers.length) {
        throw FormatException('CSV row ${index + 1} has extra columns.');
      }
      final values = List<String>.filled(headers.length, '');
      for (var cellIndex = 0; cellIndex < cells.length; cellIndex++) {
        values[cellIndex] = cells[cellIndex];
      }
      String cell(String key) => values[positions[key]!].trim();
      final version = cell('schema_version');
      if (version != '1') {
        throw FormatException(
          'CSV row ${index + 1} uses unsupported schema version "$version".',
        );
      }
      final kind = _kindFromApiValue(cell('kind'));
      final catalogProperties =
          catalogItemV1WriteSchemaForKind(kind)['properties'];
      if (catalogProperties is! Map<String, dynamic>) {
        throw StateError('The pinned schema has no fields for $kind.');
      }
      final catalogDetails = <String, Object?>{'kind': kind.apiValue};
      final copyValues = <String, Object?>{};
      final kindDetails = <String, Object?>{};
      for (final header in headers) {
        if (header.startsWith('catalog.')) {
          final key = header.substring('catalog.'.length);
          if (!catalogProperties.containsKey(key)) continue;
          final raw = cell(header);
          if (raw.isEmpty) continue;
          final propertySchema = catalogProperties[key];
          catalogDetails[key] = propertySchema is Map<String, dynamic>
              ? _decodeCatalogCell(raw, propertySchema)
              : raw;
        } else if (header.startsWith('copy.details.')) {
          final key = header.substring('copy.details.'.length);
          final raw = cell(header);
          if (raw.isNotEmpty) {
            kindDetails[key] = _decodeKindDetailCell(kind, key, raw);
          }
        } else if (header.startsWith('copy.')) {
          final key = header.substring('copy.'.length);
          final raw = cell(header);
          if (raw.isNotEmpty) copyValues[key] = _decodeCopyCell(key, raw);
        }
      }
      final title = catalogDetails['title'];
      if (title is! String || title.trim().isEmpty) {
        throw FormatException(
          'CSV row ${index + 1} is missing the Catalog Item title.',
        );
      }
      final copyId = copyValues['id'];
      if (copyId is! String || copyId.trim().isEmpty) {
        throw FormatException(
          'CSV row ${index + 1} is missing the Owned Copy ID.',
        );
      }
      final status = copyValues['status'];
      if (status is! String || status.trim().isEmpty) {
        throw FormatException(
          'CSV row ${index + 1} is missing the Owned Copy status.',
        );
      }
      final catalogItemId = cell('catalog_item_id');
      final row = CatalogItemV1CsvImportRow(
        rowNumber: index + 1,
        kind: kind,
        catalogItemId: catalogItemId.isEmpty ? null : catalogItemId,
        catalogDetails: Map.unmodifiable(catalogDetails),
        copyValues: Map.unmodifiable(copyValues),
        kindDetails: Map.unmodifiable(kindDetails),
      );
      // Validate every typed Owned Copy field during preview, before making
      // network requests or writing any rows.
      row.toOwnedCopy(
        CatalogItemRef(
          kind: kind,
          id: catalogItemId.isEmpty ? 'csv-preview' : catalogItemId,
        ),
        now: DateTime.now().toUtc(),
      );
      result.add(row);
    }
    return List.unmodifiable(result);
  }

  Future<CatalogItemV1CsvImportReport> importContent(String content) async {
    final rows = parse(content);
    final cachedItems = <String, CatalogItemV1Dto>{};
    final copies = <OwnedCopyV1>[];
    final failures = <CatalogItemV1CsvImportFailure>[];
    final now = DateTime.now().toUtc();
    for (final row in rows) {
      try {
        final cacheKey = row.cacheKey;
        final item = cachedItems[cacheKey] ?? await _resolveItem(row);
        cachedItems[cacheKey] = item;
        copies.add(row.toOwnedCopy(item.reference, now: now));
      } catch (error) {
        failures.add(
          CatalogItemV1CsvImportFailure(
            rowNumber: row.rowNumber,
            message: error.toString(),
          ),
        );
      }
    }
    await _ownedCopies.upsertAll(copies);
    return CatalogItemV1CsvImportReport(
      importedRows: copies.length,
      failures: failures,
    );
  }

  Future<CatalogItemV1Dto> _resolveItem(
    CatalogItemV1CsvImportRow row,
  ) async {
    final existingId = row.catalogItemId;
    if (existingId != null) {
      try {
        final item = await _api.getCatalogItem(
          CatalogItemRef(kind: row.kind, id: existingId),
        );
        if (item.kind != row.kind.apiValue) {
          throw StateError(
            'Catalog Item $existingId is ${item.kind}, not ${row.kind.apiValue}.',
          );
        }
        return item;
      } on DioException catch (error) {
        if (error.response?.statusCode != 404) rethrow;
      }
    }
    final details = catalogItemWriteDetailsFromJson(
      Map<String, dynamic>.from(row.catalogDetails),
    );
    if (details.kind != row.kind.apiValue) {
      throw StateError('CSV kind does not match Catalog Item details.');
    }
    return _api.createCatalogItem(CatalogItemWriteV1Dto(details: details));
  }

  Object? _decodeCatalogCell(String value, Map<String, dynamic> schema) {
    final type = _schemaType(schema);
    return switch (type) {
      'array' || 'object' => _decodeJson(value, 'catalog field'),
      'integer' => int.parse(value),
      'number' => num.parse(value),
      'boolean' => _parseBoolean(value),
      _ => value,
    };
  }

  String? _schemaType(Map<String, dynamic> schema) {
    final direct = schema['type'];
    if (direct is String) return direct;
    if (direct is List) {
      for (final value in direct) {
        if (value is String && value != 'null') return value;
      }
    }
    final alternatives = schema['anyOf'] ?? schema['oneOf'];
    if (alternatives is List) {
      for (final alternative in alternatives) {
        if (alternative is Map) {
          final type = _schemaType(Map<String, dynamic>.from(alternative));
          if (type != null) return type;
        }
      }
    }
    final reference = schema[r'$ref'];
    if (reference is String && reference.startsWith(r'#/$defs/')) {
      final definition = catalogItemV1SchemaDefinitions[
          reference.substring(r'#/$defs/'.length)];
      if (definition is Map) {
        return _schemaType(Map<String, dynamic>.from(definition));
      }
    }
    return null;
  }

  Object? _decodeCopyCell(String key, String value) {
    return switch (key) {
      'index_number' || 'rating' => int.parse(value),
      'is_digital' => _parseBoolean(value),
      'owner' ||
      'purchase_date' ||
      'purchase_price' ||
      'current_value' ||
      'sold_at' ||
      'sale_price' ||
      'tags' ||
      'personal_images' ||
      'custom_fields' =>
        _decodeJson(value, 'copy.$key'),
      _ => value,
    };
  }

  Object? _decodeKindDetailCell(
    CatalogMediaKind kind,
    String key,
    String value,
  ) {
    if ((kind == CatalogMediaKind.boardgame && key == 'painted_miniatures') ||
        (kind == CatalogMediaKind.boardgame && key == 'has_sleeves') ||
        (kind == CatalogMediaKind.game &&
            (key == 'has_box' || key == 'has_manual'))) {
      return _parseBoolean(value);
    }
    if ((kind == CatalogMediaKind.music &&
            (key == 'last_cleaned_date' || key == 'disc_storage')) ||
        (kind == CatalogMediaKind.music && key == 'signed_by')) {
      return _decodeJson(value, 'copy.details.$key');
    }
    return value;
  }

  Object? _decodeJson(String value, String field) {
    try {
      return jsonDecode(value);
    } on FormatException catch (error) {
      throw FormatException('Invalid JSON in $field: ${error.message}');
    }
  }

  bool _parseBoolean(String value) => switch (value.trim().toLowerCase()) {
        'true' || '1' || 'yes' => true,
        'false' || '0' || 'no' => false,
        _ => throw FormatException('Invalid boolean value "$value".'),
      };

  CatalogMediaKind _kindFromApiValue(String value) {
    for (final kind in CatalogMediaKind.values) {
      if (!kind.isUnknown && kind.apiValue == value) return kind;
    }
    throw FormatException('Unsupported Catalog Item kind "$value".');
  }
}

final class CatalogItemV1CsvImportRow {
  const CatalogItemV1CsvImportRow({
    required this.rowNumber,
    required this.kind,
    required this.catalogItemId,
    required this.catalogDetails,
    required this.copyValues,
    required this.kindDetails,
  });

  final int rowNumber;
  final CatalogMediaKind kind;
  final String? catalogItemId;
  final Map<String, Object?> catalogDetails;
  final Map<String, Object?> copyValues;
  final Map<String, Object?> kindDetails;

  String get cacheKey {
    final id = catalogItemId;
    final fingerprint = jsonEncode(SplayTreeMap<String, Object?>.from(
      catalogDetails,
    ));
    return '${kind.apiValue}:${id ?? fingerprint}';
  }

  OwnedCopyV1 toOwnedCopy(CatalogItemRef item, {required DateTime now}) {
    final copyJson = <String, Object?>{
      ...copyValues,
      'catalog_item': item.toJson(),
      'created_at': copyValues['created_at'] ?? now.toIso8601String(),
      'updated_at': copyValues['updated_at'] ?? now.toIso8601String(),
      'kind_details': kindDetails,
    };
    return OwnedCopyV1.fromJson(copyJson);
  }
}

final class CatalogItemV1CsvImportReport {
  CatalogItemV1CsvImportReport({
    required this.importedRows,
    required List<CatalogItemV1CsvImportFailure> failures,
  }) : failures = List.unmodifiable(failures);

  final int importedRows;
  final List<CatalogItemV1CsvImportFailure> failures;
}

final class CatalogItemV1CsvImportFailure {
  const CatalogItemV1CsvImportFailure({
    required this.rowNumber,
    required this.message,
  });

  final int rowNumber;
  final String message;
}
