import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class MissingComicReportOptions {
  const MissingComicReportOptions({
    this.includeVariants = false,
    this.excludeOnOrder = true,
    this.excludeUnreleased = true,
    this.ascending = true,
    this.verbose = false,
  });

  final bool includeVariants;
  final bool excludeOnOrder;
  final bool excludeUnreleased;
  final bool ascending;
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
    required this.coverUrl,
    required this.issueGroups,
    required this.ownedIssueCount,
  });

  final String seriesKey;
  final String seriesTitle;
  final String? coverUrl;
  final List<MissingComicIssueGroup> issueGroups;
  final int ownedIssueCount;

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
    if (item.entry.mediaType != 'comic') {
      continue;
    }
    final issueNumber = _issueNumber(item.entry.itemNumber);
    if (issueNumber == null) {
      continue;
    }
    final seriesKey =
        item.entry.series?.seriesId?.trim().isNotEmpty == true
            ? item.entry.series!.seriesId!.trim()
            : item.entry.series?.seriesTitle?.trim().isNotEmpty == true
                ? item.entry.series!.seriesTitle!.trim()
                : item.entry.title;
    final accumulator = bySeries.putIfAbsent(
      seriesKey,
      () => _MissingComicSeriesAccumulator(
        seriesKey: seriesKey,
        seriesTitle: item.entry.series?.seriesTitle?.trim().isNotEmpty == true
            ? item.entry.series!.seriesTitle!.trim()
            : item.entry.title,
        coverUrl: item.entry.displayCoverUrl,
        ownedIssueNumbers: <int>{},
        candidateVariants: <int, List<MissingComicIssueVariant>>{},
      ),
    );

    if (accumulator.coverUrl == null && item.entry.displayCoverUrl != null) {
      accumulator.coverUrl = item.entry.displayCoverUrl;
    }

    if (item.entry.isOwned) {
      accumulator.ownedIssueNumbers.add(issueNumber);
      continue;
    }
    if (options.excludeOnOrder &&
        item.entry.collectionStatus?.trim().toLowerCase() == 'on_order') {
      continue;
    }
    if (options.excludeUnreleased && _isFutureRelease(item.entry.releaseDate, resolvedNow)) {
      continue;
    }
    accumulator.candidateVariants.putIfAbsent(issueNumber, () => <MissingComicIssueVariant>[])
      .add(
        MissingComicIssueVariant(
          label: _missingComicVariantLabel(item),
          variant: item.entry.variant,
          releaseDate: item.entry.releaseDate,
        ),
      );
  }

  final reports = <MissingComicSeriesReport>[];
  for (final accumulator in bySeries.values) {
    final missingNumbers = accumulator.candidateVariants.keys
        .where((issue) => !accumulator.ownedIssueNumbers.contains(issue))
        .toList(growable: false)
      ..sort();
    if (missingNumbers.isEmpty) {
      continue;
    }
    final issueGroups = [
      for (final issueNumber in options.ascending
          ? missingNumbers
          : missingNumbers.reversed)
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
        coverUrl: accumulator.coverUrl,
        issueGroups: issueGroups,
        ownedIssueCount: accumulator.ownedIssueNumbers.length,
      ),
    );
  }

  reports.sort((a, b) {
    final comparison = a.seriesTitle.compareTo(b.seriesTitle);
    return options.ascending ? comparison : -comparison;
  });
  return reports;
}

String formatComicIssueRanges(Iterable<int> numbers) {
  final sorted = numbers.toList(growable: false)..sort();
  if (sorted.isEmpty) {
    return '';
  }
  final labels = <String>[];
  var start = sorted.first;
  var end = start;
  for (var index = 1; index < sorted.length; index += 1) {
    final current = sorted[index];
    if (current == end + 1) {
      end = current;
      continue;
    }
    labels.add(start == end ? '#$start' : '#$start-#$end');
    start = current;
    end = current;
  }
  labels.add(start == end ? '#$start' : '#$start-#$end');
  return labels.join(', ');
}

String formatComicIssueLabel(int issueNumber) => '#$issueNumber';

pw.Document buildMissingComicsPdfDocument({
  required String title,
  required List<MissingComicSeriesReport> reports,
  required MissingComicReportOptions options,
}) {
  final doc = pw.Document(title: title, author: 'Collectarr');
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (context) => [
        pw.Header(
          level: 0,
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Text(
          '${reports.fold<int>(0, (sum, report) => sum + report.missingIssueCount)} missing issues across ${reports.length} series',
          style: const pw.TextStyle(fontSize: 11),
        ),
        pw.SizedBox(height: 10),
        for (final report in reports) ...[
          pw.Text(
            '${report.seriesTitle} (${report.missingIssueCount})',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final group in report.issueGroups)
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.grey400),
                  ),
                  child: pw.Text(
                    options.verbose && options.includeVariants
                        ? _verboseGroupLabel(group)
                        : formatComicIssueLabel(group.issueNumber),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
            ],
          ),
          pw.SizedBox(height: 10),
        ],
      ],
    ),
  );
  return doc;
}

String _verboseGroupLabel(MissingComicIssueGroup group) {
  final variants = group.variants
      .map((variant) => variant.variant?.trim())
      .where((value) => value != null && value!.isNotEmpty)
      .cast<String>()
      .toSet()
      .toList(growable: false);
  if (variants.isEmpty) {
    return formatComicIssueLabel(group.issueNumber);
  }
  return '${formatComicIssueLabel(group.issueNumber)} (${variants.join(' / ')})';
}

String _missingComicVariantLabel(LibraryProjectionItem item) {
  final variant = item.entry.variant?.trim();
  if (variant != null && variant.isNotEmpty) {
    return variant;
  }
  return item.entry.referenceFormatLabel?.trim().isNotEmpty == true
      ? item.entry.referenceFormatLabel!.trim()
      : item.entry.title;
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
    required this.coverUrl,
    required this.ownedIssueNumbers,
    required this.candidateVariants,
  });

  final String seriesKey;
  final String seriesTitle;
  String? coverUrl;
  final Set<int> ownedIssueNumbers;
  final Map<int, List<MissingComicIssueVariant>> candidateVariants;
}
