import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_domain.dart';
import 'package:collectarr_app/features/library/kinds/movie/inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/inspector/sections/contributors_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/links_trailers_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/metadata_fact_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/releases_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('movie inspector composes movie-specific sections',
      (tester) async {
    final work = MovieWork.fromDto(
      MovieWorkDto.fromJson({
        'id': 'movie-1',
        'title': 'The Matrix',
        'description': 'A hacker discovers reality is a simulation.',
        'release_date': '1999-03-31T00:00:00Z',
        'runtime_minutes': 136,
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
            'audio_tracks': 'Dolby Atmos',
            'subtitles': 'English, Spanish',
            'screen_ratios': '2.39:1',
            'extras': ['Director commentary'],
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
        'trailer_urls': [
          {'url': 'https://example.com/trailer'},
        ],
        'kind': 'movie',
      }),
    );
    final entry = buildMovieWorkWorkspaceEntry(
      work: work,
      overlay: const MoviePersonalOverlay(),
    );
    final request = LibraryInspectorRequest(
      type: moviesLibraryConfig,
      entry: entry,
      ownedItem: null,
      trackingEntry: null,
      accent: Colors.green,
    );

    late List<Widget> sections;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            sections = buildMovieInspectorSections(context, request);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(
      sections.whereType<InspectorMetadataFactsSection>(),
      hasLength(1),
    );
    final factsSection = sections.whereType<InspectorMetadataFactsSection>().single;
    expect(
      factsSection.facts.map((fact) => (fact as LibraryDetailField).label),
      containsAll(['Runtime', 'Layers', 'Trailers']),
    );
    expect(sections.whereType<InspectorReleasesSection>(), hasLength(1));
    expect(sections.whereType<InspectorContributorsSection>(), isEmpty);
    expect(sections.whereType<InspectorLinksTrailersSection>(), hasLength(1));
  });
}
