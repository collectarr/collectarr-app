import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter_test/flutter_test.dart';

import 'kind_contract_manifest.dart';

void main() {
  test('manifest lists exactly the active catalog kinds', () {
    final enumKinds =
        CatalogMediaKind.values.where((kind) => !kind.isUnknown).toSet();

    expect(kindContractManifest.activeKinds, equals(enumKinds));
    expect(kindContractManifest.activeKinds, hasLength(9));
  });

  test('every mandatory contract includes every active kind', () {
    const expectedMandatory = {
      'coreMapping',
      'repository',
      'mediaPersistence',
      'workspace',
      'fields',
      'sort',
      'group',
      'facet',
      'vocabulary',
      'add',
      'mediaEdit',
      'identity',
    };

    expect(
      kindContractManifest.mandatoryParticipants.keys.toSet(),
      equals(expectedMandatory),
    );
    for (final entry in kindContractManifest.mandatoryParticipants.entries) {
      expect(
        entry.value,
        equals(kindContractManifest.activeKinds),
        reason: '${entry.key} must include every active kind',
      );
    }
  });

  test('optional contracts declare only known kind participants', () {
    const expectedOptional = {
      'release',
      'releaseEdit',
      'releasePersistence',
      'tracking',
      'hierarchy',
      'providerIntegration',
    };

    expect(
      kindContractManifest.optionalParticipants.keys.toSet(),
      equals(expectedOptional),
    );
    for (final entry in kindContractManifest.optionalParticipants.entries) {
      expect(
        kindContractManifest.activeKinds.containsAll(entry.value),
        isTrue,
        reason: '${entry.key} contains an unknown kind',
      );
    }
  });
}
