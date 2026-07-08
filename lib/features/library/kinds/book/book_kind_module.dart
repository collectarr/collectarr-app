import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/book/book_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

final bookKindModule = LibraryKindModule(
  type: booksLibraryConfig,
  mediaAdapter: booksMediaAdapter,
  workspaceDtoFactory: BookWorkspaceDto.fromEntry,
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
);
