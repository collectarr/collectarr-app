import 'package:collectarr_app/features/library/edit/contracts/library_vocabulary_edit_change.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_details_form_pane.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_disc_details_view.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_managed_vocabulary_field.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MusicAlbumDetailsPane extends StatefulWidget {
  const MusicAlbumDetailsPane({
    super.key,
    required this.draft,
    this.onChanged,
    this.discPersonalFieldBuilder,
    this.onDiscRemoved,
  });

  final MusicAlbumEditDraft draft;
  final VoidCallback? onChanged;
  final Widget Function(MusicDisc disc, String label, String key)?
      discPersonalFieldBuilder;
  final ValueChanged<String>? onDiscRemoved;

  @override
  State<MusicAlbumDetailsPane> createState() => _MusicAlbumDetailsPaneState();
}

class _MusicAlbumDetailsPaneState extends State<MusicAlbumDetailsPane> {
  int _selectedSubTabIndex = 0;

  MusicAlbumEditDraft get draft => widget.draft;

  void _notify() {
    setState(() {});
    widget.onChanged?.call();
  }

  void _rememberValues(String fieldId, String? listName, Set<String> values) {
    draft.pendingDetailVocabularyValues[fieldId] = [
      if (listName != null)
        for (final value in values)
          if (value.trim().isNotEmpty)
            (listName: listName, value: value.trim(), mediaKind: 'music'),
    ];
  }

  Widget _condition(
    LibraryEntryEditDraft? entry,
    String label,
    String key,
    String listName,
    List<String> builtIns,
  ) =>
      LibraryManagedVocabularyField(
        label: label,
        listName: listName,
        mediaKind: 'music',
        value: entry?.text(key).isNotEmpty == true ? entry!.text(key) : null,
        builtIns: builtIns,
        enabled: entry != null,
        onChanged: (value) {
          if (entry == null) return;
          entry.set(key, value);
          entry.pendingChanges['vocabulary:$listName'] =
              LibraryVocabularyEditChange([
            if (value?.trim().isNotEmpty == true)
              (listName: listName, value: value!.trim(), mediaKind: 'music'),
          ]);
        },
      );

  Future<void> _removeDisc(MusicDisc disc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AccentAlertDialog(
        title: Text('Remove Disc ${disc.discNumber}?'),
        content: Text(
          'This removes ${disc.tracks.length} track entries from the release. '
          'Storage, slot, and matrix details for this disc will also be removed when you save.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove disc'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final entry = LibraryEntryEditScope.maybeOf(context);
    if (entry != null) {
      final raw = entry.values['media'];
      if (raw is List) {
        final details = [
          for (final row in raw)
            if (row is Map && row['disc_id'] is String)
              Map<String, dynamic>.from(row),
        ];
        details.removeWhere((row) => row['disc_id'] == disc.id.value);
        entry.set('media', details);
      }
    }
    widget.onDiscRemoved?.call(disc.id.value);
    draft.removeDisc(disc.id);
    setState(() {
      _selectedSubTabIndex = 0;
    });
    widget.onChanged?.call();
  }

  Widget _subTabButton(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(80, 32),
          foregroundColor: selected ? palette.textPrimary : palette.textMuted,
          backgroundColor: selected ? palette.surfaceBright : palette.surface,
          side: BorderSide(
            color: selected ? palette.accent : palette.divider,
            width: selected ? 1.5 : 1.0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _subTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _subTabButton(
                    context,
                    label: 'General',
                    selected: _selectedSubTabIndex == 0,
                    onPressed: () => setState(() => _selectedSubTabIndex = 0),
                  ),
                  for (var i = 0; i < draft.discs.length; i++) ...[
                    _subTabButton(
                      context,
                      label: (draft.discs[i].format?.trim().isNotEmpty == true)
                          ? 'Disc ${i + 1} · ${draft.discs[i].format!.trim()}'
                          : 'Disc ${i + 1}',
                      selected: _selectedSubTabIndex == i + 1,
                      onPressed: () =>
                          setState(() => _selectedSubTabIndex = i + 1),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_selectedSubTabIndex > 0 &&
              _selectedSubTabIndex <= draft.discs.length) ...[
            IconButton(
              tooltip: 'Remove Disc $_selectedSubTabIndex',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: () =>
                  _removeDisc(draft.discs[_selectedSubTabIndex - 1]),
            ),
            const SizedBox(width: 4),
          ],
          OutlinedButton.icon(
            onPressed: () {
              draft.addDisc();
              setState(() {
                _selectedSubTabIndex = draft.discs.length;
              });
              _notify();
            },
            icon: const Icon(Icons.add, size: 15),
            label: const Text('Add Disc'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = LibraryEntryEditScope.maybeOf(context);

    if (_selectedSubTabIndex > draft.discs.length) {
      _selectedSubTabIndex = 0;
    }

    Widget generalContent() => MusicDetailsFormPane<MusicAlbumEditDraft>(
          draft: draft,
          values: (draft) => draft.values,
          onVocabularyValueChanged: (
                  {required fieldId, required listName, required value}) =>
              _rememberValues(fieldId, listName, {if (value != null) value}),
          onVocabularyValuesChanged: (
                  {required fieldId, required listName, required values}) =>
              _rememberValues(fieldId, listName, values),
          packageCondition: _condition(
            entry,
            'Package/Sleeve Condition',
            'condition',
            MusicVocabularies.condition.key,
            MusicVocabularies.condition.builtIns,
          ),
          mediaCondition: _condition(
            entry,
            'Media Condition',
            'media_condition',
            MusicVocabularies.mediaCondition.key,
            MusicVocabularies.mediaCondition.builtIns,
          ),
        );

    Widget activeContent() {
      if (_selectedSubTabIndex == 0 || draft.discs.isEmpty) {
        return generalContent();
      }
      final discIndex = _selectedSubTabIndex - 1;
      if (discIndex < 0 || discIndex >= draft.discs.length) {
        return generalContent();
      }
      return MusicDiscDetailsView(
        key: ValueKey('disc-details-${draft.discs[discIndex].id.value}'),
        disc: draft.discs[discIndex],
        draft: draft,
        onChanged: _notify,
        discPersonalFieldBuilder: widget.discPersonalFieldBuilder,
      );
    }

    Widget content() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _subTabBar(context),
            activeContent(),
          ],
        );

    return entry == null
        ? content()
        : ListenableBuilder(listenable: entry, builder: (_, __) => content());
  }
}
