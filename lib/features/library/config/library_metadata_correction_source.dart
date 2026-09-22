import 'package:flutter/foundation.dart';

/// Opaque values crossing the provider/admin correction boundary.
///
/// The generic correction host can pass this object to a kind contributor,
/// but cannot inspect catalog semantics. The only map in this class is the
/// serialization representation; all business code uses [read], [write], and
/// [remove].
final class LibraryMetadataCorrectionValues {
  LibraryMetadataCorrectionValues.fromSerialized(
    Map<String, Object?> serialized,
  )   : _values = Map<String, Object?>.from(serialized),
        _clearedKeys = {
          for (final entry in serialized.entries)
            if (entry.value == null) entry.key,
        };

  final Map<String, Object?> _values;
  final Set<String> _clearedKeys;

  Object? read(String key) => _values[key];

  void write(String key, Object? value) {
    if (value == null) {
      _values[key] = null;
      _clearedKeys.add(key);
    } else {
      _values[key] = value;
      _clearedKeys.remove(key);
    }
  }

  /// Omits the field from the proposal. Use [write] with null to send an
  /// explicit canonical clear operation.
  void remove(String key) {
    _values.remove(key);
    _clearedKeys.remove(key);
  }

  Map<String, Object?> toSerialized() => {
        ..._values,
        for (final key in _clearedKeys) key: null,
      };
}

/// Structural metadata supplied to the correction form host.
///
/// The source is already decoded at the catalog/provider boundary. The form
/// host only owns title presentation and the opaque values object; the owning
/// kind's contributor interprets field keys and values.
@immutable
final class LibraryMetadataCorrectionSource {
  const LibraryMetadataCorrectionSource({
    required this.title,
    required this.values,
  });

  final String title;
  final LibraryMetadataCorrectionValues values;
}
