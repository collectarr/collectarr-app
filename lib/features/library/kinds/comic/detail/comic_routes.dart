const comicSeriesRoutePath = '/comic/series/:seriesId';
const comicCreatorRoutePath = '/comic/creator/:name';
const comicCharacterRoutePath = '/comic/character/:name';
const comicStoryArcRoutePath = '/comic/story-arc/:name';

String comicCreatorLocation(String name) =>
    '/comic/creator/${Uri.encodeComponent(name)}';

String comicCharacterLocation(String name) =>
    '/comic/character/${Uri.encodeComponent(name)}';

String comicStoryArcLocation(String name) =>
    '/comic/story-arc/${Uri.encodeComponent(name)}';

String comicSeriesLocation({required String seriesId, String? title}) {
  final query = title == null || title.isEmpty
      ? ''
      : '?title=${Uri.encodeQueryComponent(title)}';
  return '/comic/series/${Uri.encodeComponent(seriesId)}$query';
}
