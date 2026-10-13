import 'dart:convert';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';

Future<bool> saveExportFile({
  required String filename,
  required Uint8List bytes,
  required String mimeType,
}) async {
  final file = XFile.fromData(bytes, name: filename, mimeType: mimeType);
  if (kIsWeb) {
    await file.saveTo(filename);
    return true;
  }
  final extension = filename.split('.').last;
  final destination = await getSaveLocation(
    suggestedName: filename,
    acceptedTypeGroups: [
      XTypeGroup(label: extension.toUpperCase(), extensions: [extension])
    ],
  );
  if (destination == null) return false;
  await file.saveTo(destination.path);
  return true;
}

Future<bool> saveExportText({
  required String filename,
  required String content,
  required String mimeType,
}) =>
    saveExportFile(
        filename: filename,
        bytes: Uint8List.fromList(utf8.encode(content)),
        mimeType: mimeType);
