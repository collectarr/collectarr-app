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

The rendered grid is measured on a real device in profile mode:

```sh
flutter drive --profile -d windows --driver test_driver/perf_driver.dart --target integration_test/perf/library_grid_perf_test.dart
```

It seeds 1500 fictional comics into an in-memory database, serves 420 x 630
JPEG covers from a local server, and reports the cover load time and the frame
build times of fast scrolling and of dragging the cover-size slider to
`build/integration_response_data.json`. `tool/ci_check.dart --integration`
runs only the top-level flows, so the measurement never gates CI. Compare a
change with the same command on the previous commit.

Coverage is an informational artifact, without a global percentage threshold.
The full release gate still includes generators, analyze, architecture checks,
correctness tests, native integration flows and platform builds.

## Native application flows

The native flows share explicit auth/sync overrides and an owned database through
`test/support/app/`. Navigation smoke uses empty collection projections; add and
edit flows use the real repositories/providers. The Core fake accepts only its
explicit Music search requests and rejects unexpected network traffic.

```sh
flutter test integration_test/app_smoke_test.dart -d windows
flutter test integration_test/accessibility_startup_test.dart -d windows
flutter test integration_test/library_add_flow_test.dart -d windows
flutter test integration_test/library_edit_flow_test.dart -d windows
```

Run them sequentially per checkout to avoid native SQLite library locks. CI runs
the same files on Linux under Xvfb. Personal persistence uses a temporary database
created by the test, closes it and reloads it; it never opens the user's database.

CI also uploads machine test events and `build/test-timings.json`, listing the
slowest files and directories by summed test-body duration. Concurrent test
bodies overlap; this is not exclusive wall time and omits suite compilation.
Inspect these hotspots before splitting jobs or adding timing thresholds.

## Slider accessibility

`test/accessibility/` initializes a recording binding before the ordinary test
binding can be created. Its helper in `test/support/accessibility/` checks the
serialized semantics updates sent to the engine, including retained parents
from earlier frames. Every updated node must be reachable from root 0; checking
only the final Dart semantics tree misses orphan nodes emitted during a route
transition.

Library and appearance sliders own a local, content-sized overlay through
`AppSlider`. This keeps their value-indicator nodes under the same route as
the control, including when covered by a dialog. Flutter 3.47.7 otherwise
reproduces the Windows AXTree rejection described in
[flutter/flutter#190357](https://github.com/flutter/flutter/issues/190357).
Regression tests cover push/dialog/pop, pointer and keyboard input, accessible
increase/decrease actions, and toolbar sizing. The native startup flow uses
an in-memory database, mocked sessions/sync and disabled automatic backups.
