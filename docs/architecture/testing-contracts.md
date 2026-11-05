# Contract testing architecture

Contract helpers are shared, but participation is explicit and typed. The
manifest at `test/contracts/kind_contract_manifest.dart` records the kinds
that promise each capability; matrix tests invoke those contracts with
concrete kind fixtures.

The current contract families cover:

```text
identity, Core mapping, field adoption, repository, persistence,
workspace, fields, sorts, groups, facets, vocabulary, Add, catalog Edit,
Collection Item Edit, tracking, and kind registration
```

The current architecture status and per-kind field ledgers describe the active
implementation and the remaining cutover work.

Useful focused commands are:

```text
flutter test test/contracts
flutter test test/architecture
flutter test test/domain
```

The preferred shape is an explicit call such as
`runMediaPersistenceContract(ComicPersistenceFixture())`, not a dynamic loop
over runtime kind objects.

Item content contracts include a synthetic presentation contribution that replaces all five view bodies and the Flow footer through the existing registration seam. Selection contracts cover mixed-kind intersections, stale target validation and asynchronous failures. Settings contracts cover scopes, inheritance, explicit false/null, reset, disabled modules, migration/reload and invalid stored values.

`test/features/library/workspace/tiles/content_golden_test.dart` exercises Music, Games and Comics in Cover, vertical/horizontal cards, Flow and Shelf on Windows and Android widget targets. Each fixture includes isolated catalog, owned and wishlist states, missing images, selection and long labels; Comics includes a slabbed cover. The 30 reference PNGs were compared byte-for-byte against the pre-separation implementation in a temporary checkout. Golden tests use deterministic Flutter test typography; physical-device font rasterization is outside this pixel comparison. Source assertions separately verify labels, grade fonts, selection behavior and item-bound cover fallbacks.

The Windows edit integration flow also hovers a real item, selects it through the shared checkbox, opens the contributed bulk Edit action, applies a tag and verifies it through the repository. Coordinator tests verify that dialogs use the selected kind rather than the navigation kind and reject mixed/stale selections before showing a dialog or accessing storage.
