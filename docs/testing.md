# Testing Collectarr App

Ordinary tests mirror the ownership of `lib/`. Architecture rules, contracts
and shared support are the special categories. Test helpers live exclusively
in `test/support/`; production imports of test support are forbidden.

## Run correctness tests

```sh
dart run tool/run_tests.dart
dart run tool/run_tests.dart -- --coverage
```

The default selection reads the released kind set from production configuration.
Shared correctness, contracts and architecture tests always run. Kind-owned
files for inactive kinds are excluded before Flutter loads them, not registered
as skipped tests.

```sh
dart run tool/run_tests.dart --kinds=all
dart run tool/run_tests.dart --kinds=music,book
dart run tool/run_tests.dart --exclude-kinds=music
dart run tool/run_tests.dart --list
```

Unknown kind names fail. Explicit source-kind selection does not enable that
kind in the product or create its database tables. Source persistence tests
need their own isolated fixture if they exercise unreleased tables. Mixed tests
must be separated by ownership rather than hidden by blanket exclusions.
Selected complete directories are compacted to respect Windows CLI limits.

## Measure workspace performance separately

```sh
flutter test benchmark/music_workspace_benchmark.dart --enable-vmservice --no-dds --reporter expanded
```

This explicitly runs the 1000/5000 album measurements and writes
`build/benchmarks/music-workspace.json`. The manual/weekly workflow uploads
that file. Normal correctness execution never discovers the benchmark and
never carries a permanent benchmark skip. Facts/group membership invariants
remain covered by the Music correctness tests.

Coverage is an informational artifact, without a global percentage threshold.
The full release gate still includes generators, analyze, architecture checks,
correctness tests, native integration flows and platform builds.
