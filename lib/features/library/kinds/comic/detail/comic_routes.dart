const comicSeriesRoutePath = '/comic/series/:seriesId';
const comicCreatorRoutePath = '/comic/creator/:name';
const comicCharacterRoutePath = '/comic/character/:name';
const comicStoryArcRoutePath = '/comic/story-arc/:name';

String comicSeriesLocation({required String seriesId, String? title}) {
  final query = title == null || title.isEmpty
      ? ''
      : '?title=${Uri.encodeQueryComponent(title)}';
  return '/comic/series/${Uri.encodeComponent(seriesId)}$query';
}
