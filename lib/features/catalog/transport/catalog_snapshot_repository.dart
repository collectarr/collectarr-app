import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';

/// Reads complete catalog snapshots at an explicit serialization boundary.
///
/// A snapshot is transport-shaped data used by sync, metadata refresh and
/// legacy edit flows. Mixed/global Library code must use
/// [CatalogDisplaySummaryRepository] instead, and kind code should decode a
/// snapshot immediately into its concrete domain model.
final class CatalogSnapshotRepository {
  CatalogSnapshotRepository(
    this._db, {
    Iterable<CatalogKindRepositoryCodec> codecs =
        collectarrKindCatalogRepositoryCodecs,
  }) : _codecs = {
          for (final codec in codecs) codec.kind: codec,
        };

  final LocalDatabase _db;
  final Map<CatalogMediaKind, CatalogKindRepositoryCodec> _codecs;

  Future<Map<String, CatalogItemDto>> findByIds(Iterable<String> ids) async {
    final wanted = ids.toSet();
    if (wanted.isEmpty) return const {};
    final result = <String, CatalogItemDto>{};
    for (final item in await _allItems()) {
      if (wanted.contains(item.id)) result[item.id] = item;
    }
    return result;
  }

  Future<List<CatalogItemDto>> findAll({String? kind}) async {
    final normalizedKind = kind?.trim().toLowerCase();
    final requestedKind = normalizedKind == null || normalizedKind.isEmpty
        ? null
        : normalizedKind;
    return [
      for (final item in await _allItems())
        if (requestedKind == null || item.kind == requestedKind) item,
    ];
  }

  Future<CatalogItemDto?> findById(String id) async {
    final normalized = id.trim();
    if (normalized.isEmpty) return null;
    return (await findByIds([normalized]))[normalized];
  }

  Future<List<CatalogItemDto>> _allItems() async {
    final result = <CatalogItemDto>[];
    for (final codec in _codecs.values) {
      result.addAll(await codec.list(_db));
    }
    return result;
  }
}
