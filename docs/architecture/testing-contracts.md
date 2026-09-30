# Contract testing architecture

Contract helpers are shared, but participation is explicit and typed. The
manifest at `test/contracts/kind_contract_manifest.dart` records the kinds
that promise each capability; matrix tests invoke those contracts with
concrete kind fixtures.

The current contract families cover:

```text
identity, Core mapping, field adoption, repository, persistence,
workspace, fields, sorts, groups, facets, vocabulary, Add, catalog Edit,
Owned Copy Edit, tracking, and kind registration
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
