import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/utils/sort_title.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_facts.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

LibrarySortDefinition<MusicKind, MusicWorkspaceProjection> musicStatusSort() {
  return LibrarySortDefinition<MusicKind, MusicWorkspaceProjection>(
    id: LibrarySortId<MusicKind>(MusicWorkspaceFields.status.id.value),
    compare: (left, right) {
      int rank(LibraryProjectionContext<MusicWorkspaceProjection> context) {
        if (context.item.entrySummary != null) return 0;
        if (context.personal.isWishlisted) return 1;
        return 2;
      }

      final result = rank(left).compareTo(rank(right));
      return result != 0
          ? result
          : left.dto.primaryLabel.compareTo(right.dto.primaryLabel);
    },
    label: 'Status',
  );
}

LibrarySortDefinition<MusicKind, MusicWorkspaceProjection>
    musicEarliestDiscRecordingDateSort() =>
        LibrarySortDefinition<MusicKind, MusicWorkspaceProjection>(
          id: LibrarySortId<MusicKind>(
            MusicCatalogWorkspaceFields.earliestDiscRecordingDate.id.value,
          ),
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
          id: LibrarySortId<MusicKind>(
            MusicCatalogWorkspaceFields.latestDiscRecordingDate.id.value,
          ),
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

/// Title order uses the sort title, or the automatic one ("Wall, The"), and
/// ignores letter case, as the reference does.
LibrarySortDefinition<MusicKind, MusicWorkspaceProjection> musicTitleSort() =>
    LibrarySortDefinition<MusicKind, MusicWorkspaceProjection>(
      id: LibrarySortId<MusicKind>(MusicCatalogWorkspaceFields.title.id.value),
      label: MusicCatalogWorkspaceFields.title.label,
      compare: (left, right) =>
          _sortTitleOf(left).compareTo(_sortTitleOf(right)),
    );

String _sortTitleOf(
        LibraryProjectionContext<MusicWorkspaceProjection> context) =>
    (context.sorting.useSortTitles
            ? resolveSortTitle(
                context.dto.common.title, context.dto.music.sortTitle)
            : context.dto.common.title)
        .toLowerCase();

/// Artist order uses the artists' sort names ("Adams, Bryan"), falling back
/// to the name with a leading article moved ("Beatles, The"), unless sort
/// names are ignored in Settings.
LibrarySortDefinition<MusicKind, MusicWorkspaceProjection> musicArtistSort() =>
    LibrarySortDefinition<MusicKind, MusicWorkspaceProjection>(
      id: LibrarySortId<MusicKind>(
          MusicCatalogWorkspaceFields.artistSummary.id.value),
      label: MusicCatalogWorkspaceFields.artistSummary.label,
      compare: (left, right) =>
          _artistSortKey(left).compareTo(_artistSortKey(right)),
    );

String _artistSortKey(
        LibraryProjectionContext<MusicWorkspaceProjection> context) =>
    (context.sorting.useSortNames
            ? musicArtistSortName(context.dto)
            : _artistDisplay(context.dto))
        .toLowerCase();

String _artistDisplay(MusicWorkspaceProjection dto) =>
    dto.music.artist ?? dto.facts.primaryArtist ?? '';

/// The album's artists by sort name, falling back to the name with a leading
/// article moved to the end.
String musicArtistSortName(MusicWorkspaceProjection dto) {
  final credits = [...dto.music.artistCredits]
    ..sort((a, b) => a.sequence.compareTo(b.sequence));
  if (credits.isEmpty) return automaticSortTitle(_artistDisplay(dto));
  return credits
      .map((credit) => credit.sortName?.trim().isNotEmpty == true
          ? credit.sortName!.trim()
          : automaticSortTitle(credit.creditedName))
      .join(' / ');
}

/// Release dates are partial; ordering by their DateTime view would drop
/// every year-only date.
LibrarySortDefinition<MusicKind, MusicWorkspaceProjection> musicPartialDateSort(
  LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, Object?> field,
  PartialDate? Function(MusicWorkspaceProjection dto) dateOf, {
  bool defaultAscending = true,
}) =>
    LibrarySortDefinition<MusicKind, MusicWorkspaceProjection>(
      id: LibrarySortId<MusicKind>(field.id.value),
      label: field.label,
      defaultAscending: defaultAscending,
      compare: (left, right) => _compareNullableDates(
        dateOf(left.dto),
        dateOf(right.dto),
        latest: false,
      ),
    );
