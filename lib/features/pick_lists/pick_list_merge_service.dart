import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
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
  PickListMergeService(
    this._db, {
    PickListRepository? repository,
    Iterable<PickListDefinitionContributor> contributors = const [],
  })  : repository =
            repository ?? PickListRepository(_db, contributors: contributors),
        _contributors = contributors.toList(growable: false);

  final LocalDatabase _db;
  final PickListRepository repository;
  final List<PickListDefinitionContributor> _contributors;

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
    final semanticName = pickListSemanticName(listName);
    final requestedKind =
        mediaKind == null ? null : catalogMediaKindFromApiValue(mediaKind);
    for (final contributor in _contributors) {
      if (requestedKind != null && contributor.kind != requestedKind) {
        continue;
      }
      final result = await contributor.previewOwnedMerge(
        _db,
        semanticName,
        normalizedSources,
      );
      affected += result.affectedCount;
      for (final sample in result.sampleValues) {
        if (samples.length >= 5) break;
        samples.add(sample);
      }
    }
    final customRows = await _db.select(_db.customFieldValuesCache).get();
    final customDefinitions = {
      for (final definition
          in await _db.select(_db.customFieldDefinitionsCache).get())
        definition.id: definition,
    };
    for (final row in customRows) {
      if (!_customFieldApplies(
        customDefinitions[row.fieldDefinitionId],
        mediaKind,
      )) {
        continue;
      }
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
      await _mergeOwnedItems(
        preview.listName,
        preview.mediaKind,
        sourceSet,
        target,
      );
      await _mergeCustomFieldValues(
        sourceSet,
        target,
        mediaKind: preview.mediaKind,
      );
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
    String? mediaKind,
    Set<String> sourceSet,
    String target,
  ) async {
    final semanticName = pickListSemanticName(listName);
    final requestedKind =
        mediaKind == null ? null : catalogMediaKindFromApiValue(mediaKind);
    for (final contributor in _contributors) {
      if (requestedKind != null && contributor.kind != requestedKind) {
        continue;
      }
      await contributor.applyOwnedMerge(
        _db,
        semanticName,
        sourceSet,
        target,
      );
    }
  }

  Future<void> _mergeCustomFieldValues(Set<String> sourceSet, String target,
      {required String? mediaKind}) async {
    final rows = await _db.select(_db.customFieldValuesCache).get();
    final definitions = {
      for (final definition
          in await _db.select(_db.customFieldDefinitionsCache).get())
        definition.id: definition,
    };
    for (final row in rows) {
      if (!_customFieldApplies(
        definitions[row.fieldDefinitionId],
        mediaKind,
      )) {
        continue;
      }
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

  bool _customFieldApplies(
    CustomFieldDefinitionsCacheData? definition,
    String? mediaKind,
  ) {
    if (mediaKind == null) return true;
    return definition == null ||
        definition.mediaKind == null ||
        definition.mediaKind == mediaKind;
  }
}
