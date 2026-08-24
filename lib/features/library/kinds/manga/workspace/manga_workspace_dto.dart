import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MangaWorkspaceDto extends WorkspaceDtoAdapter {
  MangaWorkspaceDto({
    required this.common,
    required this.personal,
    this.metadata,
    this.ownedDetails,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;

  final MangaMetadata? metadata;
  final MangaOwnedDetails? ownedDetails;
}
