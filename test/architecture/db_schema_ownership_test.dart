import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _tableDeclarationPattern = RegExp(
  r'class\s+(\w+)\s+extends\s+Table\b',
);

const _kindNames = [
  'anime',
  'boardgame',
  'book',
  'comic',
  'game',
  'manga',
  'movie',
  'music',
  'tv',
];

List<File> _dartFiles(String path) {
  return Directory(path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList(growable: false);
}

List<String> _tableNames(String source) {
  return [
    for (final match in _tableDeclarationPattern.allMatches(source))
      match.group(1)!,
  ];
}

String _repoPath(String path) => path.replaceAll(r'\', '/');

void main() {
  test('every kind-specific Drift table is declared in its kind local module',
      () {
    final kindsRoot = 'lib/features/library/kinds';
    final misplaced = <String>[];
    final declarationsByKind = <String, List<String>>{};

    for (final file in _dartFiles(kindsRoot)) {
      final path = _repoPath(file.path);
      final names = _tableNames(file.readAsStringSync());
      if (names.isEmpty) continue;

      final owner = RegExp(
        r'lib/features/library/kinds/([^/]+)/data/local/[^/]+\.dart$',
      ).firstMatch(path)?.group(1);
      if (owner == null || !_kindNames.contains(owner)) {
        misplaced.add('$path: ${names.join(', ')}');
        continue;
      }
      declarationsByKind.putIfAbsent(owner, () => []).addAll(names);
    }

    expect(misplaced, isEmpty,
        reason: 'Kind table declarations must stay beside their owner kind.');
    expect(declarationsByKind.keys, containsAll(_kindNames));
    for (final kind in _kindNames) {
      expect(declarationsByKind[kind], isNotEmpty, reason: kind);
    }
  });

  test('LocalDatabase is only the Drift composition root for kind tables', () {
    final databasePath = _repoPath('lib/core/db/local_database.dart');
    final databaseSource = File(databasePath).readAsStringSync();
    expect(_tableNames(databaseSource), isEmpty);

    final kindTableFiles = <File>[];
    for (final kind in _kindNames) {
      final path = 'lib/features/library/kinds/$kind/data/local';
      final files = _dartFiles(path)
          .where((file) => _tableNames(file.readAsStringSync()).isNotEmpty)
          .toList(growable: false);
      expect(files, hasLength(1), reason: '$kind should have one table module');
      kindTableFiles.addAll(files);
      expect(
        databaseSource,
        contains('features/library/kinds/$kind/data/local/'),
        reason: 'LocalDatabase must compose $kind tables explicitly',
      );
    }

    for (final file in kindTableFiles) {
      for (final name in _tableNames(file.readAsStringSync())) {
        expect(databaseSource, contains(name), reason: '$name is not composed');
      }
    }
  });

  test('core DB table declarations are limited to universal tables', () {
    final coreDbFiles = _dartFiles('lib/core/db');
    final declarations = <String, List<String>>{};
    for (final file in coreDbFiles) {
      final names = _tableNames(file.readAsStringSync());
      if (names.isNotEmpty) {
        declarations[_repoPath(file.path)] = names;
      }
    }

    expect(declarations.keys, {'lib/core/db/universal_local_tables.dart'});
    expect(declarations.values.single, hasLength(20));
  });
}
