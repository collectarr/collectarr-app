import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/kinds/book/config/book_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/book/config/book_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

final bookLibraryFacetDefinitions =
    <LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>>[
  LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>(
    metadata: BookWorkspaceFieldMetadata.author,
    extractValues: (dto) => dto.metadata.authors,
  ),
  if (BookFieldIdentities.publisher.filterable)
    LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>(
      metadata: BookFieldIdentities.publisher,
      extractValues: (dto) => [
        if (dto.publisher case final publisher?) publisher,
      ],
    ),
  LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>(
    metadata: BookWorkspaceFieldMetadata.genre,
    extractValues: (dto) => dto.metadata.genres,
  ),
  LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>(
    metadata: BookWorkspaceFieldMetadata.subject,
    extractValues: (dto) => dto.metadata.subjects,
  ),
  if (BookFieldIdentities.format.filterable)
    LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>(
      metadata: BookFieldIdentities.format,
      extractValues: (dto) => [
        if (dto.format case final format?) format,
      ],
    ),
  LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>(
    metadata: BookWorkspaceFieldMetadata.translator,
    extractValues: (dto) => dto.metadata.translators,
  ),
];

final bookSmartListFacetFields =
    <LibraryFieldDefinition<BookKind, BookWorkspaceDto, Object?>>[
  LibraryFieldDefinition<BookKind, BookWorkspaceDto, Iterable<String>>(
    metadata: BookWorkspaceFieldMetadata.genre,
    id: const LibraryFieldId<BookKind, Iterable<String>>('book.genre'),
    getValue: (context) => context.dto.metadata.genres,
  ),
  LibraryFieldDefinition<BookKind, BookWorkspaceDto, Iterable<String>>(
    metadata: BookWorkspaceFieldMetadata.subject,
    id: const LibraryFieldId<BookKind, Iterable<String>>('book.subject'),
    getValue: (context) => context.dto.metadata.subjects,
  ),
];
