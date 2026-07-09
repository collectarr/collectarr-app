import 'dart:convert';

import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibrarySortPresetStore {
  const LibrarySortPresetStore(this.config);

  final LibraryTypeConfig config;

  Future<List<LibrarySortPreset>> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(config.preferenceKey('sort_presets'));
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
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
      if (preset.rules.isNotEmpty) {
        presets.add(preset);
      }
    }
    return presets;
  }

  Future<List<LibrarySortPreset>> savePreset({
    String? id,
    required String label,
    required List<LibrarySortRule> rules,
  }) async {
    final normalizedLabel = label.trim();
    if (normalizedLabel.isEmpty) {
      return read();
    }

    final next = (await read()).toList(growable: true);
    final nextPreset = LibrarySortPreset(
      id: id ?? '${_slug(normalizedLabel)}-${DateTime.now().microsecondsSinceEpoch}',
      label: normalizedLabel,
      rules: List<LibrarySortRule>.unmodifiable(_dedupeRules(rules)),
    );
    final existingIndex = next.indexWhere((preset) => preset.id == nextPreset.id);
    if (existingIndex >= 0) {
      next[existingIndex] = nextPreset;
    } else {
      next.add(nextPreset);
    }
    await _write(next);
    return next;
  }

  Future<List<LibrarySortPreset>> deletePreset(String id) async {
    final next = [
      for (final preset in await read())
        if (preset.id != id) preset,
    ];
    await _write(next);
    return next;
  }

  Future<void> _write(List<LibrarySortPreset> presets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      config.preferenceKey('sort_presets'),
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
    return {
      'id': preset.id,
      'label': preset.label,
      'rules': [
        for (final rule in _dedupeRules(preset.rules))
          {
            'column': config.sortColumnDefinitionFor(rule.column).id,
            'ascending': rule.ascending,
          },
      ],
    };
  }

  List<LibrarySortRule> _decodeRules(dynamic rawRules) {
    if (rawRules is! List) {
      return const [];
    }
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
      final column = config.sortColumnFromFieldId(columnName);
      if (column == null) {
        continue;
      }
      rules.add(
        LibrarySortRule(
          column: column,
          ascending: json['ascending'] != false,
        ),
      );
    }
    return _dedupeRules(rules);
  }

  List<LibrarySortRule> _dedupeRules(List<LibrarySortRule> rules) {
    final seen = <Object>{};
    final deduped = <LibrarySortRule>[];
    for (final rule in rules) {
      if (!config.supportsSortColumn(rule.column)) {
        continue;
      }
      if (seen.add(rule.column)) {
        deduped.add(rule);
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
}