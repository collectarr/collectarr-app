part of 'api_client.dart';

class _ProviderApiClient {
  _ProviderApiClient(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> searchProvider({
    String? provider,
    required String query,
    String? kind,
    String? series,
    String? issueNumber,
    int? year,
  }) async {
    final providerPath = provider == null || provider.isEmpty
        ? '/metadata/providers/search'
        : '/metadata/providers/$provider/search';
    final response = await _client._dio.get<List<dynamic>>(
      providerPath,
      queryParameters: {
        'q': query,
        if (kind != null) 'kind': kind,
        if (series != null && series.trim().isNotEmpty) 'series': series.trim(),
        if (issueNumber != null && issueNumber.trim().isNotEmpty)
          'issue_number': issueNumber.trim(),
        if (year != null) 'year': year,
      },
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(_client._resolveImageUrls)
        .toList(growable: false);
  }

  Future<AdminProviderPreview> providerPreview({
    required String provider,
    required String providerItemId,
  }) async {
    return _client._providerPreview(
      '/metadata/providers/preview',
      provider: provider,
      providerItemId: providerItemId,
    );
  }

  Future<List<Season>> getProviderSeasons(
    String provider,
    String providerItemId,
  ) async {
    final response = await _client._dio.get<List<dynamic>>(
      '/metadata/providers/$provider/seasons/${Uri.encodeComponent(providerItemId)}',
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(Season.fromJson)
        .toList(growable: false);
  }

  Future<List<Season>> getProviderVolumes(
    String provider,
    String providerItemId,
  ) async {
    final response = await _client._dio.get<List<dynamic>>(
      '/metadata/providers/$provider/volumes/${Uri.encodeComponent(providerItemId)}',
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(Season.fromJson)
        .toList(growable: false);
  }
}