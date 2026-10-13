import 'dart:typed_data';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/actions/music_merge_albums.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

MusicLibraryEntry album(String id) => MusicLibraryEntry(
    id: LibraryEntryId(id),
    updatedAt: DateTime.utc(2026),
    metadata: MusicAlbum(title: id, credits: [
      MusicCredit(
          id: const MusicCreditId('producer'),
          name: 'Producer $id',
          role: 'Producer',
          sequence: 1)
    ], discs: [
      MusicDisc(
          id: const MusicDiscId('disc'),
          discNumber: 1,
          formatFamily: MusicDiscFormatFamily.opticalDisc,
          format: 'CD',
          tracks: [
            MusicTrack(
                id: const MusicTrackId('header'),
                title: 'Side A',
                position: '',
                isHeader: true),
            MusicTrack(
                id: const MusicTrackId('track'),
                title: 'Song $id',
                position: '1',
                parentHeaderId: 'header',
                indentLevel: 1)
          ])
    ]),
    personal: MusicPersonalData(
        quantity: 2,
        ownerLabel: id,
        details: MusicEntryDetails(media: [
          MusicEntryDiscDetails(discId: 'disc', storageDevice: id)
        ])));

void main() {
  test(
      'merge keeps chosen edition and remaps colliding identities and header links',
      () {
    var id = 0;
    final kept = album('kept');
    final merged = mergeMusicAlbums(
        retained: kept,
        donors: [album('second'), album('third')],
        at: DateTime.utc(2026, 10),
        newId: () => 'new-${++id}');
    expect(merged.id, kept.id);
    expect(merged.metadata.title, 'kept');
    expect(merged.personal.ownerLabel, 'kept');
    expect(merged.personal.quantity, 2);
    expect(merged.metadata.discs.map((disc) => disc.discNumber), [1, 2, 3]);
    expect(
        merged.metadata.discs.map((disc) => disc.id.value).toSet().length, 3);
    expect(merged.metadata.discs.first.tracks.first.id.value, 'header');
    expect(merged.metadata.discs[1].tracks.last.parentHeaderId,
        merged.metadata.discs[1].tracks.first.id.value);
    expect(merged.metadata.discs[2].credits.single.name, 'Producer third');
    expect(merged.metadata.credits.single.name, 'Producer kept');
    expect(merged.personal.details.media.map((media) => media.discId),
        merged.metadata.discs.map((disc) => disc.id.value));
    expect(MusicAlbum.fromJson(merged.metadata.toJson()).trackCount, 3);
    expect(
        () => mergeMusicAlbums(
            retained: kept,
            donors: [kept],
            at: DateTime.utc(2026),
            newId: () => 'new'),
        throwsArgumentError);
  });
  test(
      'database merge moves loans and images and rolls back when a source is missing',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MusicEntryRepository(db);
    final kept = album('kept'), donor = album('donor');
    await repository.upsertAll([kept, donor]);
    final donorRef =
        LibraryEntryRef(kind: CatalogMediaKind.music, id: donor.id);
    await LoanRepository(db).create(Loan(
        id: 'loan',
        libraryEntryRef: donorRef,
        borrowerName: 'Alice',
        lentDate: DateTime.utc(2026)));
    await db.into(db.itemImagesCache).insert(ItemImagesCacheCompanion.insert(
        id: 'image',
        libraryEntryRefKey: donorRef.key,
        imageData: Uint8List.fromList([1, 2]),
        createdAt: DateTime.utc(2026)));
    await expectLater(
        mergeMusicAlbumsInDatabase(
            db, [kept.id, const LibraryEntryId('missing')]),
        throwsStateError);
    expect((await repository.findById(kept.id))!.metadata.discs, hasLength(1));
    final result = await mergeMusicAlbumsInDatabase(db, [kept.id, donor.id]);
    expect(await repository.listActive(), hasLength(1));
    expect((await repository.findById(kept.id))!.metadata.discs, hasLength(2));
    expect((await repository.findById(donor.id))!.isDeleted, isTrue);
    expect((await LoanRepository(db).getActiveLoans()).single.libraryEntryRef,
        result);
    expect(
        (await db.select(db.itemImagesCache).get()).single.libraryEntryRefKey,
        result.key);
  });
}
