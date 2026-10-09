import 'package:uuid/uuid.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_managed_vocabulary_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_options_dialog.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_pick_field.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
import 'package:flutter/material.dart';

/// One editor for credits owned by the album or any contained disc.
final class MusicAlbumCreditsEditor {
  MusicAlbumCreditsEditor({required MusicAlbumEditDraft draft})
      : _draft = draft,
        _rows = [
          for (final credit in draft.credits)
            _MusicCreditEditRow.from(credit, scopeId: 'album'),
          for (final disc in draft.discs)
            for (final credit in disc.credits)
              _MusicCreditEditRow.from(credit, scopeId: disc.id.value),
        ];

  final MusicAlbumEditDraft _draft;
  final List<_MusicCreditEditRow> _rows;

  List<_MusicCreditEditRow> get _rowsView => List.unmodifiable(_rows);

  List<({String id, String label})> get scopes => [
        (id: 'album', label: 'Album'),
        for (final disc in _draft.discs)
          (id: disc.id.value, label: 'Disc ${disc.discNumber}'),
      ];

  bool get hasIncompleteCredits => _rows.any(
        (row) => row.name.trim().isEmpty || row.role.trim().isEmpty,
      );

  void add() {
    _rows.add(
      _MusicCreditEditRow(
        id: const Uuid().v4(),
        name: '',
        role: '',
        instruments: const [],
        scopeId: 'album',
      ),
    );
  }

  void remove(String id) {
    _rows.removeWhere((row) => row.id == id);
    _sync();
  }

  void updateName(String id, String value) {
    _row(id).name = value;
    _sync();
  }

  void updateRole(String id, String value) {
    _row(id).role = value;
    _sync();
  }

  void updateInstruments(String id, Iterable<String> values) {
    _row(id).instruments = List.unmodifiable(values);
    _sync();
  }

  void updateScope(String id, String scopeId) {
    _row(id).scopeId = scopeId;
    _sync();
  }

  void removeCreditsForMissingDiscs() {
    final discIds = _draft.discs.map((disc) => disc.id.value).toSet();
    _rows.removeWhere(
        (row) => row.scopeId != 'album' && !discIds.contains(row.scopeId));
    _sync();
  }

  _MusicCreditEditRow _row(String id) =>
      _rows.firstWhere((row) => row.id == id);

  void _sync() {
    final validDiscIds = _draft.discs.map((disc) => disc.id.value).toSet();
    final albumCredits = <MusicCredit>[];
    final discCredits = <String, List<MusicCredit>>{
      for (final id in validDiscIds) id: <MusicCredit>[],
    };
    for (final row in _rows) {
      if (row.name.trim().isEmpty || row.role.trim().isEmpty) continue;
      final target =
          row.scopeId == 'album' ? albumCredits : discCredits[row.scopeId];
      if (target == null) continue;
      target.add(
        MusicCredit(
          id: MusicCreditId(row.id),
          contributorId: row.contributorId,
          name: row.name.trim(),
          sortName: _optional(row.sortName),
          role: row.role.trim(),
          roleId: row.roleId,
          instruments: row.instruments,
          sequence: target.length + 1,
        ),
      );
    }
    _draft.credits = albumCredits;
    for (final entry in discCredits.entries) {
      _draft.discList.updateDiscCredits(
        MusicDiscId(entry.key),
        entry.value,
      );
    }
  }
}

final class MusicAlbumCreditsTab extends StatefulWidget {
  const MusicAlbumCreditsTab({
    super.key,
    required this.editor,
    required this.accent,
  });

  final MusicAlbumCreditsEditor editor;
  final Color accent;

  @override
  State<MusicAlbumCreditsTab> createState() => _MusicAlbumCreditsTabState();
}

final class _MusicAlbumCreditsTabState extends State<MusicAlbumCreditsTab> {
  @override
  Widget build(BuildContext context) {
    final editor = widget.editor;
    editor.removeCreditsForMissingDiscs();
    final scopes = editor.scopes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: () => setState(editor.add),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add credit'),
          ),
        ),
        const SizedBox(height: 8),
        if (editor._rowsView.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No credits added.')),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 12,
              headingRowHeight: 34,
              dataRowMinHeight: 46,
              dataRowMaxHeight: double.infinity,
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Instruments')),
                DataColumn(label: Text('Applies to')),
                DataColumn(label: SizedBox.shrink()),
              ],
              rows: [
                for (final row in editor._rowsView)
                  DataRow(
                    key: ValueKey(row.id),
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 190,
                          child: LibraryTextFormControl(
                            key: ValueKey('credit-name-${row.id}'),
                            initialValue: row.name,
                            onChanged: (value) =>
                                editor.updateName(row.id, value),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 170,
                          child: LibraryManagedVocabularyField(
                            label: 'Role',
                            showFieldLabel: false,
                            listName: MusicVocabularyIds.creditRole.value,
                            mediaKind: 'music',
                            value: row.role.isEmpty ? null : row.role,
                            builtIns: MusicVocabularies.creditRole.builtIns,
                            onChanged: (value) =>
                                editor.updateRole(row.id, value ?? ''),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 230,
                          child: LibraryMultiValuePickField<String>(
                            label: 'Instruments',
                            showFieldLabel: false,
                            value: row.instruments.toSet(),
                            options: [
                              for (final value
                                  in MusicVocabularies.instrument.builtIns)
                                LibraryFieldOption(value: value, label: value),
                            ],
                            onChanged: (values) => editor.updateInstruments(
                              row.id,
                              values,
                            ),
                            onOpenPicker: ({
                              required label,
                              required selectedValues,
                              required options,
                              searchHint,
                              customValueHint,
                            }) =>
                                showLibraryMultiValueOptionsDialog<String>(
                              context: context,
                              label: label,
                              options: options,
                              selectedValues: selectedValues,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 150,
                          child: DropdownButtonFormField<String>(
                            initialValue:
                                scopes.any((scope) => scope.id == row.scopeId)
                                    ? row.scopeId
                                    : 'album',
                            isExpanded: true,
                            style: context.libraryTextTheme.controlText,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 6,
                              ),
                            ),
                            items: [
                              for (final scope in scopes)
                                DropdownMenuItem(
                                  value: scope.id,
                                  child: Text(scope.label),
                                ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => editor.updateScope(row.id, value));
                            },
                          ),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          tooltip: 'Remove credit',
                          onPressed: () =>
                              setState(() => editor.remove(row.id)),
                          icon: const Icon(Icons.close, size: 18),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        if (editor.hasIncompleteCredits)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Each credit needs a name and role.',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
      ],
    );
  }
}

final class _MusicCreditEditRow {
  _MusicCreditEditRow({
    required this.id,
    required this.name,
    required this.role,
    required this.instruments,
    required this.scopeId,
  });

  factory _MusicCreditEditRow.from(MusicCredit credit,
          {required String scopeId}) =>
      _MusicCreditEditRow(
        id: credit.id.value,
        name: credit.name,
        role: credit.role,
        instruments: List.unmodifiable(credit.instruments),
        scopeId: scopeId,
      )..copyReference(credit);

  final String id;
  String name;
  String role;
  List<String> instruments;
  String scopeId;
  String? contributorId;
  String? sortName;
  String? roleId;

  void copyReference(MusicCredit credit) {
    contributorId = credit.contributorId;
    sortName = credit.sortName;
    roleId = credit.roleId;
  }
}

String? _optional(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
