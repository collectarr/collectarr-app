import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_add_registry.dart';

final collectarrLibraryTypes = LibraryTypeRegistry([
  for (final module in collectarrKindModules) module.type,
]);

// Register LibraryAdd builders from kinds so the generic dialog can remain
// decoupled and discover per-kind custom panes.
void registerLibraryAddBuilders() {
  for (final module in collectarrKindModules) {
    LibraryAddRegistry.registerManualBuilder(
      module.type.workspace.kind,
      buildDefaultManualPane,
    );
    LibraryAddRegistry.registerManualKindSpecificFactory(
      module.type.workspace.kind,
      () => <String, dynamic>{},
    );
    module.add.registerBuilders();
  }
}

// NOTE: registration should be invoked from application init (e.g. main())
// to avoid module-load ordering issues in tests. Call `registerLibraryAddBuilders()`
// from a centralized initialization point when the app starts.
