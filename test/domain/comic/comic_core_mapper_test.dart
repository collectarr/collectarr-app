import 'dart:io';

import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_publishing_details_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/core_field_adoption_contract.dart';
import '../../contracts/core_mapping_contract.dart';

void main() {
  test('ComicWorkDto maps directly into ComicMedia', () {
    final dto = ComicWorkDto.fromJson({
      'id': 'comic-1',
      'kind': 'comic',
      'title': 'Saga',
      'contributors': [
        {'name': 'Brian K. Vaughan', 'role': 'writer'},
        'Fiona Staples',
      ],
      'description': 'A family caught in an interstellar war.',
      'first_publication_date': '2012-03-14T00:00:00Z',
      'original_language': 'en',
      'sort_title': 'Saga',
      'subtitle': 'Volume One',
      'issues': [
        {
          'id': 'comic-1-issue-1',
          'title': 'Saga #1',
          'release_date': '2012-03-14T00:00:00Z',
        },
      ],
    });

    final media = ComicCoreMapper.fromWorkDto(dto);

    expect(media.id, const ComicMediaId('comic-1'));
    expect(media.title, 'Saga');
    expect(media.sortTitle, 'Saga');
    expect(media.synopsis, 'A family caught in an interstellar war.');
    expect(media.releaseDate, DateTime.utc(2012, 3, 14));
    expect(media.language, 'en');
    expect(media.publishing?.subtitle, 'Volume One');
    expect(media.creatorCredits, hasLength(2));
    expect(media.creatorCredits.first.role, 'writer');
    expect(media.creatorCredits.last.name, 'Fiona Staples');
    expect(media.releases, hasLength(1));
    expect(
        media.releases.single.typedId, const ComicReleaseId('comic-1-issue-1'));
  });

  test('Comic remote source maps a fetched Core DTO', () async {
    final source = ApiComicRemoteSource((id) async {
      expect(id, 'comic-2');
      return ComicWorkDto.fromJson({
        'id': id,
        'kind': 'comic',
        'title': 'Monstress',
      });
    });

    final media = await source.fetchMedia(const ComicMediaId('comic-2'));

    expect(media.id, const ComicMediaId('comic-2'));
    expect(media.title, 'Monstress');
  });

  defineCoreMappingContract<ComicMedia, ComicWorkDto>(
    name: 'comic',
    createDomain: () => ComicMedia(
      id: ComicMediaId('comic-contract'),
      title: 'Contract Comic',
      sortTitle: 'Contract Comic',
      synopsis: 'Contract synopsis',
      releaseDate: DateTime.utc(2020, 1, 2),
      language: 'en',
      publishing: CatalogPublishingDetailsDto(subtitle: 'Volume 1'),
      creatorCredits: [
        ComicCreatorCredit(name: 'Creator', role: 'writer'),
      ],
      releases: [
        ComicRelease(id: 'release-contract', title: 'Issue 1'),
      ],
    ),
    encode: (domain) => ComicWorkDto.fromJson({
      'id': domain.id!.value,
      'kind': 'comic',
      'title': domain.title,
      'contributors': domain.creatorCredits.map((e) => e.toJson()).toList(),
      'description': domain.synopsis,
      'first_publication_date': domain.releaseDate?.toIso8601String(),
      'original_language': domain.language,
      'sort_title': domain.sortTitle,
      'subtitle': domain.publishing?.subtitle,
      'issues': domain.releases.map((e) => e.toJson()).toList(),
    }),
    decode: ComicCoreMapper.fromWorkDto,
    equals: (left, right) =>
        left.id == right.id &&
        left.title == right.title &&
        left.sortTitle == right.sortTitle &&
        left.synopsis == right.synopsis &&
        left.releaseDate == right.releaseDate &&
        left.language == right.language &&
        left.publishing?.subtitle == right.publishing?.subtitle &&
        left.creatorCredits.length == right.creatorCredits.length &&
        left.releases.length == right.releases.length,
  );

  test('ComicWorkDto fields are explicitly classified', () {
    final source = File(
      'lib/core/api/generated/collectarr_api.models.dart',
    ).readAsStringSync();
    validateCoreDtoFieldAdoption(
      source: source,
      policy: CoreFieldAdoptionPolicy(
        dtoName: 'ComicWorkDto',
        mapped: {
          'id',
          'title',
          'contributors',
          'description',
          'firstPublicationDate',
          'originalLanguage',
          'sortTitle',
          'subtitle',
          'issues',
        },
        intentionallyIgnored: {
          'kind': 'used to validate the typed Comic DTO boundary',
        },
      ),
    );
  });
}
