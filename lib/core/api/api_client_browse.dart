part of 'api_client.dart';

class _BrowseApiClient {
  _BrowseApiClient(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> _fetchList(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
  }) async {
    final response = data != null
        ? await _client._dio.post<List<dynamic>>(
            path,
            queryParameters: queryParameters,
            data: data,
          )
        : await _client._dio.get<List<dynamic>>(
            path,
            queryParameters: queryParameters,
          );
    final body = response.data;
    if (body == null) {
      return const [];
    }
    return body
        .cast<Map<String, dynamic>>()
        .map(_client._resolveImageUrls)
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> searchStoryArcs({
    String? query,
    int limit = 50,
  }) {
    return _fetchList(
      '/story-arcs',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        'limit': limit,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getStoryArcItems(String storyArcId) {
    return _fetchList('/story-arcs/${Uri.encodeComponent(storyArcId)}/items');
  }

  Future<List<Map<String, dynamic>>> storyArcFacets(
    Iterable<String> itemIds,
  ) {
    final ids = itemIds.where((id) => id.trim().isNotEmpty).toSet().toList();
    if (ids.isEmpty) {
      return Future.value(const []);
    }
    return _fetchList('/story-arcs/facets', data: {'item_ids': ids});
  }

  Future<List<Map<String, dynamic>>> searchCreators({
    String? query,
    int limit = 50,
  }) {
    return _fetchList(
      '/creators',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        'limit': limit,
      },
    );
  }

  Future<List<Map<String, dynamic>>> creatorFacets(
    Iterable<String> itemIds,
  ) {
    final ids = itemIds.where((id) => id.trim().isNotEmpty).toSet().toList();
    if (ids.isEmpty) {
      return Future.value(const []);
    }
    return _fetchList('/creators/facets', data: {'item_ids': ids});
  }

  Future<List<Map<String, dynamic>>> getCreatorCredits(String creatorId) {
    return _fetchList('/creators/${Uri.encodeComponent(creatorId)}/credits');
  }

  Future<List<Map<String, dynamic>>> searchCharacters({
    String? query,
    int limit = 50,
  }) {
    return _fetchList(
      '/characters',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        'limit': limit,
      },
    );
  }

  Future<List<Map<String, dynamic>>> characterFacets(
    Iterable<String> itemIds,
  ) {
    final ids = itemIds.where((id) => id.trim().isNotEmpty).toSet().toList();
    if (ids.isEmpty) {
      return Future.value(const []);
    }
    return _fetchList('/characters/facets', data: {'item_ids': ids});
  }

  Future<List<Map<String, dynamic>>> getCharacterAppearances(
    String characterId,
  ) {
    return _fetchList(
      '/characters/${Uri.encodeComponent(characterId)}/appearances',
    );
  }
}