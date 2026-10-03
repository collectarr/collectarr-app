import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec_control_builder.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicAlbumDetailsPane extends ConsumerStatefulWidget {
  const MusicAlbumDetailsPane({super.key, required this.draft});
  final MusicAlbumEditDraft draft;
  @override
  ConsumerState<MusicAlbumDetailsPane> createState() =>
      _MusicAlbumDetailsPaneState();
}

class _MusicAlbumDetailsPaneState extends ConsumerState<MusicAlbumDetailsPane> {
  final _controllers = <String, TextEditingController>{};
  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _field(String id) {
    final field =
        musicAlbumFields<MusicAlbumEditDraft>(values: (draft) => draft.values)
            .firstWhere((field) => field.id == id);
    return LibraryFieldSpecControlBuilder<MusicAlbumEditDraft>(
      context: context,
      draft: widget.draft,
      mode: LibraryFieldSpecControlMode.edit,
      mediaKind: 'music',
      controllerFor: (key, value) => _controllers.putIfAbsent(
          key, () => TextEditingController(text: value)),
      onChanged: () => setState(() {}),
    ).build(field);
  }

  Widget _condition(LibraryEntryEditDraft? entry, String label, String key) =>
      LibraryDropdownPickField<String>(
        label: label,
        value: entry?.text(key).isNotEmpty == true ? entry!.text(key) : null,
        enabled: entry != null,
        allowCustomValue: true,
        options: [
          for (final condition in MusicVocabularies.condition.builtIns)
            LibraryFieldOption(value: condition, label: condition)
        ],
        onChanged: (value) => setState(() => entry?.set(key, value)),
        openPicker: (
                {required label, required selectedValue, required options}) =>
            showPickListSelectDialog(
          context: context,
          label: label,
          selectedValue: selectedValue,
          options: options,
          listName: key,
          mediaKind: 'music',
          allowUserValues: true,
          db: ref.read(localDatabaseProvider),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final entry = LibraryEntryEditScope.maybeOf(context);
    Widget spaced(List<Widget> children) =>
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            children[i]
          ]
        ]);
    final left = spaced([
      LibraryFormGroup(
          title: 'Packaging',
          child: spaced([
            _field('packaging'),
            _condition(entry, 'Package/Sleeve Condition', 'condition'),
            _condition(entry, 'Media Condition', 'media_condition'),
          ])),
      _field('studios'),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _field('country')),
        const SizedBox(width: 14),
        Expanded(child: _field('is_live')),
      ]),
      _field('sound_types'),
    ]);
    final right = spaced([
      LibraryFormGroup(
          title: 'Vinyl',
          child: spaced(
              [_field('vinyl_color'), _field('vinyl_weight'), _field('rpm')])),
      _field('extra'),
      _field('spars'),
      _field('box_set_name'),
    ]);
    return LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= 720
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: left),
                const SizedBox(width: 14),
                Expanded(child: right)
              ])
            : spaced([left, right]));
  }
}
