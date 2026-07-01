import 'package:collectarr_app/features/library/config/library_kind_hooks.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';

const bookLibraryKindHooks = LibraryKindHooks(
  edit: LibraryEditKindHooks(
    defaultScope: LibraryEditScope.media,
  ),
);
