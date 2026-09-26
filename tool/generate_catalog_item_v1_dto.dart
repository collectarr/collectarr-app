import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const _contractPath = 'tool/core_contracts/catalog-item-v1.json';
const _manifestPath = 'tool/core_contracts/contract-manifest.json';
const _outputPath = 'lib/core/api/generated/catalog_item_v1.models.g.dart';

const _schemas = <String, String>{
  'CatalogComponentV1': 'CatalogComponentV1Dto',
  'CatalogCreditV1': 'CatalogCreditV1Dto',
  'CatalogEpisodeV1': 'CatalogEpisodeV1Dto',
  'CatalogIdentifierV1': 'CatalogIdentifierV1Dto',
  'CatalogImageV1': 'CatalogImageV1Dto',
  'CatalogMediaTrackV1': 'CatalogMediaTrackV1Dto',
  'CatalogRelatedItemV1': 'CatalogRelatedItemV1Dto',
  'CatalogSeasonV1': 'CatalogSeasonV1Dto',
  'CatalogSeriesMembershipV1': 'CatalogSeriesMembershipV1Dto',
  'MusicAlbumTrackV1': 'MusicAlbumTrackV1Dto',
  'AnimeCatalogDetailsV1': 'AnimeCatalogDetailsV1Dto',
  'BoardGameCatalogDetailsV1': 'BoardGameCatalogDetailsV1Dto',
  'BookCatalogDetailsV1': 'BookCatalogDetailsV1Dto',
  'ComicCatalogDetailsV1': 'ComicCatalogDetailsV1Dto',
  'GameCatalogDetailsV1': 'GameCatalogDetailsV1Dto',
  'MangaCatalogDetailsV1': 'MangaCatalogDetailsV1Dto',
  'MovieCatalogDetailsV1-Input': 'MovieCatalogWriteDetailsV1Dto',
  'MovieCatalogDetailsV1-Output': 'MovieCatalogDetailsV1Dto',
  'MusicAlbumArtistV1': 'MusicAlbumArtistV1Dto',
  'MusicAlbumCreditV1': 'MusicAlbumCreditV1Dto',
  'MusicAlbumDiscTitleV1': 'MusicAlbumDiscTitleV1Dto',
  'MusicAlbumLabelV1': 'MusicAlbumLabelV1Dto',
  'MusicAlbumLinkV1': 'MusicAlbumLinkV1Dto',
  'MusicAlbumTrackInputV1': 'MusicAlbumTrackInputV1Dto',
  'MusicCatalogDetailsV1': 'MusicCatalogDetailsV1Dto',
  'MusicCatalogWriteDetailsV1': 'MusicCatalogWriteDetailsV1Dto',
  'TVCatalogDetailsV1': 'TVCatalogDetailsV1Dto',
};

const _writeKindDetails = <String, String>{
  'anime': 'AnimeCatalogDetailsV1Dto',
  'boardgame': 'BoardGameCatalogDetailsV1Dto',
  'book': 'BookCatalogDetailsV1Dto',
  'comic': 'ComicCatalogDetailsV1Dto',
  'game': 'GameCatalogDetailsV1Dto',
  'manga': 'MangaCatalogDetailsV1Dto',
  'movie': 'MovieCatalogWriteDetailsV1Dto',
  'music': 'MusicCatalogWriteDetailsV1Dto',
  'tv': 'TVCatalogDetailsV1Dto',
};

const _kindDetails = <String, String>{
  'anime': 'AnimeCatalogDetailsV1Dto',
  'boardgame': 'BoardGameCatalogDetailsV1Dto',
  'book': 'BookCatalogDetailsV1Dto',
  'comic': 'ComicCatalogDetailsV1Dto',
  'game': 'GameCatalogDetailsV1Dto',
  'manga': 'MangaCatalogDetailsV1Dto',
  'movie': 'MovieCatalogDetailsV1Dto',
  'music': 'MusicCatalogDetailsV1Dto',
  'tv': 'TVCatalogDetailsV1Dto',
};

Future<void> main(List<String> args) async {
  final checkOnly = args.contains('--check');
  final contractBytes = await File(_contractPath).readAsBytes();
  final manifest = jsonDecode(await File(_manifestPath).readAsString())
      as Map<String, dynamic>;
  final actualHash = sha256.convert(contractBytes).toString();
  if (manifest['catalogItemHash'] != actualHash) {
    stderr.writeln(
      'Pinned Catalog Item contract hash does not match contract-manifest.json.',
    );
    exitCode = 1;
    return;
  }
  final contract =
      jsonDecode(utf8.decode(contractBytes)) as Map<String, dynamic>;
  final defs = contract[r'$defs'] as Map<String, dynamic>;
  for (final schemaName in _schemas.keys) {
    if (defs[schemaName] is! Map<String, dynamic>) {
      throw FormatException('Catalog Item contract is missing $schemaName.');
    }
  }
  final source = await _formatSource(_generate(defs, actualHash));
  final output = File(_outputPath);
  if (checkOnly) {
    if (!await output.exists() || await output.readAsString() != source) {
      stderr.writeln('Generated Catalog Item DTOs are out of date.');
      exitCode = 1;
    }
    return;
  }
  await output.parent.create(recursive: true);
  await output.writeAsString(source);
}

Future<String> _formatSource(String source) async {
  final temporary = File('$_outputPath.format.dart');
  await temporary.writeAsString(source);
  try {
    final result = await Process.run(
      Platform.resolvedExecutable,
      ['format', temporary.path],
    );
    if (result.exitCode != 0) {
      throw ProcessException(
        Platform.resolvedExecutable,
        ['format', temporary.path],
        result.stderr.toString(),
        result.exitCode,
      );
    }
    return await temporary.readAsString();
  } finally {
    if (await temporary.exists()) await temporary.delete();
  }
}

String _generate(Map<String, dynamic> defs, String hash) {
  final out = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: $_contractPath')
    ..writeln('// Contract SHA-256: $hash')
    ..writeln("part of 'collectarr_api.models.dart';")
    ..writeln()
    ..writeln('abstract interface class CatalogItemKindDetailsV1Dto {')
    ..writeln('  String get kind;')
    ..writeln('  String get title;')
    ..writeln('  Map<String, dynamic> toJson();')
    ..writeln('}')
    ..writeln()
    ..writeln('abstract interface class CatalogItemWriteKindDetailsV1Dto {')
    ..writeln('  String get kind;')
    ..writeln('  String get title;')
    ..writeln('  Map<String, dynamic> toJson();')
    ..writeln('}')
    ..writeln()
    ..writeln('String _catalogString(Object? value, String field) {')
    ..writeln('  if (value is String) return value;')
    ..writeln(
        "  throw FormatException('Missing or invalid Catalog Item field: \$field');")
    ..writeln('}')
    ..writeln()
    ..writeln('int _catalogInt(Object? value, String field) {')
    ..writeln('  if (value is int) return value;')
    ..writeln('  if (value is num) return value.toInt();')
    ..writeln(
        "  throw FormatException('Missing or invalid Catalog Item field: \$field');")
    ..writeln('}')
    ..writeln()
    ..writeln('double _catalogDouble(Object? value, String field) {')
    ..writeln('  if (value is num) return value.toDouble();')
    ..writeln('  final parsed = double.tryParse(value?.toString() ?? \'\');')
    ..writeln('  if (parsed != null) return parsed;')
    ..writeln(
        "  throw FormatException('Missing or invalid Catalog Item field: \$field');")
    ..writeln('}')
    ..writeln()
    ..writeln('DateTime _catalogDateTime(Object? value, String field) {')
    ..writeln(
        '  final parsed = value is String ? DateTime.tryParse(value) : null;')
    ..writeln('  if (parsed != null) return parsed;')
    ..writeln(
        "  throw FormatException('Missing or invalid Catalog Item field: \$field');")
    ..writeln('}')
    ..writeln()
    ..writeln('List<String> _catalogStrings(Object? value) {')
    ..writeln('  if (value is! List) return const <String>[];')
    ..writeln('  return value.whereType<String>().toList(growable: false);')
    ..writeln('}')
    ..writeln()
    ..writeln('List<T> _catalogObjects<T>(')
    ..writeln('  Object? value,')
    ..writeln('  T Function(Map<String, dynamic>) decode,')
    ..writeln(') {')
    ..writeln('  if (value is! List) return <T>[];')
    ..writeln('  return [for (final row in value)')
    ..writeln('    if (row is Map) decode(Map<String, dynamic>.from(row))];')
    ..writeln('}')
    ..writeln();

  for (final entry in _schemas.entries) {
    final schema = defs[entry.key] as Map<String, dynamic>;
    final properties = schema['properties'] as Map<String, dynamic>;
    final required = (schema['required'] as List<dynamic>? ?? const [])
        .cast<String>()
        .toSet();
    final isResponseDetails = _kindDetails.values.contains(entry.value);
    final isWriteDetails = _writeKindDetails.values.contains(entry.value);
    final detailInterfaces = [
      if (isResponseDetails) 'CatalogItemKindDetailsV1Dto',
      if (isWriteDetails) 'CatalogItemWriteKindDetailsV1Dto',
    ];
    out
      ..writeln('@immutable')
      ..writeln(
        'final class ${entry.value}${detailInterfaces.isEmpty ? '' : ' implements ${detailInterfaces.join(', ')}'} {',
      )
      ..writeln('  const ${entry.value}({');
    for (final property in properties.entries) {
      out.writeln('    required this.${_camel(property.key)},');
    }
    out
      ..writeln('  });')
      ..writeln();
    for (final property in properties.entries) {
      if (detailInterfaces.isNotEmpty &&
          (property.key == 'kind' || property.key == 'title')) {
        out.writeln('  @override');
      }
      out.writeln(
        '  final ${_dartType(property.value as Map<String, dynamic>)} ${_camel(property.key)};',
      );
    }
    out
      ..writeln()
      ..writeln(
          '  factory ${entry.value}.fromJson(Map<String, dynamic> json) {')
      ..writeln('    return ${entry.value}(');
    for (final property in properties.entries) {
      final key = property.key;
      out.writeln(
        '      ${_camel(key)}: ${_decode(property.value as Map<String, dynamic>, key, required.contains(key))},',
      );
    }
    out
      ..writeln('    );')
      ..writeln('  }')
      ..writeln()
      ..writeln(detailInterfaces.isNotEmpty ? '  @override' : '')
      ..writeln('  Map<String, dynamic> toJson() => {');
    for (final property in properties.entries) {
      final key = property.key;
      out.writeln(
        "        '$key': ${_encode(_camel(key), property.value as Map<String, dynamic>)},",
      );
    }
    out
      ..writeln('      };')
      ..writeln('}')
      ..writeln();
  }

  out
    ..writeln('CatalogItemKindDetailsV1Dto catalogItemDetailsFromJson(')
    ..writeln('  Map<String, dynamic> json,')
    ..writeln(') {')
    ..writeln("  final kind = json['kind'];")
    ..writeln('  return switch (kind) {');
  for (final entry in _kindDetails.entries) {
    out.writeln(
      "    '${entry.key}' => ${entry.value}.fromJson(json),",
    );
  }
  out
    ..writeln(
        "    _ => throw FormatException('Unsupported Catalog Item kind: \$kind'),")
    ..writeln('  };')
    ..writeln('}')
    ..writeln()
    ..writeln(
        'CatalogItemWriteKindDetailsV1Dto catalogItemWriteDetailsFromJson(')
    ..writeln('  Map<String, dynamic> json,')
    ..writeln(') {')
    ..writeln("  final kind = json['kind'];")
    ..writeln('  return switch (kind) {');
  for (final entry in _writeKindDetails.entries) {
    out.writeln(
      "    '${entry.key}' => ${entry.value}.fromJson(json),",
    );
  }
  out
    ..writeln(
        "    _ => throw FormatException('Unsupported Catalog Item kind: \$kind'),")
    ..writeln('  };')
    ..writeln('}')
    ..writeln()
    ..writeln('@immutable')
    ..writeln('final class CatalogItemV1Dto {')
    ..writeln('  const CatalogItemV1Dto({')
    ..writeln('    required this.id,')
    ..writeln('    required this.details,')
    ..writeln('    required this.createdAt,')
    ..writeln('    required this.updatedAt,')
    ..writeln('  });')
    ..writeln('  final String id;')
    ..writeln('  final CatalogItemKindDetailsV1Dto details;')
    ..writeln('  final DateTime createdAt;')
    ..writeln('  final DateTime updatedAt;')
    ..writeln('  String get kind => details.kind;')
    ..writeln('  String get title => details.title;')
    ..writeln('  CatalogItemRef get reference => CatalogItemRef(')
    ..writeln('        kind: catalogMediaKindFromApiValue(kind), id: id);')
    ..writeln(
        '  factory CatalogItemV1Dto.fromJson(Map<String, dynamic> json) =>')
    ..writeln('      CatalogItemV1Dto(')
    ..writeln("        id: _catalogString(json['id'], 'id'),")
    ..writeln("        details: catalogItemDetailsFromJson(")
    ..writeln("          Map<String, dynamic>.from(json['details'] as Map),")
    ..writeln('        ),')
    ..writeln(
        "        createdAt: _catalogDateTime(json['created_at'], 'created_at'),")
    ..writeln(
        "        updatedAt: _catalogDateTime(json['updated_at'], 'updated_at'),")
    ..writeln('      );')
    ..writeln('  Map<String, dynamic> toJson() => {')
    ..writeln("        'id': id,")
    ..writeln("        'details': details.toJson(),")
    ..writeln("        'created_at': createdAt.toIso8601String(),")
    ..writeln("        'updated_at': updatedAt.toIso8601String(),")
    ..writeln('      };')
    ..writeln('}')
    ..writeln()
    ..writeln('@immutable')
    ..writeln('final class CatalogItemWriteV1Dto {')
    ..writeln('  const CatalogItemWriteV1Dto({required this.details});')
    ..writeln('  final CatalogItemWriteKindDetailsV1Dto details;')
    ..writeln(
        "  Map<String, dynamic> toJson() => {'details': details.toJson()};")
    ..writeln('}')
    ..writeln()
    ..writeln('@immutable')
    ..writeln('final class CatalogItemSummaryV1Dto {')
    ..writeln('  const CatalogItemSummaryV1Dto({')
    ..writeln('    required this.id,')
    ..writeln('    required this.kind,')
    ..writeln('    required this.title,')
    ..writeln('    this.sortTitle,')
    ..writeln('    this.releaseDate,')
    ..writeln('    this.coverImageUrl,')
    ..writeln('  });')
    ..writeln('  final String id;')
    ..writeln('  final String kind;')
    ..writeln('  final String title;')
    ..writeln('  final String? sortTitle;')
    ..writeln('  final PartialDate? releaseDate;')
    ..writeln('  final String? coverImageUrl;')
    ..writeln('  CatalogItemRef get reference => CatalogItemRef(')
    ..writeln('        kind: catalogMediaKindFromApiValue(kind), id: id);')
    ..writeln('  factory CatalogItemSummaryV1Dto.fromJson(')
    ..writeln('    Map<String, dynamic> json,')
    ..writeln('  ) => CatalogItemSummaryV1Dto(')
    ..writeln("        id: _catalogString(json['id'], 'id'),")
    ..writeln("        kind: _catalogString(json['kind'], 'kind'),")
    ..writeln("        title: _catalogString(json['title'], 'title'),")
    ..writeln("        sortTitle: json['sort_title'] as String?,")
    ..writeln(
        "        releaseDate: PartialDate.tryParse(json['release_date']),")
    ..writeln("        coverImageUrl: json['cover_image_url'] as String?,")
    ..writeln('      );')
    ..writeln('  Map<String, dynamic> toJson() => {')
    ..writeln("        'id': id,")
    ..writeln("        'kind': kind,")
    ..writeln("        'title': title,")
    ..writeln("        'sort_title': sortTitle,")
    ..writeln("        'release_date': releaseDate?.toJson(),")
    ..writeln("        'cover_image_url': coverImageUrl,")
    ..writeln('      };')
    ..writeln('}')
    ..writeln();
  return out.toString();
}

String _camel(String value) => value.replaceAllMapped(
      RegExp(r'_([a-z])'),
      (match) => match.group(1)!.toUpperCase(),
    );

String _dartType(Map<String, dynamic> schema) {
  if (schema['anyOf'] case final List<dynamic> variants) {
    final inner = variants.cast<Map<String, dynamic>>().firstWhere(
          (variant) => variant['type'] != 'null',
          orElse: () => <String, dynamic>{},
        );
    if (inner.isEmpty) return 'Object?';
    final type = _dartType(inner);
    final nullable = variants.any(
      (variant) => (variant as Map<String, dynamic>)['type'] == 'null',
    );
    return nullable && !type.endsWith('?') ? '$type?' : type;
  }
  if (schema[r'$ref'] case final String ref) {
    final name = ref.split('/').last;
    if (name == 'PartialDateValue') return 'PartialDate';
    return _schemas[name] ?? 'Object';
  }
  if (schema['type'] == 'array') {
    return 'List<${_dartType(schema['items'] as Map<String, dynamic>)}>';
  }
  return switch (schema['format']) {
    'date-time' => 'DateTime',
    _ => switch (schema['type']) {
        'string' => 'String',
        'integer' => 'int',
        'number' => 'double',
        'boolean' => 'bool',
        'object' => 'Map<String, dynamic>',
        _ => 'Object?',
      },
  };
}

String _decode(Map<String, dynamic> schema, String field, bool required) {
  final value = "json['$field']";
  if (schema['anyOf'] case final List<dynamic> variants) {
    final inner = variants.cast<Map<String, dynamic>>().firstWhere(
          (variant) => variant['type'] != 'null',
          orElse: () => <String, dynamic>{},
        );
    if (inner.isEmpty) return value;
    final nullable = variants.any(
      (variant) => (variant as Map<String, dynamic>)['type'] == 'null',
    );
    final decoded = _decode(inner, field, required && !nullable);
    return nullable ? '$value == null ? null : $decoded' : decoded;
  }
  if (schema[r'$ref'] case final String ref) {
    final name = ref.split('/').last;
    if (name == 'PartialDateValue') return 'PartialDate.tryParse($value)';
    final className = _schemas[name];
    if (className != null) {
      return '$className.fromJson(Map<String, dynamic>.from($value as Map))';
    }
  }
  if (schema['type'] == 'array') {
    final item = schema['items'] as Map<String, dynamic>;
    if (item['type'] == 'string') return '_catalogStrings($value)';
    if (item[r'$ref'] case final String ref) {
      final className = _schemas[ref.split('/').last];
      if (className != null) {
        return '_catalogObjects<$className>($value, $className.fromJson)';
      }
    }
    final itemType = _dartType(item);
    return '$value is List ? $value.whereType<$itemType>().toList() : <$itemType>[]';
  }
  final type = schema['type'];
  if (type == 'string') {
    final decoded =
        required ? "_catalogString($value, '$field')" : '$value as String?';
    return _withDefault(decoded, schema);
  }
  if (type == 'integer') {
    final decoded = required
        ? "_catalogInt($value, '$field')"
        : '($value as num?)?.toInt()';
    return _withDefault(decoded, schema);
  }
  if (type == 'number') {
    final decoded = required
        ? "_catalogDouble($value, '$field')"
        : '($value == null ? null : _catalogDouble($value, \'$field\'))';
    return _withDefault(decoded, schema);
  }
  if (type == 'boolean') {
    final decoded = required ? '$value as bool' : '$value as bool?';
    return _withDefault(decoded, schema);
  }
  if (schema['format'] == 'date-time') {
    return required
        ? "_catalogDateTime($value, '$field')"
        : '($value is String ? DateTime.tryParse($value) : null)';
  }
  return value;
}

String _encode(String field, Map<String, dynamic> schema) {
  if (schema['anyOf'] case final List<dynamic> variants) {
    final inner = variants.cast<Map<String, dynamic>>().firstWhere(
          (variant) => variant['type'] != 'null',
          orElse: () => <String, dynamic>{},
        );
    if (inner.isEmpty) return field;
    if (inner[r'$ref'] != null) {
      return '$field?.toJson()';
    }
    if (inner['format'] == 'date-time') return '$field?.toIso8601String()';
    return field;
  }
  return _encodeValue(field, schema);
}

String _withDefault(String decoded, Map<String, dynamic> schema) {
  if (!schema.containsKey('default')) return decoded;
  return '($decoded ?? ${jsonEncode(schema['default'])})';
}

String _encodeValue(String field, Map<String, dynamic> schema) {
  if (schema['type'] == 'array') {
    final item = schema['items'] as Map<String, dynamic>;
    if (item[r'$ref'] != null) {
      return '$field.map((value) => value.toJson()).toList()';
    }
    return field;
  }
  if (schema[r'$ref'] case final String ref) {
    if (ref.endsWith('/PartialDateValue')) return '$field?.toJson()';
    return '$field.toJson()';
  }
  if (schema['format'] == 'date-time') return '$field.toIso8601String()';
  return field;
}
