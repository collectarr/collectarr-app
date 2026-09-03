import 'add_contract.dart';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'core_field_adoption_contract.dart';
import 'core_mapping_contract.dart';
import 'facet_contract.dart';
import 'fields_contract.dart';
import 'group_contract.dart';
import 'kind_identity_contract.dart';
import 'media_edit_contract.dart';
import 'owned_edit_contract.dart';
import 'persistence_contract.dart';
import 'provider_integration_contract.dart';
import 'release_edit_contract.dart';
import 'repository_contract.dart';
import 'sort_contract.dart';
import 'tracking_contract.dart';
import 'vocabulary_contract.dart';
import 'workspace_contract.dart';

void main() {
  defineKindIdentityContract<String>(
    name: 'fixture',
    create: () => 'fixture',
    kindKey: (subject) => subject,
    singularLabel: (_) => 'Item',
    pluralLabel: (_) => 'Items',
    countLabel: (_) => 'Item',
  );

  defineCoreMappingContract<int, String>(
    name: 'fixture',
    createDomain: () => 7,
    encode: (domain) => '$domain',
    decode: int.parse,
    equals: (left, right) => left == right,
  );

  defineCoreFieldAdoptionContract(
    name: 'fixture',
    createPolicy: () => CoreFieldAdoptionPolicy(
      dtoName: 'FixtureDto',
      mapped: {'id'},
      intentionallyIgnored: {'legacy': 'compatibility'},
    ),
    actualFields: (_) => const ['id', 'legacy'],
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
          'kind',
        },
        intentionallyIgnored: const {},
      ),
    );
  });

  test('Core field adoption rejects an unclassified DTO field', () {
    const source = '''
class FixtureDto {
  final String id;
  final String firstPublicationDate;
}
''';

    expect(
      () => validateCoreDtoFieldAdoption(
        source: source,
        policy: CoreFieldAdoptionPolicy(
          dtoName: 'FixtureDto',
          mapped: {'id'},
          intentionallyIgnored: const {},
        ),
      ),
      throwsA(anything),
    );
  });

  final repositoryData = <String, int>{};
  defineRepositoryContract<int, String>(
    name: 'fixture',
    create: () => 7,
    idOf: (_) => 'fixture-7',
    save: (subject) async => repositoryData['fixture-7'] = subject,
    find: (id) async => repositoryData[id],
    equals: (left, right) => left == right,
  );

  definePersistenceContract<int>(
    name: 'fixture',
    create: () => 7,
    encode: (subject) => {'value': subject},
    decode: (payload) => payload['value']! as int,
    equals: (left, right) => left == right,
  );

  defineWorkspaceContract<int>(
    name: 'fixture',
    create: () => 1,
    title: (_) => 'Fixture',
    fieldIds: (_) => const ['title'],
    sortIds: (_) => const ['title'],
  );

  defineFieldsContract<int>(
    name: 'fixture',
    create: () => 1,
    fieldIds: (_) => const ['title'],
    label: (_, fieldId) => fieldId,
  );

  defineSortContract<int>(
    name: 'fixture',
    create: () => 1,
    sortIds: (_) => const ['title'],
    compare: (_, __, ___, ____) => 0,
  );

  defineGroupContract<int>(
    name: 'fixture',
    create: () => 1,
    groupIds: (_) => const ['title'],
    bucket: (_, __, ___) => 'all',
  );

  defineFacetContract<int>(
    name: 'fixture',
    create: () => 1,
    facetIds: (_) => const ['title'],
    label: (_, facetId) => facetId,
  );

  defineVocabularyContract<int>(
    name: 'fixture',
    create: () => 1,
    vocabularies: (_) => const {
      'status': ['owned', 'wanted']
    },
  );

  defineAddContract<int>(
    name: 'fixture',
    create: () => 1,
    fieldIds: (_) => const ['title'],
    label: (_, fieldId) => fieldId,
  );

  defineMediaEditContract<int>(
    name: 'fixture',
    create: () => 1,
    tabIds: (_) => const ['media'],
    fieldIds: (_, __) => const ['title'],
  );

  defineReleaseEditContract<int>(
    name: 'fixture',
    create: () => 1,
    tabIds: (_) => const ['release'],
    fieldIds: (_, __) => const ['format'],
  );

  defineOwnedEditContract<int>(
    name: 'fixture',
    create: () => 1,
    fieldIds: (_) => const ['condition'],
    label: (_, fieldId) => fieldId,
  );

  defineProviderIntegrationContract<int>(
    name: 'fixture',
    create: () => 1,
    providerIds: (_) => const ['fixture-provider'],
    load: (_, __) async => const Object(),
  );

  defineTrackingContract<int>(
    name: 'fixture',
    create: () => 1,
    state: (_) => 'active',
    progress: (_) => 0,
  );
}
