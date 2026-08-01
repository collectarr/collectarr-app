import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/book/book_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

import 'package:collectarr_app/features/library/kinds/book/workspace/book_fields.dart';

import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_projector.dart';

final bookKindModule = LibraryKindSpec<BookWorkspaceDto, GenericOwnedDetails>(
  type: booksLibraryConfig,
  mediaAdapter: booksMediaAdapter,
  projector: const BookWorkspaceProjector(),
  ownedDetailsCodec: const GenericOwnedDetailsCodec(),
  fields: bookKindSchema.toRegistry(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
);
