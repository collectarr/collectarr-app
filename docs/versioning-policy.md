# 🏷️ Collectarr App Versioning & Release Policy

This document defines the versioning scheme, update channels, and release policies for **Collectarr App**.

---

## 1. Versioning Scheme

Collectarr App adheres to **Semantic Versioning 2.0.0** (`MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]`):

```text
  0 . 2 . 1 - beta . 1 + 1
  │   │   │   └──┬───┘   └─ Build metadata
  │   │   │      └───────── Prerelease identifier (beta / nightly)
  │   │   └──────────────── Patch version
  │   └──────────────────── Minor version
  └──────────────────────── Major version
```

### Pre-1.0 Releases
- Until version `1.0.0` is reached, minor version bumps (`0.x.0`) indicate feature milestones or schema migrations.
- Patch version bumps (`0.x.y`) indicate bug fixes or incremental domain improvements.
- Prereleases take precedence according to SemVer spec rules (`0.2.1-beta.1 < 0.2.1-beta.2 < 0.2.1`).

---

## 2. Update Channels

Users can configure their preferred update channel in **Settings → Updates**:

| Channel | Identifier Tag Format | Eligible Releases | Target Audience |
|---------|------------------------|-------------------|-----------------|
| **Stable** | `vX.Y.Z` | Stable releases only (`!isPrerelease`) | General users seeking maximum stability |
| **Beta** *(Default for prerelease builds)* | `vX.Y.Z-beta.N` | Beta and Stable releases | Early adopters and community testers |
| **Nightly** | `vX.Y.Z-nightly.YYYYMMDD` | Nightly, Beta, and Stable releases | Developers and active contributors |

### Channel Filtering Rules
1. **Stable channel**: Automatically ignores any candidate release marked as `prerelease` or containing `-beta`, `-alpha`, `-rc`, or `-nightly`.
2. **Beta channel**: Allows stable releases and `-beta`/`-rc` prereleases, but excludes `-nightly` builds.
3. **Nightly channel**: Receives all releases regardless of prerelease tag.

---

## 3. Publishing a Release

A release is one run of the **Release** workflow (`.github/workflows/release.yml`, *Run workflow* on `main`):

1. **Version**: picked from the conventional commits since the last stable tag: a breaking change (`!` or `BREAKING CHANGE:`) raises MAJOR, `feat` raises MINOR, `fix`/`perf` raise PATCH; other types do not release. The *version* input overrides it and may be a prerelease such as `1.2.0-beta.1`.
2. **Changelog and pubspec**: the "Unreleased" entries of `CHANGELOG.md` move under `## X.Y.Z - date`, and `pubspec.yaml` gets `version: X.Y.Z+N` with the build number raised. The workflow commits this as `chore(release): X.Y.Z` on `main` and tags it `vX.Y.Z`.
3. **GitHub release**: created from the tag with the moved changelog entries as notes; prereleases are marked as such and never become *Latest*.
4. **Downloads**: Windows (`.exe` / `.zip`), Linux (`.deb` / `.tar.gz`), Android (`.apk`), macOS (`.dmg` / `.zip`, when `COLLECTARR_ENABLE_MACOS_RELEASE` is `true`), a web bundle, and the `ghcr.io/collectarr/collectarr-app-web` image are built from the tag and attached.

*Dry run* shows the version and notes in the run summary without committing. *Backfill version* rebuilds and attaches the downloads of an existing release.

Run `dart run tool/prepare_release.dart --check` locally to preview the next release.

**Setup**: `main` requires reviewed pull requests, so the workflow pushes the release commit with the `RELEASE_TOKEN` secret: a fine-grained personal access token of a repository admin with *Contents: read and write* on this repository (admins may bypass the review rule). Without it, only dry runs work.

---

## 4. Upgrading Channels

When switching channels in the App Settings:
- Switching from **Beta** to **Stable** will hold updates until a stable version higher than the current beta is published.
- Switching from **Stable** to **Beta** will immediately check for newer beta builds.
