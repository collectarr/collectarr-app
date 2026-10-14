# Device-local Gilroy loading

The font files are supplied by the user's device. No Gilroy asset is bundled,
committed, downloaded from CLZ, or sent through catalog/library sync.

Normal UI roles (400 and 500) use the local SemiBold face when available,
then Medium, then Regular. This is an optical adjustment for Flutter rendering:
matching the reference's CSS weight alone left ordinary text visibly lighter.
Bold headings retain their own face. Registration changes copies in memory;
the imported files, saved face identities and bundled fallback stay unchanged.
Registration synchronizes the numeric OS/2 weight with legacy/typographic
subfamily names. DirectWrite can infer weight from those names; an inconsistent
copy can leave the normal slots missing and select an installed Light face.
The SFNT directory/table checksums and whole-font adjustment are rebuilt while
glyph tables remain byte-for-byte unchanged.
Restart the application after changing this registration policy; hot reload
does not replace fonts already registered with the engine.

Settings → Appearance → Typography provides:

- Enable/disable local Gilroy, with immediate theme updates.
- Use installed Gilroy: desktop discovery or a user-triggered browser request.
- Import upright static TTF/OTF faces, persisted locally across restarts.
- Per-weight availability/source and removal of saved imported/browser faces.
- Plus Jakarta Sans for missing UI weights and when local fonts are disabled.

Windows searches per-user and system font directories. macOS searches user,
local and system Library/Fonts. Linux searches XDG/user and system font paths,
including subdirectories without following symlinks. Android/iOS use the file
selector instead of filesystem font enumeration.

Web detection uses feature checking for Local Font Access in a secure context.
`queryLocalFonts` is invoked synchronously from the Settings action before the
first await. Permission denial or unsupported browsers retain manual import.
Startup restores saved browser/imported bytes without requesting permission.
[Local Font Access](https://developer.mozilla.org/en-US/docs/Web/API/Window/queryLocalFonts).

The SFNT reader validates directory/name bounds, family, weight and upright
style. It rejects unrelated families, collections, variable faces, italics and
duplicate weights in an import batch. Total saved font bytes are limited to
2 MB. Missing 400–800 weights use the corresponding bundled face; missing
900 uses the bundled ExtraBold outlines registered in an explicit 900 slot,
with adjusted OS/2 and whole-font checksums. No synthetic Gilroy weight is
substituted for that missing slot.

Imports register into a new engine family before committing local settings.
Rejected imports preserve the prior active font and cache. Identical contents
reuse the existing registration; toggling does not repeatedly load font bytes.
Read-only validated bytes are copied for registration because the web engine
requires a native ArrayBuffer. Runtime text styles resolve the active alias,
including editor and selection-dialog overrides. The Windows-only loader and
obsolete font-diagnostics widget were removed rather than retained as adapters.

Imported/browser font bytes and the enabled choice use the device-local
`app.localFonts` preference. Clearing saved faces removes browser-session
faces too; independently discovered desktop fonts remain available. Clearing
site/app data also clears imports. Font access does not establish usage rights.

Validation covers malformed metadata, persistence/restart, disable/restore,
duplicate imports, failed registration rollback, permission errors, browser
cache removal, fallback checksum/weight and desktop font directory selection.
The native font integration contract includes a competing Light face and runs
on Windows CI as well as in the Linux integration flows. It uses bundled OFL
fonts and does not depend on user-installed Gilroy.
Completed verification on 2026-10-12:

- 18 focused font/controller/widget tests pass; 97 shared UI regression tests pass.
- Analyzer reports no issues; Windows debug and Web debug builds pass.
- Native Windows engine probing registers seven installed weights and verifies
  distinct text measurements plus disable/re-enable behavior.
- Playwright imports real Regular/Bold files, reloads persisted faces, grants
  local-font access and loads seven installed weights, then clears the cache.
- Unsupported and permission-denied browser scenarios keep manual import
  available and report no uncaught/framework exceptions.
- The Typography panel remains usable at 700px and in the compact Settings
  subpage at 500px; the inspected flows report no framework/page exceptions.
- Architecture inspection reports no AST boundary violations; the existing
  365 informational complexity reports remain.

macOS/Linux/mobile runtime checks require their respective devices. Directory
selection, shared import/controller behavior and compact UI are covered here;
no claim of physical-device verification is made for those platforms.
