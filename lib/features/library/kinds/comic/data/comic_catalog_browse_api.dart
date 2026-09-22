import 'package:collectarr_app/core/api/api_client.dart';

/// Comic-owned access to creator, character, and story-arc catalog data.
///
/// The shared API client only transports JSON rows. Comic decides which
/// endpoints and response fields represent its domain.
final class ComicCatalogBrowseApi {
  const ComicCatalogBrowseApi(this._api);

  final ApiClient _api;

  Future<List<Map<String, dynamic>>> searchStoryArcs({
    String? query,
    int limit = 50,
  }) {
    return _api.getJsonRows(
      '/api/v1/story-arcs',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        'limit': limit,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getStoryArcItems(String storyArcId) {
    return _api.getJsonRows(
      '/api/v1/story-arcs/${Uri.encodeComponent(storyArcId)}/items',
    );
  }

  Future<List<Map<String, dynamic>>> storyArcFacets(
    Iterable<String> itemIds,
  ) {
    final ids = _normalizedIds(itemIds);
    if (ids.isEmpty) {
      return Future.value(const []);
    }
    return _api.postJsonRows(
      '/api/v1/story-arcs/facets',
      data: {'item_ids': ids},
    );
  }

  Future<List<Map<String, dynamic>>> searchCreators({
    String? query,
    int limit = 50,
  }) {
    return _api.getJsonRows(
      '/api/v1/creators',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        'limit': limit,
      },
    );
  }

  Future<List<Map<String, dynamic>>> creatorFacets(
    Iterable<String> itemIds,
  ) {
    final ids = _normalizedIds(itemIds);
    if (ids.isEmpty) {
      return Future.value(const []);
    }
    return _api.postJsonRows(
      '/api/v1/creators/facets',
      data: {'item_ids': ids},
    );
  }

  Future<List<Map<String, dynamic>>> getCreatorCredits(String creatorId) async {
    final credits = await _api.getJsonRows(
      '/api/v1/creators/${Uri.encodeComponent(creatorId)}/credits',
    );
    return credits
        .where((credit) => credit['kind']?.toString() == 'comic')
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> searchCharacters({
    String? query,
    int limit = 50,
  }) {
    return _api.getJsonRows(
      '/api/v1/characters',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        'limit': limit,
      },
    );
  }

  Future<List<Map<String, dynamic>>> characterFacets(
    Iterable<String> itemIds,
  ) {
    final ids = _normalizedIds(itemIds);
    if (ids.isEmpty) {
      return Future.value(const []);
    }
    return _api.postJsonRows(
      '/api/v1/characters/facets',
      data: {'item_ids': ids},
    );
  }

  Future<List<Map<String, dynamic>>> getCharacterAppearances(
    String characterId,
  ) {
    return _api.getJsonRows(
      '/api/v1/characters/${Uri.encodeComponent(characterId)}/appearances',
    );
  }
}

List<String> _normalizedIds(Iterable<String> values) => values
    .where((value) => value.trim().isNotEmpty)
    .toSet()
    .toList(growable: false);
