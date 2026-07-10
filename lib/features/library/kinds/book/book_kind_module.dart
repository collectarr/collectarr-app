import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/book/book_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

import 'package:collectarr_app/features/library/kinds/book/workspace/book_fields.dart';

final bookKindModule = LibraryKindModule(
  type: booksLibraryConfig,
  mediaAdapter: booksMediaAdapter,
  workspaceDtoFactory: BookWorkspaceDto.fromEntry,
  fields: AnyLibraryFieldRegistry(
    groups: bookLibraryGroupDefinitions,
    sorts: bookLibrarySortDefinitions,
    columns: bookLibraryColumnDefinitions,
    defaultVisibleColumnIds:
        booksLibraryDefaultVisibleColumns.map((c) => c.toString().split('.').last).toSet(),
    defaultSortId: 'title',
    defaultGroupId: 'series',
  ),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
);
