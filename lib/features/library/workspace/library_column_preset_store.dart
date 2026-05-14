import 'dart:convert';

import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryColumnPresetStore {
  const LibraryColumnPresetStore(this.config);

  final LibraryWorkspaceConfig config;

  Future<List<LibraryTableColumnPreset>> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(config.preferenceKey('table_column_presets'));
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }
    return [
      for (final value in decoded)
        if (value is Map<String, dynamic>)
          _presetFromJson(value)
        else if (value is Map)
          _presetFromJson(Map<String, dynamic>.from(value)),
    ].where((preset) => preset.columns.isNotEmpty).toList(growable: false);
  }

  Future<List<LibraryTableColumnPreset>> savePreset({
    required String label,
    required Set<LibraryTableColumn> columns,
  }) async {
    final normalizedLabel = label.trim();
    if (normalizedLabel.isEmpty) {
      return read();
    }
    final existing = await read();
    final existingIndex = existing.indexWhere(
      (preset) => preset.label.toLowerCase() == normalizedLabel.toLowerCase(),
    );
    final nextId = existingIndex == -1
        ? '${_slug(normalizedLabel)}-${DateTime.now().microsecondsSinceEpoch}'
        : existing[existingIndex].id ??
            '${_slug(normalizedLabel)}-${DateTime.now().microsecondsSinceEpoch}';
    final nextPreset = LibraryTableColumnPreset(
      id: nextId,
      label: normalizedLabel,
      columns: {...columns, LibraryTableColumn.title},
    );
    final next = existing.toList(growable: true);
    if (existingIndex == -1) {
      next.add(nextPreset);
    } else {
      next[existingIndex] = nextPreset;
    }
    await _write(next);
    return next;
  }

  Future<List<LibraryTableColumnPreset>> deletePreset(String id) async {
    final next = [
      for (final preset in await read())
        if (preset.id != id) preset,
    ];
    await _write(next);
    return next;
  }

  Future<void> _write(List<LibraryTableColumnPreset> presets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      config.preferenceKey('table_column_presets'),
      jsonEncode([for (final preset in presets) _presetToJson(preset)]),
    );
  }

  LibraryTableColumnPreset _presetFromJson(Map<String, dynamic> json) {
    return LibraryTableColumnPreset(
      id: json['id'] as String?,
      label: json['label'] as String? ?? 'Saved preset',
      columns: {
        for (final value in (json['columns'] as List<dynamic>? ?? []))
          if (_columnByName(value.toString()) != null)
            _columnByName(value.toString())!,
      }..add(LibraryTableColumn.title),
    );
  }

  Map<String, dynamic> _presetToJson(LibraryTableColumnPreset preset) {
    return {
      'id': preset.id,
      'label': preset.label,
      'columns': [for (final column in preset.columns) column.name],
    };
  }

  LibraryTableColumn? _columnByName(String name) {
    for (final column in LibraryTableColumn.values) {
      if (column.name == name) {
        return column;
      }
    }
    return null;
  }

  String _slug(String value) {
    final slug = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'preset' : slug;
  }
}
