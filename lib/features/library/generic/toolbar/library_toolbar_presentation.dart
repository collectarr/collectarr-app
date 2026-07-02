import 'package:collectarr_app/features/library/generic/toolbar/library_toolbar_actions.dart';
import 'package:collectarr_app/features/library/generic/toolbar/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/generic/toolbar/library_toolbar_state.dart';

class LibraryToolbarPresentation {
  const LibraryToolbarPresentation({
    required this.config,
    required this.state,
    required this.actions,
  });

  final LibraryToolbarConfig config;
  final LibraryToolbarState state;
  final LibraryToolbarActions actions;
}
