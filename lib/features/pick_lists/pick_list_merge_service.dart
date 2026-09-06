import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_owned_details_codecs.dart';
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
    final ownedRows = await OwnedItemsRepository(_db).listActive();
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
      await repository.addValue(preview.listName, target,
          mediaKind: preview.mediaKind);
    });
  }

  Future<void> _mergeOwnedItems(
    String listName,
    Set<String> sourceSet,
    String target,
  ) async {
    final semanticName = pickListSemanticName(listName);
    final repository = OwnedItemsRepository(_db);
    final rows = await repository.listActive();
    for (final row in rows) {
      if (semanticName == 'condition' &&
          sourceSet.contains(normalizePickListValue(row.condition ?? ''))) {
        await repository.upsert(row.copyWith(condition: target));
      } else if (semanticName == 'grade' &&
          sourceSet.contains(normalizePickListValue(row.grade ?? ''))) {
        await repository.upsert(row.copyWith(grade: target));
      } else if (semanticName == 'purchase_store' &&
          sourceSet.contains(normalizePickListValue(row.purchaseStore ?? ''))) {
        await repository.upsert(row.copyWith(purchaseStore: target));
      } else if (semanticName == 'sold_to' &&
          sourceSet.contains(normalizePickListValue(row.soldTo ?? ''))) {
        await repository.upsert(row.copyWith(soldTo: target));
      } else if (semanticName == 'tags' && (row.tags?.isNotEmpty ?? false)) {
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
          await repository.upsert(row.copyWith(tags: replaced.join(', ')));
        }
      } else {
        final detailsKey = _ownedDetailsKey(semanticName);
        if (detailsKey != null) {
          final details = row.details.toJson();
          final value = details[detailsKey];
          if (value is String &&
              sourceSet.contains(normalizePickListValue(value))) {
            details[detailsKey] = target;
            final codec = collectarrOwnedDetailsCodecForKind(
              row.catalogRef.mediaKind,
            );
            await repository.upsert(
              row.copyWith(details: codec.fromJson(details)),
            );
          }
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

  List<String> _valuesForRow(String listName, OwnedItem row) {
    final semanticName = pickListSemanticName(listName);
    final detailsKey = _ownedDetailsKey(semanticName);
    if (detailsKey != null) {
      final value = row.details.toJson()[detailsKey];
      return value is String ? [value] : const [];
    }
    return switch (semanticName) {
      'condition' => [row.condition ?? ''],
      'grade' => [row.grade ?? ''],
      'purchase_store' => [row.purchaseStore ?? ''],
      'sold_to' => [row.soldTo ?? ''],
      'tags' => (row.tags ?? '')
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false),
      _ => const [],
    };
  }

  String? _ownedDetailsKey(String semanticName) {
    return switch (semanticName) {
      'raw_or_slabbed' => 'raw_or_slabbed',
      'grading_company' => 'grading_company',
      'grader_notes' => 'grader_notes',
      'signed_by' => 'signed_by',
      'label_type' => 'label_type',
      'custom_label' => 'custom_label',
      'page_quality' => 'page_quality',
      'certification_number' => 'certification_number',
      'key_category' => 'key_category',
      'key_severity' => 'key_severity',
      'features' => 'features',
      'region' => 'region',
      'packaging' => 'packaging',
      'distributor' => 'distributor',
      'game_completeness' => 'game_completeness',
      _ => null,
    };
  }
}
