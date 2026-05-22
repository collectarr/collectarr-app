import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:flutter/widgets.dart';

abstract class LibraryCoverScanService {
  const LibraryCoverScanService();

  Future<LibraryCoverScanResult?> scanCover({
    required BuildContext context,
    required LibraryTypeConfig type,
  });
}

class NoopLibraryCoverScanService implements LibraryCoverScanService {
  const NoopLibraryCoverScanService();

  @override
  Future<LibraryCoverScanResult?> scanCover({
    required BuildContext context,
    required LibraryTypeConfig type,
  }) async {
    return null;
  }
}

class LibraryCoverScanResult {
  const LibraryCoverScanResult({
    this.query,
    this.series,
    this.issueNumber,
    this.publisher,
    this.year,
    this.confidenceLabel,
    this.warnings = const <String>[],
  });

  final String? query;
  final String? series;
  final String? issueNumber;
  final String? publisher;
  final int? year;
  final String? confidenceLabel;
  final List<String> warnings;

  bool get hasAnyHint {
    return (query?.trim().isNotEmpty ?? false) ||
        (series?.trim().isNotEmpty ?? false) ||
        (issueNumber?.trim().isNotEmpty ?? false) ||
        (publisher?.trim().isNotEmpty ?? false) ||
        year != null;
  }

  bool get showAdvancedFields {
    return (series?.trim().isNotEmpty ?? false) ||
        (issueNumber?.trim().isNotEmpty ?? false) ||
        (publisher?.trim().isNotEmpty ?? false) ||
        year != null;
  }
}