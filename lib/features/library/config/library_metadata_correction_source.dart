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
  ) : _values = Map<String, Object?>.from(serialized);

  final Map<String, Object?> _values;

  Object? read(String key) => _values[key];

  void write(String key, Object? value) {
    if (value == null) {
      remove(key);
    } else {
      _values[key] = value;
    }
  }

  void remove(String key) => _values.remove(key);

  Map<String, Object?> toSerialized() => Map<String, Object?>.from(_values);
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
