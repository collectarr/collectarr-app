import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InspectorTrackList extends StatelessWidget {
  const InspectorTrackList({
    super.key,
    required this.tracks,
    required this.accent,
    this.trackCount,
    this.coverUrl,
    this.title,
  });

  final List<CatalogTrack> tracks;
  final int? trackCount;
  final Color accent;
  final String? coverUrl;
  final String? title;

  static String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String? get _totalDuration {
    var total = 0;
    for (final track in tracks) {
      final dur = track.durationSeconds;
      if (dur != null) {
        total += dur;
      }
    }
    if (total == 0) {
      return null;
    }
    final hours = total ~/ 3600;
    final minutes = (total % 3600) ~/ 60;
    final seconds = total % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final textTheme = Theme.of(context).textTheme;
    final count = trackCount ?? tracks.length;
    final duration = _totalDuration;
    final headerLabel = duration != null
        ? '$count tracks ($duration)'
        : '$count tracks';
    final rows = [
      ['Disc', 'Track', 'Artist', 'Duration'],
      for (final track in tracks)
        [
          track.discNumber?.toString() ?? '-',
          track.position?.toString() ?? '-',
          track.artist?.trim().isNotEmpty == true ? track.artist!.trim() : '',
          track.durationSeconds == null
              ? ''
              : _formatDuration(track.durationSeconds!),
        ],
    ];

    final trackColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            Text(
              headerLabel,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            TextButton.icon(
              onPressed: tracks.isEmpty
                  ? null
                  : () => _copyTrackList(context, rows),
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy'),
            ),
            TextButton.icon(
              onPressed: tracks.isEmpty
                  ? null
                  : () => _printTrackList(context, rows),
              icon: const Icon(Icons.print_outlined, size: 16),
              label: const Text('Print'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final track in tracks)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  child: Text(
                    '${track.position ?? '-'}',
                    style: textTheme.bodySmall?.copyWith(
                      color: palette.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: textTheme.bodySmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (track.artist?.trim().isNotEmpty == true)
                        Text(
                          track.artist!.trim(),
                          style: textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (track.durationSeconds != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      _formatDuration(track.durationSeconds!),
                      style: textTheme.bodySmall?.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );

    return LibraryDetailSection(
      title: 'Track List',
      accentColor: accent,
      children: [
        if (coverUrl != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: trackColumn),
              const SizedBox(width: 14),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.surfaceSubtle.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: palette.divider),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: LibraryInteractiveCover(
                        title: title ?? '',
                        imageUrl: coverUrl,
                        accentColor: accent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          trackColumn,
      ],
    );
  }
}

class InspectorTrackListUnavailable extends StatelessWidget {
  const InspectorTrackListUnavailable({
    super.key,
    required this.trackCount,
    required this.accent,
  });

  final int trackCount;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LibraryDetailSection(
      title: 'Track List',
      accentColor: accent,
      children: [
        Text(
          '$trackCount tracks found, but the cached metadata does not include the full track list yet.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Refresh metadata after re-matching the album to load individual tracks.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: appPalette(context).textMuted,
              ),
        ),
      ],
    );
  }
}

Future<void> _copyTrackList(
  BuildContext context,
  List<List<String>> rows,
) async {
  final text = _rowsToCsv(rows);
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied track list')),
    );
  }
}

Future<void> _printTrackList(
  BuildContext context,
  List<List<String>> rows, {
  String? title,
  int? count,
}) async {
  final doc = pw.Document(title: title ?? 'Track list');
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title ?? 'Track list',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text('${count ?? (rows.length - 1)} tracks'),
            pw.SizedBox(height: 12),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: const {
                0: pw.FixedColumnWidth(40),
                1: pw.FixedColumnWidth(40),
                2: pw.FlexColumnWidth(3),
                3: pw.FixedColumnWidth(55),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _pdfCell('Disc', bold: true),
                    _pdfCell('Track', bold: true),
                    _pdfCell('Artist', bold: true),
                    _pdfCell('Duration', bold: true),
                  ],
                ),
                for (final row in rows.skip(1))
                  pw.TableRow(
                    children: [
                      _pdfCell(row[0]),
                      _pdfCell(row[1]),
                      _pdfCell(row[2]),
                      _pdfCell(row[3]),
                    ],
                  ),
              ],
            ),
          ],
        );
      },
    ),
  );
  await Printing.layoutPdf(
    onLayout: (_) => doc.save(),
    name: '${(title ?? 'track_list').replaceAll(RegExp(r'[^\w\s]'), '')}.pdf',
  );
}

pw.Widget _pdfCell(String value, {bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      value,
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
}

String _rowsToCsv(List<List<String>> rows) {
  return rows
      .map(
        (row) => row
            .map((value) => '"${value.replaceAll('"', '""')}"')
            .join(','),
      )
      .join('\n');
}
