# Library Parity Contract (App)

`collectarr-app` follows the shared Collectarr parity contract defined in
`collectarr-core`.

- Canonical contract: https://github.com/collectarr/collectarr-core/blob/main/docs/library-parity-contract.md
- App implementation plan: `docs/implementation-plan.md`

## App-side guarantees

1. The app exposes exactly 9 active library kinds:
   `comic`, `manga`, `anime`, `book`, `game`, `boardgame`, `movie`, `tv`, `music`.
2. Add/search/edit/workspace flows remain compatible with Core's canonical kind
   and provider model.
3. App-side local-first OCR/reranking stays the default cover-photo strategy;
   server-side ranking remains opt-in only if measurable quality gates fail.
