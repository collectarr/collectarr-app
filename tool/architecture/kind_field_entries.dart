import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const kindFieldEntryPolicyManifestPath =
    'tool/architecture/generated/kind-field-entries.json';

final _fieldSymbolsByRepo = <String, Set<String>>{};

Set<String> loadKindEntryFieldSymbols(String repoRoot) => _fieldSymbolsByRepo
    .putIfAbsent(repoRoot, () => _readKindEntryFieldSymbols(repoRoot));

Set<String> _readKindEntryFieldSymbols(String repoRoot) {
  final file = File(p.joinAll([
    repoRoot,
    ...kindFieldEntryPolicyManifestPath.split('/'),
  ]));
  if (!file.existsSync()) {
    throw StateError(
      'Missing generated kind field entries manifest at '
      '$kindFieldEntryPolicyManifestPath. Run '
      '`dart run tool/generate_kind_field_entries.dart`.',
    );
  }

  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic> || decoded['kinds'] is! Map) {
    throw FormatException(
      'Invalid kind field entries manifest: ${file.path}',
    );
  }

  final symbols = <String>{};
  final kinds = decoded['kinds'] as Map;
  for (final kindEntry in kinds.entries) {
    final kind = kindEntry.value;
    if (kind is! Map || kind['fields'] is! Map) continue;
    final fields = kind['fields'] as Map;
    for (final fieldEntry in fields.entries) {
      symbols.add(fieldEntry.key.toString());
      final field = fieldEntry.value;
      if (field is Map && field['symbols'] is List) {
        symbols.addAll((field['symbols'] as List).whereType<String>());
      }
    }
  }
  return Set<String>.unmodifiable(symbols);
}
