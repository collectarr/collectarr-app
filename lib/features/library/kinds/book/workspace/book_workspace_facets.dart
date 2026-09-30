import 'package:collectarr_app/features/library/kinds/book/workspace/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

final bookLibraryFacetDefinitions =
    <LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>>[
  LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>(
    id: BookFacetIds.author,
    label: 'Author',
    extractValues: (dto) =>
        dto.metadata?.authors ??
        [
          if (dto.author case final author?) author,
        ],
  ),
  LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>(
    id: BookFacetIds.publisher,
    label: 'Publisher',
    extractValues: (dto) => [
      if (dto.publisher case final publisher?) publisher,
    ],
  ),
  LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>(
    id: BookFacetIds.genre,
    label: 'Genre',
    extractValues: (dto) => dto.metadata?.genres ?? const <String>[],
  ),
  LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>(
    id: BookFacetIds.format,
    label: 'Format',
    extractValues: (dto) => [
      if (dto.format case final format?) format,
    ],
  ),
  LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>(
    id: BookFacetIds.subject,
    label: 'Subject',
    extractValues: (dto) => dto.metadata?.subjects ?? const <String>[],
  ),
  LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>(
    id: BookFacetIds.translator,
    label: 'Translator',
    extractValues: (dto) => dto.metadata?.translators ?? const <String>[],
  ),
];
