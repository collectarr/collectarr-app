import 'package:collectarr_app/features/library/config/library_kind_hooks.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/kinds/book/state_hooks.dart';

bool _bookCanOpenItemDetailDrilldown(LibraryProjectionItem item) {
  return false;
}

const bookLibraryKindHooks = LibraryKindHooks(
  page: LibraryPageKindHooks(
    canOpenItemDetailDrilldown: _bookCanOpenItemDetailDrilldown,
  ),
  inspector: LibraryInspectorKindHooks(
    showActionBar: false,
  ),
  edit: LibraryEditKindHooks(
    defaultScope: LibraryEditScope.media,
  ),
  state: bookLibraryStateHooks,
);
