import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_contents.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_contribution_groups_field.dart';
import 'package:flutter/material.dart';

/// Manual Add editor for Music's source-neutral credit fields.
final class MusicAddManualCreditsTab extends StatelessWidget {
  const MusicAddManualCreditsTab({
    super.key,
    required this.draft,
    required this.accent,
    required this.classical,
  });

  final MusicAddManualDraft draft;
  final Color accent;
  final bool classical;

  MusicCreditFieldGroup _group(
    String role,
    List<MusicAddManualNamedCredit> credits, {
    bool hasInstrument = false,
  }) =>
      MusicCreditFieldGroup(
        role: role,
        label: role,
        hasInstrument: hasInstrument,
        values: [
          for (final credit in credits)
            MusicCreditFieldValue(
              id: credit.id,
              name: credit.name,
              sortName: credit.sortName,
              instrument: credit.instrument,
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final columns = classical
        ? [
            [
              _group('Composer', draft.composers),
              _group('Conductor', draft.conductors),
              _group('Chorus', draft.choruses),
            ],
            [
              _group('Composition', draft.compositions),
              _group('Orchestra', draft.orchestras),
            ],
          ]
        : [
            [
              _group('Songwriter', draft.songwriters),
              _group('Producer', draft.producers),
              _group('Engineer', draft.engineers),
            ],
            [
              _group('Musician', draft.musicians, hasInstrument: true),
            ],
          ];

    return MusicContributionGroupsField(
      columns: columns,
      accent: accent,
      columnLabels: classical ? const [] : const ['Credits', 'Musicians'],
      onChanged: (group) {
        final target = switch (group.role.toLowerCase()) {
          'composer' => draft.composers,
          'conductor' => draft.conductors,
          'chorus' => draft.choruses,
          'composition' => draft.compositions,
          'orchestra' => draft.orchestras,
          'songwriter' => draft.songwriters,
          'producer' => draft.producers,
          'engineer' => draft.engineers,
          'musician' => draft.musicians,
          _ => null,
        };
        if (target == null) return;
        target
          ..clear()
          ..addAll([
            for (final value in group.values)
              MusicAddManualNamedCredit(
                id: value.id,
                name: value.name,
                sortName: value.sortName,
                instrument: value.instrument,
              ),
          ]);
      },
    );
  }
}
