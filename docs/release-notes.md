# Release notes

Every GitHub release uses this order: Collectarr banner; `Changes since last release:`; Known Issues; Installing & Updating; About Collectarr; Community & Contributors; Support Collectarr; separator; automatic `What's Changed`, contributor credits and comparison link.

Write a short English editorial summary in `docs/release-summaries.json`, keyed by release tag (for example `v1.2.0`). Explain user-visible outcomes, group related work, and do not claim tests or compatibility that were not checked. This summary is distinct from the complete change list. Keep `CHANGELOG.md` Unreleased entries grouped by Features, Fixes, Refactors, Docs and CI & Build for release preparation.

`tool/release_notes.py` uses GitHub generated release notes for PR titles, authors and links. If GitHub returns no change section, it includes the complete commit range with author and commit links. Existing release-specific notes supply an initial summary when no editorial entry exists. Re-running preserves the existing editorial section. Review and shorten imported summaries as needed.

Preview with `python tool/release_notes.py --repo collectarr/REPOSITORY --tag vX.Y.Z`. Publish with the same command plus `--write`; `--all` backfills every published release. Drafts are excluded. Only release descriptions change: tags, versions, assets and databases are untouched.

The Release notes workflow runs after a successful Release workflow, on publication, or manually. It uses the repository token and checks out main. Run it manually to apply an edited summary to existing releases.

The banner at `docs/assets/release-banner.png` was created with the built-in imagegen tool. Prompt: original Collectarr collection-library banner, dark navy shelves of records, books, games, film reels and collectibles; blue, amber and teal accents; text Collectarr / Your collections. Connected. / App · Core · Sync / Free & open source. No third-party logos or changing statistics.