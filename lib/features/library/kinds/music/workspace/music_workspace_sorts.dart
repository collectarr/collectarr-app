import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_facts.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

LibrarySortDefinition<MusicKind, MusicWorkspaceProjection>
    musicEarliestDiscRecordingDateSort() =>
        LibrarySortDefinition<MusicKind, MusicWorkspaceProjection>(
          id: MusicSortIds.earliestDiscRecordingDate,
          label: 'Earliest Disc Recording Date',
          group: 'Recording',
          compare: (left, right) => _compareNullableDates(
            left.dto.facts.earliestDiscRecordingDate,
            right.dto.facts.earliestDiscRecordingDate,
            latest: false,
          ),
        );

LibrarySortDefinition<MusicKind, MusicWorkspaceProjection>
    musicLatestDiscRecordingDateSort() =>
        LibrarySortDefinition<MusicKind, MusicWorkspaceProjection>(
          id: MusicSortIds.latestDiscRecordingDate,
          label: 'Latest Disc Recording Date',
          group: 'Recording',
          compare: (left, right) => _compareNullableDates(
            left.dto.facts.latestDiscRecordingDate,
            right.dto.facts.latestDiscRecordingDate,
            latest: true,
          ),
        );

int _compareNullableDates(
  PartialDate? left,
  PartialDate? right, {
  required bool latest,
}) {
  if (left == null && right == null) return 0;
  if (left == null) return 1;
  if (right == null) return -1;

  final byBoundary = compareMusicPartialDateBounds(
    left,
    right,
    latest: latest,
  );
  if (byBoundary != 0) return byBoundary;
  return (left.isoString ?? '').compareTo(right.isoString ?? '');
}
