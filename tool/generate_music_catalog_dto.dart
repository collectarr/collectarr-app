import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const _contractPath = 'tool/core_contracts/music-catalog-v1.json';
const _manifestPath = 'tool/core_contracts/contract-manifest.json';
const _outputPath = 'lib/core/api/generated/music_catalog.models.g.dart';

const _classes = <String, String>{
  'MusicAlbumArtistV1': 'MusicAlbumArtistDto',
  'MusicAlbumCreditV1': 'MusicAlbumCreditDto',
  'MusicAlbumDiscTitleV1': 'MusicAlbumDiscTitleDto',
  'MusicAlbumLabelV1': 'MusicAlbumLabelDto',
  'MusicAlbumLinkV1': 'MusicAlbumLinkDto',
  'MusicAlbumTrackInputV1': 'MusicAlbumTrackInputDto',
  'MusicAlbumTrackV1': 'MusicAlbumTrackDto',
  'MusicAlbumV1Response': 'MusicAlbumDto',
  'MusicAlbumWriteV1': 'MusicAlbumWriteDto',
};

Future<void> main(List<String> args) async {
  final checkOnly = args.contains('--check');
  final contractBytes = await File(_contractPath).readAsBytes();
  final manifest = jsonDecode(await File(_manifestPath).readAsString())
      as Map<String, dynamic>;
  final actualHash = sha256.convert(contractBytes).toString();
  if (manifest['musicCatalogHash'] != actualHash) {
    stderr.writeln(
      'Pinned Music catalog contract hash does not match contract-manifest.json.',
    );
    exitCode = 1;
    return;
  }
  final contract = jsonDecode(utf8.decode(contractBytes)) as Map<String, dynamic>;
  final defs = contract[r'$defs'] as Map<String, dynamic>;
  for (final name in _classes.keys) {
    if (defs[name] is! Map<String, dynamic>) {
      throw FormatException('Music contract is missing $name.');
    }
  }
  final source = await _formatSource(_generate(defs, actualHash));
  final output = File(_outputPath);
  if (checkOnly) {
    if (!await output.exists() || await output.readAsString() != source) {
      stderr.writeln('Generated Music DTOs are out of date.');
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
      throw ProcessException(Platform.resolvedExecutable, ['format', temporary.path],
          result.stderr.toString(), result.exitCode);
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
    ..writeln('String _musicString(Object? value, String field) {')
    ..writeln('  if (value is String) return value;')
    ..writeln("  throw FormatException('Missing or invalid Music field: \$field');")
    ..writeln('}')
    ..writeln()
    ..writeln('int _musicInt(Object? value, String field) {')
    ..writeln('  if (value is int) return value;')
    ..writeln('  if (value is num) return value.toInt();')
    ..writeln("  throw FormatException('Missing or invalid Music field: \$field');")
    ..writeln('}')
    ..writeln()
    ..writeln('DateTime _musicDateTime(Object? value, String field) {')
    ..writeln('  final result = value is String ? DateTime.tryParse(value) : null;')
    ..writeln('  if (result != null) return result;')
    ..writeln("  throw FormatException('Missing or invalid Music field: \$field');")
    ..writeln('}')
    ..writeln()
    ..writeln('List<T> _musicObjects<T>(')
    ..writeln('  Object? value,')
    ..writeln('  T Function(Map<String, dynamic>) decode,')
    ..writeln(') {')
    ..writeln('  if (value is! List) return <T>[];')
    ..writeln('  return [for (final row in value)')
    ..writeln('    if (row is Map) decode(Map<String, dynamic>.from(row))];')
    ..writeln('}')
    ..writeln();

  for (final schemaEntry in _classes.entries) {
    final schemaName = schemaEntry.key;
    final className = schemaEntry.value;
    final schema = defs[schemaName] as Map<String, dynamic>;
    final properties = schema['properties'] as Map<String, dynamic>;
    final required = (schema['required'] as List<dynamic>? ?? const [])
        .cast<String>()
        .toSet();
    final isResponse = schemaName == 'MusicAlbumV1Response';
    out.writeln('class $className${isResponse ? ' extends TypedMetadataResponse' : ''} {');
    if (isResponse) {
      out.writeln('  const $className._(super.raw, {');
    } else {
      out.writeln('  const $className({');
    }
    for (final property in properties.entries) {
      final field = _propertyName(property.key, response: isResponse);
      if (isResponse && field == 'kind') continue;
      out.writeln('    required this.$field,');
    }
    out.writeln('  });');
    out.writeln();
    for (final property in properties.entries) {
      final field = _propertyName(property.key, response: isResponse);
      if (isResponse && field == 'kind') continue;
      final type = _dartType(property.value as Map<String, dynamic>);
      if (isResponse && (field == 'id' || field == 'title')) {
        out.writeln('  @override');
      }
      out.writeln('  final $type $field;');
    }
    if (isResponse) {
      out
        ..writeln('  @override')
        ..writeln("  String? get kind => 'music';")
        ..writeln('  @override')
        ..writeln('  DateTime? get releaseDate => releaseDateParts?.asDateTime;')
        ..writeln('  @override')
        ..writeln('  String? get coverImageUrl => coverImageUrlValue;')
        ..writeln('  @override')
        ..writeln('  String? get thumbnailImageUrl => coverImageUrl;')
        ..writeln('  @override')
        ..writeln('  String? get barcode => barcodeValue;');
    }
    out.writeln();
    out.writeln('  factory $className.fromJson(Map<String, dynamic> json) {');
    out.writeln('    return $className${isResponse ? '._' : ''}(');
    if (isResponse) out.writeln('      Map<String, dynamic>.from(json),');
    for (final property in properties.entries) {
      final field = _propertyName(property.key, response: isResponse);
      if (isResponse && field == 'kind') continue;
      final spec = property.value as Map<String, dynamic>;
      out.writeln('      $field: ${_decode(spec, property.key, required.contains(property.key))},');
    }
    out
      ..writeln('    );')
      ..writeln('  }')
      ..writeln('  Map<String, dynamic> toJson() => {')
      ..writeln('        ${properties.keys.map((key) => _encode(_propertyName(key, response: isResponse), key, properties[key] as Map<String, dynamic>)).join(',\n        ')},')
      ..writeln('      };')
      ..writeln('}')
      ..writeln();
  }
  return out.toString();
}

String _propertyName(String value, {bool response = false}) {
  if (response && value == 'release_date') return 'releaseDateParts';
  if (response && value == 'barcode') return 'barcodeValue';
  if (response && value == 'cover_image_url') return 'coverImageUrlValue';
  return value.replaceAllMapped(
      RegExp(r'_([a-z])'),
      (match) => match.group(1)!.toUpperCase(),
    );
}

String _dartType(Map<String, dynamic> schema) {
  if (schema['anyOf'] case final List<dynamic> choices) {
    final variant = choices.cast<Map<String, dynamic>>().firstWhere(
          (choice) => choice['type'] != 'null',
          orElse: () => <String, dynamic>{},
        );
    final type = _dartType(variant);
    return type.endsWith('?') ? type : '$type?';
  }
  if (schema[r'$ref'] case final String ref) {
    final name = ref.split('/').last;
    if (name == 'PartialDateValue') return 'PartialDate';
    return _classes[name] ?? 'Object';
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
  final variants = schema['anyOf'] as List<dynamic>?;
  if (variants != null) {
    final inner = variants.cast<Map<String, dynamic>>().firstWhere(
          (choice) => choice['type'] != 'null',
          orElse: () => <String, dynamic>{},
        );
    if (inner.isEmpty) return value;
    final expr = _decode(inner, field, false);
    return '($value == null ? null : $expr)';
  }
  if (schema[r'$ref'] case final String ref) {
    final name = ref.split('/').last;
    if (name == 'PartialDateValue') return 'PartialDate.tryParse($value)';
    final className = _classes[name];
    if (className != null) {
      return '$className.fromJson(Map<String, dynamic>.from($value as Map))';
    }
  }
  if (schema['type'] == 'array') {
    final item = schema['items'] as Map<String, dynamic>;
    if (item['type'] == 'string') {
      return '($value as List? ?? const <dynamic>[]).whereType<String>().toList(growable: false)';
    }
    if (item[r'$ref'] case final String ref) {
      final className = _classes[ref.split('/').last];
      if (className != null) return '_musicObjects<$className>($value, $className.fromJson)';
    }
    final itemType = _dartType(item);
    return '$value is List ? $value.whereType<$itemType>().toList() : <$itemType>[]';
  }
  if (schema['format'] == 'date-time') {
    return required
        ? "_musicDateTime($value, '$field')"
        : "($value is String ? DateTime.tryParse($value) : null)";
  }
  final type = schema['type'];
  if (type == 'string') {
    return required ? "_musicString($value, '$field')" : '$value as String?';
  }
  if (type == 'integer') {
    return required ? "_musicInt($value, '$field')" : '($value as num?)?.toInt()';
  }
  if (type == 'number') {
    return required ? "($value as num).toDouble()" : '($value as num?)?.toDouble()';
  }
  if (type == 'boolean') return required ? "$value as bool" : '$value as bool?';
  if (type == 'object') return 'Map<String, dynamic>.from($value as Map)';
  return value;
}

String _encode(String field, String key, Map<String, dynamic> schema) {
  final normalized = schema['anyOf'] is List
      ? '($field == null ? null : ${_encodeValue(field, (schema['anyOf'] as List).cast<Map<String, dynamic>>().firstWhere((item) => item['type'] != 'null'))})'
      : _encodeValue(field, schema);
  return "'$key': $normalized";
}

String _encodeValue(String field, Map<String, dynamic> schema) {
  if (schema['type'] == 'array') {
    final item = schema['items'] as Map<String, dynamic>;
    if (item[r'$ref'] != null) return '$field.map((item) => item.toJson()).toList()';
    return field;
  }
  if (schema[r'$ref'] != null) {
    final name = (schema[r'$ref'] as String).split('/').last;
    if (name == 'PartialDateValue') return '$field?.toJson()';
    return '$field.toJson()';
  }
  if (schema['format'] == 'date-time') return '$field.toIso8601String()';
  return field;
}
