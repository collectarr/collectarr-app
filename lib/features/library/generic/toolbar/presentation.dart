import 'package:collectarr_app/features/library/generic/toolbar/actions.dart';
import 'package:collectarr_app/features/library/generic/toolbar/config.dart';
import 'package:collectarr_app/features/library/generic/toolbar/state.dart';

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
