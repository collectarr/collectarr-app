import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';

/// Structural toolbar contribution supplied by a kind.
final class LibraryKindToolbarModule {
  const LibraryKindToolbarModule({
    this.actions = const [],
  });

  final List<LibraryToolbarActionDescriptor> actions;
}
