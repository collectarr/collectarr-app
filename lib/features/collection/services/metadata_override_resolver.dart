import 'package:collectarr_app/core/models/metadata_field_id.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/user_metadata_override.dart';

/// Resolves opaque kind-entry metadata overrides for catalog display.
///
/// The host compares local entry references only. Field IDs and values remain
/// the responsibility of the owning kind.
class MetadataOverrideResolver {
  MetadataOverrideResolver(Iterable<UserMetadataOverride> overrides)
      : _byField = {
          for (final override in overrides)
            if (!override.isDeleted)
              _key(override.libraryEntryRef, override.fieldId): override,
        };

  final Map<(LibraryEntryRef, MetadataFieldId), UserMetadataOverride> _byField;

  static (LibraryEntryRef, MetadataFieldId) _key(
    LibraryEntryRef libraryEntryRef,
    MetadataFieldId fieldId,
  ) =>
      (libraryEntryRef, fieldId);

  bool get hasOverrides => _byField.isNotEmpty;

  Iterable<UserMetadataOverride> get overrides => _byField.values;

  UserMetadataOverride? find(
    LibraryEntryRef libraryEntryRef,
    MetadataFieldId fieldId,
  ) =>
      _byField[_key(libraryEntryRef, fieldId)];

  String? resolve(
    LibraryEntryRef libraryEntryRef,
    MetadataFieldId fieldId,
    String? original,
  ) =>
      find(libraryEntryRef, fieldId)?.overrideValue ?? original;

  Map<LibraryEntryRef, List<UserMetadataOverride>> groupedByLibraryEntry() {
    final result = <LibraryEntryRef, List<UserMetadataOverride>>{};
    for (final override in _byField.values) {
      result
          .putIfAbsent(override.libraryEntryRef, () => <UserMetadataOverride>[])
          .add(override);
    }
    return result;
  }
}
