import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_preferences.dart';
import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:collectarr_app/ui/app_select.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
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
        catalogMediaKindFromValue(
            context.getInheritedWidgetOfExactType<LibraryAccentScope>()?.kind ??
                ref.read(selectedLibraryKindProvider)));
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
        builder: (context, snapshot) => AppSelect<LibraryDetailsLayout>(
          value: _selection ?? snapshot.data?.detailsLayout,
          // Labelled by its Settings group legend.
          decoration: settingsSelectDecoration(context),
          options: const [
            (LibraryDetailsLayout.right, 'Vertical split'),
            (LibraryDetailsLayout.bottom, 'Horizontal split'),
            (LibraryDetailsLayout.hidden, 'Hide Details panel'),
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
