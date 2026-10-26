import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/duplication/kind_duplication_checker.dart';

void main() {
  group('kind duplication fixtures', () {
    late Directory root;

    setUp(() {
      root = Directory.systemTemp.createTempSync('collectarr-duplication-');
    });
    tearDown(() => root.deleteSync(recursive: true));

    void writeKind(String kind, String prefix,
        {String literal = 'No matching values',
        String suffix = 'Values',
        String fileName = 'sample.dart'}) {
      final file =
          File('${root.path}/lib/features/library/kinds/$kind/$fileName')
            ..createSync(recursive: true);
      file.writeAsStringSync(_fixture(prefix, kind, literal, suffix));
    }

    test('finds multiline functions, methods and classes with kind names', () {
      writeKind('game_hardware', 'GameHardware');
      writeKind('game_toy', 'GameToy');

      final clusters = findKindDuplicationClusters(root.path);
      expect(clusters, isNotEmpty);
      final occurrences = clusters.expand((cluster) => cluster.occurrences);
      expect(occurrences.map((item) => item.nodeKind).toSet(),
          containsAll(['function', 'method', 'class']));
      expect(occurrences.map((item) => item.kind).toSet(),
          {'game_hardware', 'game_toy'});
      for (final occurrence in occurrences) {
        final lines = File('${root.path}/${occurrence.path}').readAsLinesSync();
        expect(lines[occurrence.line - 1], contains(occurrence.name));
      }
    });

    test('preserves string literals containing kind names', () {
      writeKind('book', 'Book', literal: 'book');
      writeKind('movie', 'Movie', literal: 'movie');
      expect(findKindDuplicationClusters(root.path), isEmpty);
    });

    test('preserves identifier responsibilities after a kind prefix', () {
      writeKind('book', 'Book', suffix: 'Positive');
      writeKind('movie', 'Movie', suffix: 'Negative');
      expect(findKindDuplicationClusters(root.path), isEmpty);
    });

    test('preserves text between string interpolations', () {
      writeKind('book', 'Book', literal: r'${values}book${values}');
      writeKind('movie', 'Movie', literal: r'${values}movie${values}');
      expect(findKindDuplicationClusters(root.path), isEmpty);
    });

    test('does not replace kind names inside unrelated words', () {
      writeKind('book', 'Book', suffix: 'keeping');
      writeKind('movie', 'Movie', suffix: 'keeping');
      expect(findKindDuplicationClusters(root.path), isEmpty);
    });

    test('ignores whitespace and comments between tokens', () {
      writeKind('book', 'Book');
      writeKind('movie', 'Movie');
      final file =
          File('${root.path}/lib/features/library/kinds/movie/sample.dart');
      file.writeAsStringSync(file
          .readAsStringSync()
          .replaceAll('return ', '// Formatting differs.\n    return   '));
      expect(findKindDuplicationClusters(root.path), isNotEmpty);
    });

    test('requires more than one kind', () {
      writeKind('book', 'Book');
      writeKind('book', 'Book', fileName: 'other.dart');
      expect(findKindDuplicationClusters(root.path), isEmpty);
    });

    test('excludes generated files', () {
      writeKind('book', 'Book');
      writeKind('movie', 'Movie', fileName: 'sample.g.dart');
      expect(findKindDuplicationClusters(root.path), isEmpty);
    });

    test('applies the line threshold to original source bodies', () {
      for (final kind in ['book', 'movie']) {
        final file =
            File('${root.path}/lib/features/library/kinds/$kind/sample.dart')
              ..createSync(recursive: true);
        file.writeAsStringSync('int count() => 123456789;');
      }
      expect(
          findKindDuplicationClusters(root.path, minimumFingerprintLength: 1),
          isEmpty);
      expect(
          findKindDuplicationClusters(root.path,
              minimumBodyLines: 1, minimumFingerprintLength: 1),
          hasLength(1));
    });
  });

  test('kind duplication audit is informational and returns typed clusters',
      () {
    final clusters = findKindDuplicationClusters(Directory.current.path);

    expect(clusters, isA<List<KindDuplicationCluster>>());
    expect(clusters, isNotEmpty);
    for (final cluster in clusters) {
      expect(cluster.kinds.length, greaterThanOrEqualTo(2));
      expect(cluster.fingerprint.length, greaterThanOrEqualTo(180));
      expect(cluster.occurrences, isNotEmpty);
      for (final occurrence in cluster.occurrences) {
        expect(occurrence.path, startsWith('lib/features/library/kinds/'));
        expect(occurrence.path, endsWith('.dart'));
        expect(occurrence.kind, isNotEmpty);
      }
    }
  });
}

String _fixture(String prefix, String kind, String literal, String suffix) =>
    '''
List<int> ${prefix}Select(List<int> values) {
  final $kind$suffix = values.where((value) => value > 0).toList();
  final ${kind}_count = $kind$suffix.length;
  if (${kind}_count == 0) {
    throw StateError('$literal');
  }
  return $kind$suffix.take(${kind}_count).toList();
}

class ${prefix}Reader {
  List<int> select(List<int> values) {
    final $kind$suffix = values.where((value) => value > 0).toList();
    final ${kind}_count = $kind$suffix.length;
    if (${kind}_count == 0) {
      throw StateError('$literal');
    }
    return $kind$suffix.take(${kind}_count).toList();
  }
}
''';
