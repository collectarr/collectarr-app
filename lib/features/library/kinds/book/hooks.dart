import 'package:collectarr_app/features/library/config/library_kind_hooks.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';

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
);
