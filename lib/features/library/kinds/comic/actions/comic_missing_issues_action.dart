import 'package:collectarr_app/features/library/config/library_target_action_capability.dart';
import 'package:collectarr_app/features/library/kinds/comic/missing_comics_dialog.dart';

Future<void> runComicMissingIssuesAction(
  LibraryTargetActionContext action,
) {
  return showComicMissingComicsDialog(
    context: action.buildContext,
    type: action.type,
    projection: action.projection,
    accent: action.accent,
  );
}
