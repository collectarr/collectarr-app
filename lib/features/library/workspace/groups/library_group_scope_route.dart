import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';

class LibraryGroupScopeRoute {
  const LibraryGroupScopeRoute({
    required this.groupMode,
    required this.bucket,
    this.folderDisplayMode,
  });

  final LibraryGroupMode groupMode;
  final String bucket;
  final LibraryFolderDisplayMode? folderDisplayMode;
}
