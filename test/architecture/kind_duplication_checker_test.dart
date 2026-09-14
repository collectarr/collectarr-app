import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/duplication/kind_duplication_checker.dart';

void main() {
  test('kind duplication audit is informational and returns typed clusters',
      () {
    final clusters = findKindDuplicationClusters(Directory.current.path);

    expect(clusters, isA<List<KindDuplicationCluster>>());
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
