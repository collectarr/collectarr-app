import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';

/// Reads already projected replacement values without exposing catalog DTOs to
/// global statistics or presentation code.
final class CatalogReplacementValueRepository {
  CatalogReplacementValueRepository(
    this._db, {
    Iterable<CatalogKindRepositoryCodec>? codecs,
  }) : _codecs = codecs ?? collectarrKindCatalogRepositoryCodecs;

  final LocalDatabase _db;
  final Iterable<CatalogKindRepositoryCodec> _codecs;

  Future<Map<String, int>> findByIds(Iterable<String> ids) async {
    final wanted = ids.toSet();
    if (wanted.isEmpty) return const {};

    final result = <String, int>{};
    for (final codec in _codecs) {
      for (final item in await codec.list(_db)) {
        if (!wanted.contains(item.id)) continue;
        final value = codec.replacementValueCents(item);
        if (value != null) result[item.id] = value;
      }
    }
    return result;
  }
}
