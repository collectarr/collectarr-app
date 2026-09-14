const comicSeriesRoutePath = '/comic/series/:seriesId';

String comicSeriesLocation({required String seriesId, String? title}) {
  final query = title == null || title.isEmpty
      ? ''
      : '?title=${Uri.encodeQueryComponent(title)}';
  return '/comic/series/${Uri.encodeComponent(seriesId)}$query';
}
