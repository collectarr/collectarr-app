import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:collectarr_app/ui/theme/theme_palette.dart';
import 'package:flutter/material.dart';

/// Owns editable release credit rows across the separate People and Classical
/// tabs, including incomplete rows that are not yet valid contributions.
final class MusicReleaseCreditsEditor {
  MusicReleaseCreditsEditor({required MusicReleaseEditDraft draft})
      : _draft = draft,
        _rows = [
          for (final contribution in draft.contributions)
            _MusicReleaseCreditDraftRow.fromContribution(contribution),
        ];

  final MusicReleaseEditDraft _draft;
  final List<_MusicReleaseCreditDraftRow> _rows;

  List<_MusicReleaseCreditDraftRow> _rowsFor({required bool classical}) => [
        for (final row in _rows)
          if (_isClassical(row.role.text) == classical) row,
      ];

  List<_MusicReleaseCreditDraftRow> _rowsForRole(String role) => [
        for (final row in _rows)
          if (_sameRole(row.role.text, role)) row,
      ];

  List<_MusicReleaseCreditDraftRow> _unassignedRowsFor({
    required bool classical,
    required Set<String> displayedRoles,
  }) =>
      [
        for (final row in _rows)
          if (_isClassical(row.role.text) == classical &&
              !displayedRoles.any((role) => _sameRole(row.role.text, role)))
            row,
      ];

  bool _hasIncompleteRowsFor({required bool classical}) =>
      _rowsFor(classical: classical).any(
        (row) =>
            row.personId.text.trim().isEmpty || row.role.text.trim().isEmpty,
      );

  void _add({required String role}) {
    _rows.add(_MusicReleaseCreditDraftRow.empty(role: role));
    _syncDraft();
  }

  void _remove(_MusicReleaseCreditDraftRow row) {
    if (!_rows.remove(row)) return;
    row.dispose();
    _syncDraft();
  }

  void _syncDraft() {
    _draft.hasIncompleteContributions = _rows.any(
      (row) => row.personId.text.trim().isEmpty || row.role.text.trim().isEmpty,
    );
    final now = DateTime.now().toUtc();
    _draft.contributions = [
      for (var index = 0; index < _rows.length; index++)
        if (_rows[index].personId.text.trim().isNotEmpty &&
            _rows[index].role.text.trim().isNotEmpty)
          _rows[index].toContribution(
            _draft.original.id,
            sequence: index + 1,
            now: now,
          ),
    ];
  }

  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
  }
}

/// Edits one category of release-scoped credits. New relations require an
/// explicit canonical person ID before they are included in the draft.
final class MusicReleaseCreditsTab extends StatefulWidget {
  const MusicReleaseCreditsTab({
    super.key,
    required this.editor,
    required this.classical,
    required this.accent,
  });

  final MusicReleaseCreditsEditor editor;
  final bool classical;
  final Color accent;

  @override
  State<MusicReleaseCreditsTab> createState() => _MusicReleaseCreditsTabState();
}

final class _MusicReleaseCreditsTabState extends State<MusicReleaseCreditsTab> {
  static const _peopleGroups = [
    _MusicReleaseCreditGroup(
      title: 'Credits',
      roles: ['Songwriter', 'Producer', 'Engineer'],
    ),
    _MusicReleaseCreditGroup(title: 'Musicians', roles: ['Musician']),
  ];

  static const _classicalGroups = [
    _MusicReleaseCreditGroup(
      title: null,
      roles: ['Composer', 'Conductor', 'Chorus'],
    ),
    _MusicReleaseCreditGroup(
      title: null,
      roles: ['Composition', 'Orchestra'],
    ),
  ];

  List<_MusicReleaseCreditGroup> get _groups =>
      widget.classical ? _classicalGroups : _peopleGroups;

  Set<String> get _displayedRoles => {
        for (final group in _groups) ...group.roles,
      };

  void _onChanged() {
    widget.editor._syncDraft();
    setState(() {});
  }

  void _remove(_MusicReleaseCreditDraftRow row) {
    setState(() => widget.editor._remove(row));
  }

  @override
  Widget build(BuildContext context) {
    return EditTabShell(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final groups = _groups;
            final children = [
              for (final group in groups) Expanded(child: _creditGroup(group)),
            ];
            if (constraints.maxWidth >= 720) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < children.length; index++) ...[
                    if (index > 0) const SizedBox(width: 14),
                    children[index],
                  ],
                ],
              );
            }
            return Column(
              children: [
                for (var index = 0; index < groups.length; index++) ...[
                  if (index > 0) const SizedBox(height: 12),
                  _creditGroup(groups[index]),
                ],
              ],
            );
          },
        ),
        if (_unassignedRows.isNotEmpty) ...[
          const SizedBox(height: 12),
          _otherCreditsGroup(),
        ],
        if (widget.editor._hasIncompleteRowsFor(classical: widget.classical))
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: appPalette(context).warningBackground,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Every credit needs a role and a canonical person ID before saving.',
              style: TextStyle(color: appPalette(context).warningForeground),
            ),
          ),
      ],
    );
  }

  List<_MusicReleaseCreditDraftRow> get _unassignedRows =>
      widget.editor._unassignedRowsFor(
        classical: widget.classical,
        displayedRoles: _displayedRoles,
      );

  Widget _creditGroup(_MusicReleaseCreditGroup group) {
    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < group.roles.length; index++) ...[
          if (index > 0) const SizedBox(height: 8),
          _roleField(group.roles[index]),
        ],
      ],
    );
    final title = group.title;
    if (title == null) return fields;
    return _CreditFieldset(title: title, child: fields);
  }

  Widget _roleField(String role) {
    final rows = widget.editor._rowsForRole(role);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                role,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(
              width: 30,
              height: 28,
              child: IconButton(
                tooltip: 'Add $role',
                padding: EdgeInsets.zero,
                onPressed: () => setState(() => widget.editor._add(role: role)),
                icon: Icon(Icons.add, color: widget.accent, size: 19),
              ),
            ),
          ],
        ),
        if (rows.isEmpty)
          _emptyCreditLine()
        else
          for (var index = 0; index < rows.length; index++) ...[
            if (index > 0) const SizedBox(height: 6),
            _creditRow(rows[index], fixedRole: role),
          ],
      ],
    );
  }

  Widget _otherCreditsGroup() => _CreditFieldset(
        title: widget.classical ? 'Other classical credits' : 'Other credits',
        child: Column(
          children: [
            for (var index = 0; index < _unassignedRows.length; index++) ...[
              if (index > 0) const SizedBox(height: 8),
              _creditRow(_unassignedRows[index], fixedRole: null),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(
                  () => widget.editor._add(
                    role: widget.classical ? 'Arranger' : 'Performer',
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add credit'),
              ),
            ),
          ],
        ),
      );

  Widget _creditRow(
    _MusicReleaseCreditDraftRow row, {
    required String? fixedRole,
  }) =>
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: appPalette(context).field,
          border: Border.all(color: appPalette(context).divider),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: row.displayName,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (_) => _onChanged(),
                  ),
                ),
                IconButton(
                  tooltip: 'Remove credit',
                  onPressed: () => _remove(row),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (fixedRole == null) ...[
              const SizedBox(height: 6),
              TextFormField(
                controller: row.role,
                decoration: const InputDecoration(labelText: 'Role'),
                onChanged: (_) => _onChanged(),
              ),
            ],
            const SizedBox(height: 6),
            TextFormField(
              controller: row.personId,
              decoration: const InputDecoration(
                labelText: 'Canonical person ID',
                helperText: 'Required to save this credit relation.',
              ),
              onChanged: (_) => _onChanged(),
            ),
          ],
        ),
      );

  Widget _emptyCreditLine() => Container(
        height: 36,
        decoration: BoxDecoration(
          color: appPalette(context).field,
          border: Border.all(color: appPalette(context).divider),
          borderRadius: BorderRadius.circular(4),
        ),
      );
}

final class _MusicReleaseCreditGroup {
  const _MusicReleaseCreditGroup({required this.title, required this.roles});

  final String? title;
  final List<String> roles;
}

final class _CreditFieldset extends StatelessWidget {
  const _CreditFieldset({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 22, 10, 10),
            decoration: BoxDecoration(
              border: Border.all(color: palette.divider),
              borderRadius: BorderRadius.circular(4),
            ),
            child: child,
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: palette.panelRaised,
            child: Text(
              title,
              style: TextStyle(
                color: palette.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

final class _MusicReleaseCreditDraftRow {
  _MusicReleaseCreditDraftRow({
    required this.personId,
    required this.displayName,
    required this.role,
    this.original,
  });

  factory _MusicReleaseCreditDraftRow.empty({required String role}) =>
      _MusicReleaseCreditDraftRow(
        personId: TextEditingController(),
        displayName: TextEditingController(),
        role: TextEditingController(text: role),
      );

  factory _MusicReleaseCreditDraftRow.fromContribution(
    MusicReleaseContribution contribution,
  ) =>
      _MusicReleaseCreditDraftRow(
        personId: TextEditingController(text: contribution.personId),
        displayName: TextEditingController(
          text: contribution.displayName ?? '',
        ),
        role: TextEditingController(text: contribution.role),
        original: contribution,
      );

  final TextEditingController personId;
  final TextEditingController displayName;
  final TextEditingController role;
  final MusicReleaseContribution? original;

  MusicReleaseContribution toContribution(
    MusicReleaseId releaseId, {
    required int sequence,
    required DateTime now,
  }) {
    final previous = original;
    return MusicReleaseContribution(
      id: previous?.id ??
          MusicReleaseContributionId(
            'music-credit:${releaseId.value}:${now.microsecondsSinceEpoch}:$sequence',
          ),
      releaseId: releaseId,
      personId: personId.text.trim(),
      role: role.text.trim(),
      roleId: previous?.role == role.text.trim() ? previous?.roleId : null,
      sequence: sequence,
      displayName: _nullable(displayName.text),
      imageUrl: previous?.imageUrl,
      createdAt: previous?.createdAt ?? now,
      updatedAt: now,
    );
  }

  void dispose() {
    personId.dispose();
    displayName.dispose();
    role.dispose();
  }
}

bool _isClassical(String role) => const {
      'composer',
      'conductor',
      'chorus',
      'orchestra',
      'composition',
      'librettist',
      'arranger',
    }.contains(role.trim().toLowerCase());

bool _sameRole(String left, String right) =>
    left.trim().toLowerCase() == right.trim().toLowerCase();

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
