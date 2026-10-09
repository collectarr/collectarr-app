import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/api/dto/canonical_correction_target.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const musicItemField = CanonicalCorrectionField(
    key: 'discs',
    label: 'Discs',
    valueType: 'object_list',
    scope: 'catalog_item',
    entityType: 'music_item',
  );

  test('personal-only changes cannot enter the Core correction field schema',
      () {
    final album = MusicAlbum(
      id: const CatalogItemRef(kind: CatalogMediaKind.music, id: 'album-1'),
      title: 'Album',
    );
    final original = album.toJson();
    final proposed = <String, Object?>{
      ...album.toJson(),
      'listening_events': [
        {'id': 'listen-1', 'rating': 5},
      ],
      'personal_condition': 'Near Mint',
    };

    final changes = libraryCoreKindCorrectionChanges(
      originalFields: original,
      proposedFields: proposed,
      fieldSchema: const [musicItemField],
      scope: 'catalog_item',
      entityType: 'music_item',
    );

    expect(changes, isEmpty);
  });

  test('disc edits enter the proposal with their stable nested identities', () {
    final album = MusicAlbum(
      id: const CatalogItemRef(kind: CatalogMediaKind.music, id: 'album-2'),
      title: 'Deluxe Edition',
      discs: [
        MusicDisc(
          id: const MusicDiscId('disc-1'),
          discNumber: 1,
          format: 'CD',
          formatFamily: MusicDiscFormatFamily.opticalDisc,
          recordingDate: PartialDate(year: 2025),
        ),
      ],
    );
    final draft = MusicAlbumEditDraft.fromAlbum(album);
    draft.discList.updateDiscRecordingDate(
      const MusicDiscId('disc-1'),
      PartialDate(year: 2026, month: 2, day: 18),
    );

    final changes = libraryCoreKindCorrectionChanges(
      originalFields: album.toJson(),
      proposedFields: draft.toAlbum().toJson(),
      fieldSchema: const [musicItemField],
      scope: 'catalog_item',
      entityType: 'music_item',
    );
    final discs = (changes['discs']! as List).cast<Map<String, dynamic>>();

    expect(discs, hasLength(1));
    expect(discs.single['id'], 'disc-1');
    expect(discs.single['disc_number'], 1);
    expect(discs.single['recording_date'], {
      'year': 2026,
      'month': 2,
      'day': 18,
    });
  });

  test('correction changes require writable matching Core scope and type', () {
    final original = <String, Object?>{'discs': <Object?>[]};
    final proposed = <String, Object?>{
      'discs': <Object?>[
        {'id': 'disc-1'},
      ],
    };
    final changes = libraryCoreKindCorrectionChanges(
      originalFields: original,
      proposedFields: proposed,
      fieldSchema: const [
        musicItemField,
        CanonicalCorrectionField(
          key: 'discs',
          label: 'Entry discs',
          valueType: 'object_list',
          scope: 'library_entry',
          entityType: 'music_item',
        ),
        CanonicalCorrectionField(
          key: 'discs',
          label: 'Read-only discs',
          valueType: 'object_list',
          scope: 'catalog_item',
          entityType: 'music_item',
          writable: false,
        ),
        CanonicalCorrectionField(
          key: 'discs',
          label: 'Mismatched discs',
          valueType: 'string',
          scope: 'catalog_item',
          entityType: 'music_item',
        ),
      ],
      scope: 'catalog_item',
      entityType: 'music_item',
    );

    expect(changes.keys, ['discs']);
    expect(changes['discs'], proposed['discs']);
  });
}
