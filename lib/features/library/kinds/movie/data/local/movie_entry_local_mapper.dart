import 'dart:convert';

import 'package:collectarr_app/core/models/library_entry_ref.dart';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details.dart';
import 'package:drift/drift.dart';

/// Maps Movie-collection item state to its local Drift row.
final class MovieEntryLocalMapper {
  const MovieEntryLocalMapper._();





  static List<String> _decodeStringList(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! List) return const <String>[];
    return decoded.whereType<String>().toList(growable: false);
  }

  static dynamic _decodeJson(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }
}
