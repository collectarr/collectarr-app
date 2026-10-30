# Release notes

Every GitHub release uses this order: Collectarr banner; `Changes since last release:`; Known Issues; Installing & Updating; About Collectarr; Community & Contributors; Support Collectarr; separator; automatic `What's Changed`, contributor credits and comparison link.

Write a short English editorial summary in `docs/release-summaries.json`, keyed by release tag (for example `v1.2.0`). Explain user-visible outcomes, group related work, and do not claim tests or compatibility that were not checked. This summary is distinct from the complete change list. Keep `CHANGELOG.md` Unreleased entries grouped by Features, Fixes, Refactors, Docs and CI & Build for release preparation.

`tool/release_notes.py` builds `What's Changed` from the complete commit range of each release: every merged pull request once, with its title, author and link; every commit pushed directly to main, with its author and commit link; and the issues they close. GitHub's generated notes add New Contributors and the Full Changelog link. Lists that would exceed GitHub's description limit end with a link to the complete history. Existing release-specific notes supply an initial summary when no editorial entry exists. Re-running preserves the existing editorial section. Review and shorten imported summaries as needed.

Preview the newest release with `python tool/release_notes.py --repo collectarr/REPOSITORY`, or another one with `--tag vX.Y.Z`. Publish with the same command plus `--write`; `--all` backfills every published release. Drafts are excluded, and releases whose description is already current are not rewritten. Only release descriptions change: tags, versions, assets and databases are untouched.

The Release notes workflow runs after a successful Release workflow and formats the newest release; run it manually with a tag, or with Backfill, to apply an edited summary to existing releases. It checks out main with its tags and commits summaries imported for new tags to `docs/release-summaries.json`, so every published summary stays versioned. Pushing to protected main needs the `RELEASE_TOKEN` secret.

Each release shows the banner from the commit it was tagged with; releases tagged before the banner existed show its first version. Changing the banner on main only affects later releases.

The banner at `docs/assets/release-banner.png` was created with the built-in imagegen tool. Prompt: original Collectarr collection-library banner, dark navy shelves of records, books, games, film reels and collectibles; blue, amber and teal accents; text Collectarr / Your collections. Connected. / App · Core · Sync / Free & open source. No third-party logos or changing statistics.