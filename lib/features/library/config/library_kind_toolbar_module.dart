import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/actions/ui_action.dart';

/// Structural toolbar contribution supplied by a kind.
final class LibraryKindToolbarModule {
  const LibraryKindToolbarModule({
    this.actions = const [],
  });

  final List<UiAction<LibraryToolbarActionContext>> actions;
}
