import 'dart:io';

import 'release/release_preparation.dart';

/// Prepares a release in the working tree: picks the version from the
/// conventional commits since the last stable tag (or `--version`, which may
/// be a prerelease such as `1.2.0-beta.1`), updates
/// pubspec.yaml and CHANGELOG.md, and writes the release notes.
///
/// ```sh
/// dart run tool/prepare_release.dart --check            # print the plan only
/// dart run tool/prepare_release.dart --notes <file> [--version 1.2.0]
/// ```
///
/// The Release workflow commits, tags and publishes the result.
Future<void> main(List<String> args) async {
  String? valueOf(String flag) {
    final index = args.indexOf(flag);
    return index < 0 || index + 1 >= args.length ? null : args[index + 1];
  }

  final check = args.contains('--check');
  final notesPath = valueOf('--notes');
  if (!check && notesPath == null) {
    stderr.writeln('Pass --notes <file>, or --check to only print the plan.');
    exitCode = 2;
    return;
  }
  final previousTag = _git([
    'describe',
    '--tags',
    '--abbrev=0',
    '--match',
    'v*',
    '--exclude',
    'v*-*'
  ]);
  final messages = _git(['log', '--format=%B%x00', '$previousTag..HEAD'])
      .split('\x00')
      .map((message) => message.trim())
      .where((message) => message.isNotEmpty)
      .toList();
  final requested = valueOf('--version');
  final String version;
  if (requested != null) {
    version = requested.replaceFirst(RegExp('^v'), '');
  } else {
    final bump = releaseBumpFor(messages);
    if (bump == null) {
      stderr.writeln('No feat, fix or breaking commit since $previousTag; '
          'nothing to release. Pass --version to release anyway.');
      exitCode = 1;
      return;
    }
    version = nextVersion(previousTag.substring(1), bump);
  }

  final now = DateTime.now().toUtc();
  final date = '${now.year}-${_two(now.month)}-${_two(now.day)}';
  final changelogFile = File('CHANGELOG.md');
  final cut = cutChangelog(changelogFile.readAsStringSync(), version, date);
  stdout.writeln('Release $previousTag -> v$version '
      '(${messages.length} commits since $previousTag)');
  if (check) {
    stdout.writeln('\n${cut.entries}');
    return;
  }
  final pubspecFile = File('pubspec.yaml');
  pubspecFile.writeAsStringSync(
      bumpPubspecVersion(pubspecFile.readAsStringSync(), version));
  changelogFile.writeAsStringSync(cut.changelog);
  File(notesPath!).writeAsStringSync(releaseNotes(
    entries: cut.entries,
    version: version,
    previousTag: previousTag,
    repository: Platform.environment['GITHUB_REPOSITORY'] ??
        'collectarr/collectarr-app',
  ));
  final output = Platform.environment['GITHUB_OUTPUT'];
  if (output != null) {
    File(output).writeAsStringSync('version=$version\n', mode: FileMode.append);
  }
}

String _two(int value) => value.toString().padLeft(2, '0');

String _git(List<String> args) {
  final result = Process.runSync('git', args);
  if (result.exitCode != 0) {
    throw ProcessException('git', args, '${result.stderr}', result.exitCode);
  }
  return (result.stdout as String).trim();
}
