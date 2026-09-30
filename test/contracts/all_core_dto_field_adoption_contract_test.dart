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
