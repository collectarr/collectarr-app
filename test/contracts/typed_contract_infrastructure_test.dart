import 'add_contract.dart';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:collectarr_app/features/library/actions/ui_action.dart';
import 'package:collectarr_app/features/library/actions/import_export_actions.dart';

import 'actions/import_export_contract.dart';
import 'actions/ui_action_contract.dart';
import 'barcode/barcode_contract.dart';
import 'calendar/calendar_contract.dart';
import 'core_field_adoption_contract.dart';
import 'core_mapping_contract.dart';
import 'facet_contract.dart';
import 'fields_contract.dart';
import 'group_contract.dart';
import 'kind_identity_contract.dart';
import 'media_edit_contract.dart';
import 'owned_edit_contract.dart';
import 'overrides/override_contract.dart';
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
      intentionallyIgnored: {'ignoredField': 'intentionally ignored'},
    ),
    actualFields: (_) => const ['id', 'ignoredField'],
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

  test('Core field adoption rejects a stale policy field', () {
    expect(
      () => validateCoreDtoFieldAdoption(
        source: '''
class FixtureDto {
  final String id;
}
''',
        policy: CoreFieldAdoptionPolicy(
          dtoName: 'FixtureDto',
          mapped: {'id', 'removedField'},
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
    tabIds: (_) => const ['owned'],
    fieldIds: (_, __) => const ['condition'],
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

  defineUiActionContract<_FixtureAction, String>(
    name: 'fixture',
    create: _FixtureAction.new,
    id: (action) => action.id,
    label: (action) => action.label,
    isVisible: (action, context) => action.isVisible(context),
    isEnabled: (action, context) => action.isEnabled(context),
    run: (action, context) => action.run(context),
    createContext: () => 'context',
  );

  defineExportActionContract<_FixtureAction, String>(
    name: 'fixture',
    create: _FixtureAction.new,
    export: (action, context) => action.export(context),
    createContext: () => 'context',
  );

  defineImportActionContract<_FixtureAction, String, ImportPreview>(
    name: 'fixture',
    create: _FixtureAction.new,
    preview: (action, context) => action.previewImport(context),
    issues: (preview) => preview.issues.map((issue) => issue.message),
    createContext: () => 'context',
  );

  defineCalendarContributorContract<_FixtureCalendarContributor, String,
      _FixtureCalendarEvent>(
    name: 'fixture',
    create: _FixtureCalendarContributor.new,
    project: (_, __) => [
      _FixtureCalendarEvent(
        id: 'event-1',
        title: 'Fixture event',
        kindReference: 'fixture:1',
        startsAt: DateTime.utc(2026, 1, 1),
        endsAt: DateTime.utc(2026, 1, 1, 1),
      ),
    ],
    id: (event) => event.id,
    title: (event) => event.title,
    kindReference: (event) => event.kindReference,
    startsAt: (event) => event.startsAt,
    endsAt: (event) => event.endsAt,
    createContext: () => 'context',
  );

  defineBarcodeResolverContract<_FixtureBarcodeResolver, String, String>(
    name: 'fixture',
    create: _FixtureBarcodeResolver.new,
    normalize: (_, code) => code.trim(),
    isSupported: (_, code) => RegExp(r'^\d{10}$').hasMatch(code),
    resolve: (_, code) => RegExp(r'^\d{10}$').hasMatch(code) ? code : null,
    validCode: () => '1234567890',
    unsupportedCode: () => 'not-a-code',
    isValidResult: (result) => result == '1234567890',
  );

  defineMetadataOverrideContract<_FixtureOverrideSchema, String, String,
      String>(
    name: 'fixture',
    create: _FixtureOverrideSchema.new,
    target: (_) => 'fixture:1',
    field: (_) => 'title',
    fieldId: (field) => field,
    value: () => 'Override title',
    encode: (_, value) => value,
    decode: (_, payload) => payload! as String,
    isValidTarget: (_, target) => target.startsWith('fixture:'),
    equals: (left, right) => left == right,
  );
}

final class _FixtureAction
    implements
        UiAction<String>,
        ExportAction<String>,
        ImportAction<String, ImportPreview> {
  const _FixtureAction();

  @override
  String get id => 'fixture.action';

  @override
  String get label => 'Fixture action';

  @override
  IconData get icon => Icons.play_arrow;

  @override
  UiActionPlacement get placement => UiActionPlacement.secondary;

  @override
  bool isVisible(String context) => context == 'context';

  @override
  bool isEnabled(String context) => context == 'context';

  @override
  void run(String context) {}

  @override
  Future<ExportArtifact> export(String context) async {
    return ExportArtifact(
      filename: 'fixture.json',
      mimeType: 'application/json',
      bytes: Uint8List.fromList(const [123, 125]),
    );
  }

  @override
  Future<ImportPreview> previewImport(String context) async {
    return const ImportPreview();
  }

  @override
  Future<void> applyImport(String context, ImportPreview preview) async {}
}

final class _FixtureCalendarContributor {
  const _FixtureCalendarContributor();
}

final class _FixtureCalendarEvent {
  const _FixtureCalendarEvent({
    required this.id,
    required this.title,
    required this.kindReference,
    required this.startsAt,
    required this.endsAt,
  });

  final String id;
  final String title;
  final String kindReference;
  final DateTime startsAt;
  final DateTime endsAt;
}

final class _FixtureBarcodeResolver {
  const _FixtureBarcodeResolver();
}

final class _FixtureOverrideSchema {
  const _FixtureOverrideSchema();
}
