import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const _musicCreditIdGenerator = Uuid();

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
  });

  final List<List<MusicCreditFieldGroup>> columns;
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

  void _add(MusicCreditFieldGroup group) => _replace(
        group.role,
        [
          ...group.values,
          MusicCreditFieldValue(
            id: _musicCreditIdGenerator.v4(),
            name: '',
          ),
        ],
      );

  Widget _group(MusicCreditFieldGroup group) {
    final palette = appPalette(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group.label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'Add ${group.label}',
                visualDensity: VisualDensity.compact,
                onPressed: () => _add(group),
                icon: Icon(Icons.add, color: widget.accent, size: 19),
              ),
            ],
          ),
          if (group.values.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                'No ${group.label.toLowerCase()} entries',
                style: TextStyle(color: palette.textMuted),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: group.values.length,
              onReorderItem: (oldIndex, newIndex) {
                final values = [...group.values];
                values.insert(newIndex, values.removeAt(oldIndex));
                _replace(group.role, values);
              },
              itemBuilder: (context, index) {
                final value = group.values[index];
                final nameField = LibraryFormField(
                  label: group.label,
                  child: LibraryTextFormControl(
                    key: ValueKey('music-credit-name-${value.id}'),
                    initialValue: value.name,
                    decoration: const InputDecoration(isDense: true),
                    onChanged: (text) => _replace(
                      group.role,
                      [
                        for (final candidate in group.values)
                          if (candidate.id == value.id)
                            candidate.copyWith(name: text)
                          else
                            candidate,
                      ],
                    ),
                  ),
                );
                final sortNameField = LibraryFormField(
                  label: 'Sort Name',
                  child: LibraryTextFormControl(
                    key: ValueKey('music-credit-sort-name-${value.id}'),
                    initialValue: value.sortName,
                    decoration: const InputDecoration(isDense: true),
                    onChanged: (text) => _replace(
                      group.role,
                      [
                        for (final candidate in group.values)
                          if (candidate.id == value.id)
                            candidate.copyWith(sortName: text)
                          else
                            candidate,
                      ],
                    ),
                  ),
                );
                return Padding(
                  key: ValueKey(value.id),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReorderableDragStartListener(
                        index: index,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Icon(Icons.drag_handle, size: 18),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  nameField,
                                  const SizedBox(height: 6),
                                  sortNameField,
                                ],
                              ),
                            ),
                            if (group.hasInstrument) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: LibraryFormField(
                                  label: 'Instrument',
                                  child: LibraryTextFormControl(
                                    key: ValueKey(
                                      'music-credit-instrument-${value.id}',
                                    ),
                                    initialValue: value.instrument,
                                    decoration:
                                        const InputDecoration(isDense: true),
                                    onChanged: (text) => _replace(
                                      group.role,
                                      [
                                        for (final candidate in group.values)
                                          if (candidate.id == value.id)
                                            candidate.copyWith(instrument: text)
                                          else
                                            candidate,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove ${group.label.toLowerCase()}',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _replace(
                          group.role,
                          group.values
                              .where((candidate) => candidate.id != value.id)
                              .toList(growable: false),
                        ),
                        icon: const Icon(Icons.close, size: 18),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 720 || _columns.length < 2) {
            return Column(
              children: [
                for (final group in _columns.expand((value) => value))
                  _group(group)
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < _columns.length; index++) ...[
                if (index > 0) const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    children: [
                      for (final group in _columns[index]) _group(group)
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      );
}
