import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:flutter/material.dart';

class InspectorContributorsSection extends StatelessWidget {
  const InspectorContributorsSection({
    super.key,
    required this.request,
  });

  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context) {
    final creators = request.entry.creators ?? const <Map<String, dynamic>>[];
    if (creators.isEmpty) {
      return const SizedBox.shrink();
    }
    final byRole = <String, List<String>>{};
    for (final credit in creators) {
      final name = credit['name']?.toString().trim();
      if (name == null || name.isEmpty) continue;
      final role = credit['role']?.toString().trim();
      final key = (role == null || role.isEmpty) ? 'Cast & crew' : role;
      byRole.putIfAbsent(key, () => <String>[]).add(name);
    }
    final entries = byRole.entries.toList(growable: false);
    return LibraryInspectorSection(
      title: 'Cast & crew',
      accentColor: request.accent,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          LibraryInspectorChipWrap(
            label: entries[i].key,
            values: entries[i].value,
            onValueTap: request.onFilterByValue,
          ),
          if (i != entries.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}
