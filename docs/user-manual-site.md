# Website and user manual

The manual belongs to the separate `collectarr-site` repository. It contains the
product landing page, common workflows and nine kind-specific chapters. The app
opens it externally from **Help → User Manual**, targeting the active kind. An
unknown kind opens the manual overview. Opening Help does not reset the current
library route, collection or selection.

The website's source lives alongside this checkout at `../collectarr-site`.
Its README describes local preview, static builds and hosting. Its initial
publication is pending the hosting destination; creating the local repository
does not publish a website.

The expected GitHub Pages manual root is
`https://collectarr.github.io/collectarr-site/manual/`. Configure another host or
a local preview at app build time:

```powershell
flutter run --dart-define=COLLECTARR_MANUAL_URL=http://127.0.0.1:4321/collectarr-site/manual/
```

The define must be an HTTP(S) manual-root URL without credentials, query or
fragment. Its path is preserved when appending `kinds/music/` or another kind's
chapter. Server hosting can use a root such as `https://your-domain/manual/`.

Manual screenshots use an isolated fictional database and original demo artwork.
No production database, CLZ account data or licensed font files are distributed.
The manual describes the beta application's actual controls, not CLZ's behavior
where Collectarr differs.
