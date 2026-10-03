import 'package:collectarr_app/features/library/kinds/music/domain/music_album_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_ordered_names_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:flutter/material.dart';

/// Named credits are editable locally without a manually entered canonical ID.
/// Existing references survive edits when their displayed name is unchanged.
final class MusicAlbumCreditsEditor {
  MusicAlbumCreditsEditor({required MusicAlbumEditDraft draft})
      : _draft = draft,
        _rows = [
          for (final value in draft.contributions) _CreditRow.from(value)
        ];
  final MusicAlbumEditDraft _draft;
  final List<_CreditRow> _rows;

  List<_CreditRow> _rowsFor(String role) => [
        for (final row in _rows)
          if (row.role.toLowerCase() == role.toLowerCase()) row
      ];

  void replace(String role, List<LibraryNamedValue> names) {
    final old = {for (final row in _rowsFor(role)) row.id: row};
    final first =
        _rows.indexWhere((row) => row.role.toLowerCase() == role.toLowerCase());
    _rows.removeWhere((row) => row.role.toLowerCase() == role.toLowerCase());
    _rows.insertAll(first < 0 ? _rows.length : first, [
      for (final name in names)
        _CreditRow(
            id: name.id,
            role: role,
            name: name.name,
            sortName: name.sortName,
            previous: old[name.id]?.previous),
    ]);
    _sync();
  }

  void _sync() {
    _draft.hasIncompleteContributions =
        _rows.any((row) => row.name.trim().isEmpty);
    final now = DateTime.now().toUtc();
    _draft.contributions = [
      for (var index = 0; index < _rows.length; index++)
        if (_rows[index].name.trim().isNotEmpty)
          MusicAlbumContribution(
            id: MusicAlbumContributionId(_rows[index].id),
            albumId: _draft.original.id,
            personId: _rows[index].previous?.displayName == _rows[index].name
                ? _rows[index].previous!.personId
                : _rows[index].name.trim(),
            role: _rows[index].role,
            roleId: _rows[index].previous?.roleId,
            sequence: index + 1,
            displayName: _rows[index].name.trim(),
            sortName: _rows[index].sortName,
            imageUrl: _rows[index].previous?.imageUrl,
            createdAt: _rows[index].previous?.createdAt ?? now,
            updatedAt: now,
          ),
    ];
  }

  void dispose() {}
}

final class MusicAlbumCreditsTab extends StatefulWidget {
  const MusicAlbumCreditsTab(
      {super.key,
      required this.editor,
      required this.classical,
      required this.accent});
  final MusicAlbumCreditsEditor editor;
  final bool classical;
  final Color accent;
  @override
  State<MusicAlbumCreditsTab> createState() => _MusicAlbumCreditsTabState();
}

class _MusicAlbumCreditsTabState extends State<MusicAlbumCreditsTab> {
  Widget _role(String role) => LibraryOrderedNamesField(
        label: role,
        values: [
          for (final row in widget.editor._rowsFor(role))
            LibraryNamedValue(
                id: row.id, name: row.name, sortName: row.sortName)
        ],
        onChanged: (names) =>
            setState(() => widget.editor.replace(role, names)),
      );

  Widget _roles(List<String> roles) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (var index = 0; index < roles.length; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          _role(roles[index]),
        ],
      ]);

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final leftRoles = widget.classical
            ? ['Composer', 'Conductor', 'Chorus']
            : ['Songwriter', 'Producer', 'Engineer'];
        final rightRoles =
            widget.classical ? ['Composition', 'Orchestra'] : ['Musician'];
        final left = widget.classical
            ? _roles(leftRoles)
            : LibraryFormGroup(title: 'Credits', child: _roles(leftRoles));
        final right = widget.classical
            ? _roles(rightRoles)
            : LibraryFormGroup(title: 'Musicians', child: _roles(rightRoles));
        final known = {...leftRoles, ...rightRoles}
            .map((role) => role.toLowerCase())
            .toSet();
        final other = widget.editor._rows
            .map((row) => row.role)
            .where((role) =>
                !known.contains(role.toLowerCase()) &&
                _classical(role) == widget.classical)
            .toSet();
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (constraints.maxWidth >= 720)
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: left),
                  const SizedBox(width: 14),
                  Expanded(child: right)
                ])
              else ...[left, const SizedBox(height: 14), right],
              if (other.isNotEmpty) ...[
                const SizedBox(height: 14),
                LibraryFormGroup(
                    title: 'Other credits', child: _roles(other.toList()))
              ],
            ]);
      });
}

class _CreditRow {
  const _CreditRow(
      {required this.id,
      required this.role,
      required this.name,
      this.sortName,
      this.previous});
  factory _CreditRow.from(MusicAlbumContribution value) => _CreditRow(
        id: value.id.value,
        role: value.role,
        name: value.displayName ?? value.personId,
        sortName: value.sortName,
        previous: value,
      );
  final String id;
  final String role;
  final String name;
  final String? sortName;
  final MusicAlbumContribution? previous;
}

bool _classical(String role) => const {
      'composer',
      'conductor',
      'chorus',
      'composition',
      'orchestra',
      'arranger',
      'librettist'
    }.contains(role.toLowerCase());
