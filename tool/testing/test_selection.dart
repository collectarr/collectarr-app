/// Select kind-owned files while always retaining shared correctness checks.
class TestSelection {
  TestSelection({
    required Iterable<String> files,
    required Set<String> knownKinds,
    required Set<String> releasedKinds,
    String kinds = 'released',
    Set<String> excludedKinds = const {},
  }) {
    selectedKinds = switch (kinds) {
      'released' => Set.of(releasedKinds),
      'all' => Set.of(knownKinds),
      _ => kinds.split(',').map((kind) => kind.trim()).toSet(),
    };
    final unknown = {...selectedKinds, ...excludedKinds}.difference(knownKinds);
    if (unknown.isNotEmpty) {
      throw ArgumentError('Unknown kinds: ${unknown.join(', ')}');
    }
    selectedKinds.removeAll(excludedKinds);
    allFiles = files.map((file) => file.replaceAll('\\', '/')).toList()..sort();
    selectedFiles = [];
    excludedFiles = [];
    for (final file in allFiles) {
      final segments = file.split('/');
      final index = segments.indexOf('kinds');
      final kind = index >= 0 && index + 1 < segments.length
          ? segments[index + 1]
          : null;
      if (kind != null &&
          knownKinds.contains(kind) &&
          !selectedKinds.contains(kind)) {
        excludedFiles.add(file);
      } else {
        selectedFiles.add(file);
      }
    }
  }

  late final Set<String> selectedKinds;
  late final List<String> allFiles;
  late final List<String> selectedFiles;
  late final List<String> excludedFiles;

  /// Compact complete selected subtrees to avoid Windows command-line limits.
  List<String> get paths {
    final selected = selectedFiles.toSet();
    final result = <String>[];
    void visit(String prefix) {
      final descendants = allFiles.where((file) => file.startsWith('$prefix/'));
      if (descendants.every(selected.contains)) {
        if (descendants.isNotEmpty) result.add(prefix);
        return;
      }
      final children = descendants
          .map((file) => file.substring(prefix.length + 1).split('/').first)
          .toSet()
          .toList()
        ..sort();
      for (final child in children) {
        final path = '$prefix/$child';
        if (allFiles.contains(path)) {
          if (selected.contains(path)) result.add(path);
        } else {
          visit(path);
        }
      }
    }

    visit('test');
    return result;
  }
}
