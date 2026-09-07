# Kind registration code generation

Collectarr uses static source generation for kind registration. The generator
is `tool/generate_kind_registries.dart` and writes the checked-in files under
`lib/features/library/kinds/registry/`.

The generator discovers a kind by finding both:

- `<kind>/<kind>_kind_module.dart` with a top-level `*KindModule` value;
- `<kind>/page.dart` with a `*LibraryPage` widget.

It then emits one generated registry containing the imports, module list, page
registrations, kind lookup functions, and typed owned-persistence dispatch
maps, catalog repository codecs, vocabulary contributors, serial authority
contributors, export-preview contributors, and typed catalog lookup
constructors and route contributions. The public registry entry points
(`collectarr_kind_modules.dart` and `library_kind_registrations.dart`) only
export that generated registry; they do not duplicate kind imports.
The generated source is ordinary Dart and is compiled normally. The owned
dispatch maps are derived from each kind's owned repository, projection, and
typed ID files; `CollectarrOwnedItemPersistence` consumes those structural
maps without manually importing every kind.

The same generator also writes
`lib/dev/seeds/collectarr_dev_seed_registry.g.dart`. It discovers the
kind-owned `DevSeedKindContributor` values from the seed scripts and emits the
typed seed composition list and exports. `dev_seed.dart` therefore orchestrates
catalog, owned, tracking, and kind-specific database fixtures without a
manual nine-kind import list or a switch over concrete repositories.

This is deliberately build-time discovery rather than runtime reflection:

- Flutter AOT/tree-shaking remains predictable;
- registration errors are compile errors or generator errors;
- generic runtime code receives only the structural registration boundary;
- adding a kind does not require editing a central import/list file.

This is the Dart equivalent of compile-time reflection for this use case: the
generator inspects the source tree before compilation and emits ordinary typed
Dart. Runtime `dart:mirrors`-style reflection is intentionally not used, and
there is no native compile-time reflection API that would be safe for Flutter
AOT builds.

Run after adding or renaming a kind:

```text
dart run tool/generate_kind_registries.dart
```

The generator formats its output itself. CI runs it before Drift generation and checks the resulting tree
with `git diff --exit-code`. A new kind therefore only needs its own module,
page, and any convention-based contributor files; the generated composition
root supplies the imports, registrations, routes, lookup constructors, and
contributor maps.

Generated files are committed so CI, IDE analysis, and release builds use the
same source. The generator should be run before committing a kind module or
page rename.
