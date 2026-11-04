import 'dart:convert';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/foundation.dart' show compute, kIsWeb;
import 'package:flutter/material.dart';

typedef ImportFile = ({String name, Future<String> Function() readContent});
typedef ImportFilePicker = Future<ImportFile?> Function(
    {required String label, required List<String> extensions});

Future<ImportFile?> pickLibraryImportFile(
    {required String label, required List<String> extensions}) async {
  final file = await openFile(
      acceptedTypeGroups: [XTypeGroup(label: label, extensions: extensions)]);
  if (file == null) return null;
  return (
    name: file.name,
    readContent: () async {
      final bytes = await file.readAsBytes();
      return kIsWeb
          ? decodeImportFileChunked(bytes)
          : compute(decodeImportFile, bytes);
    }
  );
}

/// Yield between chunks on web, where [compute] runs on the UI isolate.
Future<String> decodeImportFileChunked(Uint8List bytes,
    {int chunkSize = 65536}) async {
  assert(chunkSize > 0);
  final output = StringBuffer();
  if (bytes.length >= 2 &&
      ((bytes[0] == 0xff && bytes[1] == 0xfe) ||
          (bytes[0] == 0xfe && bytes[1] == 0xff))) {
    if (bytes.length.isOdd) {
      throw const FormatException('Truncated UTF-16 export.');
    }
    final data = ByteData.sublistView(bytes);
    final endian = bytes[0] == 0xff ? Endian.little : Endian.big;
    final unitsPerChunk = chunkSize < 2 ? 1 : chunkSize ~/ 2;
    for (var start = 2; start < bytes.length; start += unitsPerChunk * 2) {
      final end = (start + unitsPerChunk * 2).clamp(0, bytes.length);
      output.write(String.fromCharCodes(
          [for (var i = start; i < end; i += 2) data.getUint16(i, endian)]));
      await Future<void>.delayed(Duration.zero);
    }
    return output.toString();
  } else {
    final sink = utf8.decoder
        .startChunkedConversion(StringConversionSink.fromStringSink(output));
    for (var start = 0; start < bytes.length; start += chunkSize) {
      final end = (start + chunkSize).clamp(0, bytes.length);
      sink.add(Uint8List.sublistView(bytes, start, end));
      await Future<void>.delayed(Duration.zero);
    }
    sink.close();
  }
  return output.toString().replaceFirst('\ufeff', '');
}

String decodeImportFile(Uint8List bytes) {
  if (bytes.length >= 2 &&
      ((bytes[0] == 0xff && bytes[1] == 0xfe) ||
          (bytes[0] == 0xfe && bytes[1] == 0xff))) {
    if (bytes.length.isOdd) {
      throw const FormatException('Truncated UTF-16 export.');
    }
    final data = ByteData.sublistView(bytes);
    final endian = bytes[0] == 0xff ? Endian.little : Endian.big;
    final units = [
      for (var i = 2; i < bytes.length; i += 2) data.getUint16(i, endian)
    ];
    return String.fromCharCodes(units);
  }
  return utf8.decode(bytes).replaceFirst('\ufeff', '');
}

class ImportFilePickerBar extends StatelessWidget {
  const ImportFilePickerBar(
      {super.key,
      required this.selectedFileName,
      required this.onPick,
      required this.onReset});
  final String? selectedFileName;
  final VoidCallback? onPick;
  final VoidCallback? onReset;
  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      decoration: BoxDecoration(
        color: palette.panel,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color: palette.isDark
                ? appManagementCanvasColor(context)
                : palette.divider),
      ),
      padding: const EdgeInsets.all(14),
      child: Container(
        decoration: BoxDecoration(
          color: palette.isDark ? const Color(0xFF444444) : palette.field,
          border: Border.all(color: palette.divider),
          borderRadius: BorderRadius.circular(4),
        ),
        child: selectedFileName != null
            ? Row(children: [
                const SizedBox(width: 10),
                const Text('Selected File: '),
                Expanded(
                    child: Text(selectedFileName!,
                        overflow: TextOverflow.ellipsis)),
                TextButton(
                    key: const Key('import_file_reset'),
                    onPressed: onReset,
                    child: const Text('Reset')),
              ])
            : Row(
                children: [
                  ElevatedButton(
                    key: const Key('import_file_picker_btn'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.utilityAction,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.horizontal(left: Radius.circular(3)),
                      ),
                      minimumSize: const Size(0, 32),
                      fixedSize: const Size.fromHeight(32),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      elevation: 0,
                    ),
                    onPressed: onPick,
                    child: const Text(
                      'Choose File...',
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No File Selected',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: palette.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
