import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_add_registry.dart';

final collectarrLibraryTypes = LibraryTypeRegistry([
  for (final module in collectarrKindModules) module.type,
]);

void registerLibraryAddBuilders() {
  for (final module in collectarrKindModules) {
    LibraryAddRegistry.registerManualBuilder(
      module.type.workspace.kind,
      buildDefaultManualPane,
    );
  }
  registerComicAddBuilders();
  registerMovieAddBuilders();
}
