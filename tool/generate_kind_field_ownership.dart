import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as p;

import 'architecture/kind_field_ownership.dart';

void main() {
  final repoRoot = Directory.current.path;
  final activeKindsFile = File(
    p.join(repoRoot, 'tool', 'core_contracts', 'active-kinds.json'),
  );
  if (!activeKindsFile.existsSync()) {
    stderr.writeln('Missing ${activeKindsFile.path}');
    exitCode = 1;
    return;
  }

  final activeKinds =
      (jsonDecode(activeKindsFile.readAsStringSync()) as Map<String, dynamic>)
          .cast<String, dynamic>()['kinds'];
  if (activeKinds is! List || activeKinds.any((kind) => kind is! String)) {
    stderr.writeln('Invalid active kind list in ${activeKindsFile.path}');
    exitCode = 1;
    return;
  }

  final kinds = <String, Object?>{};
  for (final kind in activeKinds.cast<String>()..sort()) {
    kinds[kind] = _buildKindManifest(repoRoot, kind);
  }

  final manifest = <String, Object?>{
    'formatVersion': 1,
    'policy': <String, Object?>{
      'databaseSource': 'Drift Table column getters',
      'domainAliases': 'Kind-local Drift mapper named arguments',
      'workspaceSource': 'Kind-owned LibraryFieldId declarations',
      'generatedAt': null,
    },
    'kinds': kinds,
  };

  final output = File(p.joinAll([
    repoRoot,
    ...kindFieldOwnershipManifestPath.split('/'),
  ]));
  output.parent.createSync(recursive: true);
  final manifestJson = const JsonEncoder.withIndent('  ').convert(manifest);
  output.writeAsStringSync('$manifestJson\n');

  final fieldCount = kinds.values
      .whereType<Map<String, Object?>>()
      .fold<int>(0, (sum, kind) => sum + (kind['fields'] as Map).length);
  stdout.writeln(
    'Generated kind field ownership for ${kinds.length} kinds '
    '($fieldCount field records): ${p.relative(output.path, from: repoRoot)}',
  );
}

Map<String, Object?> _buildKindManifest(String repoRoot, String kind) {
  final kindRoot = p.join(
    repoRoot,
    'lib',
    'features',
    'library',
    'kinds',
    kind,
  );
  final tablesRoot = Directory(p.join(kindRoot, 'data', 'local'));
  final tableFiles = _dartFiles(tablesRoot)
      .where((file) => p.basename(file.path).endsWith('_tables.dart'))
      .toList()
    ..sort((left, right) => left.path.compareTo(right.path));
  if (tableFiles.isEmpty) {
    throw StateError('No Drift *_tables.dart found for kind "$kind".');
  }

  final tables = <_TableSchema>[];
  for (final file in tableFiles) {
    final relativePath = _relative(repoRoot, file.path);
    final result = parseString(
      content: file.readAsStringSync(),
      path: file.path,
      throwIfDiagnostics: false,
    );
    final collector = _TableCollector(relativePath);
    result.unit.accept(collector);
    tables.addAll(collector.tables);
  }
  if (tables.isEmpty) {
    throw StateError('No Drift Table declarations found for kind "$kind".');
  }

  final mapperFiles = _dartFiles(Directory(kindRoot))
      .where((file) => p.basename(file.path).contains('local_mapper.dart'))
      .toList()
    ..sort((left, right) => left.path.compareTo(right.path));
  final columns = <String>{
    for (final table in tables)
      for (final column in table.columns) column.propertyName,
  };
  final mapperAliases = <String, Set<String>>{};
  for (final file in mapperFiles) {
    final result = parseString(
      content: file.readAsStringSync(),
      path: file.path,
      throwIfDiagnostics: false,
    );
    result.unit.accept(_MapperAliasCollector(columns, mapperAliases));
  }

  final fields = <String, _FieldOwnership>{};
  final canonicalFieldNames = <String, String>{};
  for (final table in tables) {
    for (final column in table.columns) {
      final aliases = <String>{
        ...mapperAliases[column.propertyName] ?? const {}
      };
      final jsonAlias = _jsonColumnAlias(column.propertyName);
      if (jsonAlias != null) aliases.add(jsonAlias);
      if (aliases.isEmpty) aliases.add(column.propertyName);

      final sortedAliases = aliases.toList()..sort();
      final canonical = jsonAlias != null && aliases.contains(jsonAlias)
          ? jsonAlias
          : sortedAliases.first;
      final fieldName = canonicalFieldNames.putIfAbsent(
        canonical.toLowerCase(),
        () => canonical,
      );
      final field = fields.putIfAbsent(fieldName, _FieldOwnership.new);
      field.databaseColumns.add(column.propertyName);
      field.databaseTables.add(table.name);
      field.sqlNames.add(column.sqlName);
      field.symbols.addAll(aliases);
      field.symbols.add(column.propertyName);
      field.symbols.add(column.sqlName);
      for (final alias in aliases) {
        field.symbols.add(_toSnakeCase(alias));
      }
    }
  }

  final workspaceIdFiles = _dartFiles(Directory(kindRoot)).where((file) {
    final relative = _relative(repoRoot, file.path);
    return relative.contains('/workspace/') &&
        p.basename(file.path).endsWith('_ids.dart');
  }).toList()
    ..sort((left, right) => left.path.compareTo(right.path));
  final fieldIdPattern = RegExp(
    r"""LibraryFieldId(?:<[^>]+>)?\s*\(\s*['"]([^'"]+)['"]""",
  );
  final seenIds = <String>{};
  for (final file in workspaceIdFiles) {
    final content = file.readAsStringSync();
    for (final match in fieldIdPattern.allMatches(content)) {
      final fieldId = match.group(1)!;
      if (!fieldId.startsWith('$kind.')) continue;
      if (!seenIds.add(fieldId)) continue;
      final suffix = fieldId.substring(kind.length + 1);
      final symbol = _toCamelCase(suffix);
      final fieldName = canonicalFieldNames.putIfAbsent(
        symbol.toLowerCase(),
        () => symbol,
      );
      final field = fields.putIfAbsent(fieldName, _FieldOwnership.new);
      field.workspaceFieldIds.add(fieldId);
      field.symbols
        ..add(symbol)
        ..add(suffix);
    }
  }

  final serializedFields = <String, Object?>{};
  final sortedFieldNames = fields.keys.toList()..sort();
  for (final fieldName in sortedFieldNames) {
    final field = fields[fieldName]!;
    serializedFields[fieldName] = field.toJson();
  }

  return <String, Object?>{
    'tables': [
      for (final table in tables)
        <String, Object?>{
          'name': table.name,
          'source': table.sourcePath,
          'columns': [
            for (final column in table.columns)
              <String, String>{
                'property': column.propertyName,
                'sqlName': column.sqlName,
              },
          ],
        },
    ],
    'workspaceIdSources':
        workspaceIdFiles.map((file) => _relative(repoRoot, file.path)).toList(),
    'mapperSources':
        mapperFiles.map((file) => _relative(repoRoot, file.path)).toList(),
    'fields': serializedFields,
  };
}

class _TableCollector extends RecursiveAstVisitor<void> {
  _TableCollector(this.sourcePath);

  final String sourcePath;
  final List<_TableSchema> tables = [];

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node.extendsClause?.superclass.toSource() == 'Table') {
      final columns = <_ColumnSchema>[];
      for (final member in node.body.members.whereType<MethodDeclaration>()) {
        final returnType = member.returnType?.toSource() ?? '';
        if (!member.isGetter || !returnType.endsWith('Column')) continue;
        final property = member.name.lexeme;
        final namedMatch = RegExp(
          r"""\.named\(\s*['"]([^'"]+)['"]\s*\)""",
        ).firstMatch(member.body.toSource());
        columns.add(_ColumnSchema(
          propertyName: property,
          sqlName: namedMatch?.group(1) ?? _toSnakeCase(property),
        ));
      }
      tables.add(_TableSchema(
        name: node.namePart.toSource(),
        sourcePath: sourcePath,
        columns: columns,
      ));
    }
    super.visitClassDeclaration(node);
  }
}

class _MapperAliasCollector extends RecursiveAstVisitor<void> {
  _MapperAliasCollector(this.databaseColumns, this.aliases);

  final Set<String> databaseColumns;
  final Map<String, Set<String>> aliases;

  @override
  void visitNamedExpression(NamedExpression node) {
    final namedArgument =
        RegExp(r'^([A-Za-z_]\w*)').firstMatch(node.name.toSource());
    if (namedArgument != null) {
      final name = namedArgument.group(1)!;
      final propertyCollector = _PropertyNameCollector();
      node.expression.accept(propertyCollector);
      final properties = propertyCollector.names;

      if (databaseColumns.contains(name)) {
        aliases.putIfAbsent(name, () => <String>{}).addAll(
              properties.where((property) => property != name),
            );
      }
      for (final property in properties.where(databaseColumns.contains)) {
        if (property != name) {
          aliases.putIfAbsent(property, () => <String>{}).add(name);
        }
      }
    }
    super.visitNamedExpression(node);
  }
}

class _PropertyNameCollector extends RecursiveAstVisitor<void> {
  final Set<String> names = {};

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (node.target is SimpleIdentifier) {
      names.add(node.propertyName.name);
    }
    super.visitPropertyAccess(node);
  }
}

class _ColumnSchema {
  const _ColumnSchema({required this.propertyName, required this.sqlName});

  final String propertyName;
  final String sqlName;
}

class _TableSchema {
  const _TableSchema({
    required this.name,
    required this.sourcePath,
    required this.columns,
  });

  final String name;
  final String sourcePath;
  final List<_ColumnSchema> columns;
}

class _FieldOwnership {
  final Set<String> databaseColumns = {};
  final Set<String> databaseTables = {};
  final Set<String> sqlNames = {};
  final Set<String> symbols = {};
  final Set<String> workspaceFieldIds = {};

  Map<String, Object?> toJson() => <String, Object?>{
        'symbols': symbols.toList()..sort(),
        'databaseColumns': databaseColumns.toList()..sort(),
        'databaseTables': databaseTables.toList()..sort(),
        'sqlNames': sqlNames.toList()..sort(),
        'workspaceFieldIds': workspaceFieldIds.toList()..sort(),
      };
}

Iterable<File> _dartFiles(Directory directory) sync* {
  if (!directory.existsSync()) return;
  for (final entity
      in directory.listSync(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.dart')) yield entity;
  }
}

String _relative(String repoRoot, String path) =>
    p.relative(path, from: repoRoot).replaceAll('\\', '/');

String? _jsonColumnAlias(String name) {
  if (!name.endsWith('Json')) return null;
  if (const {'rawPayloadJson', 'targetRefJson', 'catalogRefJson'}
      .contains(name)) {
    return null;
  }
  return name.substring(0, name.length - 'Json'.length);
}

String _toSnakeCase(String value) =>
    value.replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (match) {
      return '${match.group(1)}_${match.group(2)!.toLowerCase()}';
    }).toLowerCase();

String _toCamelCase(String value) {
  final parts = value.split(RegExp(r'[_\-\s]+'));
  if (parts.isEmpty) return value;
  return parts.first +
      parts.skip(1).map((part) {
        if (part.isEmpty) return '';
        return '${part[0].toUpperCase()}${part.substring(1)}';
      }).join();
}
