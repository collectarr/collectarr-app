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
                responseType: ResponseType.json,
              ),
            );

  final Dio _client;

  Future<List<MusicOnlineCoverCandidate>> search(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return const [];

    final response = await _client.getUri<Object?>(
      Uri.https('itunes.apple.com', '/search', {
        'term': normalizedQuery,
        'entity': 'album',
        'limit': '36',
      }),
    );
    final data = response.data;
    if (data is! Map) {
      throw const FormatException('Online cover search returned invalid data.');
    }
    return decodeMusicOnlineCoverCandidates(data);
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
