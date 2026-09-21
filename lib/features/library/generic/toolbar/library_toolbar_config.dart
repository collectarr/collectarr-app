import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';

class LibraryToolbarConfig {
  const LibraryToolbarConfig({
    required this.type,
    required this.browserMode,
    required this.includeDesktopSecondaryBand,
  });

  final LibraryKindRegistration type;
  final LibraryWorkspaceBrowserMode browserMode;
  final bool includeDesktopSecondaryBand;
}
