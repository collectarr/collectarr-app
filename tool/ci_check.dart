import 'dart:io';

/// Runs the same checks as CI, so a push does not wait for CI to find them.
///
/// ```sh
/// dart run tool/ci_check.dart                 # checks and tests
/// dart run tool/ci_check.dart checks          # one stage
/// dart run tool/ci_check.dart --integration   # also the native flows
/// ```
///
/// CI runs each stage as its own job through this script.
Future<void> main(List<String> args) async {
  if (args.contains('--help')) {
    stdout.writeln('dart run tool/ci_check.dart [checks] [tests] [integration] '
        '[--integration] [--report] [--device <id>]');
    return;
  }
  final named = args.where(_stages.containsKey).toList();
  final stages = named.isNotEmpty
      ? named
      : ['checks', 'tests', if (args.contains('--integration')) 'integration'];
  final options = _Options(
    report: args.contains('--report'),
    device: _valueAfter(args, '--device') ?? _localDevice(),
  );
  final failures = <String>[];
  for (final stage in stages) {
    stdout.writeln('\n== $stage');
    failures.addAll(await _stages[stage]!(options));
  }
  stdout.writeln();
  if (failures.isEmpty) {
    stdout.writeln('All CI checks passed: ${stages.join(', ')}.');
    return;
  }
  stderr.writeln('Failed:\n${failures.map((f) => '  - $f').join('\n')}');
  exitCode = 1;
}

final class _Options {
  const _Options({required this.report, required this.device});

  /// Writes the JSON test results and timings CI keeps as artifacts.
  final bool report;
  final String device;
}

typedef _Stage = Future<List<String>> Function(_Options options);

final _stages = <String, _Stage>{
  'checks': (_) => _runAll([
        _Step('Format', 'dart',
            ['format', '--output=none', '--set-exit-if-changed', '.']),
        _Step('Kind registries', 'dart',
            ['run', 'tool/generate_kind_registries.dart']),
        _Step('Kind field entries', 'dart',
            ['run', 'tool/generate_kind_field_entries.dart']),
        _Step('Music catalog contract', 'dart',
            ['run', 'tool/check_music_catalog_contract.dart']),
        _Step('Catalog Item v1 fields', 'dart',
            ['run', 'tool/generate_catalog_item_v1_fields.dart', '--check']),
        _Step('Drift code', 'dart', ['run', 'build_runner', 'build']),
        _Step('Generated files are clean', 'git', ['diff', '--exit-code']),
        _Step('Library kind boundaries', 'dart',
            ['run', 'tool/check_library_kind_boundaries.dart']),
        _Step('Analyze', _flutter,
            ['analyze', '--fatal-warnings', '--fatal-infos']),
      ]),
  'tests': (options) async {
    if (!options.report) {
      return _runAll([
        _Step('Unit and widget tests', 'dart', ['run', 'tool/run_tests.dart']),
      ]);
    }
    Directory('build').createSync(recursive: true);
    return _runAll([
      _Step(
        'Unit and widget tests',
        'dart',
        [
          'run',
          'tool/run_tests.dart',
          '--',
          '--coverage',
          '--reporter',
          'json'
        ],
        stdoutFile: 'build/test-results.jsonl',
      ),
      _Step('Test timings', 'dart', [
        'run',
        'tool/testing/report_test_timings.dart',
        'build/test-results.jsonl',
      ]),
    ]);
  },
  'integration': (options) => _runAll([
        for (final flow
            in Directory('integration_test')
                .listSync()
                .whereType<File>()
                .map((file) => file.path.replaceAll(r'\', '/'))
                .where((path) => path.endsWith('_test.dart'))
                .toList()
              ..sort())
          _Step('Integration $flow', _flutter,
              ['test', flow, '-d', options.device]),
      ]),
};

/// Runs every step and reports all failures instead of stopping at the first.
Future<List<String>> _runAll(List<_Step> steps) async {
  final failures = <String>[];
  for (final step in steps) {
    stdout.writeln('-- ${step.name}');
    final process = await Process.start(step.executable, step.arguments,
        runInShell: Platform.isWindows);
    final sink =
        step.stdoutFile == null ? null : File(step.stdoutFile!).openWrite();
    await Future.wait([
      process.stdout.forEach((chunk) {
        sink?.add(chunk);
        stdout.add(chunk);
      }),
      process.stderr.forEach(stderr.add),
    ]);
    await sink?.close();
    if (await process.exitCode != 0) failures.add(step.name);
  }
  return failures;
}

final class _Step {
  const _Step(this.name, this.executable, this.arguments, {this.stdoutFile});

  final String name;
  final String executable;
  final List<String> arguments;
  final String? stdoutFile;
}

const _flutter = 'flutter';

String? _valueAfter(List<String> args, String flag) {
  final index = args.indexOf(flag);
  return index < 0 || index + 1 >= args.length ? null : args[index + 1];
}

String _localDevice() => Platform.isWindows
    ? 'windows'
    : Platform.isMacOS
        ? 'macos'
        : 'linux';
