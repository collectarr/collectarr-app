import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared utilities for library pages (comics and generic).
mixin LibraryPageUtilities<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Map<String, List<String>> customFieldValuesByItem = const {};

  Future<void> loadCustomFieldValues() async {
    final db = ref.read(localDatabaseProvider);
    final repo = CustomFieldRepository(db);
    final allValues = await repo.listAllValues();
    final flat = <String, List<String>>{};
    for (final entry in allValues.entries) {
      flat[entry.key] = [
        for (final v in entry.value)
          if (v.value != null && v.value!.trim().isNotEmpty) v.value!,
      ];
    }
    if (mounted) {
      setState(() => customFieldValuesByItem = flat);
    }
  }

  static String? rowText(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static List<String> rowTextList(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is! Iterable) return const [];
    return [
      for (final item in value)
        if (item != null && item.toString().trim().isNotEmpty)
          item.toString().trim(),
    ];
  }
}
