import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_contents.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_managed_vocabulary_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_options_dialog.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_pick_field.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
import 'package:flutter/material.dart';

/// Manual Add editor for generic album- and disc-scoped Music credits.
final class MusicAddManualCreditsTab extends StatefulWidget {
  const MusicAddManualCreditsTab({
    super.key,
    required this.draft,
    required this.accent,
  });

  final MusicAddManualDraft draft;
  final Color accent;

  @override
  State<MusicAddManualCreditsTab> createState() =>
      _MusicAddManualCreditsTabState();
}

final class _MusicAddManualCreditsTabState
    extends State<MusicAddManualCreditsTab> {
  List<({String id, String label})> get _scopes => [
        (id: 'album', label: 'Album'),
        for (final disc in widget.draft.discs.indexed)
          (id: disc.$2.id, label: 'Disc ${disc.$1 + 1}'),
      ];

  void _add() => setState(() {
        widget.draft.credits.add(
          MusicAddManualCredit(
            role: 'Producer',
            discId: null,
          ),
        );
      });

  @override
  Widget build(BuildContext context) {
    final credits = widget.draft.credits;
    final scopes = _scopes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add credit'),
            style: OutlinedButton.styleFrom(foregroundColor: widget.accent),
          ),
        ),
        const SizedBox(height: 8),
        if (credits.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No credits added.')),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 12,
              headingRowHeight: 40,
              dataRowMinHeight: 58,
              dataRowMaxHeight: 78,
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Instruments')),
                DataColumn(label: Text('Applies to')),
                DataColumn(label: SizedBox.shrink()),
              ],
              rows: [
                for (final credit in credits)
                  DataRow(
                    key: ValueKey(credit.id),
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 190,
                          child: LibraryTextFormControl(
                            key: ValueKey('manual-credit-name-${credit.id}'),
                            initialValue: credit.name,
                            onChanged: (value) => credit.name = value,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 170,
                          child: LibraryManagedVocabularyField(
                            label: 'Role',
                            listName: MusicVocabularyIds.creditRole.value,
                            mediaKind: 'music',
                            value: credit.role.isEmpty ? null : credit.role,
                            builtIns: MusicVocabularies.creditRole.builtIns,
                            onChanged: (value) => credit.role = value ?? '',
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 230,
                          child: LibraryMultiValuePickField<String>(
                            label: 'Instruments',
                            value: credit.instruments.toSet(),
                            options: [
                              for (final value
                                  in MusicVocabularies.instrument.builtIns)
                                LibraryFieldOption(value: value, label: value),
                            ],
                            onChanged: (values) =>
                                credit.instruments = values.toList(),
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
                                credit.discId == null ? 'album' : credit.discId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                            items: [
                              for (final scope in scopes)
                                DropdownMenuItem(
                                  value: scope.id,
                                  child: Text(scope.label),
                                ),
                            ],
                            onChanged: (value) => setState(() {
                              credit.discId = value == 'album' ? null : value;
                            }),
                          ),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          tooltip: 'Remove credit',
                          onPressed: () => setState(
                            () => credits
                                .removeWhere((item) => item.id == credit.id),
                          ),
                          icon: const Icon(Icons.close, size: 18),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
