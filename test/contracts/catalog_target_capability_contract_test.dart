import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('catalog target capabilities', () {
    for (final entry in collectarrKindCatalogTargets.entries) {
      final kind = entry.key;
      final capability = entry.value;

      test('${kind.apiValue} resolves and decomposes typed targets', () {
        final targetCapability = capability;
        final root = CatalogEntityRef(
          kind: kind,
          entityType: const CatalogEntityTypeId('work'),
          id: '${kind.apiValue}-work',
        );

        expect(
          targetCapability.resolve(
            root,
            const LibraryCatalogTargetSelection(
              referenceType: LibraryAddReferenceType.media,
            ),
          ),
          root,
        );

        final edition = targetCapability.resolve(
          root,
          const LibraryCatalogTargetSelection(
            referenceType: LibraryAddReferenceType.edition,
            firstId: 'edition-1',
          ),
        );
        expect(edition.entityType.apiValue, 'edition');
        expect(edition.id, 'edition-1');
        expect(edition.rootId, root.id);

        final release = targetCapability.resolve(
          root,
          const LibraryCatalogTargetSelection(
            referenceType: LibraryAddReferenceType.edition,
            firstId: 'edition-1',
            secondId: 'release-1',
          ),
        );
        expect(release.entityType.apiValue, 'release');
        expect(release.id, 'release-1');
        expect(release.rootId, root.id);
        expect(release.parentId, 'edition-1');

        final bundle = targetCapability.resolve(
          root,
          const LibraryCatalogTargetSelection(
            referenceType: LibraryAddReferenceType.bundleRelease,
            groupId: 'bundle-1',
          ),
        );
        expect(bundle.entityType.apiValue, 'bundle_release');
        expect(bundle.id, 'bundle-1');
        expect(bundle.rootId, root.id);

        expect(targetCapability.parts(edition).firstId, 'edition-1');
        expect(targetCapability.parts(release).firstId, 'edition-1');
        expect(targetCapability.parts(release).secondId, 'release-1');
        expect(targetCapability.parts(bundle).groupId, 'bundle-1');
      });
    }
  });
}
