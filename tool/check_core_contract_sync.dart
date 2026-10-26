import 'dart:convert';
import 'dart:io';

const _contractKeys = [
  'contractVersion',
  'coreCommit',
  'openApiHash',
  'fieldSchemaHash',
  'catalogItemV1Hash',
  'musicCatalogV1Hash',
  'activeKindsHash',
];

/// Compares pinned contract identity and content, not generation timestamps.
List<String> coreContractDifferences(
  Map<String, dynamic> app,
  Map<String, dynamic> core,
) {
  final differences = <String>[];
  for (final key in _contractKeys) {
    final appValue = app[key];
    final coreValue = core[key];
    if (appValue is! String || appValue.isEmpty) {
      differences.add('App manifest is missing $key.');
    }
    if (coreValue is! String || coreValue.isEmpty) {
      differences.add('Core manifest is missing $key.');
    }
    if (appValue is String &&
        appValue.isNotEmpty &&
        coreValue is String &&
        coreValue.isNotEmpty &&
        appValue != coreValue) {
      differences.add('$key differs: App=$appValue; Core=$coreValue.');
    }
  }
  return differences;
}

int checkCoreContractSync(
  List<String> args, {
  StringSink? output,
  StringSink? errors,
}) {
  final out = output ?? stdout;
  final err = errors ?? stderr;
  const usage = 'dart run tool/check_core_contract_sync.dart '
      '--core-manifest <path> [--app-manifest <path>]';
  if (args.length == 1 && args.single == '--help') {
    out.writeln(usage);
    return 0;
  }
  try {
    String? corePath;
    var appPath = 'tool/core_contracts/contract-manifest.json';
    final seen = <String>{};
    for (var i = 0; i < args.length; i++) {
      final option = args[i];
      if (!{'--core-manifest', '--app-manifest'}.contains(option) ||
          !seen.add(option) ||
          i + 1 >= args.length ||
          args[i + 1].startsWith('--')) {
        throw ArgumentError('Invalid argument: $option. Usage: $usage');
      }
      final value = args[++i];
      if (option == '--core-manifest') {
        corePath = value;
      } else {
        appPath = value;
      }
    }
    if (corePath == null || corePath.trim().isEmpty) {
      throw ArgumentError(
          'An explicit Core manifest is required. Usage: $usage');
    }
    Map<String, dynamic> read(String path) {
      final value = jsonDecode(File(path).readAsStringSync());
      if (value is! Map<String, dynamic>) {
        throw FormatException('Manifest must be a JSON object: $path');
      }
      return value;
    }

    final differences = coreContractDifferences(read(appPath), read(corePath));
    if (differences.isNotEmpty) {
      for (final difference in differences) {
        err.writeln(difference);
      }
      return 1;
    }
    out.writeln('Core contracts match the App pin: $corePath');
    return 0;
  } on Object catch (error) {
    err.writeln(error);
    return 2;
  }
}

void main(List<String> args) => exitCode = checkCoreContractSync(args);
