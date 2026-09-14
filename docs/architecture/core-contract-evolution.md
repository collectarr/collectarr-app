# Core contract evolution

Generated Core DTOs are transport contracts. Kind-owned remote adapters map
them into canonical kind domain models; generic payloads are not a substitute
for field adoption.

When Core adds a field, the adoption path is:

```text
Core schema → generated DTO → owning kind remote mapper → kind domain model
             → local mapper/table when persisted → contract test
```

The generated DTO adoption manifest is maintained in
`test/contracts/core_field_adoption_contract.dart`. The discovery and
classification tests require each generated field to be explicitly marked as
mapped or intentionally ignored. CI runs this check after generation, so a
new unclassified field points directly to the owning kind.

The ownership boundary is additionally checked by
`test/architecture/core_dto_ownership_test.dart`.
