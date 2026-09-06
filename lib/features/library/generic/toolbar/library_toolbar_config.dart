import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';

class LibraryToolbarConfig {
  const LibraryToolbarConfig({
    required this.type,
    required this.browserMode,
    required this.supportsMediaReleaseSplit,
    required this.includeDesktopSecondaryBand,
  });

  final LibraryKindModule type;
  final LibraryWorkspaceBrowserMode browserMode;
  final bool supportsMediaReleaseSplit;
  final bool includeDesktopSecondaryBand;
}
