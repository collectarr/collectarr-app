import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/music/add/catalog_candidate_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/inspector/sections.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation_builder.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The album shown in the Add dialog's confirm sheet: cover beside title,
/// artist and release facts, then the edition line and the track list, as in
/// the reference.
Widget buildMusicAddPreview(
    BuildContext context, LibraryAddPreviewPaneRequest request) {
  final item = request.item;
  if (item == null) return const SizedBox.shrink();
  final album = musicCatalogItemFromCandidate(item);
  final palette = appPalette(context);
  const text = TextStyle(fontSize: 14, height: 20 / 14);
  final year =
      album.releaseDateParts?.year ?? item.musicCatalogFields.releaseYear;
  final label = album.publisher?.trim();
  final releaseLine = [
    if (label != null && label.isNotEmpty) label,
    if (year != null) '($year)',
  ].join(' ');
  final seconds = album.tracks
      .fold<int>(0, (total, track) => total + (track.durationSeconds ?? 0));
  final edition = musicAlbumEditionLine(album).replaceFirst(' | ', ' - ');
  final summary = seconds == 0
      ? edition
      : '$edition (${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')})';
  return DefaultTextStyle.merge(
    style: text.copyWith(color: palette.textPrimary),
    child: ListView(
      padding: const EdgeInsets.all(15),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox.square(
              dimension: 210,
              child: LibraryInteractiveCover(
                title: album.title,
                imageUrl: item.summary.imageUrl,
                accentColor: request.accent,
                fallbackAspectRatio: 1,
                borderRadius: 0,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(album.title,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  if (album.artist case final artist?) Text(artist),
                  const SizedBox(height: 38),
                  if (releaseLine.isNotEmpty) Text(releaseLine),
                  if (album.barcode case final barcode?) Text(barcode),
                  if (album.catalogNumber case final catalogNumber?)
                    Text(catalogNumber),
                ],
              ),
            ),
          ],
        ),
        if (summary.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(summary),
        ],
        const SizedBox(height: 5),
        if (album.discs.any((disc) => disc.tracks.isNotEmpty))
          MusicCatalogDiscTables(album: album)
        else if (request.isFetchingPreview)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    ),
  );
}
