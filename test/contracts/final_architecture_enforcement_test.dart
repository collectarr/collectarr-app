import 'dart:io';

import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_action_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_edit_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_workspace_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
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
            file.path.contains('${Platform.pathSeparator}provider${Platform.pathSeparator}') &&
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
      expect(source, isNot(contains('_placeholderRelease')),
          reason: file.path);
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

  test('kind component files are composition-only', () {
    final componentFiles = Directory('lib/features/library/kinds')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) =>
            file.path.endsWith('_kind_components.dart') &&
            !file.path.contains('${Platform.pathSeparator}registry${Platform.pathSeparator}'));
    for (final file in componentFiles) {
      final source = file.readAsStringSync();
      expect(source.length, lessThan(5000), reason: file.path);
      expect(source, isNot(contains('class ')), reason: file.path);
    }
  });
}
