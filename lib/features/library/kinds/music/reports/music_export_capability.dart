import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_export_capability.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_catalog_item_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';

final musicExportCapability = LibraryExportCapability(
  itemLabel: 'Albums',
  itemModeLabel: 'Album list',
  itemFileName: 'export_albums',
  defaultSortColumnId: MusicFieldIds.artist.value,
  pdfItemTitle: 'My Albums',
  pdfChildTitle: 'My Tracks',
  itemColumns: [
    if (MusicFieldIdentities.artist.exportable)
      exportColumnFromWorkspaceField(
        field: MusicCatalogItemWorkspaceFields.artist,
        valueFormatter: (value) => value ?? '',
        pdfWidthFlex: 2.0,
        pdfOrder: 0,
      ),
    ExportColumnDefinition(
      id: 'artist_sort',
      label: 'Artist Sort',
      getValue: (item) =>
          _musicAlbum(item)?.artist ?? item.dto.secondaryLabel ?? '',
      includeInPdf: false,
    ),
    if (MusicFieldIdentities.title.exportable)
      exportColumnFromWorkspaceField(
        field: MusicCatalogItemWorkspaceFields.title,
        valueFormatter: (value) => value ?? '',
        pdfWidthFlex: 2.5,
        pdfOrder: 1,
      ),
    if (MusicFieldIdentities.format.exportable)
      exportColumnFromWorkspaceField(
        field: MusicCatalogItemWorkspaceFields.format,
        valueFormatter: (value) => value ?? '',
        pdfWidthFlex: 1.2,
        pdfOrder: 2,
      ),
    if (MusicFieldIdentities.barcode.exportable)
      exportColumnFromWorkspaceField(
        field: MusicCatalogItemWorkspaceFields.barcode,
        valueFormatter: (value) => value ?? '',
        defaultVisible: false,
        pdfWidthFlex: 1.5,
        pdfDefaultVisible: true,
        pdfOrder: 3,
      ),
    if (MusicFieldIdentities.catalogNumber.exportable)
      exportColumnFromWorkspaceField(
        field: MusicCatalogItemWorkspaceFields.catalogNumber,
        valueFormatter: (value) => value ?? '',
        defaultVisible: false,
        pdfLabel: 'Cat No',
        pdfWidthFlex: 1.5,
        pdfDefaultVisible: true,
        pdfOrder: 4,
      ),
    if (MusicFieldIdentities.releaseDate.exportable)
      exportColumnFromWorkspaceField(
        field: MusicCatalogItemWorkspaceFields.releaseDate,
        valueFormatter: (value) => value?.year.toString() ?? '',
        pdfLabel: 'Release Year',
        pdfWidthFlex: 1.0,
        pdfOrder: 7,
      ),
    ExportColumnDefinition(
      id: 'orig_year',
      label: 'Original Year',
      getValue: (item) =>
          _musicAlbum(item)?.originalReleaseDate?.year.toString() ?? '',
      defaultVisible: false,
      pdfWidthFlex: 1.0,
      pdfDefaultVisible: false,
      pdfOrder: 8,
    ),
    ExportColumnDefinition(
      id: 'discs',
      label: 'Discs',
      getValue: (item) => _musicAlbum(item)?.discs.length.toString() ?? '1',
      pdfWidthFlex: 0.8,
      pdfDefaultVisible: false,
      pdfOrder: 9,
    ),
    exportColumnFromWorkspaceField(
      field: MusicCatalogItemWorkspaceFields.trackCount,
      valueFormatter: (value) => value?.toString() ?? '',
      pdfValueFormatter: (value) => value?.toString() ?? '',
      pdfWidthFlex: 0.8,
      pdfDefaultVisible: false,
      pdfOrder: 10,
    ),
    ExportColumnDefinition(
      id: 'length',
      label: 'Length',
      getValue: (item) => _albumLength(_musicAlbum(item)),
      includeInPdf: false,
    ),
    if (MusicFieldIdentities.genre.exportable)
      ExportColumnDefinition(
        id: MusicFieldIdentities.genreId,
        label: MusicFieldIdentities.genreLabel,
        getValue: (item) => _musicAlbum(item)?.genres.join(' | ') ?? '',
        pdfGetValue: (item) => _musicAlbum(item)?.genres.join(', ') ?? '',
        pdfWidthFlex: 2.0,
        pdfOrder: 5,
      ),
    if (MusicFieldIdentities.publisher.exportable)
      exportColumnFromWorkspaceField(
        field: MusicCatalogItemWorkspaceFields.publisher,
        valueFormatter: (value) => value ?? '',
        pdfWidthFlex: 1.8,
        pdfOrder: 6,
      ),
    ExportColumnDefinition(
      id: 'added_date',
      label: 'Added Date',
      getValue: (item) => _addedDate(item),
      includeInPdf: false,
    ),
    ExportColumnDefinition(
      id: 'condition',
      label: 'Condition',
      getValue: (item) => switch (item.dto) {
        MusicWorkspaceProjection musicDto => musicDto.personal.condition ?? '',
        _ => '',
      },
      defaultVisible: false,
      pdfWidthFlex: 1.0,
      pdfDefaultVisible: false,
      pdfOrder: 11,
    ),
    ExportColumnDefinition(
      id: 'rating',
      label: 'Rating',
      getValue: (item) => item.source.trackingRating?.toString() ?? '',
      defaultVisible: false,
      pdfWidthFlex: 0.8,
      pdfDefaultVisible: false,
      pdfOrder: 12,
    ),
    ExportColumnDefinition(
      id: 'location',
      label: 'Location',
      getValue: (item) => item.source.locationPath ?? '',
      defaultVisible: false,
      pdfWidthFlex: 1.2,
      pdfDefaultVisible: false,
      pdfOrder: 13,
    ),
    ExportColumnDefinition(
      id: 'price_paid',
      label: 'Price Paid',
      getValue: (item) => item.source.pricePaidCents != null
          ? formatMoney(item.source.pricePaidCents, item.source.currency)
          : '',
      defaultVisible: false,
      pdfWidthFlex: 1.0,
      pdfDefaultVisible: false,
      pdfOrder: 14,
    ),
    ExportColumnDefinition(
      id: 'value',
      label: 'Value',
      getValue: (item) => item.source.marketValueCents != null
          ? formatMoney(item.source.marketValueCents, item.source.currency)
          : '',
      defaultVisible: false,
      pdfWidthFlex: 1.0,
      pdfDefaultVisible: false,
      pdfOrder: 15,
    ),
  ],
  childLabel: 'Tracks',
  childModeLabel: 'Track list',
  childFileName: 'export_tracks',
  childColumns: [
    LibraryExportChildColumnDefinition(
      id: 'pos',
      label: '#',
      getValue: _trackPosition,
      pdfWidthFlex: 0.8,
      pdfOrder: 0,
    ),
    LibraryExportChildColumnDefinition(
      id: 'track_title',
      label: 'Track Title',
      getValue: _trackTitle,
      pdfWidthFlex: 3.0,
      pdfOrder: 1,
    ),
    LibraryExportChildColumnDefinition(
      id: 'track_artist',
      label: 'Artist',
      getValue: _trackArtist,
      pdfWidthFlex: 2.0,
      pdfOrder: 2,
    ),
    LibraryExportChildColumnDefinition(
      id: 'track_album',
      label: 'Album',
      getValue: _trackAlbum,
      pdfWidthFlex: 2.5,
      pdfOrder: 3,
    ),
    LibraryExportChildColumnDefinition(
      id: 'duration',
      label: 'Duration',
      getValue: _trackDuration,
      pdfWidthFlex: 1.0,
      pdfOrder: 4,
    ),
    LibraryExportChildColumnDefinition(
      id: 'format',
      label: 'Format',
      getValue: _trackFormat,
      pdfWidthFlex: 1.2,
      pdfOrder: 5,
    ),
    LibraryExportChildColumnDefinition(
      id: 'genre',
      label: 'Genre',
      getValue: _trackGenre,
      pdfGetValue: (row) => _trackData(row).album.genres.join(', '),
      pdfWidthFlex: 1.5,
      pdfOrder: 6,
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
