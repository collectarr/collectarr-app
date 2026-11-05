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

## Library view screenshot comparisons

The 30 reference images in `workspace/tiles/goldens` use the Windows Flutter
renderer. Run comparisons and regenerate references on Windows with the Flutter
version pinned in `.github/workflows/tests.yml`:

```sh
flutter test test/features/library/workspace/tiles/content_golden_test.dart
flutter test test/features/library/workspace/tiles/content_golden_test.dart --update-goldens
```

The test file requires a Windows host. Its Windows and Android presentation
variants choose UI behavior; they do not change the host's font rasterizer or
graphics engine. Comparing these images on Linux produces rendering differences
even with the same Flutter version. CI runs all 30 comparisons in its existing
Windows job and retains image differences on failure. Linux still runs shared
correctness, contracts, architecture checks and native integration flows.

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
flutter test integration_test/font_rendering_test.dart -d windows
flutter test integration_test/library_add_flow_test.dart -d windows
flutter test integration_test/library_edit_flow_test.dart -d windows
```

Run them sequentially per checkout to avoid native SQLite library locks. CI runs
the same files on Linux under Xvfb. Personal persistence uses a temporary database
created by the test, closes it and reloads it; it never opens the user's database.

For Android, use a disposable checkout with a distinct application ID, then run
`dart run tool/ci_check.dart integration --device <adb-serial>` there. Installing
an integration APK replaces its entry point and may uninstall that package on
completion. The runner's **Test starting...** screen is not the normal app.
When finished, build `flutter build apk --debug --target lib/main.dart`, install
that normal review APK and launch it explicitly. Never run device installs over
an application ID containing the user's collection.

## Native presentation matrix

Platform policy is independent of width. The widget matrices cover Android/iOS
at 320, 390, 600, 840 and 1024 dp, plus 844x390 landscape with 200 percent text
and keyboard insets. Native detail checks include cold local/catalog/wishlist
hydration, deleted targets, identical IDs in different namespaces, long-press
selection and Back retaining the library query. Settings checks include cold
section URLs, account access and returning to the index. Desktop dialog geometry
runs with an explicit desktop target; synthetic-kind and architecture contracts
remain part of normal correctness execution.

| Environment | Coverage and limits |
| --- | --- |
| Android / BlueStacks | Five integration files cover six flows: wide/phone navigation, accessibility/account, fonts, Core Add and persistent local Edit. A separate normal review build is inspected at phone/tablet widths. |
| Windows | The same six native flows, desktop widget regressions and the rendered 1500-comic grid profile. |
| iOS | Widget presentation and lifecycle matrices; no runner or physical iOS permission/gesture verification is available. |
| Browser | Release compilation and explicit web-policy unit cases pass. The local Windows Chrome widget harness fails during Flutter bootstrap before test bodies. A fresh visual browser launch was rejected by automatic tool review, so it is not counted as a passed check. |
| Source-only kinds | Run the inactive-kind files selected by `--kinds=all` as well as the released/shared suite; this does not enable those kinds in the app. |

The current Windows profile is a local measurement, not a portable performance
threshold: first cover 286 ms, twelve covers 323 ms, scroll build p99 8.95 ms
with no missed build budgets; cover-size dragging build p99 12.10 ms with two
missed build budgets in 737 frames. Music projection/facts reuse is also checked
with the 1000/5000-album benchmark. Keep reports and captures in temporary
storage or ignored build artifacts, and compare against the same environment
before claiming a performance improvement.

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
