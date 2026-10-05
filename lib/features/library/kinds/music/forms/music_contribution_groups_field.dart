import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_ordered_names_field.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_ordered_pick_list_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_pick_list_tags.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';

@immutable
final class MusicCreditFieldValue {
  const MusicCreditFieldValue({
    required this.id,
    required this.name,
    this.sortName = '',
    this.instrument = '',
  });

  final String id;
  final String name;
  final String sortName;
  final String instrument;

  MusicCreditFieldValue copyWith({
    String? name,
    String? sortName,
    String? instrument,
  }) =>
      MusicCreditFieldValue(
        id: id,
        name: name ?? this.name,
        sortName: sortName ?? this.sortName,
        instrument: instrument ?? this.instrument,
      );
}

@immutable
final class MusicCreditFieldGroup {
  const MusicCreditFieldGroup({
    required this.role,
    required this.label,
    required this.values,
    this.hasInstrument = false,
  });

  final String role;
  final String label;
  final List<MusicCreditFieldValue> values;
  final bool hasInstrument;
}

/// Shared ordered Music credit editor used by both Manual Add and Edit.
final class MusicContributionGroupsField extends StatefulWidget {
  const MusicContributionGroupsField({
    super.key,
    required this.columns,
    required this.accent,
    required this.onChanged,
    this.columnLabels = const [],
  });

  final List<List<MusicCreditFieldGroup>> columns;
  final List<String> columnLabels;
  final Color accent;
  final ValueChanged<MusicCreditFieldGroup> onChanged;

  @override
  State<MusicContributionGroupsField> createState() =>
      _MusicContributionGroupsFieldState();
}

final class _MusicContributionGroupsFieldState
    extends State<MusicContributionGroupsField> {
  late List<List<MusicCreditFieldGroup>> _columns = widget.columns;

  @override
  void didUpdateWidget(covariant MusicContributionGroupsField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.columns, widget.columns)) {
      _columns = widget.columns;
    }
  }

  void _replace(String role, List<MusicCreditFieldValue> values) {
    MusicCreditFieldGroup? changed;
    final columns = [
      for (final column in _columns)
        [
          for (final group in column)
            if (group.role.toLowerCase() == role.toLowerCase())
              (changed = MusicCreditFieldGroup(
                role: group.role,
                label: group.label,
                values: List.unmodifiable(values),
                hasInstrument: group.hasInstrument,
              ))
            else
              group,
        ],
    ];
    setState(() => _columns = columns);
    if (changed case final group?) widget.onChanged(group);
  }

  Widget _group(MusicCreditFieldGroup group) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: LibraryOrderedPickListField(
          listName: MusicVocabularyIds.creditNames(group.role).value,
          mediaKind: 'music',
          loadOptions: (db) => MusicVocabularies.nameOptions(
              db, MusicVocabularyIds.creditNames(group.role).value),
          label: group.label,
          values: [
            for (final value in group.values)
              LibraryNamedValue(
                  id: value.id, name: value.name, sortName: value.sortName),
          ],
          rowTrailingBuilder: group.hasInstrument
              ? (value) => SizedBox(
                    width: 210,
                    child: LibraryPickListTags(
                      label: 'Instrument',
                      listName: MusicVocabularyIds.instrument.value,
                      mediaKind: 'music',
                      key: ValueKey('music-credit-instrument-${value.id}'),
                      loadOptions: (db) => MusicVocabularies.nameOptions(
                          db, MusicVocabularyIds.instrument.value),
                      values: splitPickListValues(group.values
                          .firstWhere((row) => row.id == value.id)
                          .instrument),
                      onChanged: (instrument) => _replace(group.role, [
                        for (final row in group.values)
                          row.id == value.id
                              ? row.copyWith(
                                  instrument:
                                      joinPickListValues(instrument) ?? '')
                              : row,
                      ]),
                    ),
                  )
              : null,
          onChanged: (names) => _replace(group.role, [
            for (final name in names)
              MusicCreditFieldValue(
                id: name.id,
                name: name.name,
                sortName: name.sortName ?? '',
                instrument: group.values
                        .where((row) => row.id == name.id)
                        .firstOrNull
                        ?.instrument ??
                    '',
              ),
          ]),
        ),
      );

  Widget _column(int index) {
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final group in _columns[index]) _group(group)],
    );
    return index < widget.columnLabels.length
        ? LibraryFormGroup(title: widget.columnLabels[index], child: child)
        : child;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 720 || _columns.length < 2) {
            return Column(
              children: [
                for (var index = 0; index < _columns.length; index++) ...[
                  if (index > 0) const SizedBox(height: 12),
                  _column(index),
                ]
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < _columns.length; index++) ...[
                if (index > 0) const SizedBox(width: 14),
                Expanded(
                  child: _column(index),
                ),
              ],
            ],
          );
        },
      );
}
