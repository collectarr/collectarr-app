import 'dart:convert';
import 'dart:io';

/// Reports summed test-body durations, not exclusive directory wall time.
void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln(
        'dart run tool/testing/report_test_timings.dart <JSONL results>');
    exitCode = 2;
    return;
  }
  final suites = <int, String>{};
  final starts = <int, (int, int)>{};
  final totals = <String, int>{};
  for (final line in File(args.single).readAsLinesSync()) {
    if (!line.trimLeft().startsWith('{')) continue;
    final event = jsonDecode(line) as Map<String, dynamic>;
    switch (event['type']) {
      case 'suite':
        final suite = event['suite'] as Map<String, dynamic>;
        suites[suite['id'] as int] = suite['path'] as String;
      case 'testStart':
        final test = event['test'] as Map<String, dynamic>;
        if ((test['name'] as String).startsWith('loading ')) continue;
        starts[test['id'] as int] =
            (test['suiteID'] as int, event['time'] as int);
      case 'testDone':
        final start = starts.remove(event['testID']);
        if (start == null || event['skipped'] == true) continue;
        final path = suites[start.$1];
        if (path == null) continue;
        final normalized = path.replaceAll('\\', '/');
        final marker = normalized.indexOf('/test/');
        final relative =
            marker < 0 ? normalized : normalized.substring(marker + 1);
        totals.update(
            relative, (value) => value + (event['time'] as int) - start.$2,
            ifAbsent: () => (event['time'] as int) - start.$2);
    }
  }
  if (totals.isEmpty) {
    throw StateError('No completed test durations found in ${args.single}');
  }
  final sorted = totals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final directories = <String, int>{};
  for (final entry in sorted) {
    final directory = entry.key.substring(0, entry.key.lastIndexOf('/'));
    directories.update(directory, (v) => v + entry.value,
        ifAbsent: () => entry.value);
  }
  final orderedDirectories = directories.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final output = File('build/test-timings.json');
  output.parent.createSync(recursive: true);
  output.writeAsStringSync(const JsonEncoder.withIndent('  ').convert({
    'measurement': 'Summed test-body milliseconds; concurrent cases overlap. '
        'Excludes suite compilation/loading. Informational, not a timing gate.',
    'files': Map.fromEntries(sorted),
    'directories': Map.fromEntries(orderedDirectories),
  }));
  stdout.writeln('Top 20 files by summed test-body duration:');
  for (final entry in sorted.take(20)) {
    stdout.writeln('${entry.value} ms  ${entry.key}');
  }
}
