# Contract testing architecture

Contract helpers are shared, but participation is explicit and typed. The
manifest at `test/contracts/kind_contract_manifest.dart` records the kinds
that promise each capability; matrix tests invoke those contracts with
concrete kind fixtures.

The current contract families cover:

```text
identity, Core mapping, field adoption, repository, persistence,
workspace, fields, sorts, groups, facets, vocabulary, Add, Media Edit,
Release, Release Edit, tracking, and provider-kind mapping
```

The final parity report records PASS/N/A per kind, while the semantic-vacuum
and deleted-code reports record the remaining bounded migration debt.

Useful focused commands are:

```text
flutter test test/contracts
flutter test test/architecture
flutter test test/domain
```

The preferred shape is an explicit call such as
`runMediaPersistenceContract(ComicPersistenceFixture())`, not a dynamic loop
over runtime kind objects.
