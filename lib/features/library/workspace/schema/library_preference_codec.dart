import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

/// Kind-owned preference codec for converting between persisted string identifiers
/// and strongly-typed canonical kind identifiers.
abstract interface class LibraryWorkspacePreferenceCodec<TKind> {
  /// Decodes a persisted column ID string into a canonical typed [LibraryFieldId].
  /// Returns null if the persisted string is unknown or invalid.
  LibraryFieldId<TKind, Object?>? decodeColumn(String persisted);

  /// Decodes a persisted sort ID string into a canonical typed [LibrarySortId].
  /// Returns null if the persisted string is unknown or invalid.
  LibrarySortId<TKind>? decodeSort(String persisted);

  /// Decodes a persisted group ID string into a canonical typed [LibraryGroupId].
  /// Returns null if the persisted string is unknown or invalid.
  LibraryGroupId<TKind, Object?>? decodeGroup(String persisted);

  /// Encodes a canonical typed column ID to its canonical persisted string representation.
  String encodeColumn(LibraryFieldIdRuntime id);

  /// Encodes a canonical typed sort ID to its canonical persisted string representation.
  String encodeSort(LibrarySortId<TKind> id);

  /// Encodes a canonical typed group ID to its canonical persisted string representation.
  String encodeGroup(LibraryGroupIdRuntime id);
}

/// Default identity codec for kind-owned persisted identifiers.
class IdentityLibraryWorkspacePreferenceCodec<TKind>
    implements LibraryWorkspacePreferenceCodec<TKind> {
  const IdentityLibraryWorkspacePreferenceCodec();

  @override
  LibraryFieldId<TKind, Object?>? decodeColumn(String persisted) =>
      LibraryFieldId<TKind, Object?>(persisted);

  @override
  LibrarySortId<TKind>? decodeSort(String persisted) =>
      LibrarySortId<TKind>(persisted);

  @override
  LibraryGroupId<TKind, Object?>? decodeGroup(String persisted) =>
      LibraryGroupId<TKind, Object?>(persisted);

  @override
  String encodeColumn(LibraryFieldIdRuntime id) => id.value;

  @override
  String encodeSort(LibrarySortId<TKind> id) => id.value;

  @override
  String encodeGroup(LibraryGroupIdRuntime id) => id.value;
}
