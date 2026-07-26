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

## 3. Repository Version Alignment

To prevent version downgrades or workflow failures:

1. **`pubspec.yaml`**: Holds the authoritative app version (`version: X.Y.Z-channel.N+B`).
2. **GitHub Releases**: Tags are prefixed with `v` (e.g. `v0.2.1-beta.1`).
3. **Release Workflow (`.github/workflows/release.yml`)**:
   - Validates that `pubspec.yaml` matches the planned release tag before publishing artifacts.
   - Pushes Docker containers to GHCR (`ghcr.io/collectarr/collectarr-app-web`).
   - Builds Windows (`.exe` / `.zip`), Linux (`.deb` / `.tar.gz`), Android (`.apk`), and macOS (`.dmg` / `.zip`).

---

## 4. Upgrading Channels

When switching channels in the App Settings:
- Switching from **Beta** to **Stable** will hold updates until a stable version higher than the current beta is published.
- Switching from **Stable** to **Beta** will immediately check for newer beta builds.
