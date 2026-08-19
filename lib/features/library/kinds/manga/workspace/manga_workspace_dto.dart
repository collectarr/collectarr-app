import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MangaWorkspaceDto extends WorkspaceDtoAdapter {
  MangaWorkspaceDto({
    required this.common,
    required this.personal,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
}
