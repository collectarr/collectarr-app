import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/dto.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class MissingComicReportOptions {
  const MissingComicReportOptions({
    this.includeVariants = false,
    this.excludeOnOrder = true,
    this.excludeUnreleased = false,
    this.ascending = true,
    this.verbose = false,
  });

  final bool includeVariants;
  final bool excludeOnOrder;
  final bool excludeUnreleased;

  /// Issue order within a series; series stay in title order.
  final bool ascending;

  /// Every issue instead of compact ranges.
  final bool verbose;
}

class MissingComicIssueVariant {
  const MissingComicIssueVariant({
    required this.label,
    this.variant,
    this.releaseDate,
  });

  final String label;
  final String? variant;
  final DateTime? releaseDate;
}

class MissingComicIssueGroup {
  const MissingComicIssueGroup({
    required this.issueNumber,
    required this.variants,
  });

  final int issueNumber;
  final List<MissingComicIssueVariant> variants;
}

class MissingComicSeriesReport {
  const MissingComicSeriesReport({
    required this.seriesKey,
    required this.seriesTitle,
    required this.issueGroups,
    required this.entryIssueCount,
  });

  final String seriesKey;
  final String seriesTitle;
  final List<MissingComicIssueGroup> issueGroups;
  final int entryIssueCount;

  int get missingIssueCount => issueGroups.length;
}

List<MissingComicSeriesReport> buildMissingComicSeriesReports(
  List<LibraryProjectionItem> items, {
  MissingComicReportOptions options = const MissingComicReportOptions(),
  DateTime? now,
}) {
  final resolvedNow = now ?? DateTime.now();
  final bySeries = <String, _MissingComicSeriesAccumulator>{};
  for (final item in items) {
    final dto = item.dto;
    if (dto is! ComicWorkspaceDto) {
      continue;
    }
    final metadata = dto.comic;
    final issueNumber = _issueNumber(metadata.issueNumber);
    if (issueNumber == null) {
      continue;
    }
    final seriesKey = metadata.seriesId?.trim().isNotEmpty == true
        ? metadata.seriesId!.trim()
        : metadata.seriesTitle?.trim().isNotEmpty == true
            ? metadata.seriesTitle!.trim()
            : metadata.title;
    final accumulator = bySeries.putIfAbsent(
      seriesKey,
      () => _MissingComicSeriesAccumulator(
        seriesKey: seriesKey,
        seriesTitle: metadata.seriesTitle?.trim().isNotEmpty == true
            ? metadata.seriesTitle!.trim()
            : metadata.title,
        entryIssueNumbers: <int>{},
        candidateVariants: <int, List<MissingComicIssueVariant>>{},
      ),
    );

    if (dto.libraryEntry != null) {
      accumulator.entryIssueNumbers.add(issueNumber);
      continue;
    }
    if (options.excludeOnOrder &&
        dto.libraryEntry?.personal.collectionStatus?.trim().toLowerCase() ==
            'on_order') {
      continue;
    }
    if (options.excludeUnreleased &&
        _isFutureRelease(metadata.releaseDate, resolvedNow)) {
      continue;
    }
    accumulator.candidateVariants
        .putIfAbsent(issueNumber, () => <MissingComicIssueVariant>[])
        .add(
          MissingComicIssueVariant(
            label: _missingComicVariantLabel(metadata),
            variant: metadata.variant,
            releaseDate: metadata.releaseDate,
          ),
        );
  }

  final reports = <MissingComicSeriesReport>[];
  for (final accumulator in bySeries.values) {
    final missingNumbers = accumulator.candidateVariants.keys
        .where((issue) => !accumulator.entryIssueNumbers.contains(issue))
        .toList(growable: false)
      ..sort();
    if (missingNumbers.isEmpty) {
      continue;
    }
    final issueGroups = [
      for (final issueNumber
          in options.ascending ? missingNumbers : missingNumbers.reversed)
        MissingComicIssueGroup(
          issueNumber: issueNumber,
          variants: options.includeVariants
              ? List<MissingComicIssueVariant>.unmodifiable(
                  accumulator.candidateVariants[issueNumber]!,
                )
              : List<MissingComicIssueVariant>.unmodifiable(
                  accumulator.candidateVariants[issueNumber]!.take(1),
                ),
        ),
    ];
    reports.add(
      MissingComicSeriesReport(
        seriesKey: accumulator.seriesKey,
        seriesTitle: accumulator.seriesTitle,
        issueGroups: issueGroups,
        entryIssueCount: accumulator.entryIssueNumbers.length,
      ),
    );
  }

  reports.sort((a, b) => a.seriesTitle.compareTo(b.seriesTitle));
  return reports;
}

/// The Missing Issues cell: runs of consecutive issues as "3–26" in a
/// compact list, else every issue, with its variants when they are shown.
String missingComicIssuesText(
    MissingComicSeriesReport report, MissingComicReportOptions options) {
  final groups = report.issueGroups;
  if (options.verbose) {
    return [
      for (final group in groups)
        options.includeVariants
            ? _verboseGroupLabel(group)
            : '${group.issueNumber}'
    ].join(' ');
  }
  final labels = <String>[];
  for (var index = 0; index < groups.length;) {
    final start = groups[index].issueNumber;
    var end = index;
    while (end + 1 < groups.length &&
        (groups[end + 1].issueNumber - groups[end].issueNumber).abs() == 1) {
      end += 1;
    }
    final last = groups[end].issueNumber;
    labels.add(start == last ? '$start' : '$start–$last');
    index = end + 1;
  }
  return labels.join(' ');
}

/// The dialog's table as a printable page.
Future<pw.Document> buildMissingComicsPdfDocument({
  required List<MissingComicSeriesReport> reports,
  required MissingComicReportOptions options,
}) async {
  final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/PlusJakartaSans-Regular.ttf'));
  final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/PlusJakartaSans-Bold.ttf'));
  final doc = pw.Document(
      title: 'Missing Comics',
      author: 'Collectarr',
      theme: pw.ThemeData.withFont(base: regular, bold: bold));
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (context) => [
        pw.Text('Missing Comics',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          headers: ['Series', 'Owned', 'Missing', 'Missing Issues'],
          cellAlignments: {
            1: pw.Alignment.centerRight,
            2: pw.Alignment.centerRight,
          },
          cellStyle: const pw.TextStyle(fontSize: 10),
          headerStyle:
              pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          data: [
            for (final report in reports)
              [
                report.seriesTitle,
                '${report.entryIssueCount}',
                '${report.missingIssueCount}',
                missingComicIssuesText(report, options),
              ]
          ],
        ),
      ],
    ),
  );
  return doc;
}

String _verboseGroupLabel(MissingComicIssueGroup group) {
  final variants = group.variants
      .map((variant) => variant.variant?.trim())
      .where((value) => value != null && value.isNotEmpty)
      .cast<String>()
      .toSet()
      .toList(growable: false);
  if (variants.isEmpty) {
    return '${group.issueNumber}';
  }
  return '${group.issueNumber} (${variants.join(' / ')})';
}

String _missingComicVariantLabel(ComicCatalogItem metadata) {
  final variant = metadata.variant?.trim();
  if (variant != null && variant.isNotEmpty) {
    return variant;
  }
  return metadata.physicalFormat?.trim().isNotEmpty == true
      ? metadata.physicalFormat!.trim()
      : metadata.title;
}

int? _issueNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final match = RegExp(r'^\s*(\d+)').firstMatch(value);
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(1)!);
}

bool _isFutureRelease(DateTime? releaseDate, DateTime now) {
  if (releaseDate == null) {
    return false;
  }
  return releaseDate.isAfter(now);
}

class _MissingComicSeriesAccumulator {
  _MissingComicSeriesAccumulator({
    required this.seriesKey,
    required this.seriesTitle,
    required this.entryIssueNumbers,
    required this.candidateVariants,
  });

  final String seriesKey;
  final String seriesTitle;
  final Set<int> entryIssueNumbers;
  final Map<int, List<MissingComicIssueVariant>> candidateVariants;
}
