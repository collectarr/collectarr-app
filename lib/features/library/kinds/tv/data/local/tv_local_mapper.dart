import 'dart:convert';

import 'package:collectarr_app/core/models/library_entry_ref.dart';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/tv/entries/tv_entry_details.dart';
import 'package:drift/drift.dart';

/// Maps TV-collection item state to its App-entry Drift row.
///
/// TV catalog data lives in the shared Catalog Item cache; this mapper only
/// handles personal entry state.
final class TvLocalMapper {
  const TvLocalMapper._();





  static dynamic _decodeJson(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  static List<String> _decodeStrings(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! List) return const <String>[];
    return decoded.whereType<String>().toList(growable: false);
  }
}
