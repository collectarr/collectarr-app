import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
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

/// Accepts an SVG up to 2 MB or a raster image the library accepts.
Future<void> validateListValueImage(Uint8List bytes) async {
  if (isSvgImage(bytes)) {
    if (bytes.length > 2 * 1024 * 1024) {
      throw const FormatException('Choose an SVG up to 2 MB.');
    }
    return;
  }
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

  Future<void> save(String list, String value, Uint8List image) async {
    final key = listValueImageKey(value);
    if (key == null) return;
    await _db.into(_db.listValueImagesCache).insertOnConflictUpdate(
          ListValueImagesCacheCompanion.insert(
            listKey: list,
            valueKey: key,
            value: value.trim(),
            valueImage: image,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<void> remove(String list, String value) async {
    final key = listValueImageKey(value);
    if (key == null) return;
    final rows = _db.listValueImagesCache;
    await (_db.delete(rows)
          ..where((row) => row.listKey.equals(list) & row.valueKey.equals(key)))
        .go();
  }

  Future<void> removeAll(String list) async {
    final rows = _db.listValueImagesCache;
    await (_db.delete(rows)..where((row) => row.listKey.equals(list))).go();
  }

  /// Lets the user pick image files and stores each under the value it is
  /// named after; returns how many loaded and the files skipped.
  Future<({int loaded, List<String> skipped})> loadFiles(String list) async {
    final files = await openFiles(acceptedTypeGroups: listValueImageFileTypes);
    var loaded = 0;
    final skipped = <String>[];
    for (final file in files) {
      try {
        final bytes = await file.readAsBytes();
        await validateListValueImage(bytes);
        await save(list, listValueFromFileName(file.name), bytes);
        loaded++;
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

/// A loaded list value image, SVG or raster, scaled to fit.
class ListValueImageView extends StatelessWidget {
  const ListValueImageView(this.image,
      {this.fit = BoxFit.contain,
      this.width,
      this.height,
      this.blackSvgTint,
      super.key});

  final Uint8List image;
  final BoxFit fit;
  final double? width;
  final double? height;

  /// Paints an all-black SVG in this colour instead, as built-in logos take
  /// the text colour.
  final Color? blackSvgTint;

  @override
  Widget build(BuildContext context) => isSvgImage(image)
      ? SvgPicture.memory(image,
          fit: fit,
          width: width,
          height: height,
          colorFilter: blackSvgTint != null && isBlackSvg(image)
              ? ColorFilter.mode(blackSvgTint!, BlendMode.srcIn)
              : null)
      : Image.memory(image,
          fit: fit, width: width, height: height, gaplessPlayback: true);
}

/// "Loaded 3 images. Skipped: a.txt." after loading files.
String listValueImagesLoadMessage(
        ({int loaded, List<String> skipped}) result) =>
    [
      'Loaded ${result.loaded} ${result.loaded == 1 ? 'image' : 'images'}.',
      if (result.skipped.isNotEmpty) 'Skipped: ${result.skipped.join(', ')}.',
    ].join(' ');
