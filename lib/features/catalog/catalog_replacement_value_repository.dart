import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';

/// Reads already projected replacement values without exposing catalog DTOs to
/// global statistics or presentation code.
final class CatalogReplacementValueRepository {
  CatalogReplacementValueRepository(
    this._db, {
    Iterable<CatalogKindTransportCodec>? codecs,
  }) : _codecs = codecs ?? collectarrKindCatalogTransportCodecs;

  final LocalDatabase _db;
  final Iterable<CatalogKindTransportCodec> _codecs;

  Future<Map<CatalogEntityRef, int>> findByRefs(
    Iterable<CatalogEntityRef> refs,
  ) async {
    final wanted = refs.toSet();
    if (wanted.isEmpty) return const {};

    final idsByKind = <CatalogMediaKind, Set<String>>{};
    for (final ref in wanted) {
      idsByKind.putIfAbsent(ref.mediaKind, () => <String>{}).add(ref.id);
    }
    final result = <CatalogEntityRef, int>{};
    for (final codec in _codecs) {
      final ids = idsByKind[codec.kind];
      if (ids == null || ids.isEmpty) continue;
      final values = await codec.replacementValuesByIds(_db, ids);
      for (final ref in wanted.where((ref) => ref.mediaKind == codec.kind)) {
        final value = values[ref.id];
        if (value != null) result[ref] = value;
      }
    }
    return result;
  }
}
