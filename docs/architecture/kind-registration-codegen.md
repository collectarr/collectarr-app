# Kind registration code generation

Collectarr uses static source generation for kind registration. The generator
is `tool/generate_kind_registries.dart` and writes the checked-in files under
`lib/features/library/kinds/registry/`.

The generator discovers a kind by finding both:

- `<kind>/<kind>_kind_module.dart` with a top-level `*KindModule` value;
- `<kind>/page.dart` with a `*LibraryPage` widget.

It then emits one generated registry containing the imports, module list, page
registrations, kind lookup functions, and typed owned-persistence dispatch
maps, catalog repository codecs, vocabulary contributors, and serial
authority contributors. The two public registry entry points
(`collectarr_kind_modules.dart` and `library_kind_registrations.dart`) only
export that generated registry; they do not duplicate kind imports.
The generated source is ordinary Dart and is compiled normally. The owned
dispatch maps are derived from each kind's owned repository, projection, and
typed ID files; `CollectarrOwnedItemPersistence` consumes those structural
maps without manually importing every kind.

This is deliberately build-time discovery rather than runtime reflection:

- Flutter AOT/tree-shaking remains predictable;
- registration errors are compile errors or generator errors;
- generic runtime code receives only the structural registration boundary;
- adding a kind does not require editing a central import/list file.

Run after adding or renaming a kind:

```text
dart run tool/generate_kind_registries.dart
```

The generator formats its output itself. CI runs it before Drift generation and checks the resulting tree
with `git diff --exit-code`. A new kind therefore only needs its own module and
page files; the generated composition root supplies the imports, registrations,
and contributor maps.

Generated files are committed so CI, IDE analysis, and release builds use the
same source. The generator should be run before committing a kind module or
page rename.
