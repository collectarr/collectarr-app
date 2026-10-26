import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/settings/custom_fields_display_settings.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef _InspectorCustomFieldsRequest = ({
  LocalDatabase db,
  LibraryEntryRef libraryEntryRef,
});

final _inspectorCustomFieldsProvider = FutureProvider.autoDispose
    .family<_CustomFieldData, _InspectorCustomFieldsRequest>(
  (ref, request) async {
    final repo = CustomFieldRepository(request.db);
    final definitions = await repo.listDefinitions(
        mediaKind: request.libraryEntryRef.kind.apiValue);
    final values = await repo.listValuesForTarget(
      targetId: request.libraryEntryRef.key,
      targetScope: CustomFieldTargetScope.libraryEntry,
    );
    final display = <String, CustomFieldDisplaySettings>{};
    for (final definition in definitions) {
      if (definition.valueType == CustomFieldValueType.multiSelect ||
          definition.valueType == CustomFieldValueType.currency) {
        display[definition.id] =
            await CustomFieldDisplaySettings.read(definition.id);
      }
    }
    final tab = await CustomFieldsDisplaySettings.read(
        request.libraryEntryRef.kind.apiValue);
    return _CustomFieldData(
      display: display,
      tabName: tab.tabName,
      definitions: definitions,
      valueMap: {for (final v in values) v.fieldDefinitionId: v.value ?? ''},
    );
  },
);

/// Refresh labels and presentation after definition or tab settings are saved.
void invalidateInspectorCustomFields(ProviderContainer container) {
  container.invalidate(_inspectorCustomFieldsProvider);
}

class InspectorCustomFieldsSection extends ConsumerWidget {
  const InspectorCustomFieldsSection({
    super.key,
    required this.libraryEntryRef,
    required this.db,
    this.onFilterByValue,
  });

  final LibraryEntryRef libraryEntryRef;
  final LocalDatabase db;

  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref
        .watch(_inspectorCustomFieldsProvider(
          (db: db, libraryEntryRef: libraryEntryRef),
        ))
        .value;
    if (data == null || data.definitions.isEmpty) {
      return const SizedBox.shrink();
    }
    final resolved = <_ResolvedField>[];
    for (final def in data.definitions) {
      final value = data.valueMap[def.id];
      if (value != null && value.trim().isNotEmpty) {
        resolved.add(
          _ResolvedField(
            label: def.name,
            value: def.valueType == CustomFieldValueType.multiSelect &&
                    data.display[def.id]?.multiValueDisplay ==
                        CustomFieldMultiValueDisplay.list
                ? parseCustomFieldMultiValues(value).join('\n')
                : def.valueType == CustomFieldValueType.currency
                    ? '${AppFormats.current.currencyName(data.display[def.id]?.currencyCode)} $value'
                    : displayCustomFieldValue(def, value),
          ),
        );
      }
    }
    if (resolved.isEmpty) return const SizedBox.shrink();
    return LibraryDetailSection(
      title: data.tabName,
      children: [
        LibraryDetailFieldTable(
          fields: [
            for (final f in resolved)
              LibraryDetailField(
                label: f.label,
                value: f.value,
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
  const _CustomFieldData(
      {required this.definitions,
      required this.valueMap,
      required this.display,
      required this.tabName});
  final Map<String, CustomFieldDisplaySettings> display;
  final String tabName;
  final List<CustomFieldDefinition> definitions;
  final Map<String, String> valueMap;
}

class _ResolvedField {
  const _ResolvedField({required this.label, required this.value});
  final String label;
  final String value;
}
