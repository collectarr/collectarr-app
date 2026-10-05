import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:pasteboard/pasteboard.dart';

const libraryImageFileTypes = [
  XTypeGroup(label: 'Images', extensions: ['jpg', 'jpeg', 'png', 'webp', 'gif'])
];

bool _validImage(Uint8List bytes) {
  final decoder = img.findDecoderForData(bytes);
  final info = decoder?.startDecode(bytes);
  return info != null &&
      info.width > 0 &&
      info.height > 0 &&
      info.width * info.height <= 80000000 &&
      decoder!.decodeFrame(0) != null;
}

Future<void> validateLibraryImageBytes(Uint8List bytes) async {
  if (bytes.isEmpty ||
      bytes.length > 20 * 1024 * 1024 ||
      !await compute(_validImage, bytes)) {
    throw const FormatException(
        'Choose a valid image up to 20 MB and 80 megapixels.');
  }
}

/// One intake path for file selection, native file drops, and clipboard images.
class LibraryImageIntake extends StatefulWidget {
  const LibraryImageIntake(
      {super.key,
      required this.remaining,
      required this.onImages,
      this.child,
      this.height = 140});
  final int remaining;
  final ValueChanged<List<Uint8List>> onImages;
  final Widget? child;
  final double height;
  @override
  State<LibraryImageIntake> createState() => _LibraryImageIntakeState();
}

class _LibraryImageIntakeState extends State<LibraryImageIntake> {
  bool _busy = false;
  bool _dragging = false;
  bool get _enabled => !_busy && widget.remaining > 0;
  Future<void> _run(Future<List<Uint8List>> Function() read) async {
    if (!_enabled) return;
    final capacity = widget.remaining;
    setState(() => _busy = true);
    try {
      final bytes = await read();
      if (!mounted) return;
      for (final image in bytes.take(capacity)) {
        await validateLibraryImageBytes(image);
      }
      if (!mounted) return;
      if (bytes.isNotEmpty) {
        widget.onImages(bytes.take(capacity).toList());
      }
      if (bytes.length > capacity && mounted) {
        _message('Only the available image slots were added.');
      }
    } catch (error) {
      if (mounted) {
        _message(error is FormatException
            ? error.message.toString()
            : 'Could not read the image.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _dragging = false;
        });
      }
    }
  }

  void _message(String message) => ScaffoldMessenger.maybeOf(context)
      ?.showSnackBar(SnackBar(content: Text(message)));
  Future<List<Uint8List>> _readFiles(List<XFile> files) async {
    final result = <Uint8List>[];
    for (final file in files.take(widget.remaining)) {
      if (await file.length() > 20 * 1024 * 1024) {
        throw const FormatException('Choose an image up to 20 MB.');
      }
      result.add(await file.readAsBytes());
    }
    return result;
  }

  void _pick() => _run(() async =>
      _readFiles(await openFiles(acceptedTypeGroups: libraryImageFileTypes)));
  void _paste() => _run(() async {
        final image = await Pasteboard.image;
        if (image != null) return [image];
        if (!kIsWeb &&
            [TargetPlatform.windows, TargetPlatform.macOS, TargetPlatform.linux]
                .contains(defaultTargetPlatform)) {
          final files = await Pasteboard.files();
          if (files.isNotEmpty) {
            return _readFiles([for (final path in files) XFile(path)]);
          }
        }
        throw const FormatException('The clipboard does not contain an image.');
      });
  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DropTarget(
      enable: _enabled,
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (details) => _run(() => _readFiles(details.files)),
      child: Shortcuts(
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.keyV, control: true):
                _PasteImageIntent(),
            SingleActivator(LogicalKeyboardKey.keyV, meta: true):
                _PasteImageIntent(),
          },
          child: Actions(
              actions: {
                _PasteImageIntent:
                    CallbackAction<_PasteImageIntent>(onInvoke: (_) {
                  _paste();
                  return null;
                })
              },
              child: Focus(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    if (widget.child != null)
                      widget.child!
                    else
                      InkWell(
                          onTap: _enabled ? _pick : null,
                          child: Container(
                              height: widget.height,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: _dragging
                                      ? palette.surfaceBright
                                      : palette.surface,
                                  border: Border.all(
                                      color: _dragging
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : palette.divider)),
                              child: _busy
                                  ? const CircularProgressIndicator()
                                  : Text(
                                      widget.remaining > 0
                                          ? 'Drop, paste or click to add an image'
                                          : 'All image slots are filled',
                                      style: TextStyle(
                                          color: palette.textMuted)))),
                    const SizedBox(height: 6),
                    Wrap(spacing: 8, children: [
                      TextButton.icon(
                          onPressed: _enabled ? _pick : null,
                          icon:
                              const Icon(Icons.upload_file_outlined, size: 18),
                          label: const Text('Upload')),
                      TextButton.icon(
                          onPressed: _enabled ? _paste : null,
                          icon: const Icon(Icons.content_paste, size: 18),
                          label: const Text('Paste')),
                    ]),
                  ])))),
    );
  }
}

class _PasteImageIntent extends Intent {
  const _PasteImageIntent();
}
