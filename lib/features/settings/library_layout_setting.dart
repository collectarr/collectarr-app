import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryLayoutSetting extends ConsumerStatefulWidget {
  const LibraryLayoutSetting({super.key});
  @override
  ConsumerState<LibraryLayoutSetting> createState() =>
      _LibraryLayoutSettingState();
}

class _LibraryLayoutSettingState extends ConsumerState<LibraryLayoutSetting> {
  late final LibraryWorkspacePreferences _store;
  late final Future<LibraryWorkspacePreferenceSnapshot> _initial;
  LibraryDetailsLayout? _selection;
  @override
  void initState() {
    super.initState();
    final registration = libraryKindRegistrationForKind(
        catalogMediaKindFromValue(ref.read(selectedLibraryKindProvider)));
    _store = LibraryWorkspacePreferences(registration);
    final cached = LibraryWorkspacePreferences.cachedSnapshot(registration);
    _initial = cached == null
        ? _store.read(defaultCoverSize: 120)
        : Future.value(cached);
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<LibraryWorkspacePreferenceSnapshot>(
        future: _initial,
        builder: (context, snapshot) =>
            DropdownButtonFormField<LibraryDetailsLayout>(
          isExpanded: true,
          initialValue: _selection ?? snapshot.data?.detailsLayout,
          decoration: const InputDecoration(labelText: 'Main screen layout'),
          items: const [
            DropdownMenuItem(
                value: LibraryDetailsLayout.right,
                child: Text('Vertical split')),
            DropdownMenuItem(
                value: LibraryDetailsLayout.bottom,
                child: Text('Horizontal split')),
            DropdownMenuItem(
                value: LibraryDetailsLayout.hidden,
                child: Text('Hide Details panel')),
          ],
          onChanged: !snapshot.hasData
              ? null
              : (value) async {
                  if (value == null) return;
                  setState(() => _selection = value);
                  await _store.writeDetailsLayout(value);
                },
        ),
      );
}
