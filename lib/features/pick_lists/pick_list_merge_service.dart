import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:drift/drift.dart';

class PickListMergePreview {
  const PickListMergePreview({
    required this.listName,
    required this.mediaKind,
    required this.sourceValues,
    required this.targetValue,
    required this.affectedCount,
    required this.sampleValues,
  });

  final String listName;
  final String? mediaKind;
  final List<String> sourceValues;
  final String targetValue;
  final int affectedCount;
  final List<String> sampleValues;
}

class PickListMergeService {
  PickListMergeService(this._db, {PickListRepository? repository})
      : repository = repository ?? PickListRepository(_db);

  final LocalDatabase _db;
  final PickListRepository repository;

  Future<PickListMergePreview> previewMerge({
    required String listName,
    required List<String> sourceValues,
    required String targetValue,
    required String? mediaKind,
  }) async {
    final normalizedSources = {
      for (final value in sourceValues) normalizePickListValue(value),
    };
    var affected = 0;
    final samples = <String>[];
    final ownedRows = await _db.select(_db.ownedItemsCache).get();
    for (final row in ownedRows) {
      final rowValues = _valuesForRow(listName, row);
      if (rowValues.any(normalizedSources.contains)) {
        affected += 1;
        if (samples.length < 5) {
          samples.add(row.id);
        }
      }
    }
    final customRows = await _db.select(_db.customFieldValuesCache).get();
    for (final row in customRows) {
      final rowValue = normalizePickListValue(row.value ?? '');
      if (normalizedSources.contains(rowValue)) {
        affected += 1;
        if (samples.length < 5) {
          samples.add(row.id);
        }
      }
    }
    return PickListMergePreview(
      listName: listName,
      mediaKind: mediaKind,
      sourceValues: sourceValues,
      targetValue: targetValue,
      affectedCount: affected,
      sampleValues: samples,
    );
  }

  Future<void> applyMerge(PickListMergePreview preview) async {
    final sourceSet = {
      for (final value in preview.sourceValues) normalizePickListValue(value),
    };
    final target = preview.targetValue.trim();
    await _db.transaction(() async {
      await _mergeOwnedItems(preview.listName, sourceSet, target);
      await _mergeCustomFieldValues(sourceSet, target);
      final rows = await repository.valuesForList(
        listName: preview.listName,
        mediaKind: preview.mediaKind,
      );
      for (final row in rows) {
        if (sourceSet.contains(row.effectiveNormalizedValue)) {
          await repository.deleteValue(row.id);
        }
      }
      await repository.addValue(preview.listName, target, mediaKind: preview.mediaKind);
    });
  }

  Future<void> _mergeOwnedItems(
    String listName,
    Set<String> sourceSet,
    String target,
  ) async {
    final rows = await _db.select(_db.ownedItemsCache).get();
    for (final row in rows) {
      if (listName == 'condition' && sourceSet.contains(normalizePickListValue(row.condition ?? ''))) {
        await (_db.update(_db.ownedItemsCache)
              ..where((table) => table.id.equals(row.id)))
            .write(OwnedItemsCacheCompanion(condition: Value(target)));
      } else if (listName == 'grade' && sourceSet.contains(normalizePickListValue(row.grade ?? ''))) {
        await (_db.update(_db.ownedItemsCache)
              ..where((table) => table.id.equals(row.id)))
            .write(OwnedItemsCacheCompanion(grade: Value(target)));
      } else if (listName == 'purchase_store' && sourceSet.contains(normalizePickListValue(row.purchaseStore ?? ''))) {
        await (_db.update(_db.ownedItemsCache)
              ..where((table) => table.id.equals(row.id)))
            .write(OwnedItemsCacheCompanion(purchaseStore: Value(target)));
      } else if (listName == 'sold_to' && sourceSet.contains(normalizePickListValue(row.soldTo ?? ''))) {
        await (_db.update(_db.ownedItemsCache)
              ..where((table) => table.id.equals(row.id)))
            .write(OwnedItemsCacheCompanion(soldTo: Value(target)));
      } else if (listName == 'region' && sourceSet.contains(normalizePickListValue(row.region ?? ''))) {
        await (_db.update(_db.ownedItemsCache)
              ..where((table) => table.id.equals(row.id)))
            .write(OwnedItemsCacheCompanion(region: Value(target)));
      } else if (listName == 'packaging' && sourceSet.contains(normalizePickListValue(row.packaging ?? ''))) {
        await (_db.update(_db.ownedItemsCache)
              ..where((table) => table.id.equals(row.id)))
            .write(OwnedItemsCacheCompanion(packaging: Value(target)));
      } else if (listName == 'distributor' && sourceSet.contains(normalizePickListValue(row.distributor ?? ''))) {
        await (_db.update(_db.ownedItemsCache)
              ..where((table) => table.id.equals(row.id)))
            .write(OwnedItemsCacheCompanion(distributor: Value(target)));
      } else if (listName == 'game_completeness' && sourceSet.contains(normalizePickListValue(row.gameCompleteness ?? ''))) {
        await (_db.update(_db.ownedItemsCache)
              ..where((table) => table.id.equals(row.id)))
            .write(OwnedItemsCacheCompanion(gameCompleteness: Value(target)));
      } else if (listName == 'tags' && (row.tags?.isNotEmpty ?? false)) {
        final tags = row.tags!
            .split(',')
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList(growable: false);
        final replaced = tags.map((value) {
          final normalized = normalizePickListValue(value);
          return sourceSet.contains(normalized) ? target : value;
        }).toList(growable: false);
        if (replaced.join(', ') != row.tags) {
          await (_db.update(_db.ownedItemsCache)
                ..where((table) => table.id.equals(row.id)))
              .write(OwnedItemsCacheCompanion(tags: Value(replaced.join(', '))));
        }
      }
    }
  }

  Future<void> _mergeCustomFieldValues(
    Set<String> sourceSet,
    String target,
  ) async {
    final rows = await _db.select(_db.customFieldValuesCache).get();
    for (final row in rows) {
      if (!sourceSet.contains(normalizePickListValue(row.value ?? ''))) {
        continue;
      }
      await (_db.update(_db.customFieldValuesCache)
            ..where((table) => table.id.equals(row.id)))
          .write(
            CustomFieldValuesCacheCompanion(value: Value(target)),
          );
    }
  }

  List<String> _valuesForRow(String listName, OwnedItemsCacheData row) {
    return switch (listName) {
      'condition' => [row.condition ?? ''],
      'grade' => [row.grade ?? ''],
      'purchase_store' => [row.purchaseStore ?? ''],
      'sold_to' => [row.soldTo ?? ''],
      'region' => [row.region ?? ''],
      'packaging' => [row.packaging ?? ''],
      'distributor' => [row.distributor ?? ''],
      'game_completeness' => [row.gameCompleteness ?? ''],
      'tags' => (row.tags ?? '')
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false),
      _ => const [],
    };
  }
}
