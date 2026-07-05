import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_domain.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('movie work and release project into workspace entries', () {
    final work = MovieWork.fromDto(
      MovieWorkDto.fromJson({
        'id': 'movie-1',
        'title': 'The Matrix',
        'description': 'A hacker discovers reality is a simulation.',
        'release_date': '1999-03-31T00:00:00Z',
        'runtime_minutes': 136,
        'original_language': 'en',
        'releases': [
          {
            'id': 'release-1',
            'work_id': 'movie-1',
            'title': '4K UHD',
            'release_date': '2024-01-01T00:00:00Z',
            'country': 'US',
            'language': 'en',
            'barcode': '1234567890123',
            'format_label': '4K UHD',
            'media': [
              {
                'id': 'media-1',
                'release_id': 'release-1',
                'title': 'Disc 1',
                'disc_number': 1,
                'format_label': '4K UHD',
              },
            ],
          },
        ],
        'kind': 'movie',
      }),
    );

    final overlay = const MoviePersonalOverlay();
    final titleEntry = buildMovieWorkWorkspaceEntry(work: work, overlay: overlay);
    final releaseEntry = buildMovieReleaseWorkspaceEntry(
      work: work,
      release: work.releases.single,
      overlay: overlay,
    );

    expect(titleEntry.title, 'The Matrix');
    expect(titleEntry.browseScope, LibraryBrowserScope.title);
    expect(titleEntry.editions, hasLength(1));
    expect(titleEntry.video?.runtimeMinutes, 136);
    expect(releaseEntry.browseScope, LibraryBrowserScope.release);
    expect(releaseEntry.releaseId, 'release-1');
    expect(releaseEntry.video?.nrDiscs, 1);
  });
}
