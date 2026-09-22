import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';

String? mangaHierarchyContractDiagnosticLabel(LibraryProjectionView item) {
  final dto = item.dto;
  if (dto is! MangaWorkspaceDto) {
    return null;
  }
  if (dto.seriesTitle?.trim().isNotEmpty != true) {
    return 'Missing series title';
  }
  if (item.node.scope != LibraryEntityScope.work &&
      dto.variant?.trim().isNotEmpty != true) {
    return 'Missing release variant';
  }
  return null;
}
