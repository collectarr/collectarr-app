import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/book/book_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_fields.dart';

import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_projector.dart';

final bookKindModule = LibraryKindSpec<BookWorkspaceDto, BookOwnedDetails>(
  type: booksLibraryConfig,
  mediaAdapter: booksMediaAdapter,
  projector: const BookWorkspaceProjector(),
  ownedDetailsCodec: const BookOwnedDetailsCodec(),
  fields: bookLibraryKindSchema.toRegistry(),
  add: const StandardLibraryAddCapability<BookAddDraft>(
    kind: CatalogMediaKind.book,
    initialDraftBuilder: BookAddDraft.new,
  ),
  edit: LibraryEditCapability.fromTypeConfig(
    booksLibraryConfig,
    createDraft: createBookEditDraft,
  ),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
);
