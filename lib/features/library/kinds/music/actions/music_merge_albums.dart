import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Keep the chosen edition and personal fields; append donor discs in UI order.
/// Donor edition credits follow their discs, rather than becoming album credits.
MusicLibraryEntry mergeMusicAlbums(
    {required MusicLibraryEntry retained,
    required List<MusicLibraryEntry> donors,
    required DateTime at,
    required String Function() newId}) {
  if (retained.isDeleted || donors.any((entry) => entry.isDeleted)) {
    throw StateError('Albums must be active.');
  }
  final entries = {retained.id.value};
  if (donors.isEmpty || donors.any((entry) => !entries.add(entry.id.value))) {
    throw ArgumentError('Choose distinct albums to merge.');
  }
  final discs = retained.metadata.discs.map((disc) => disc.toJson()).toList();
  final discIds = discs.map((disc) => disc['id'] as String).toSet();
  final trackIds = {
    for (final disc in retained.metadata.discs)
      for (final track in disc.tracks) track.id.value
  };
  final creditIds = {
    for (final credit in retained.metadata.credits) credit.id.value,
    for (final disc in retained.metadata.discs)
      for (final credit in disc.credits) credit.id.value
  };
  String claim(String id, Set<String> used) {
    var result = id;
    while (!used.add(result)) {
      result = newId();
    }
    return result;
  }

  final media = [...retained.personal.details.media];
  for (final donor in donors) {
    for (final source in donor.metadata.discs) {
      final disc = source.toJson();
      final id = claim(source.id.value, discIds);
      disc['id'] = id;
      disc['disc_number'] = discs.length + 1;
      final tracks = source.tracks.map((track) => track.toJson()).toList();
      final trackIdMap = {
        for (final track in tracks)
          track['id'] as String: claim(track['id'] as String, trackIds)
      };
      for (final track in tracks) {
        track['id'] = trackIdMap[track['id']];
        if (track['parent_header_id'] != null) {
          track['parent_header_id'] = trackIdMap[track['parent_header_id']];
        }
      }
      disc['tracks'] = tracks;
      final credits = [...source.credits, ...donor.metadata.credits]
          .map((credit) => credit.toJson())
          .toList();
      for (var index = 0; index < credits.length; index++) {
        credits[index]['id'] = claim(credits[index]['id'] as String, creditIds);
        credits[index]['sequence'] = index + 1;
      }
      disc['credits'] = credits;
      discs.add(disc);
      for (final details in donor.personal.details.media
          .where((details) => details.discId == source.id.value)) {
        media.add(MusicEntryDiscDetails(
            discId: id,
            storageDevice: details.storageDevice,
            storageSlot: details.storageSlot));
      }
    }
  }
  final metadata =
      MusicAlbum.fromJson({...retained.metadata.toJson(), 'discs': discs});
  return retained.copyWith(
      metadata: metadata,
      personal: retained.personal
          .copyWith(details: retained.personal.details.copyWith(media: media)),
      updatedAt: at);
}

Future<LibraryEntryRef?> showMusicMergeAlbums(BuildContext context,
    LocalDatabase database, List<LibraryEntryRef> refs) async {
  if (refs.length < 2 ||
      refs.any((ref) => ref.kind != CatalogMediaKind.music)) {
    return null;
  }
  final repository = MusicEntryRepository(database);
  final albums = <MusicLibraryEntry>[];
  for (final ref in refs) {
    final album = await repository.findById(ref.id);
    if (album == null || album.isDeleted) {
      throw StateError('An album no longer exists.');
    }
    albums.add(album);
  }
  if (!context.mounted) return null;
  final ordered = await showDialog<List<MusicLibraryEntry>>(
      context: context, builder: (_) => _MusicMergeDialog(albums: albums));
  if (ordered == null) return null;
  return mergeMusicAlbumsInDatabase(
      database, ordered.map((album) => album.id).toList());
}

Future<LibraryEntryRef> mergeMusicAlbumsInDatabase(
    LocalDatabase database, List<LibraryEntryId> ordered) async {
  if (ordered.length < 2 || ordered.toSet().length != ordered.length) {
    throw ArgumentError('Choose distinct albums to merge.');
  }
  final repository = MusicEntryRepository(database);
  final at = DateTime.now().toUtc();
  final kept = LibraryEntryRef(kind: CatalogMediaKind.music, id: ordered.first);
  await database.transaction(() async {
    final current = <MusicLibraryEntry>[];
    for (final album in ordered) {
      final value = await repository.findById(album);
      if (value == null || value.isDeleted) {
        throw StateError('An album changed while merging.');
      }
      current.add(value);
    }
    final merged = mergeMusicAlbums(
        retained: current.first,
        donors: current.skip(1).toList(),
        at: at,
        newId: const Uuid().v4);
    await repository.upsert(merged);
    for (final donor in current.skip(1)) {
      final source =
          LibraryEntryRef(kind: CatalogMediaKind.music, id: donor.id);
      // Attached records retain identity and move with the contained music.
      await (database.update(database.itemImagesCache)
            ..where((row) => row.libraryEntryRefKey.equals(source.key)))
          .write(ItemImagesCacheCompanion(libraryEntryRefKey: Value(kept.key)));
      await (database.update(database.userExternalLinksCache)
            ..where((row) => row.libraryEntryRefKey.equals(source.key)))
          .write(UserExternalLinksCacheCompanion(
              libraryEntryRefKey: Value(kept.key), updatedAt: Value(at)));
      await (database.update(database.loansCache)
            ..where((row) => row.libraryEntryRefKey.equals(source.key)))
          .write(LoansCacheCompanion(libraryEntryRefKey: Value(kept.key)));
      await (database.update(database.musicListenEventsRows)
            ..where((row) => row.libraryEntryRefKey.equals(source.key)))
          .write(MusicListenEventsRowsCompanion(
              libraryEntryRefKey: Value(kept.key), updatedAt: Value(at)));
      await (database.update(database.musicTrackingRows)
            ..where((row) => row.libraryEntryRefKey.equals(source.key)))
          .write(MusicTrackingRowsCompanion(
              libraryEntryRefKey: Value(kept.key), updatedAt: Value(at)));
      final folders = await (database.select(database.userFolderItemsCache)
            ..where((row) => row.libraryEntryRefKey.equals(source.key)))
          .get();
      for (final folder in folders) {
        await database.into(database.userFolderItemsCache).insert(
            UserFolderItemsCacheCompanion.insert(
                folderId: folder.folderId,
                libraryEntryRefKey: kept.key,
                sortOrder: Value(folder.sortOrder)),
            mode: InsertMode.insertOrIgnore);
      }
      await (database.delete(database.userFolderItemsCache)
            ..where((row) => row.libraryEntryRefKey.equals(source.key)))
          .go();
      final queue = await (database.select(database.readingQueueCache)
            ..where((row) => row.libraryEntryRefKey.equals(source.key)))
          .getSingleOrNull();
      if (queue != null) {
        await database.into(database.readingQueueCache).insert(
            ReadingQueueCacheCompanion.insert(
                libraryEntryRefKey: kept.key,
                position: queue.position,
                addedAt: queue.addedAt),
            mode: InsertMode.insertOrIgnore);
        await (database.delete(database.readingQueueCache)
              ..where((row) => row.libraryEntryRefKey.equals(source.key)))
            .go();
      }
      final existingFields =
          await (database.select(database.customFieldValuesCache)
                ..where((row) =>
                    row.targetId.equals(kept.key) &
                    row.targetScope.equals('libraryEntry')))
              .get();
      final ownedFields =
          existingFields.map((field) => field.fieldDefinitionId).toSet();
      final donorFields =
          await (database.select(database.customFieldValuesCache)
                ..where((row) =>
                    row.targetId.equals(source.key) &
                    row.targetScope.equals('libraryEntry')))
              .get();
      for (final field in donorFields) {
        if (ownedFields.add(field.fieldDefinitionId)) {
          await (database.update(database.customFieldValuesCache)
                ..where((row) => row.id.equals(field.id)))
              .write(CustomFieldValuesCacheCompanion(
                  targetId: Value(kept.key), updatedAt: Value(at)));
        }
      }
      await repository.markDeleted(donor, at);
    }
  });
  return kept;
}

class _MusicMergeDialog extends StatefulWidget {
  const _MusicMergeDialog({required this.albums});
  final List<MusicLibraryEntry> albums;
  @override
  State<_MusicMergeDialog> createState() => _MusicMergeDialogState();
}

class _MusicMergeDialogState extends State<_MusicMergeDialog> {
  MusicLibraryEntry? _kept;
  late final List<MusicLibraryEntry> _order = [...widget.albums];
  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final donors = _order.where((album) => album.id != _kept?.id).toList();
    Widget tile(MusicLibraryEntry album, {int? index}) => Material(
        color: album.id == _kept?.id
            ? Color.alphaBlend(
                palette.accent.withValues(alpha: .2), palette.panel)
            : palette.panel,
        child: ListTile(
            key: ValueKey(album.id.value),
            onTap: () => setState(() => _kept = album),
            leading: index == null
                ? const Icon(Icons.check, size: 20)
                : ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle, size: 20)),
            title: Text(album.metadata.title,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            subtitle: Text(album.metadata.artist ?? ''),
            trailing: Text(
                '${album.metadata.discs.length} discs / ${album.metadata.trackCount} tracks')));
    return Dialog(
        alignment: Alignment.topCenter,
        insetPadding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
        child: SizedBox(
            width: 600,
            height: 520,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AccentDialogHeader(
                      title: 'Merge Albums',
                      flat: true,
                      foregroundColor: Colors.white),
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Merge ${widget.albums.length} albums',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700))),
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                          'Select the album to keep. Discs from the other albums will be appended in the order below. Edition and personal fields from the selected album are kept.')),
                  const SizedBox(height: 12),
                  if (_kept != null) tile(_kept!),
                  Expanded(
                      child: ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          itemCount: donors.length,
                          onReorderItem: (oldIndex, newIndex) {
                            setState(() {
                              final album = donors.removeAt(oldIndex);
                              donors.insert(newIndex, album);
                              _order
                                ..clear()
                                ..addAll(
                                    [if (_kept != null) _kept!, ...donors]);
                            });
                          },
                          itemBuilder: (_, index) => KeyedSubtree(
                              key: ValueKey(donors[index].id.value),
                              child: tile(donors[index], index: index)))),
                  Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel')),
                            const SizedBox(width: 8),
                            FilledButton(
                                onPressed: _kept == null
                                    ? null
                                    : () => Navigator.pop(
                                        context, [_kept!, ...donors]),
                                child: const Text('Merge'))
                          ])),
                ])));
  }
}
