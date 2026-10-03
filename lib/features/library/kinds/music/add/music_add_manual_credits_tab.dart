import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_contents.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Manual Add editor for Music's source-neutral credit fields.
final class MusicAddManualCreditsTab extends StatefulWidget {
  const MusicAddManualCreditsTab({
    super.key,
    required this.draft,
    required this.accent,
    required this.classical,
  });

  final MusicAddManualDraft draft;
  final Color accent;
  final bool classical;

  @override
  State<MusicAddManualCreditsTab> createState() =>
      _MusicAddManualCreditsTabState();
}

final class _MusicAddManualCreditsTabState
    extends State<MusicAddManualCreditsTab> {
  List<List<_CreditGroup>> get _columns => widget.classical
      ? [
          [
            _CreditGroup('Composer', widget.draft.composers),
            _CreditGroup('Conductor', widget.draft.conductors),
          ],
          [
            _CreditGroup('Chorus', widget.draft.choruses),
            _CreditGroup('Composition', widget.draft.compositions),
            _CreditGroup('Orchestra', widget.draft.orchestras),
          ],
        ]
      : [
          [
            _CreditGroup('Songwriter', widget.draft.songwriters),
            _CreditGroup('Producer', widget.draft.producers),
            _CreditGroup('Engineer', widget.draft.engineers),
          ],
          [
            _CreditGroup('Musician', widget.draft.musicians, instrument: true),
          ],
        ];

  @override
  Widget build(BuildContext context) {
    final columns = _columns;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              for (final group in columns.expand((column) => column))
                _creditGroup(group),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < columns.length; index++) ...[
              if (index > 0) const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: [
                    for (final group in columns[index]) _creditGroup(group)
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _creditGroup(_CreditGroup group) {
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
                onPressed: () => setState(
                  () => group.credits.add(MusicAddManualNamedCredit()),
                ),
                icon: Icon(Icons.add, color: widget.accent, size: 19),
              ),
            ],
          ),
          if (group.credits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                'No ${group.label.toLowerCase()} entries',
                style: TextStyle(color: palette.textMuted),
              ),
            )
          else
            for (final credit in group.credits) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TextFormField(
                          key: ValueKey('music-add-credit-${credit.id}'),
                          initialValue: credit.name,
                          decoration: InputDecoration(
                            labelText: group.label,
                            isDense: true,
                          ),
                          onChanged: (value) => credit.name = value,
                        ),
                        TextFormField(
                          key: ValueKey('music-add-credit-sort-${credit.id}'),
                          initialValue: credit.sortName,
                          decoration: const InputDecoration(
                            labelText: 'Sort name',
                            isDense: true,
                          ),
                          onChanged: (value) => credit.sortName = value,
                        ),
                      ],
                    ),
                  ),
                  if (group.instrument) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        key: ValueKey('music-add-instrument-${credit.id}'),
                        initialValue: credit.instrument,
                        decoration: const InputDecoration(
                          labelText: 'Instrument',
                          isDense: true,
                        ),
                        onChanged: (value) => credit.instrument = value,
                      ),
                    ),
                  ],
                  IconButton(
                    tooltip: 'Remove ${group.label.toLowerCase()}',
                    visualDensity: VisualDensity.compact,
                    onPressed: () =>
                        setState(() => group.credits.remove(credit)),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ],
        ],
      ),
    );
  }
}

final class _CreditGroup {
  const _CreditGroup(
    this.label,
    this.credits, {
    this.instrument = false,
  });

  final String label;
  final List<MusicAddManualNamedCredit> credits;
  final bool instrument;
}
