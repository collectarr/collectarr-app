import 'package:collectarr_app/features/library/config/library_entity_action_capability.dart';
import 'package:collectarr_app/features/library/kinds/comic/missing_comics_dialog.dart';

Future<void> runComicMissingIssuesAction(
  LibraryEntityActionContext action,
) {
  return showComicMissingComicsDialog(
    context: action.buildContext,
    type: action.type,
    projection: action.projection,
    accent: action.accent,
  );
}
