import 'package:collectarr_app/features/library/kinds/music/domain/music_album_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_contribution_groups_field.dart';
import 'package:flutter/material.dart';

/// Edits typed album contributions while retaining canonical references.
final class MusicAlbumCreditsEditor {
  MusicAlbumCreditsEditor({required MusicAlbumEditDraft draft})
      : _draft = draft,
        _rows = [
          for (final value in draft.contributions) _CreditRow.from(value)
        ];

  final MusicAlbumEditDraft _draft;
  final List<_CreditRow> _rows;

  List<List<MusicCreditFieldGroup>> columnsFor({required bool classical}) {
    final roles = classical
        ? const [
            ['Composer', 'Conductor'],
            ['Chorus', 'Composition', 'Orchestra'],
          ]
        : const [
            ['Songwriter', 'Producer', 'Engineer'],
            ['Musician'],
          ];
    final known = roles.expand((column) => column).toSet();
    final otherRoles = _rows
        .map((row) => row.role)
        .where((role) =>
            !known.any(
                (knownRole) => knownRole.toLowerCase() == role.toLowerCase()) &&
            _isClassicalRole(role) == classical)
        .toSet()
        .toList(growable: false);
    return [
      for (var index = 0; index < roles.length; index++)
        [
          for (final role in roles[index]) _group(role),
          if (index == roles.length - 1)
            for (final role in otherRoles) _group(role),
        ],
    ];
  }

  MusicCreditFieldGroup _group(String role) => MusicCreditFieldGroup(
        role: role,
        label: role,
        hasInstrument: role.toLowerCase() == 'musician',
        values: [
          for (final row in _rows)
            if (row.role.toLowerCase() == role.toLowerCase())
              MusicCreditFieldValue(
                id: row.id,
                name: row.name,
                sortName: row.sortName ?? '',
                instrument: row.instrument,
              ),
        ],
      );

  void replace(String role, List<MusicCreditFieldValue> values) {
    final previousById = {
      for (final row in _rows)
        if (row.role.toLowerCase() == role.toLowerCase()) row.id: row,
    };
    final first =
        _rows.indexWhere((row) => row.role.toLowerCase() == role.toLowerCase());
    _rows.removeWhere((row) => row.role.toLowerCase() == role.toLowerCase());
    _rows.insertAll(
      first < 0 ? _rows.length : first,
      [
        for (final value in values)
          _CreditRow(
            id: value.id,
            role: role,
            name: value.name,
            sortName: _optional(value.sortName),
            instrument: value.instrument,
            previous: previousById[value.id]?.previous,
          ),
      ],
    );
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
            personId: _personIdFor(_rows[index]),
            role: _rows[index].role,
            roleId: _rows[index].previous?.roleId,
            sequence: index + 1,
            displayName: _rows[index].name.trim(),
            sortName: _optional(_rows[index].sortName ?? ''),
            instrument: _optional(_rows[index].instrument),
            imageUrl: _rows[index].previous?.imageUrl,
            createdAt: _rows[index].previous?.createdAt ?? now,
            updatedAt: now,
          ),
    ];
  }

  void dispose() {}
}

final class MusicAlbumCreditsTab extends StatefulWidget {
  const MusicAlbumCreditsTab({
    super.key,
    required this.editor,
    required this.classical,
    required this.accent,
  });

  final MusicAlbumCreditsEditor editor;
  final bool classical;
  final Color accent;

  @override
  State<MusicAlbumCreditsTab> createState() => _MusicAlbumCreditsTabState();
}

class _MusicAlbumCreditsTabState extends State<MusicAlbumCreditsTab> {
  @override
  Widget build(BuildContext context) => MusicContributionGroupsField(
        columns: widget.editor.columnsFor(classical: widget.classical),
        accent: widget.accent,
        onChanged: (group) => setState(
          () => widget.editor.replace(group.role, group.values),
        ),
      );
}

class _CreditRow {
  const _CreditRow({
    required this.id,
    required this.role,
    required this.name,
    this.sortName,
    this.instrument = '',
    this.previous,
  });

  factory _CreditRow.from(MusicAlbumContribution value) => _CreditRow(
        id: value.id.value,
        role: value.role,
        name: value.displayName ?? value.personId,
        sortName: value.sortName,
        instrument: value.instrument ?? '',
        previous: value,
      );

  final String id;
  final String role;
  final String name;
  final String? sortName;
  final String instrument;
  final MusicAlbumContribution? previous;
}

bool _isClassicalRole(String role) => const {
      'composer',
      'conductor',
      'chorus',
      'composition',
      'orchestra',
      'arranger',
      'librettist',
    }.contains(role.toLowerCase());

String _personIdFor(_CreditRow row) {
  final previous = row.previous;
  if (previous != null &&
      (previous.displayName ?? previous.personId) == row.name) {
    return previous.personId;
  }
  return row.name.trim();
}

String? _optional(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
