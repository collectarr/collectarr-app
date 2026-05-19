import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:flutter/material.dart';

class InspectorCustomFieldsSection extends StatelessWidget {
  const InspectorCustomFieldsSection({
    super.key,
    required this.ownedItemId,
    required this.mediaKind,
    required this.db,
    required this.accent,
  });

  final String ownedItemId;
  final String mediaKind;
  final LocalDatabase db;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final repo = CustomFieldRepository(db);
    return FutureBuilder<_CustomFieldData>(
      future: _load(repo),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final data = snapshot.data!;
        if (data.definitions.isEmpty) return const SizedBox.shrink();
        final resolved = <_ResolvedField>[];
        for (final def in data.definitions) {
          final value = data.valueMap[def.id];
          if (value != null && value.trim().isNotEmpty) {
            resolved.add(_ResolvedField(label: def.name, value: value));
          }
        }
        if (resolved.isEmpty) return const SizedBox.shrink();
        return LibraryInspectorSection(
          title: 'Custom fields',
          accentColor: accent,
          children: [
            LibraryInspectorFactGrid(
              facts: [
                for (final f in resolved)
                  LibraryInspectorFactData(f.label, f.value),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<_CustomFieldData> _load(CustomFieldRepository repo) async {
    final definitions = await repo.listDefinitions(mediaKind: mediaKind);
    final values = await repo.listValuesForItem(ownedItemId);
    return _CustomFieldData(
      definitions: definitions,
      valueMap: {for (final v in values) v.fieldDefinitionId: v.value ?? ''},
    );
  }
}

class _CustomFieldData {
  const _CustomFieldData({required this.definitions, required this.valueMap});
  final List<CustomFieldDefinition> definitions;
  final Map<String, String> valueMap;
}

class _ResolvedField {
  const _ResolvedField({required this.label, required this.value});
  final String label;
  final String value;
}
