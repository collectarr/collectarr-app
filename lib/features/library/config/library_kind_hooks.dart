import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';

class LibraryPageKindHooks {
  const LibraryPageKindHooks();
}

class LibraryInspectorKindHooks {
  const LibraryInspectorKindHooks({
    this.showActionBar = true,
  });

  final bool showActionBar;
}

class LibraryEditKindHooks {
  const LibraryEditKindHooks({
    this.defaultScope,
  });

  final LibraryEditScope? defaultScope;
}

class LibraryKindHooks {
  const LibraryKindHooks({
    this.page = const LibraryPageKindHooks(),
    this.inspector = const LibraryInspectorKindHooks(),
    this.edit = const LibraryEditKindHooks(),
  });

  final LibraryPageKindHooks page;
  final LibraryInspectorKindHooks inspector;
  final LibraryEditKindHooks edit;
}
