import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';

class LibraryToolbarConfig {
  const LibraryToolbarConfig({
    required this.type,
    required this.includeDesktopSecondaryBand,
  });

  final LibraryKindRegistration type;
  final bool includeDesktopSecondaryBand;
}
