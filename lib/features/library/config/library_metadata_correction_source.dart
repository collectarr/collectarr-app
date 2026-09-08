import 'package:flutter/foundation.dart';

/// Structural metadata supplied to the correction form host.
///
/// The source is already decoded at the catalog/provider boundary. The form
/// host only owns title presentation and the opaque proposal payload; the
/// owning kind's contributor interprets field keys and values.
@immutable
final class LibraryMetadataCorrectionSource {
  const LibraryMetadataCorrectionSource({
    required this.title,
    required this.payload,
  });

  final String title;
  final Map<String, Object?> payload;
}
