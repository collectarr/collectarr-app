import 'dart:convert';

import 'package:dio/dio.dart';

final class MusicOnlineCoverCandidate {
  const MusicOnlineCoverCandidate({
    required this.title,
    required this.artist,
    required this.imageUrl,
  });

  final String title;
  final String artist;
  final String imageUrl;
}

final class MusicOnlineCoverSearch {
  MusicOnlineCoverSearch({Dio? client})
      : _client = client ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 20),
                responseType: ResponseType.plain,
              ),
            );

  final Dio _client;

  Future<List<MusicOnlineCoverCandidate>> search(String query,
      {String? barcode}) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return const [];

    final artworkQuery = barcode == null
        ? normalizedQuery
        : normalizedQuery.replaceAll(barcode, '').trim();
    var barcodeCovers = const <MusicOnlineCoverCandidate>[];
    if (barcode != null && barcode.isNotEmpty) {
      try {
        barcodeCovers = await _searchBarcode(barcode);
      } on DioException {
        if (artworkQuery.isEmpty) rethrow;
      }
    }
    if (artworkQuery.isEmpty) return barcodeCovers;
    final response = await _client.getUri<String>(
      Uri.https('itunes.apple.com', '/search', {
        'term': artworkQuery,
        'entity': 'album',
        'limit': '36',
      }),
      options: Options(responseType: ResponseType.plain),
    );
    // Apple serves JSON as text/javascript. Decode the wire body explicitly
    // rather than relying on Dio's content-type based transformer.
    final data = jsonDecode(response.data ?? '');
    if (data is! Map) {
      throw const FormatException('Online cover search returned invalid data.');
    }
    final artwork = decodeMusicOnlineCoverCandidates(data);
    return List.unmodifiable([
      ...barcodeCovers,
      ...artwork.where((candidate) =>
          !barcodeCovers.any((cover) => cover.imageUrl == candidate.imageUrl))
    ]);
  }

  Future<List<MusicOnlineCoverCandidate>> _searchBarcode(String barcode) async {
    final response = await _client.getUri<String>(
        Uri.https('musicbrainz.org', '/ws/2/release/', {
          'query': 'barcode:$barcode',
          'fmt': 'json',
          'limit': '3',
        }),
        options: Options(responseType: ResponseType.plain));
    final payload = jsonDecode(response.data ?? '') as Map<String, dynamic>;
    final releases = payload['releases'] as List? ?? const [];
    final covers = <MusicOnlineCoverCandidate>[];
    final seenUrls = <String>{};
    for (final release in releases.whereType<Map<String, dynamic>>()) {
      final id = release['id'];
      if (id is! String || !RegExp(r'^[a-f0-9-]{36}$').hasMatch(id)) continue;
      final archive = await _client.getUri<String>(
          Uri.https('coverartarchive.org', '/release/$id'),
          options: Options(
              responseType: ResponseType.plain,
              validateStatus: (status) => status == 200 || status == 404));
      if (archive.statusCode == 404) continue;
      final images =
          (jsonDecode(archive.data ?? '') as Map)['images'] as List? ??
              const [];
      for (final image in images.whereType<Map<String, dynamic>>()) {
        final rawUrl = image['image'];
        if (rawUrl is! String) continue;
        final uri = Uri.tryParse(rawUrl);
        if (uri == null ||
            uri.host.isEmpty ||
            (uri.scheme != 'http' && uri.scheme != 'https')) {
          continue;
        }
        // CAA's JSON advertises HTTP originals, served identically over HTTPS.
        final url = uri.replace(scheme: 'https').toString();
        if (!seenUrls.add(url)) continue;
        covers.add(MusicOnlineCoverCandidate(
            title: release['title'] as String? ?? '',
            artist: image['front'] == true
                ? 'Front cover'
                : image['back'] == true
                    ? 'Back cover'
                    : 'Release artwork',
            imageUrl: url));
      }
    }
    return covers;
  }
}

List<MusicOnlineCoverCandidate> decodeMusicOnlineCoverCandidates(
  Map<Object?, Object?> response,
) {
  final results = response['results'];
  if (results is! List) return const [];

  final seenUrls = <String>{};
  final candidates = <MusicOnlineCoverCandidate>[];
  for (final result in results) {
    if (result is! Map) continue;
    final title = result['collectionName'];
    final artist = result['artistName'];
    final rawImageUrl = result['artworkUrl100'];
    if (title is! String || artist is! String || rawImageUrl is! String) {
      continue;
    }
    final imageUrl = rawImageUrl.replaceFirst(
      RegExp(r'\d+x\d+bb'),
      '600x600bb',
    );
    final uri = Uri.tryParse(imageUrl);
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        !seenUrls.add(imageUrl)) {
      continue;
    }
    candidates.add(
      MusicOnlineCoverCandidate(
        title: title,
        artist: artist,
        imageUrl: imageUrl,
      ),
    );
  }
  return List.unmodifiable(candidates);
}
