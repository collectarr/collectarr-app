import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test/flutter_test.dart';

import 'core_field_adoption_contract.dart';

void main() {
  final source = File(
    'lib/core/api/generated/collectarr_api.models.dart',
  ).readAsStringSync();
  final policies = _policies();

  test('all generated typed Core DTOs have an adoption policy', () {
    final declarations = parseString(
      content: source,
      throwIfDiagnostics: false,
    ).unit.declarations.whereType<ClassDeclaration>();
    final generatedDtoNames = {
      for (final declaration in declarations)
        if (declaration.extendsClause?.superclass.toSource() ==
            'TypedMetadataResponse')
          declaration.namePart.toSource(),
    };

    expect(
      policies.map((policy) => policy.dtoName).toSet(),
      generatedDtoNames,
      reason: 'Adding a generated DTO requires a field adoption policy.',
    );
  });

  for (final policy in policies) {
    test('${policy.dtoName} fields are explicitly classified', () {
      validateCoreDtoFieldAdoption(source: source, policy: policy);
    });
  }
}

List<CoreFieldAdoptionPolicy> _policies() => [
      _policy(
        'BookWorkDto',
        'id title searchAliases genres contributors editions series '
            'firstPublicationDate originalPublicationDate originalLanguage '
            'sortTitle subtitle description',
        ignored: _kindReason('Book'),
      ),
      _policy(
        'BookEditionDto',
        'id workId titleValue ageRating audioLengthMinutes binding contributors '
            'coverImageKey coverImageUrlValue description displayTitle '
            'editionStatement format isbn identifiers imprint language pageCount '
            'publicationDate publisher region releaseStatus upc',
      ),
      _policy(
        'GameWorkDto',
        'id title platforms identifiers companyRoles ageRatings genres '
            'searchAliases releases originalLanguage publisher releaseDateValue '
            'sortTitle subtitle description',
        ignored: _kindReason('Game'),
      ),
      _policy(
        'GameReleaseDto',
        'id workId releaseTitle platform releaseDateValue regionCode format '
            'publisher catalogNumber releaseStatus language barcodeValue '
            'coverImageUrlValue',
      ),
      _policy(
        'BoardGameWorkDto',
        'id title platforms identifiers contributors mechanics categories '
            'families expansions rankings searchAliases originalLanguage '
            'publisher releaseDateValue sortTitle subtitle description',
        ignored: _kindReason('BoardGame'),
      ),
      _policy(
        'BoardGameEditionDto',
        'id workId titleValue ageRating audienceRating barcodeValue '
            'catalogNumber country coverImageUrlValue description editionTitle '
            'format language maxPlayers minAge minPlayers playingTimeMinutes '
            'publisher releaseDateValue releaseStatus',
      ),
      _policy(
        'MusicReleaseDto',
        'id titleValue contributions identifiers media countryCode extras '
            'publisher recordingDate releaseDateValue releaseStatus releaseType '
            'sortTitle studio subtitle trackCount barcodeValue coverImageUrlValue '
            'language',
        ignored: _kindReason('Music'),
      ),
      _policy(
        'MusicMediaDto',
        'id releaseId mediaNumber mediaCondition mediaType packaging rpm '
            'soundType spars titleValue trackCount tracks vinylColor vinylWeight',
      ),
      _policy(
        'MusicTrackDto',
        'id mediaId position titleValue composition durationMs instrument',
      ),
      _policy(
        'TvEpisodeDto',
        'id seasonId episodeNumber episodeTitle airDateValue description '
            'coverImageUrlValue coverImageKey runtimeMinutes',
      ),
      _policy(
        'TvSeasonDto',
        'id seriesId seasonNumber airDateValue episodeCount description '
            'coverImageUrlValue coverImageKey episodes',
      ),
      _policy(
        'TvReleaseMediaDto',
        'id releaseId mediaNumber mediaType titleValue episodeCount '
            'runtimeMinutes regionCode encoding aspectRatio color audioTracks '
            'subtitles layers frameRate bitDepth resolution hdrFormat',
      ),
      _policy(
        'TvReleaseEpisodeMapDto',
        'id releaseId mediaId episodeId discNumber sequenceNumber',
      ),
      _policy(
        'TvReleaseDto',
        'id seriesId titleValue sortTitle description mediaCount format '
            'regionCode releaseDateValue publisher sku caseType episodeCount '
            'seasonCount runtimeMinutes languageAudio languageSubtitles '
            'contentRating coverImageUrlValue coverImageKey media '
            'episodeMappings',
      ),
      _policy(
        'ComicWorkDto',
        'id title contributors description firstPublicationDate '
            'originalLanguage sortTitle subtitle issues',
        ignored: _kindReason('Comic'),
      ),
      _policy(
        'MangaWorkDto',
        'id title chapters characterAppearances contributions description '
            'firstPublicationDate identifiers originalLanguage '
            'originalPublicationDate series sortTitle status subtitle',
        ignored: _kindReason('Manga'),
      ),
      _policy(
        'AnimeSeriesDto',
        'id title characterAppearances contributions description endDate '
            'episodeCount episodes identifiers originalAirDate originalLanguage '
            'sortTitle status',
        ignored: _kindReason('Anime'),
      ),
      _policy(
        'MovieWorkDto',
        'id title ageRating audienceRating characterAppearances contributions '
            'description externalLinks identifiers originalLanguage '
            'releaseDateValue releases runtimeMinutes sortTitle subtitle '
            'trailerUrls',
        ignored: _kindReason('Movie'),
      ),
      _policy(
        'TvSeriesDto',
        'id title characterAppearances contributions description endDate '
            'episodeCount identifiers media network originalAirDate '
            'originalLanguage seasonCount seasons sortTitle status',
        ignored: _kindReason('TV'),
      ),
    ];

CoreFieldAdoptionPolicy _policy(
  String dtoName,
  String fields, {
  Map<String, String> ignored = const {},
}) {
  return CoreFieldAdoptionPolicy(
    dtoName: dtoName,
    mapped: fields.split(' ').where((field) => field.isNotEmpty).toSet(),
    intentionallyIgnored: ignored,
  );
}

Map<String, String> _kindReason(String kind) => {
      'kind': 'used to validate the typed $kind DTO boundary',
    };
