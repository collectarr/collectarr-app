import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const kindFieldOwnershipManifestPath =
    'tool/architecture/generated/kind-field-ownership.json';

final _fieldSymbolsByRepo = <String, Set<String>>{};

Set<String> loadKindOwnedFieldSymbols(String repoRoot) => _fieldSymbolsByRepo
    .putIfAbsent(repoRoot, () => _readKindOwnedFieldSymbols(repoRoot));

Set<String> _readKindOwnedFieldSymbols(String repoRoot) {
  final file = File(p.joinAll([
    repoRoot,
    ...kindFieldOwnershipManifestPath.split('/'),
  ]));
  if (!file.existsSync()) {
    throw StateError(
      'Missing generated kind field ownership manifest at '
      '$kindFieldOwnershipManifestPath. Run '
      '`dart run tool/generate_kind_field_ownership.dart`.',
    );
  }

  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic> || decoded['kinds'] is! Map) {
    throw FormatException(
      'Invalid kind field ownership manifest: ${file.path}',
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
