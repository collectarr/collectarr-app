import 'package:collectarr_app/features/imports/personal_lists/tv_episode_import_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = TvEpisodeImportMapper();

  test('maps episode rows to episode scope summaries', () {
    final mapping = mapper.mapRow(
      TvEpisodeImportRow(
        kind: 'tv',
        title: 'Example Show',
        seasonNumber: 2,
        episodeNumber: 4,
        status: 'Watched',
        score: 8,
        progress: 0.75,
        repeats: 1,
        watchedDate: DateTime.utc(2026, 7, 6),
      ),
    );

    expect(mapping.targetKind, 'tv');
    expect(mapping.targetScope, 'episode');
    expect(mapping.summary, contains('Watched'));
    expect(mapping.summary, contains('Score 8'));
  });
}
