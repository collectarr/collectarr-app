import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/sync/list_value_image_sync.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/csv/csv_mechanics.dart';
import 'package:collectarr_app/features/library/ui/primitives/image_intake.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The key a value's image is stored under: its trimmed, lower-case text, or
/// null for an empty value.
String? listValueImageKey(String? value) => switch (value?.trim()) {
      null || '' => null,
      final text => text.toLowerCase(),
    };

/// Image files a list value's image is loaded from; SVG keeps logos sharp.
const listValueImageFileTypes = [
  XTypeGroup(
      label: 'Images', extensions: ['svg', 'png', 'jpg', 'jpeg', 'webp', 'gif'])
];

/// What a bulk load accepts: image files and the index naming them.
const listValueImageLoadFileTypes = [
  XTypeGroup(
      label: 'Images and index',
      extensions: ['svg', 'png', 'jpg', 'jpeg', 'webp', 'gif', 'csv'])
];

/// The values an index file gives each image file, by lower-case file name.
/// An index is a CSV with Name and File columns; one file can serve many
/// values, and rows without a file are skipped.
Map<String, List<String>> listValueImageIndex(String source) {
  final rows = const CsvReader().read(source);
  if (rows.isEmpty) throw const FormatException('The index is empty.');
  final header = [for (final cell in rows.first) cell.trim().toLowerCase()];
  final nameColumn = header.indexOf('name');
  final fileColumn = header.indexOf('file');
  if (nameColumn < 0 || fileColumn < 0) {
    throw const FormatException('The index needs Name and File columns.');
  }
  final index = <String, List<String>>{};
  for (final row in rows.skip(1)) {
    if (row.length <= nameColumn || row.length <= fileColumn) continue;
    final name = row[nameColumn].trim();
    final file = row[fileColumn].trim().toLowerCase();
    if (name.isEmpty || file.isEmpty) continue;
    (index[file] ??= []).add(name);
  }
  return index;
}

/// Whether [bytes] hold an SVG document rather than a raster image.
bool isSvgImage(Uint8List bytes) {
  final head = utf8
      .decode(bytes.take(512).toList(), allowMalformed: true)
      .trimLeft()
      .toLowerCase();
  return head.startsWith('<svg') ||
      (head.startsWith('<?xml') && head.contains('<svg')) ||
      (head.startsWith('<!--') && head.contains('<svg'));
}

/// Whether an SVG [image] draws only in black, so it can take the text
/// colour like a built-in logo: every colour it names is black.
bool isBlackSvg(Uint8List image) {
  if (!isSvgImage(image)) return false;
  final text = utf8.decode(image, allowMalformed: true).toLowerCase();
  final colours = RegExp(r'#([0-9a-f]{6}|[0-9a-f]{3})\b|'
          r'(?:fill|stroke|stop-color)[=:]\s*"?([a-z]+)')
      .allMatches(text)
      .map((match) => match.group(1) ?? match.group(2)!)
      .where((colour) => colour != 'none' && colour != 'currentcolor');
  return colours.every((colour) => colour == 'black' || _nearBlack(colour));
}

/// Whether a hex colour such as "221e1f" is black or nearly so.
bool _nearBlack(String hex) {
  final full = hex.length == 3 ? hex.split('').map((c) => '$c$c').join() : hex;
  final value = int.tryParse(full, radix: 16);
  if (value == null) return false;
  return [16, 8, 0].every((shift) => (value >> shift) & 0xff <= 0x33);
}

/// Accepts an SVG or a raster image the library accepts, up to the size Sync
/// carries.
Future<void> validateListValueImage(Uint8List bytes) async {
  if (bytes.length > maxSyncedListValueImageBytes) {
    throw const FormatException('Choose an image up to 2 MB.');
  }
  if (isSvgImage(bytes)) return;
  await validateLibraryImageBytes(bytes);
}

/// The value an image file is named after: "Spawn #1" from "Spawn #1.png".
String listValueFromFileName(String fileName) {
  final dot = fileName.lastIndexOf('.');
  return (dot > 0 ? fileName.substring(0, dot) : fileName).trim();
}

/// The images users load from their own files for the values of a list.
class ListValueImages {
  const ListValueImages(this._db);

  final LocalDatabase _db;

  Stream<Uint8List?> watch(String list, String value) {
    final key = listValueImageKey(value);
    if (key == null) return Stream.value(null);
    final rows = _db.listValueImagesCache;
    return (_db.select(rows)
          ..where((row) => row.listKey.equals(list) & row.valueKey.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.valueImage);
  }

  /// The values of [list] that have an image, by value.
  Stream<List<String>> watchValues(String list) {
    final rows = _db.listValueImagesCache;
    return (_db.selectOnly(rows)
          ..addColumns([rows.value])
          ..where(rows.listKey.equals(list))
          ..orderBy([OrderingTerm.asc(rows.valueKey)]))
        .map((row) => row.read(rows.value)!)
        .watch();
  }

  /// Every image of [list], by [listValueImageKey].
  Stream<Map<String, Uint8List>> watchImages(String list) {
    final rows = _db.listValueImagesCache;
    return (_db.select(rows)..where((row) => row.listKey.equals(list)))
        .watch()
        .map((rows) => {for (final row in rows) row.valueKey: row.valueImage});
  }

  Future<void> save(String list, String value, Uint8List image) async {
    final key = listValueImageKey(value);
    if (key == null) return;
    await _db.transaction(() async {
      await _write(list, key, value.trim(), image, DateTime.now().toUtc());
      await SyncQueueRepository(_db).enqueue(listValueImageChange(
          list: list, valueKey: key, value: value.trim(), image: image));
    });
  }

  Future<void> remove(String list, String value) async {
    final key = listValueImageKey(value);
    if (key == null) return;
    final rows = _db.listValueImagesCache;
    await _db.transaction(() async {
      await (_db.delete(rows)
            ..where(
                (row) => row.listKey.equals(list) & row.valueKey.equals(key)))
          .go();
      await SyncQueueRepository(_db).enqueue(
          listValueImageChange(list: list, valueKey: key, value: value.trim()));
    });
  }

  Future<void> removeAll(String list) async {
    final table = _db.listValueImagesCache;
    await _db.transaction(() async {
      final rows = await (_db.select(table)
            ..where((row) => row.listKey.equals(list)))
          .get();
      await (_db.delete(table)..where((row) => row.listKey.equals(list))).go();
      final queue = SyncQueueRepository(_db);
      for (final row in rows) {
        await queue.enqueue(listValueImageChange(
            list: list, valueKey: row.valueKey, value: row.value));
      }
    });
  }

  /// Stores an image pulled from Sync, without queueing it back.
  Future<void> applySyncedUpsert(
      String list, String value, Uint8List image, DateTime changedAt) async {
    final key = listValueImageKey(value);
    if (key == null) return;
    await _write(list, key, value.trim(), image, changedAt);
  }

  /// Removes the image a Sync tombstone names, without queueing it back.
  Future<void> applySyncedDelete(String entityId) async {
    final table = _db.listValueImagesCache;
    final rows = await (_db.selectOnly(table)
          ..addColumns([table.listKey, table.valueKey]))
        .get();
    for (final row in rows) {
      final list = row.read(table.listKey)!;
      final key = row.read(table.valueKey)!;
      if (listValueImageSyncId(list, key) != entityId) continue;
      await (_db.delete(table)
            ..where(
                (row) => row.listKey.equals(list) & row.valueKey.equals(key)))
          .go();
    }
  }

  Future<void> _write(String list, String key, String value, Uint8List image,
          DateTime updatedAt) =>
      _db.into(_db.listValueImagesCache).insertOnConflictUpdate(
            ListValueImagesCacheCompanion.insert(
              listKey: list,
              valueKey: key,
              value: value,
              valueImage: image,
              updatedAt: updatedAt,
            ),
          );

  /// Lets the user pick image files, and optionally their index, to load.
  Future<({int loaded, List<String> skipped})> loadFiles(String list) async =>
      loadPickedFiles(list,
          await openFiles(acceptedTypeGroups: listValueImageLoadFileTypes));

  /// Stores each image under the values an index among [files] gives it, else
  /// under the value it is named after; returns how many values loaded and
  /// the files skipped.
  Future<({int loaded, List<String> skipped})> loadPickedFiles(
      String list, List<XFile> files) async {
    final index = <String, List<String>>{};
    final images = <XFile>[];
    final skipped = <String>[];
    for (final file in files) {
      if (!file.name.toLowerCase().endsWith('.csv')) {
        images.add(file);
        continue;
      }
      try {
        index.addAll(listValueImageIndex(await file.readAsString()));
      } catch (_) {
        skipped.add(file.name);
      }
    }
    var loaded = 0;
    for (final file in images) {
      try {
        final bytes = await file.readAsBytes();
        await validateListValueImage(bytes);
        final values = index[file.name.toLowerCase()] ??
            [listValueFromFileName(file.name)];
        for (final value in values) {
          await save(list, value, bytes);
          loaded++;
        }
      } catch (_) {
        skipped.add(file.name);
      }
    }
    return (loaded: loaded, skipped: skipped);
  }
}

final listValueImagesProvider = Provider<ListValueImages>(
    (ref) => ListValueImages(ref.watch(localDatabaseProvider)));

/// The image loaded for a list value.
final listValueImageProvider = StreamProvider.autoDispose
    .family<Uint8List?, ({String list, String value})>((ref, key) =>
        ref.watch(listValueImagesProvider).watch(key.list, key.value));

/// The values of a list that have an image.
final listValueImageValuesProvider = StreamProvider.autoDispose
    .family<List<String>, String>(
        (ref, list) => ref.watch(listValueImagesProvider).watchValues(list));

/// Every image of a list, by [listValueImageKey].
final listValueImagesByKeyProvider = StreamProvider.autoDispose
    .family<Map<String, Uint8List>, String>(
        (ref, list) => ref.watch(listValueImagesProvider).watchImages(list));

/// Asks for an image file and stores it for [value]; returns what went wrong.
Future<String?> chooseListValueImage(
    ListValueImages images, String list, String value) async {
  final file = await openFile(acceptedTypeGroups: listValueImageFileTypes);
  if (file == null) return null;
  try {
    final bytes = await file.readAsBytes();
    await validateListValueImage(bytes);
    await images.save(list, value, bytes);
    return null;
  } on FormatException catch (error) {
    return error.message;
  } catch (_) {
    return 'Could not load the image.';
  }
}

/// A loaded list value image, SVG or raster, scaled to fit.
class ListValueImageView extends StatelessWidget {
  const ListValueImageView(this.image,
      {this.fit = BoxFit.contain,
      this.alignment = Alignment.center,
      this.width,
      this.height,
      this.blackSvgTint,
      super.key});

  final Uint8List image;
  final BoxFit fit;
  final Alignment alignment;
  final double? width;
  final double? height;

  /// Paints an all-black SVG in this colour instead, as built-in logos take
  /// the text colour.
  final Color? blackSvgTint;

  @override
  Widget build(BuildContext context) => isSvgImage(image)
      ? SvgPicture.memory(image,
          fit: fit,
          alignment: alignment,
          width: width,
          height: height,
          colorFilter: blackSvgTint != null && isBlackSvg(image)
              ? ColorFilter.mode(blackSvgTint!, BlendMode.srcIn)
              : null)
      : Image.memory(image,
          fit: fit,
          alignment: alignment,
          width: width,
          height: height,
          gaplessPlayback: true);
}

/// "Loaded 3 images. Skipped: a.txt." after loading files.
String listValueImagesLoadMessage(
        ({int loaded, List<String> skipped}) result) =>
    [
      'Loaded ${result.loaded} ${result.loaded == 1 ? 'image' : 'images'}.',
      if (result.skipped.isNotEmpty) 'Skipped: ${result.skipped.join(', ')}.',
    ].join(' ');
