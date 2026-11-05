import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_workspace_registry.dart';
import 'kind_settings.dart';
import 'kind_settings_controls.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/settings/settings_layout.dart';
import 'package:flutter/material.dart';

/// A settings tab for one library or a family of related libraries.
class SettingsKindGroup {
  const SettingsKindGroup(
      {required this.id, required this.title, required this.types});
  final String id;
  final String title;
  final List<LibraryKindRegistration> types;

  LibraryKindRegistration get primaryType =>
      types.where((type) => type.identity.isTopLevel).firstOrNull ??
      types.first;
}

List<SettingsKindGroup> settingsKindGroups(
    List<LibraryKindRegistration> types) {
  final grouped = <String, List<LibraryKindRegistration>>{};
  for (final type in types) {
    final id = type.identity.collectionFamily ?? type.kind.apiValue;
    grouped.putIfAbsent(id, () => []).add(type);
  }
  return [
    for (final entry in grouped.entries)
      SettingsKindGroup(
          id: entry.key,
          title: entry.value.first.identity.title,
          types: List.unmodifiable(entry.value))
  ];
}

class SettingsKindSection extends ConsumerWidget {
  const SettingsKindSection({super.key, required this.types});
  final List<LibraryKindRegistration> types;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SettingsTabBody(
      children: [for (final type in types) _buildPanel(context, type)]);

  Widget _buildPanel(BuildContext context, LibraryKindRegistration type) =>
      SettingsPanel(
        icon: type.identity.icon,
        title:
            '${type.identity.collectionFamily != null ? type.identity.pluralLabel : type.identity.title} settings',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          KindSettingsControls(kind: type.kind),
          for (final section in collectarrKindSettings[type.kind]?.sections ??
              const <KindSettingsSectionBuilder>[])
            section(context, type.kind),
        ]),
      );
}
