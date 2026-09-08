import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

/// Kind-owned facet execution contract.
///
/// The generic host may render the structural definitions and ask the
/// composition root for this module, but it does not interpret facet values
/// or metadata payloads itself.
final class LibraryFacetModule {
  const LibraryFacetModule({
    this.loadRows,
    this.getFacetValues,
    this.externalFacetBucketIdsByMode = const {},
  });

  final LibraryFacetRowsLoader? loadRows;
  final Iterable<String> Function(
          LibraryProjectionView item, LibraryFacetIdRuntime facetId)?
      getFacetValues;
  final Map<String, LibraryFacetIdRuntime> externalFacetBucketIdsByMode;
}

/// Kind-owned facet execution with a concrete workspace DTO.
///
/// The erased callback is created only at this composition boundary. Kind
/// implementations and their tests use [typedGetFacetValues] directly and do
/// not need to cast a generic projection item.
final class TypedLibraryFacetModule<TDto extends LibraryWorkspaceDto>
    extends LibraryFacetModule {
  TypedLibraryFacetModule({
    required Iterable<String> Function(TDto dto, LibraryFacetIdRuntime facetId)
        getFacetValues,
    super.loadRows,
    super.externalFacetBucketIdsByMode,
  })  : typedGetFacetValues = getFacetValues,
        super(
          getFacetValues: (item, facetId) {
            final dto = item.dto;
            if (dto is! TDto) return const <String>[];
            return getFacetValues(dto, facetId);
          },
        );

  final Iterable<String> Function(TDto dto, LibraryFacetIdRuntime facetId)
      typedGetFacetValues;
}

typedef LibraryFacetRowsLoader = Future<List<Map<String, dynamic>>> Function({
  required LibraryFacetIdRuntime facetId,
  required Set<String> itemIds,
  required ApiClient api,
});
