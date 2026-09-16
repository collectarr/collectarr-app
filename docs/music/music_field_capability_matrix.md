# Music field capability matrix

This is the implementation-plan audit for the typed Music graph. “Round-trip”
means load -> edit/draft -> save -> reload. “Projection” means the field is
available for read-only display but does not have a canonical write path in
that layer.

| Field | Scope | Domain | DB | Provider | Sync | CSV in | CSV out | Add | Edit | Inspector | Workspace | Stats |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Track Artist | Release | Full | Full | Full | Full | N/A | Full | N/A | Full | Full | Projection | N/A |
| Track Header | Release | Full | Full | Full | Full | N/A | Full | N/A | Full | Full | N/A | Excluded |
| Storage Device / Slot | Copy | Full | Full | N/A | Full | N/A | Full | N/A | Full | Full | Full | N/A |
| Matrix / Runout | Copy | Full | Full | N/A | Full | N/A | Full | N/A | Full | Full | N/A | N/A |
| Signed By | Copy | Full | Full | N/A | Full | N/A | Full | N/A | Full | Full | Full | Full |
| Last Cleaned | Copy | Full | Full | N/A | Full | N/A | Full | N/A | Full | Full | Full | Candidate |
| Listen Event / history | Release | Full | Full | N/A | Full | N/A | Projection | N/A | CRUD | CRUD | Full | Full |
| Catalog Number | Release | Full | Full | Full | Full | Full | Full | Full | Full | Full | Full | N/A |
| Box Set + position | Release | Full | Typed relation | Full | Full | N/A | Projection | N/A | Full | Full | Full | N/A |
| Image role/order/caption | Copy | Full | Full | N/A | Full | N/A | Full | N/A | Full | Full | Hero/extra | N/A |
| Group/release/copy scope | Structural | Full | N/A | N/A | N/A | N/A | N/A | N/A | N/A | Full | Full | N/A |
| Group/release aggregates | Group/Release | Derived | N/A | N/A | N/A | N/A | N/A | N/A | Read-only | Full | Full | Full |

## Boundary rules

- A Copy always points at a concrete Release; the Release Group is only the
  root context.
- Release tracking is canonical and writable; Group tracking/listening is a
  derived read-only projection.
- Catalog/provider payloads are mapped through typed accessors and explicit
  mappers; box-set membership is persisted through a dedicated relation.
- Generic workspace code selects a schema structurally and does not interpret
  Music roles, releases, or box-set semantics.

## Known non-green verification boundary

The targeted Music/domain/config suite is green. The repository-wide Flutter
suite still has pre-existing failures in unrelated UI/fixture areas; see
`music_main_execution_baseline.md` for the recorded baseline and scope.
