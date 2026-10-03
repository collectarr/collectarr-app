import 'dart:convert';

import 'package:collectarr_app/core/models/library_entry_ref.dart';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details.dart';
import 'package:drift/drift.dart';

/// Maps Music-collection item data to its local Drift row.
final class MusicEntryLocalMapper {
  const MusicEntryLocalMapper._();

  static List<Map<String, dynamic>> _decodeMaps(String raw) {
    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return const <Map<String, dynamic>>[];
    }
    if (decoded is! List) return const <Map<String, dynamic>>[];
    return [
      for (final value in decoded)
        if (value is Map) Map<String, dynamic>.from(value),
    ];
  }
}
