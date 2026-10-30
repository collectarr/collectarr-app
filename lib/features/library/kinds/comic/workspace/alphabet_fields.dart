import 'package:collectarr_app/core/utils/sort_title.dart';
import 'package:collectarr_app/features/library/config/presentation/library_alphabet_field.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/data.dart';

/// Series comes first: the reference's letters pick series, filed past a
/// leading article ("The Art of Witch Hat Atelier" under A).
const comicAlphabetFields = [
  LibraryAlphabetField(id: 'series', label: 'Series', values: _series),
  LibraryAlphabetField.title,
];

Iterable<String> _series(LibraryProjectionView item) {
  final data = item.source.kindPresentationData;
  if (data is! ComicWorkspaceData) return const [];
  final series = data.comic.seriesTitle?.trim();
  return [if (series != null && series.isNotEmpty) automaticSortTitle(series)];
}
