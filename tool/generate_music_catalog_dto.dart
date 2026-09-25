import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const _contractPath = 'tool/core_contracts/music-catalog-v1.json';
const _manifestPath = 'tool/core_contracts/contract-manifest.json';
const _outputPath = 'lib/core/api/generated/music_catalog.models.g.dart';

const _classes = <String, String>{
  'MusicArtistCreditResponse': 'MusicArtistCreditDto',
  'MusicContributorResponse': 'MusicContributorDto',
  'MusicIdentifierResponse': 'MusicIdentifierDto',
  'MusicMediumV1Response': 'MusicMediumDto',
  'MusicReleaseGroupV1Response': 'MusicReleaseGroupDto',
  'MusicReleaseLabelResponse': 'MusicReleaseLabelDto',
  'MusicReleaseSummaryV1Response': 'MusicReleaseSummaryDto',
  'MusicReleaseV1Response': 'MusicReleaseDto',
  'MusicTrackV1Response': 'MusicTrackDto',
};

const _responseClasses = <String>{
  'MusicMediumDto',
  'MusicReleaseGroupDto',
  'MusicReleaseDto',
  'MusicTrackDto',
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

  final contract =
      jsonDecode(utf8.decode(contractBytes)) as Map<String, dynamic>;
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
    ..writeln('String _musicRequiredString(Object? value, String field) {')
    ..writeln("  if (value is String) return value;")
    ..writeln(
        "  throw FormatException('Missing or invalid Music field: \$field');")
    ..writeln('}')
    ..writeln()
    ..writeln('String? _musicOptionalString(Object? value) =>')
    ..writeln('    value is String ? value : null;')
    ..writeln()
    ..writeln('int? _musicOptionalInt(Object? value) =>')
    ..writeln('    value is int ? value : value is num ? value.toInt() : null;')
    ..writeln()
    ..writeln('int _musicRequiredInt(Object? value, String field) {')
    ..writeln('  final parsed = _musicOptionalInt(value);')
    ..writeln('  if (parsed != null) return parsed;')
    ..writeln(
        "  throw FormatException('Missing or invalid Music field: \$field');")
    ..writeln('}')
    ..writeln()
    ..writeln('bool? _musicOptionalBool(Object? value) =>')
    ..writeln('    value is bool ? value : null;')
    ..writeln()
    ..writeln('bool _musicRequiredBool(Object? value, String field) {')
    ..writeln('  final parsed = _musicOptionalBool(value);')
    ..writeln('  if (parsed != null) return parsed;')
    ..writeln(
        "  throw FormatException('Missing or invalid Music field: \$field');")
    ..writeln('}')
    ..writeln()
    ..writeln('PartialDate? _musicOptionalPartialDate(Object? value) =>')
    ..writeln('    PartialDate.tryParse(value);')
    ..writeln()
    ..writeln('List<String> _musicStringList(Object? value) => value is List')
    ..writeln('    ? [for (final entry in value) if (entry is String) entry]')
    ..writeln('    : const <String>[];')
    ..writeln()
    ..writeln('List<Map<String, dynamic>> _musicMapList(Object? value) =>')
    ..writeln('    value is List')
    ..writeln('        ? [')
    ..writeln('            for (final entry in value)')
    ..writeln(
        '              if (entry is Map) Map<String, dynamic>.from(entry),')
    ..writeln('          ]')
    ..writeln('        : const <Map<String, dynamic>>[];')
    ..writeln()
    ..writeln('List<T> _musicObjectList<T>(')
    ..writeln('  Object? value,')
    ..writeln('  T Function(Map<String, dynamic>) decode,')
    ..writeln(') => value is List')
    ..writeln('    ? [')
    ..writeln('        for (final entry in value)')
    ..writeln(
        '          if (entry is Map) decode(Map<String, dynamic>.from(entry)),')
    ..writeln('      ]')
    ..writeln('    : <T>[];')
    ..writeln();

  for (final entry in _classes.entries) {
    final schemaName = entry.key;
    final className = entry.value;
    final schema = defs[schemaName] as Map<String, dynamic>;
    final properties = schema['properties'] as Map<String, dynamic>;
    final required = (schema['required'] as List<dynamic>? ?? const [])
        .cast<String>()
        .toSet();
    final isResponse = _responseClasses.contains(className);
    final extendsResponse = isResponse ? ' extends TypedMetadataResponse' : '';
    out.writeln('class $className$extendsResponse {');
    if (isResponse) {
      out.writeln('  const $className._(super.raw, {');
    } else {
      out.writeln('  const $className({');
    }
    for (final property in properties.entries) {
      final dartName = _dartProperty(property.key, response: isResponse);
      out.writeln('    required this.$dartName,');
    }
    out.writeln('  });');
    out.writeln();

    if (isResponse) {
      out.writeln('  @override');
      out.writeln('  final String id;');
    }
    for (final property in properties.entries) {
      final dartName = _dartProperty(property.key, response: isResponse);
      if (isResponse && dartName == 'id') continue;
      final type = _dartType(
        property.value as Map<String, dynamic>,
        jsonName: property.key,
      );
      final override = isResponse && dartName == 'kind' ? '  @override\n' : '';
      out.write(override);
      out.writeln('  final $type $dartName;');
    }
    if (isResponse) {
      out.writeln();
      out.writeln('  @override');
      final titleType = _dartType(
        properties['title'] as Map<String, dynamic>,
        jsonName: 'title',
      );
      out.writeln(titleType.endsWith('?')
          ? "  String get title => titleValue ?? 'Medium';"
          : '  String get title => titleValue;');
      out.writeln('  @override');
      out.writeln('  DateTime? get releaseDate =>');
      final dateField = _datePropertyFor(schemaName);
      out.writeln(dateField.isEmpty
          ? '      null;'
          : '      ($dateField)?.asDateTime;');
      out.writeln('  @override');
      out.writeln('  String? get coverImageUrl =>');
      out.writeln(properties.containsKey('cover_image_url')
          ? '      coverImageUrlValue;'
          : '      null;');
      out.writeln('  @override');
      out.writeln('  String? get thumbnailImageUrl => coverImageUrl;');
      out.writeln('  @override');
      out.writeln('  String? get barcode =>');
      out.writeln(properties.containsKey('barcode')
          ? '      barcodeValue;'
          : '      null;');
      if (!properties.containsKey('kind')) {
        out.writeln('  @override');
        out.writeln("  String? get kind => 'music';");
      }
    }
    out.writeln();
    out.writeln('  factory $className.fromJson(Map<String, dynamic> json) {');
    if (isResponse) {
      out.writeln('    return $className._(');
      out.writeln('      Map<String, dynamic>.from(json),');
    } else {
      out.writeln('    return $className(');
    }
    for (final property in properties.entries) {
      final key = property.key;
      final dartName = _dartProperty(key, response: isResponse);
      final isRequired = required.contains(key);
      out.writeln(
        '      $dartName: ${_decodeExpression(property.value as Map<String, dynamic>, key, isRequired)},',
      );
    }
    out.writeln('    );');
    out.writeln('  }');
    out.writeln('}');
    out.writeln();
  }
  return out.toString();
}

String _dartProperty(String jsonName, {bool response = false}) {
  if (response && jsonName == 'title') return 'titleValue';
  if (jsonName == 'release_date') return 'releaseDateValue';
  if (jsonName == 'original_release_date') return 'originalReleaseDateValue';
  if (jsonName == 'recording_date') return 'recordingDateValue';
  if (jsonName == 'cover_image_url') return 'coverImageUrlValue';
  if (jsonName == 'barcode') return 'barcodeValue';
  return jsonName.replaceAllMapped(
    RegExp(r'_([a-z])'),
    (match) => match.group(1)!.toUpperCase(),
  );
}

String _datePropertyFor(String schemaName) => switch (schemaName) {
      'MusicReleaseGroupV1Response' =>
        'originalReleaseDateParts ?? originalReleaseDateValue',
      'MusicReleaseV1Response' => 'releaseDateParts ?? releaseDateValue',
      _ => '',
    };

String _dartType(Map<String, dynamic> schema, {String? jsonName}) {
  final alternatives = schema['anyOf'] as List<dynamic>?;
  if (alternatives != null) {
    final nonNull = alternatives
        .cast<Map<String, dynamic>>()
        .where((value) => value['type'] != 'null')
        .toList();
    if (nonNull.isEmpty) return 'Object?';
    final inner = _dartType(nonNull.first, jsonName: jsonName);
    return inner.endsWith('?') ? inner : '$inner?';
  }
  if (schema[r'$ref'] case final String ref) {
    final name = ref.split('/').last;
    if (name == 'PartialDateValue') return 'PartialDate';
    if (name == 'ExternalProvider' || name == 'ItemKind') return 'String';
    return _classes[name] ?? 'Object';
  }
  if (schema['type'] == 'array') {
    final item = schema['items'] as Map<String, dynamic>;
    if (item['type'] == 'string') return 'List<String>';
    if (item['type'] == 'object') return 'List<Map<String, dynamic>>';
    final type = _dartType(item);
    return 'List<$type>';
  }
  return switch (schema['type']) {
    'string' => _isDateSchema(schema) || _isDateProperty(jsonName)
        ? 'PartialDate'
        : 'String',
    'integer' => 'int',
    'number' => 'double',
    'boolean' => 'bool',
    'object' => 'Map<String, dynamic>',
    _ => 'Object?',
  };
}

bool _isDateSchema(Map<String, dynamic> schema) =>
    schema['format'] == 'date' || schema['format'] == 'date-time';

bool _isDateProperty(String? name) =>
    name == 'release_date' ||
    name == 'original_release_date' ||
    name == 'recording_date';

String _decodeExpression(
    Map<String, dynamic> schema, String field, bool required,
    {bool nullable = false}) {
  final alternatives = schema['anyOf'] as List<dynamic>?;
  if (alternatives != null) {
    final nonNull = alternatives
        .cast<Map<String, dynamic>>()
        .where((value) => value['type'] != 'null')
        .toList();
    if (nonNull.isEmpty) return "json['$field']";
    return _decodeExpression(nonNull.first, field, false, nullable: true);
  }
  final value = "json['$field']";
  if (schema.containsKey('default')) {
    final defaultValue = schema['default'];
    if (defaultValue is String) {
      return "_musicOptionalString($value) ?? '${defaultValue.replaceAll("'", "\\'")}'";
    }
    if (defaultValue is bool) {
      return '_musicOptionalBool($value) ?? $defaultValue';
    }
    if (defaultValue is num) {
      return '_musicOptionalInt($value) ?? $defaultValue';
    }
  }
  if (schema[r'$ref'] case final String ref) {
    final name = ref.split('/').last;
    if (name == 'PartialDateValue') {
      return '_musicOptionalPartialDate($value)';
    }
    if (name == 'ExternalProvider' || name == 'ItemKind') {
      return nullable
          ? '_musicOptionalString($value)'
          : "_musicRequiredString($value, '$field')";
    }
    final className = _classes[name];
    if (className == null) return value;
    return "_musicObjectList<$className>($value, $className.fromJson)";
  }
  if (schema['type'] == 'array') {
    final item = schema['items'] as Map<String, dynamic>;
    if (item['type'] == 'string') return '_musicStringList($value)';
    if (item['type'] == 'object') return '_musicMapList($value)';
    if (item[r'$ref'] case final String ref) {
      final className = _classes[ref.split('/').last];
      if (className != null) {
        return '_musicObjectList<$className>($value, $className.fromJson)';
      }
    }
    return '<${_dartType(item)}>[$value]';
  }
  if (schema['type'] == 'object') return value;
  if (schema['type'] == 'string') {
    if (_isDateSchema(schema) || _isDateProperty(field)) {
      return '_musicOptionalPartialDate($value)';
    }
    return !nullable && (required || schema['nullable'] != true)
        ? "_musicRequiredString($value, '$field')"
        : '_musicOptionalString($value)';
  }
  if (schema['type'] == 'integer') {
    return !nullable && (required || schema['nullable'] != true)
        ? "_musicRequiredInt($value, '$field')"
        : '_musicOptionalInt($value)';
  }
  if (schema['type'] == 'boolean') {
    return !nullable && (required || schema['nullable'] != true)
        ? "_musicRequiredBool($value, '$field')"
        : '_musicOptionalBool($value)';
  }
  return value;
}
