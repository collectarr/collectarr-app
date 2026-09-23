import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryCustomFieldCache {
  const LibraryCustomFieldCache({
    required this.valuesByItem,
    required this.valuesByDefinitionByItem,
    required this.definitions,
  });

  final Map<String, List<String>> valuesByItem;
  final Map<String, Map<String, String>> valuesByDefinitionByItem;
  final List<CustomFieldDefinition> definitions;
}

final libraryCustomFieldCacheProvider =
    FutureProvider.family<LibraryCustomFieldCache, String?>(
        (ref, mediaKind) async {
  final db = ref.read(localDatabaseProvider);
  final repo = CustomFieldRepository(db);
  final allValues = await repo.listAllValues();
  final definitions = await repo.listDefinitions(mediaKind: mediaKind);
  final flat = <String, List<String>>{};
  final structured = <String, Map<String, String>>{};
  for (final entry in allValues.entries) {
    final valuesByDefinition = <String, String>{};
    flat[entry.key] = [
      for (final value in entry.value)
        if (value.value != null && value.value!.trim().isNotEmpty) value.value!,
    ];
    for (final value in entry.value) {
      final normalized = value.value?.trim();
      if (normalized == null || normalized.isEmpty) {
        continue;
      }
      valuesByDefinition[value.fieldDefinitionId] = normalized;
    }
    if (valuesByDefinition.isNotEmpty) {
      structured[entry.key] = valuesByDefinition;
    }
  }
  return LibraryCustomFieldCache(
    valuesByItem: flat,
    valuesByDefinitionByItem: structured,
    definitions: definitions,
  );
});
