part of 'api_client.dart';

class _AssetsApiClient {
  _AssetsApiClient(this._client);

  final ApiClient _client;

  Future<List<AdminUser>> adminListUsers() async {
    final response = await _client._dio.get<List<dynamic>>('/admin/users');
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(AdminUser.fromJson)
        .toList(growable: false);
  }

  Future<AdminImageCacheStats> adminImageCacheStats() async {
    final response =
        await _client._dio.get<Map<String, dynamic>>('/admin/image-cache/stats');
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/image-cache/stats returned empty body');
    }
    return AdminImageCacheStats.fromJson(data);
  }

  Future<AdminImageCachePurgeResult> adminPurgeImageCache({
    String? provider,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/admin/image-cache/purge',
      queryParameters: {if (provider != null) 'provider': provider},
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/image-cache/purge returned empty body');
    }
    return AdminImageCachePurgeResult.fromJson(data);
  }

  Future<AdminUser> adminUpdateUser(
    String userId, {
    String? role,
    bool? isActive,
    String? displayName,
  }) async {
    final body = <String, dynamic>{
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (displayName != null) 'display_name': displayName,
    };
    final response = await _client._dio.patch<Map<String, dynamic>>(
      '/admin/users/${Uri.encodeComponent(userId)}',
      data: body,
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/users/$userId returned an empty response body');
    }
    return AdminUser.fromJson(data);
  }

  Future<List<int>> downloadImageBytes(String objectKey) async {
    final response = await _client._dio.get<List<int>>(
      '/images/download',
      queryParameters: {'object_key': objectKey},
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? const [];
  }

  Future<Map<String, String?>> batchDownloadImages(
    List<String> objectKeys,
  ) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/images/batch-download',
      data: objectKeys,
    );
    return response.data?.map(
          (key, value) => MapEntry(key, value as String?),
        ) ??
        {};
  }

  Future<List<Map<String, dynamic>>> listEntityImages({
    required String entityType,
    required String entityId,
  }) async {
    final response = await _client._dio.get<List<dynamic>>(
      '/images/entity/$entityType/$entityId',
    );
    return (response.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> addEntityImage({
    required String entityType,
    required String entityId,
    required String imageType,
    required String imageDataBase64,
    String? sourceUrl,
    String? provider,
    bool isPrimary = false,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/images/entity/$entityType/$entityId',
      data: {
        'image_type': imageType,
        'image_data_base64': imageDataBase64,
        if (sourceUrl != null) 'source_url': sourceUrl,
        if (provider != null) 'provider': provider,
        'is_primary': isPrimary,
      },
    );
    return response.data ?? {};
  }

  Future<void> deleteEntityImage(String imageId) async {
    await _client._dio.delete<void>('/images/$imageId');
  }

  Future<Map<String, dynamic>> setImagePrimary(String imageId) async {
    final response = await _client._dio.patch<Map<String, dynamic>>(
      '/images/$imageId/primary',
    );
    return response.data ?? {};
  }

  /// Upload an image and search for visually similar covers by perceptual hash.
  Future<Map<String, dynamic>> searchByCoverUpload(
    Uint8List imageBytes, {
    int threshold = 12,
    int limit = 20,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(imageBytes, filename: 'scan.jpg'),
    });
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/images/search-by-cover-upload',
      data: formData,
      queryParameters: {
        'threshold': threshold,
        'limit': limit,
      },
    );
    return response.data ?? {};
  }
}