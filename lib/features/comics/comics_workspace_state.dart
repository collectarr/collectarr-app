import 'package:collectarr_app/features/comics/comics_workspace_view_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';

typedef ComicsWorkspaceViewState = LibraryWorkspaceViewState;

Future<ComicsWorkspaceViewState> loadComicsWorkspaceViewState() {
  return comicsWorkspaceViewProfile.load();
}

Future<void> saveComicsWorkspaceViewState(
  ComicsWorkspaceViewState state,
) {
  return comicsWorkspaceViewProfile.save(state);
}
