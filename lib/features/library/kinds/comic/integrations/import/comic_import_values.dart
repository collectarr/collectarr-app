import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';

/// The import title, as the reference list names an issue: "Series #2A".
String comicImportHeadline(String? series, String? issue, String? variant) {
  final number = '${issue ?? ''}${variant ?? ''}';
  return [
    if (series != null) series,
    if (number.isNotEmpty) '#$number',
  ].join(' ');
}

/// The reference Key values; No (or nothing) means not a key comic.
String? comicKeySeverity(String? value) =>
    switch (value?.trim().toLowerCase()) {
      null || '' || 'no' || 'false' || '0' => null,
      'major' => 'Major',
      'minor' => 'Minor',
      'trivia' => 'Trivia',
      _ => throw LibraryImportFormatException(
          'Invalid Key "$value". Use Major, Minor, Trivia or No.'),
    };
