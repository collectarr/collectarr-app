import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'dart:convert';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/features/library/entries/library_entries_repository.dart';
import 'pick_list_references.dart';
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
  PickListMergeService(this._db,
      {PickListRepository? repository,
      Iterable<PickListDefinitionContributor> contributors = const []})
      : repository =
            repository ?? PickListRepository(_db, contributors: contributors),
        _contributors = contributors.toList(growable: false);
  final LocalDatabase _db;
  final PickListRepository repository;
  final List<PickListDefinitionContributor> _contributors;

  CatalogMediaKind? _kind(String listName, String? mediaKind) {
    final kind = catalogMediaKindFromApiValue(
        listName.contains('.') ? listName.split('.').first : mediaKind);
    return kind.isUnknown ? null : kind;
  }

  Future<PickListMergePreview> previewMerge(
      {required String listName,
      required List<String> sourceValues,
      required String targetValue,
      required String? mediaKind}) async {
    final sources = sourceValues.map(normalizePickListValue).toSet()
      ..remove(normalizePickListValue(targetValue));
    final refs = <String>{};
    var affectedCount = 0;
    if (PickListReferences(_db).handles(listName)) {
      for (final entry
          in (await PickListReferences(_db).usages(listName, mediaKind))
              .entries) {
        if (sources.contains(normalizePickListValue(entry.key))) {
          refs.addAll(entry.value.map((ref) => ref.key));
        }
      }
    } else if (listName.startsWith('customField:')) {
      for (final row in await _customRows(listName, mediaKind)) {
        if (row.$2
            .any((value) => sources.contains(normalizePickListValue(value)))) {
          refs.add(row.$1.targetId);
        }
      }
    } else {
      final kind = _kind(listName, mediaKind);
      for (final contributor in _contributors) {
        if (kind != null && contributor.kind != kind) continue;
        final result = await contributor.previewEntryMerge(
            _db, pickListSemanticName(listName), sources);
        affectedCount += result.affectedCount;
        refs.addAll(result.sampleValues.take(5));
      }
    }
    return PickListMergePreview(
        listName: listName,
        mediaKind: mediaKind,
        sourceValues: sourceValues,
        targetValue: targetValue,
        affectedCount: affectedCount > 0 ? affectedCount : refs.length,
        sampleValues: refs.take(5).toList());
  }

  Future<void> rename(PickListValue original, PickListValue replacement,
      {String? mediaKind}) async {
    final values = await repository.valuesForList(
        listName: original.listName, mediaKind: mediaKind);
    if (values.any((value) =>
        value.id != original.id &&
        value.effectiveNormalizedValue ==
            replacement.effectiveNormalizedValue)) {
      throw StateError(
          'This name already exists. Use Merge Mode to combine values.');
    }
    await _db.transaction(() async {
      await _replaceReferences(original.listName, mediaKind,
          {original.effectiveNormalizedValue}, replacement.value.trim());
      if (original.effectiveNormalizedValue !=
          replacement.effectiveNormalizedValue) {
        await _hide(original, mediaKind);
      }
      await repository.upsertValue(replacement);
      if (original.sortName == replacement.sortName) return;
      final kind = _kind(original.listName, mediaKind);
      for (final contributor in _contributors) {
        if (kind == null || contributor.kind == kind) {
          await contributor.updateSortName(
              _db,
              pickListSemanticName(original.listName),
              replacement.value,
              replacement.sortName);
        }
      }
    });
  }

  Future<void> remove(PickListValue value, {String? mediaKind}) async {
    await _db.transaction(() async {
      await _replaceReferences(
          value.listName, mediaKind, {value.effectiveNormalizedValue}, '');
      await _hide(value, mediaKind);
    });
  }

  Future<void> _hide(PickListValue value, String? mediaKind) async {
    final stored = await repository.valuesForList(
        listName: value.listName, mediaKind: mediaKind);
    for (final row in stored) {
      if (row.mediaKind == mediaKind &&
          row.effectiveNormalizedValue == value.effectiveNormalizedValue) {
        await repository.deleteValue(row.id);
      }
    }
    await repository.hideValue(PickListValue(
        id: 'hidden:${mediaKind ?? 'global'}:${value.listName}:${value.effectiveNormalizedValue}',
        listName: value.listName,
        mediaKind: mediaKind,
        value: value.value,
        sortName: value.sortName,
        sortOrder: value.sortOrder));
  }

  Future<void> applyMerge(PickListMergePreview preview) async {
    final target = preview.targetValue.trim();
    if (target.isEmpty) throw ArgumentError('Choose a merge target.');
    final sources = preview.sourceValues.map(normalizePickListValue).toSet()
      ..remove(normalizePickListValue(target));
    if (sources.isEmpty) return;
    await _db.transaction(() async {
      await _replaceReferences(
          preview.listName, preview.mediaKind, sources, target);
      final rows = await repository.valuesForList(
          listName: preview.listName, mediaKind: preview.mediaKind);
      for (final source in preview.sourceValues) {
        final normalized = normalizePickListValue(source);
        if (!sources.contains(normalized)) continue;
        final row = rows
            .where((value) => value.effectiveNormalizedValue == normalized)
            .firstOrNull;
        await _hide(
            row ??
                PickListValue(
                    id: 'option:${preview.listName}:$normalized',
                    listName: preview.listName,
                    mediaKind: preview.mediaKind,
                    value: source),
            preview.mediaKind);
      }
      // Keep an existing destination's identity, sort name and position.
      if (!rows.any((row) =>
          row.effectiveNormalizedValue == normalizePickListValue(target))) {
        await repository.addValue(preview.listName, target,
            mediaKind: preview.mediaKind);
      }
    });
  }

  Future<void> _replaceReferences(String listName, String? mediaKind,
      Set<String> sources, String target) async {
    if (PickListReferences(_db).handles(listName)) {
      await PickListReferences(_db)
          .replace(listName, mediaKind, sources, target);
      return;
    }
    if (listName.startsWith('customField:')) {
      for (final item in await _customRows(listName, mediaKind)) {
        final row = item.$1;
        if (!item.$2
            .any((value) => sources.contains(normalizePickListValue(value)))) {
          continue;
        }
        final seen = <String>{};
        final replaced = item.$2
            .map((value) => sources.contains(normalizePickListValue(value))
                ? target
                : value)
            .where((value) =>
                value.isNotEmpty && seen.add(normalizePickListValue(value)))
            .toList();
        await (_db.update(_db.customFieldValuesCache)
              ..where((t) => t.id.equals(row.id)))
            .write(CustomFieldValuesCacheCompanion(
                value: Value(item.$3
                    ? encodeCustomFieldMultiValues(replaced)
                    : replaced.firstOrNull),
                updatedAt: Value(DateTime.now().toUtc())));
        if (row.targetScope == CustomFieldTargetScope.libraryEntry.apiValue) {
          await enqueueLibraryEntrySnapshot(
              _db, LibraryEntryRef.fromKey(row.targetId));
        }
      }
      return;
    }
    final kind = _kind(listName, mediaKind);
    final before = {
      for (final entry in await LibraryEntryStore(_db).list(kind: kind))
        '${entry.kind.apiValue}:${entry.id}': jsonEncode(entry.toJson())
    };
    for (final contributor in _contributors) {
      if (kind != null && contributor.kind != kind) continue;
      await contributor.applyEntryMerge(
          _db, pickListSemanticName(listName), sources, target);
      final remaining = sources.difference({normalizePickListValue(target)});
      if (remaining.isNotEmpty) {
        final result = await contributor.previewEntryMerge(
            _db, pickListSemanticName(listName), remaining);
        if (result.affectedCount > 0) {
          throw StateError(
              'This field does not yet support updating referenced values. No changes were saved.');
        }
      }
    }
    for (final entry in await LibraryEntryStore(_db).list(kind: kind)) {
      if (before['${entry.kind.apiValue}:${entry.id}'] ==
          jsonEncode(entry.toJson())) {
        continue;
      }
      await LibraryEntryStore(_db).put(LibraryEntryRecord(
          id: entry.id,
          kind: entry.kind,
          catalogData: entry.catalogData,
          personalData: entry.personalData,
          sourceCatalogRef: entry.sourceCatalogRef,
          deletedAt: entry.deletedAt,
          updatedAt: DateTime.now().toUtc()));
      await enqueueLibraryEntrySnapshot(
          _db, LibraryEntryRef(kind: entry.kind, id: LibraryEntryId(entry.id)));
    }
  }

  Future<List<(CustomFieldValuesCacheData, List<String>, bool)>> _customRows(
      String listName, String? mediaKind) async {
    final fieldId = listName.substring('customField:'.length);
    final definition = await (_db.select(_db.customFieldDefinitionsCache)
          ..where((t) => t.id.equals(fieldId)))
        .getSingleOrNull();
    if (definition == null ||
        (mediaKind != null &&
            definition.mediaKind != null &&
            definition.mediaKind != mediaKind)) {
      return [];
    }
    final multi =
        CustomFieldValueType.fromApiValue(definition.fieldType).isMultiValue;
    final active = {
      for (final entry in await LibraryEntryStore(_db).list())
        if (mediaKind == null || entry.kind.apiValue == mediaKind)
          LibraryEntryRef(kind: entry.kind, id: LibraryEntryId(entry.id)).key
    };
    return [
      for (final row in await (_db.select(_db.customFieldValuesCache)
            ..where((t) => t.fieldDefinitionId.equals(fieldId)))
          .get())
        if (row.targetScope == CustomFieldTargetScope.libraryEntry.apiValue &&
            active.contains(row.targetId))
          (
            row,
            multi
                ? parseCustomFieldMultiValues(row.value)
                : [if (row.value != null) row.value!],
            multi
          )
    ];
  }
}
