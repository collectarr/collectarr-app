import 'dart:io';

import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_action_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Core clients use only the canonical /api/v1 surface', () {
    final apiDirectory = Directory('lib/core/api');
    for (final file in apiDirectory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))) {
      final source = file.readAsStringSync();
      final paths = RegExp(r'''['"](/[^'"]*)['"]''')
          .allMatches(source)
          .map((match) => match.group(1)!)
          .where((path) => path.length > 1 && path.startsWith('/'));
      for (final path in paths) {
        expect(
          path,
          startsWith('/api/v1/'),
          reason: '${file.path} contains an unversioned Core path: $path',
        );
      }
    }
  });

  test('provider role ownership has no legacy inference switches', () {
    final providerSources = <File>[
      ...Directory('lib/features/library/kinds')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) =>
              file.path.contains(
                  '${Platform.pathSeparator}provider${Platform.pathSeparator}') &&
              file.path.endsWith('.dart')),
      ...Directory('lib/features/admin')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart')),
      ...Directory('lib/features/providers')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart')),
    ];
    for (final file in providerSources) {
      final source = file.readAsStringSync();
      expect(source, isNot(contains('isVariantOverride')), reason: file.path);
      expect(source, isNot(contains("attributeBool('is_variant')")),
          reason: file.path);
      expect(source, isNot(contains("'is_variant'")), reason: file.path);
      expect(source, isNot(contains('defaultProviderSearchRoleForScope')),
          reason: file.path);
    }
  });

  test('final boundaries reject semantic fallbacks and local target maps', () {
    final workspaceSchema = File(
      'lib/features/library/workspace/schema/library_entity_workspace_schema.dart',
    ).readAsStringSync();
    expect(workspaceSchema, isNot(contains('withEntityScope')));

    final correction = File(
      'lib/features/library/edit/core_correction/library_core_correction.dart',
    ).readAsStringSync();
    expect(correction, isNot(contains('_canonicalFieldSpec')));
    expect(correction, isNot(contains("CatalogMediaKind.book => 'book_work'")));
    expect(correction, isNot(contains('personalNotes')));
    expect(correction, isNot(contains('condition')));

    final musicWorkspace = Directory(
      'lib/features/library/kinds/music/workspace',
    )
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in musicWorkspace) {
      final source = file.readAsStringSync();
      expect(source, isNot(contains('_placeholderRelease')), reason: file.path);
      expect(source, isNot(contains('release ?? music.primaryRelease')),
          reason: file.path);
    }

    final sourceFiles = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in sourceFiles) {
      final source = file.readAsStringSync();
      expect(source, isNot(contains('LibraryKindTopology')), reason: file.path);
      expect(source, isNot(contains('supportsWorkReleaseSplit')),
          reason: file.path);
    }
  });

  test('every kind has strict Work/Release/Copy architecture contributors', () {
    const scopes = <LibraryEntityScope>[
      LibraryEntityScope.work,
      LibraryEntityScope.release,
      LibraryEntityScope.copy,
    ];

    for (final LibraryKindRegistration registration
        in collectarrKindRegistrationsList) {
      final kind = registration.kind;
      final workspace = collectarrKindWorkspaces[kind];
      final edit = collectarrKindEditCapabilities[kind];
      final inspector = collectarrKindInspectors[kind];
      final actions = collectarrKindEntityActions[kind];

      expect(workspace, isNotNull, reason: '$kind has no workspace');
      expect(edit, isNotNull, reason: '$kind has no edit registration');
      expect(inspector, isNotNull, reason: '$kind has no inspector');
      expect(actions, isNotNull, reason: '$kind has no entity actions');

      for (final scope in scopes) {
        expect(
          workspace!.projectorForScope(scope),
          isNotNull,
          reason: '$kind has no $scope workspace projector',
        );
        expect(
          edit!.presentationCapability.editRegistry.builderForScope(scope),
          isNotNull,
          reason: '$kind has no $scope edit builder',
        );
        expect(
          inspector!.entityRegistry.contributorForScope(scope),
          isNotNull,
          reason: '$kind has no $scope inspector contributor',
        );
        expect(actions!.actionSetForScope(scope), isNotNull,
            reason: '$kind has no $scope action set');
      }
    }
  });

  test('kind contributions are independent module libraries', () {
    final kindFiles = Directory('lib/features/library/kinds')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in kindFiles) {
      final source = file.readAsStringSync();
      expect(
        source,
        isNot(matches(RegExp(r'^\s*part\s+of\s+', multiLine: true))),
        reason: file.path,
      );
      expect(source, isNot(contains("part '")), reason: file.path);
      expect(source, isNot(contains('_kind_components')), reason: file.path);
    }

    final modules = kindFiles
        .where((file) => file.path.endsWith('_module.dart'))
        .toList(growable: false);
    expect(modules, hasLength(9));
  });

  test('generic hosts delegate kind semantics through capabilities', () {
    const genericHostPaths = <String>[
      'lib/features/collection/mutations/tracking_mutations.dart',
      'lib/features/library/add/services/library_provider_add_coordinator.dart',
      'lib/features/library/detail/library_detail_page.dart',
      'lib/features/library/inspector/library_inspector.dart',
      'lib/features/library/tracking/tracking_storage_repository.dart',
    ];
    for (final path in genericHostPaths) {
      final source = File(path).readAsStringSync();
      expect(source, isNot(contains('CatalogMediaKind.music')), reason: path);
      expect(source, isNot(contains('CatalogMediaKind.game')), reason: path);
      expect(source, isNot(contains('MusicOwnedItem')), reason: path);
      expect(source, isNot(contains('GameOwnedItem')), reason: path);
      expect(source, isNot(contains('MusicTracking')), reason: path);
    }
  });

  test('kind configuration does not own copy-transfer dispatch', () {
    final configurationFiles = Directory('lib/features/library/kinds')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('_kind_configuration.dart'));
    for (final file in configurationFiles) {
      final source = file.readAsStringSync();
      expect(source, isNot(contains('TransferOwnedItem')), reason: file.path);
      expect(source, isNot(contains('HierarchyContractDiagnosticLabel')),
          reason: file.path);
    }
  });

  test('smart lists have no global semantic sort fallback', () {
    final source = File('lib/core/models/smart_list.dart').readAsStringSync();
    expect(source, isNot(contains('_validSortColumns')));
    expect(source, contains('fieldsForScope'));
    expect(source, contains('degradedSortTokens'));
    expect(source, contains('degradedFieldTokens'));
  });

  test('Core correction boundary is snapshot based and excludes personal data',
      () {
    final source = File(
      'lib/features/library/edit/core_correction/library_core_correction.dart',
    ).readAsStringSync();
    expect(source, contains('baseRevision'));
    expect(source, contains('baseHash'));
    expect(source, contains('field.scope != target.scope.apiValue'));
    expect(source, contains('field.entityType != snapshot.entityType'));
    expect(source, contains('statusCode == 409'));
    expect(source, isNot(contains("'personalNotes'")));
    expect(source, isNot(contains("'condition'")));
    expect(source, isNot(contains("'locationId'")));
  });
}
