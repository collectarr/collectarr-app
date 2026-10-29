# Contributing to Collectarr App

Thanks for helping build a free, local-first collection manager.

## Before you start

- Check existing issues and pull requests; open an issue to discuss substantial changes.
- Read [AGENTS.md](AGENTS.md) for repository-specific architecture, tests, and safety rules.
- Keep personal collection data, credentials, and third-party proprietary assets out of commits.
- Do not copy CLZ code, screenshots, paid fonts, or proprietary catalog datasets.

## Development and review

Use Flutter 3.47.7 and the committed dependency lockfile:

```sh
flutter pub get --enforce-lockfile
flutter analyze
dart run tool/run_tests.dart
```

Make focused pull requests with a description, relevant issue links, testing
performed, and screenshots for UI changes (using fictional demo data).
Follow the versioning and migration guidance linked from the README.

## Licensing contributions

Collectarr App is licensed under **GNU GPLv3 only** (`GPL-3.0-only`).
By submitting a contribution, you confirm that you have the right to submit
it under that license and that it may be redistributed under those terms.
You retain copyright to your original contribution; no copyright assignment
is required. Please identify third-party code and its license in your PR;
do not assume every dependency or asset is covered by the project license.

The project was previously MIT-licensed. Existing MIT grants and notices
remain valid for copies released under MIT; see
[LICENSES/MIT-legacy.txt](LICENSES/MIT-legacy.txt).
Contributions to new releases are accepted under GPL-3.0-only.
See [LICENSE](LICENSE) for the full license text.

## Community

Be respectful in issues, discussions, and reviews. Maintainers may ask for
changes, tests, or clarification before merging.
