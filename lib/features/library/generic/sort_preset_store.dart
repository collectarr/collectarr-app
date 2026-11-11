import 'dart:convert';

import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/config.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_registry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibrarySortPresetStore {
  const LibrarySortPresetStore(this.config);

  final LibraryKindRegistration config;

  Future<List<LibrarySortPreset>> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(config.identity.preferenceKey('sort_presets'));
    if (raw == null || raw.trim().isEmpty) {
      return _initializeFavorites();
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return _initializeFavorites();
    }

    final presets = <LibrarySortPreset>[];
    for (final value in decoded) {
      final json = switch (value) {
        Map<String, dynamic> typed => typed,
        Map<dynamic, dynamic> map => Map<String, dynamic>.from(map),
        _ => null,
      };
      if (json == null) {
        continue;
      }
      final preset = _presetFromJson(json);
      if (preset.id != null &&
          preset.id!.isNotEmpty &&
          preset.rules.isNotEmpty) {
        presets.add(preset);
      }
    }
    return presets.isEmpty ? _initializeFavorites() : presets;
  }

  Future<List<LibrarySortPreset>> _initializeFavorites() async {
    final defaults = libraryPresentationForKind(config.kind).sortFavorites;
    final initial = [
      for (final favorite in defaults)
        LibrarySortPreset(
            id: favorite.id, label: favorite.label, rules: favorite.rules),
    ];
    if (initial.isEmpty) {
      final field = _fields.sortDefinitionFor(_fields.defaultSort);
      initial.add(LibrarySortPreset(id: 'default', label: field.label, rules: [
        LibrarySortRule(
            column: field.id.value, ascending: field.defaultAscending)
      ]));
    }
    await _write(initial);
    return initial;
  }

  Future<void> saveFavorites(List<LibrarySortPreset> favorites) async {
    if (favorites.isEmpty ||
        favorites.any((favorite) =>
            favorite.id == null || _dedupeRules(favorite.rules).isEmpty)) {
      throw ArgumentError(
          'Keep at least one favorite and one field per favorite.');
    }
    await _write(favorites);
  }

  Future<List<LibrarySortPreset>> savePreset({
    String? id,
    required String label,
    required List<LibrarySortRule> rules,
  }) async {
    final normalizedLabel = label.trim();
    final normalizedRules = _dedupeRules(rules);
    if (normalizedLabel.isEmpty || normalizedRules.isEmpty) {
      return read();
    }

    final next = (await read()).toList(growable: true);
    final nextPreset = LibrarySortPreset(
      id: id ??
          '${_slug(normalizedLabel)}-${DateTime.now().microsecondsSinceEpoch}',
      label: normalizedLabel,
      rules: List<LibrarySortRule>.unmodifiable(normalizedRules),
    );
    final existingIndex =
        next.indexWhere((preset) => preset.id == nextPreset.id);
    if (existingIndex >= 0) {
      next[existingIndex] = nextPreset;
    } else {
      next.add(nextPreset);
    }
    await _write(next);
    return next;
  }

  Future<List<LibrarySortPreset>> deletePreset(String id) async {
    final current = await read();
    if (current.length <= 1) return current;
    final next = [
      for (final preset in current)
        if (preset.id != id) preset,
    ];
    await _write(next);
    return next;
  }

  Future<void> _write(List<LibrarySortPreset> presets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      config.identity.preferenceKey('sort_presets'),
      jsonEncode([
        for (final preset in presets) _presetToJson(preset),
      ]),
    );
  }

  LibrarySortPreset _presetFromJson(Map<String, dynamic> json) {
    return LibrarySortPreset(
      id: json['id'] as String?,
      label: json['label'] as String? ?? 'Saved sort',
      rules: _decodeRules(json['rules']),
    );
  }

  Map<String, dynamic> _presetToJson(LibrarySortPreset preset) {
    final fields = _fields;
    return {
      'id': preset.id,
      'label': preset.label,
      'rules': [
        for (final rule in _dedupeRules(preset.rules))
          {
            'column': fields
                    .findSortDefinition(fields.decodeSortId(rule.column))
                    ?.id
                    .value ??
                rule.column.toString(),
            'ascending': rule.ascending,
          },
      ],
    };
  }

  List<LibrarySortRule> _decodeRules(dynamic rawRules) {
    if (rawRules is! List) {
      return const [];
    }
    final fields = _fields;
    final rules = <LibrarySortRule>[];
    for (final value in rawRules) {
      final json = switch (value) {
        Map<String, dynamic> typed => typed,
        Map<dynamic, dynamic> map => Map<String, dynamic>.from(map),
        _ => null,
      };
      if (json == null) {
        continue;
      }
      final columnName = json['column']?.toString();
      if (columnName == null) continue;
      final sortDef = fields.findSortDefinition(
        fields.decodeSortId(columnName),
      );
      if (sortDef == null) {
        continue;
      }
      rules.add(
        LibrarySortRule(
          column: sortDef.id.value,
          ascending: json['ascending'] != false,
        ),
      );
    }
    return _dedupeRules(rules);
  }

  List<LibrarySortRule> _dedupeRules(List<LibrarySortRule> rules) {
    final fields = _fields;
    final seen = <String>{};
    final deduped = <LibrarySortRule>[];
    for (final rule in rules) {
      final sortDef = fields.findSortDefinition(
        fields.decodeSortId(rule.column),
      );
      if (sortDef == null) {
        continue;
      }
      if (seen.add(sortDef.id.value)) {
        deduped.add(rule.copyWith(column: sortDef.id.value));
      }
    }
    return deduped;
  }

  String _slug(String value) {
    final slug = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'sort' : slug;
  }

  LibraryFieldRegistry<LibraryWorkspaceDto> get _fields =>
      libraryKindWorkspaceForKind(config.kind).workspaceFields;
}
