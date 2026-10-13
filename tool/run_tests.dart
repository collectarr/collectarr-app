import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:collectarr_app/features/library/kinds/registry/library_release_scope.dart';
import 'testing/test_selection.dart';

Future<void> main(List<String> args) async {
  var kinds = 'released';
  var listOnly = false;
  final excluded = <String>{};
  final flutterArgs = <String>[];
  var passthrough = false;
  for (final arg in args) {
    if (passthrough) {
      flutterArgs.add(arg);
    } else if (arg == '--') {
      passthrough = true;
    } else if (arg.startsWith('--kinds=')) {
      kinds = arg.substring('--kinds='.length);
    } else if (arg.startsWith('--exclude-kinds=')) {
      excluded.addAll(arg.substring('--exclude-kinds='.length).split(','));
    } else if (arg == '--list') {
      listOnly = true;
    } else if (arg == '--help') {
      stdout.writeln('dart run tool/run_tests.dart '
          '[--kinds=released|all|music,book] [--exclude-kinds=book] '
          '[--list] [-- <flutter test options>]');
      return;
    } else {
      stderr.writeln('Unknown option: $arg; use --help.');
      exitCode = 2;
      return;
    }
  }
  final root = Directory.current.path;
  final knownKinds = <String>{};
  for (final entity in Directory('lib/features/library/kinds').listSync()) {
    if (entity is Directory) {
      final kind = p.basename(entity.path);
      if (File(p.join(entity.path, '${kind}_module.dart')).existsSync()) {
        knownKinds.add(kind);
      }
    }
  }
  late final TestSelection selection;
  try {
    selection = TestSelection(
      files: Directory('test')
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .where((file) => file.path.endsWith('_test.dart'))
          .map((file) => p.relative(file.absolute.path, from: root)),
      knownKinds: knownKinds,
      releasedKinds: releasedLibraryKinds.map((kind) => kind.apiValue).toSet(),
      kinds: kinds,
      excludedKinds: excluded,
    );
  } on ArgumentError catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
    return;
  }
  stdout.writeln('Kind tests: ${selection.selectedKinds.join(', ')}; '
      '${selection.selectedFiles.length} files selected, '
      '${selection.excludedFiles.length} inactive kind files excluded. '
      'Shared correctness/contracts/architecture remain selected.');
  if (listOnly) {
    for (final file in selection.selectedFiles) {
      stdout.writeln(file);
    }
    return;
  }
  if (selection.selectedFiles.isEmpty) {
    stderr.writeln('No correctness tests found.');
    exitCode = 2;
    return;
  }
  final process = await Process.start(
      'flutter', ['test', ...selection.paths, ...flutterArgs],
      runInShell: Platform.isWindows, mode: ProcessStartMode.inheritStdio);
  exitCode = await process.exitCode;
}
