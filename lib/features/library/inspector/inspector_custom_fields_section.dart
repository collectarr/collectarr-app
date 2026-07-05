import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef _InspectorCustomFieldsRequest = ({
  LocalDatabase db,
  String ownedItemId,
  String mediaKind,
});

final _inspectorCustomFieldsProvider = FutureProvider.autoDispose
    .family<_CustomFieldData, _InspectorCustomFieldsRequest>(
  (ref, request) async {
    final repo = CustomFieldRepository(request.db);
    final definitions =
        await repo.listDefinitions(mediaKind: request.mediaKind);
    final values = await repo.listValuesForTarget(
      targetId: request.ownedItemId,
      targetScope: CustomFieldTargetScope.ownedCopy,
    );
    return _CustomFieldData(
      definitions: definitions,
      valueMap: {for (final v in values) v.fieldDefinitionId: v.value ?? ''},
    );
  },
);

class InspectorCustomFieldsSection extends ConsumerWidget {
  const InspectorCustomFieldsSection({
    super.key,
    required this.ownedItemId,
    required this.mediaKind,
    required this.db,
    required this.accent,
    this.onFilterByValue,
  });

  final String ownedItemId;
  final String mediaKind;
  final LocalDatabase db;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref
        .watch(_inspectorCustomFieldsProvider(
          (db: db, ownedItemId: ownedItemId, mediaKind: mediaKind),
        ))
        .value;
    if (data == null || data.definitions.isEmpty) {
      return const SizedBox.shrink();
    }
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
              LibraryInspectorFactData(
                f.label,
                f.value,
                onTap: onFilterByValue == null || f.value.trim().isEmpty
                    ? null
                    : () => onFilterByValue!(f.value),
                tooltip: 'Show all with ${f.value}',
              ),
          ],
        ),
      ],
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
