import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:flutter/material.dart';

/// Release-scoped people and classical credits.
///
/// New relations require an explicit canonical person ID. A display name by
/// itself is not enough to create a valid release contribution.
final class MusicReleaseCreditsTab extends StatefulWidget {
  const MusicReleaseCreditsTab({
    super.key,
    required this.draft,
    required this.accent,
  });

  final MusicReleaseEditDraft draft;
  final Color accent;

  @override
  State<MusicReleaseCreditsTab> createState() => _MusicReleaseCreditsTabState();
}

final class _MusicReleaseCreditsTabState extends State<MusicReleaseCreditsTab> {
  late final List<_CreditRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = [
      for (final contribution in widget.draft.contributions)
        _CreditRow.fromContribution(contribution),
    ];
    _syncDraft();
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _syncDraft() {
    final hasIncomplete = _rows.any(
      (row) => row.personId.text.trim().isEmpty || row.role.text.trim().isEmpty,
    );
    widget.draft.hasIncompleteContributions = hasIncomplete;
    final now = DateTime.now().toUtc();
    widget.draft.contributions = [
      for (var index = 0; index < _rows.length; index++)
        if (_rows[index].personId.text.trim().isNotEmpty &&
            _rows[index].role.text.trim().isNotEmpty)
          _rows[index].toContribution(
            widget.draft.original.id,
            sequence: index + 1,
            now: now,
          ),
    ];
  }

  void _add({required bool classical}) {
    setState(() {
      _rows.add(_CreditRow.empty(role: classical ? 'Composer' : 'Musician'));
    });
    _syncDraft();
  }

  void _remove(_CreditRow row) {
    _rows.remove(row);
    row.dispose();
    setState(() {});
    _syncDraft();
  }

  @override
  Widget build(BuildContext context) {
    final classical =
        _rows.where((row) => _isClassical(row.role.text)).toList();
    final people = _rows.where((row) => !_isClassical(row.role.text)).toList();
    return EditTabShell(
      children: [
        _section(
          title: 'People',
          icon: Icons.people_outline,
          rows: people,
          classical: false,
          emptyText: 'No performer, songwriter or production credits.',
        ),
        _section(
          title: 'Classical',
          icon: Icons.queue_music_outlined,
          rows: classical,
          classical: true,
          emptyText: 'No composer, conductor or ensemble credits.',
        ),
        if (widget.draft.hasIncompleteContributions)
          const Text(
            'Every credit needs a role and a canonical person ID before saving.',
            style: TextStyle(color: Colors.orange),
          ),
      ],
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<_CreditRow> rows,
    required bool classical,
    required String emptyText,
  }) {
    return EditSection(
      title: title,
      accent: widget.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (rows.isEmpty) Text(emptyText),
          for (final row in rows)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: row.displayName,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                            ),
                            onChanged: (_) => _syncDraft(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Remove credit',
                          onPressed: () => _remove(row),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: row.personId,
                      decoration: const InputDecoration(
                        labelText: 'Canonical person ID',
                        helperText: 'Required to save this credit relation.',
                      ),
                      onChanged: (_) => _syncDraft(),
                    ),
                    TextFormField(
                      controller: row.role,
                      decoration: InputDecoration(
                        labelText: classical ? 'Classical role' : 'Role',
                        hintText: classical
                            ? 'Composer, conductor, orchestra…'
                            : 'Performer, songwriter, producer...',
                      ),
                      onChanged: (_) => setState(_syncDraft),
                    ),
                  ],
                ),
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => _add(classical: classical),
              icon: Icon(icon),
              label: Text(classical ? 'Add classical credit' : 'Add person'),
            ),
          ),
        ],
      ),
    );
  }
}

final class _CreditRow {
  _CreditRow({
    required this.personId,
    required this.displayName,
    required this.role,
    this.original,
  });

  factory _CreditRow.empty({required String role}) => _CreditRow(
        personId: TextEditingController(),
        displayName: TextEditingController(),
        role: TextEditingController(text: role),
      );

  factory _CreditRow.fromContribution(MusicReleaseContribution contribution) =>
      _CreditRow(
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

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
