import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_export_capability.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';

final musicExportCapability = LibraryExportCapability(
  itemLabel: 'Albums',
  itemModeLabel: 'Album list',
  itemFileName: 'export_albums',
  defaultSortColumnId: 'artist',
  itemColumns: [
    ExportColumnDefinition(
      id: 'artist',
      label: 'Artist',
      getValue: (item) =>
          _musicAlbum(item)?.artist ?? item.dto.secondaryLabel ?? '',
    ),
    ExportColumnDefinition(
      id: 'artist_sort',
      label: 'Artist Sort',
      getValue: (item) =>
          _musicAlbum(item)?.artist ?? item.dto.secondaryLabel ?? '',
    ),
    ExportColumnDefinition(
      id: 'title',
      label: 'Title',
      getValue: (item) => item.dto.primaryLabel,
    ),
    ExportColumnDefinition(
      id: 'format',
      label: 'Format',
      getValue: (item) => _musicAlbum(item)?.formatSummary ?? '',
    ),
    ExportColumnDefinition(
      id: 'barcode',
      label: 'Barcode',
      getValue: (item) => _musicAlbum(item)?.barcode ?? '',
      defaultVisible: false,
    ),
    ExportColumnDefinition(
      id: 'cat_no',
      label: 'Cat No',
      getValue: (item) => _musicAlbum(item)?.catalogNumber ?? '',
      defaultVisible: false,
    ),
    ExportColumnDefinition(
      id: 'release_date',
      label: 'Release Date',
      getValue: (item) => _musicAlbum(item)?.releaseDate?.year.toString() ?? '',
    ),
    ExportColumnDefinition(
      id: 'orig_year',
      label: 'Original Year',
      getValue: (item) =>
          _musicAlbum(item)?.originalReleaseDate?.year.toString() ?? '',
      defaultVisible: false,
    ),
    ExportColumnDefinition(
      id: 'discs',
      label: 'Discs',
      getValue: (item) => _musicAlbum(item)?.discs.length.toString() ?? '1',
    ),
    ExportColumnDefinition(
      id: 'tracks',
      label: 'Tracks',
      getValue: (item) => _musicAlbum(item)?.childCount.toString() ?? '',
    ),
    ExportColumnDefinition(
      id: 'length',
      label: 'Length',
      getValue: (item) => _albumLength(_musicAlbum(item)),
    ),
    ExportColumnDefinition(
      id: 'genre',
      label: 'Genre',
      getValue: (item) => _musicAlbum(item)?.genres.join(' | ') ?? '',
    ),
    ExportColumnDefinition(
      id: 'label',
      label: 'Label',
      getValue: (item) => _musicAlbum(item)?.publisher ?? '',
    ),
    ExportColumnDefinition(
      id: 'added_date',
      label: 'Added Date',
      getValue: (item) => _addedDate(item),
    ),
    ExportColumnDefinition(
      id: 'condition',
      label: 'Condition',
      getValue: (item) => switch (item.dto) {
        MusicWorkspaceProjection musicDto => musicDto.personal.condition ?? '',
        _ => '',
      },
      defaultVisible: false,
    ),
    ExportColumnDefinition(
      id: 'rating',
      label: 'Rating',
      getValue: (item) => item.source.trackingRating?.toString() ?? '',
      defaultVisible: false,
    ),
    ExportColumnDefinition(
      id: 'location',
      label: 'Location',
      getValue: (item) => item.source.locationPath ?? '',
      defaultVisible: false,
    ),
    ExportColumnDefinition(
      id: 'price_paid',
      label: 'Price Paid',
      getValue: (item) => item.source.pricePaidCents != null
          ? formatMoney(item.source.pricePaidCents, item.source.currency)
          : '',
      defaultVisible: false,
    ),
    ExportColumnDefinition(
      id: 'value',
      label: 'Value',
      getValue: (item) => item.source.marketValueCents != null
          ? formatMoney(item.source.marketValueCents, item.source.currency)
          : '',
      defaultVisible: false,
    ),
  ],
  childLabel: 'Tracks',
  childModeLabel: 'Track list',
  childFileName: 'export_tracks',
  childColumns: const [
    LibraryExportChildColumnDefinition(
      id: 'pos',
      label: '#',
      getValue: _trackPosition,
    ),
    LibraryExportChildColumnDefinition(
      id: 'track_title',
      label: 'Track Title',
      getValue: _trackTitle,
    ),
    LibraryExportChildColumnDefinition(
      id: 'track_artist',
      label: 'Artist',
      getValue: _trackArtist,
    ),
    LibraryExportChildColumnDefinition(
      id: 'track_album',
      label: 'Album',
      getValue: _trackAlbum,
    ),
    LibraryExportChildColumnDefinition(
      id: 'duration',
      label: 'Duration',
      getValue: _trackDuration,
    ),
    LibraryExportChildColumnDefinition(
      id: 'format',
      label: 'Format',
      getValue: _trackFormat,
    ),
    LibraryExportChildColumnDefinition(
      id: 'genre',
      label: 'Genre',
      getValue: _trackGenre,
    ),
  ],
  childRowsBuilder: _childRowsFor,
);

MusicAlbum? _musicAlbum(LibraryProjectionView item) {
  final data = item.source.kindPresentationData;
  return data is MusicWorkspaceData ? data.music : null;
}

List<LibraryExportChildRow> _childRowsFor(
  List<LibraryProjectionView> items,
) {
  final rows = <LibraryExportChildRow>[];
  for (final item in items) {
    final album = _musicAlbum(item);
    if (album == null) continue;
    for (final disc in album.discs) {
      for (final track in disc.tracks) {
        if (!track.isHeader) {
          rows.add(
            LibraryExportChildRow(
              item: item,
              payload: (track: track, album: album),
            ),
          );
        }
      }
    }
  }
  return rows;
}

String _albumLength(MusicAlbum? album) {
  final tracks = album?.tracks;
  if (tracks == null || tracks.isEmpty) return '';
  final milliseconds =
      tracks.fold<int>(0, (sum, track) => sum + (track.durationMs ?? 0));
  if (milliseconds <= 0) return '';
  final seconds = (milliseconds / 1000).round();
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final remainingSeconds = seconds % 60;
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
}

String _addedDate(LibraryProjectionView item) {
  final date = item.source.addedAt;
  if (date == null) return '';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
}

({MusicTrack track, MusicAlbum album}) _trackData(LibraryExportChildRow row) =>
    row.payload as ({MusicTrack track, MusicAlbum album});

String _trackPosition(LibraryExportChildRow row) =>
    _trackData(row).track.position;

String _trackTitle(LibraryExportChildRow row) => _trackData(row).track.title;

String _trackArtist(LibraryExportChildRow row) {
  final data = _trackData(row);
  return data.track.artist ?? data.album.artist ?? '';
}

String _trackAlbum(LibraryExportChildRow row) => _trackData(row).album.title;

String _trackDuration(LibraryExportChildRow row) {
  final milliseconds = _trackData(row).track.durationMs;
  if (milliseconds == null || milliseconds <= 0) return '';
  final seconds = (milliseconds / 1000).round();
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

String _trackFormat(LibraryExportChildRow row) =>
    _trackData(row).album.formatSummary ?? '';

String _trackGenre(LibraryExportChildRow row) =>
    _trackData(row).album.genres.join(' | ');
