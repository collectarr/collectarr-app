import 'dart:math' as math;
import 'dart:typed_data';

import 'package:collectarr_app/features/library/edit/covers/crop_editor.dart';
import 'package:collectarr_app/features/library/edit/covers/panel_frame.dart';
import 'package:collectarr_app/features/library/ui/primitives/image_intake.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

final Dio _coverImageClient = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    responseType: ResponseType.bytes,
  ),
);

/// The editor's height around a cover: its title, tabs, toolbar and footer.
const double _editorChrome = 360;
const double _minPreviewHeight = 200;

/// A local cover image held by one cover panel.
@immutable
final class LibraryCoverBytes {
  const LibraryCoverBytes({required this.bytes, this.description});

  final Uint8List bytes;
  final String? description;
}

/// An online cover chosen by the kind's Find Online dialog.
@immutable
final class LibraryOnlineCover {
  const LibraryOnlineCover({required this.url, this.description});

  final String url;
  final String? description;
}

/// One reference cover panel (Front or Back): Find Online, Upload,
/// Remove/Restore and Crop / Rotate over a local image or a Core cover URL.
final class LibraryCoverEditor extends StatefulWidget {
  const LibraryCoverEditor({
    super.key,
    required this.title,
    required this.image,
    required this.coreCoverUrl,
    required this.restoreCoreCoverUrl,
    required this.onRestoreCoreCover,
    required this.onRemoveCoreCover,
    required this.onChanged,
    required this.placeholderIcon,
    this.findOnline,
  });

  final String title;
  final LibraryCoverBytes? image;
  final String? coreCoverUrl;
  final String? restoreCoreCoverUrl;
  final VoidCallback onRestoreCoreCover;
  final VoidCallback onRemoveCoreCover;
  final ValueChanged<LibraryCoverBytes?> onChanged;
  final IconData placeholderIcon;

  /// Kind-owned online cover search; without one Find Online is hidden.
  final Future<LibraryOnlineCover?> Function(BuildContext context)? findOnline;

  @override
  State<LibraryCoverEditor> createState() => _LibraryCoverEditorState();
}

final class _LibraryCoverEditorState extends State<LibraryCoverEditor> {
  Uint8List? _cropEditorBytes;
  bool _transforming = false;

  Object? get _source =>
      widget.image ??
      (widget.coreCoverUrl?.trim().isEmpty ?? true
          ? null
          : widget.coreCoverUrl!.trim());

  @override
  void didUpdateWidget(covariant LibraryCoverEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image ||
        oldWidget.coreCoverUrl != widget.coreCoverUrl) {
      _cropEditorBytes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.image;
    final cropEditorBytes = _cropEditorBytes;
    if (cropEditorBytes != null) {
      return LibraryCoverCropEditor(
        title: widget.title,
        imageBytes: cropEditorBytes,
        onApply: _applyEditedBytes,
        onReset: () => setState(() => _cropEditorBytes = null),
      );
    }
    final canEditCover = _source != null && !_transforming;
    final hasCurrentCoreCover = widget.coreCoverUrl?.trim().isNotEmpty == true;
    final canRestoreCoreCover =
        widget.restoreCoreCoverUrl?.trim().isNotEmpty == true;
    final removeActionLabel = image != null
        ? canRestoreCoreCover
            ? 'Restore'
            : 'Remove'
        : hasCurrentCoreCover
            ? 'Remove'
            : null;
    return LibraryCoverPanelFrame(
      title: widget.title,
      toolbar: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A narrow panel wraps the left group instead of overflowing.
          Expanded(
            child: Wrap(children: [
              for (final (index, action) in [
                if (widget.findOnline != null)
                  LibraryCoverToolbarButton(
                    icon: AppIcons.findOnline,
                    label: 'Find Online',
                    onPressed: _transforming ? null : _findOnline,
                  ),
                LibraryCoverToolbarButton(
                  icon: AppIcons.upload,
                  label: 'Upload',
                  onPressed: _transforming ? null : _upload,
                ),
                if (removeActionLabel != null)
                  LibraryCoverToolbarButton(
                    icon: removeActionLabel == 'Restore'
                        ? Icons.restore
                        : AppIcons.removeAction,
                    label: removeActionLabel,
                    onPressed: () {
                      if (image != null) {
                        widget.onChanged(null);
                        if (canRestoreCoreCover) {
                          widget.onRestoreCoreCover();
                        }
                      } else {
                        widget.onRemoveCoreCover();
                      }
                    },
                  ),
              ].indexed) ...[
                if (index > 0) _toolbarDivider(context),
                action,
              ],
            ]),
          ),
          LibraryCoverToolbarButton(
            icon: AppIcons.inlineEdit,
            label: 'Crop / Rotate',
            onPressed: canEditCover ? _openCropEditor : null,
          ),
        ],
      ),
      child: image != null
          ? _fitted(Image.memory(image.bytes))
          : widget.coreCoverUrl?.trim().isNotEmpty == true
              ? _fitted(Image.network(
                  widget.coreCoverUrl!,
                  errorBuilder: (context, error, stack) =>
                      _placeholder(context),
                ))
              : _placeholder(context),
    );
  }

  /// The cover across the panel's width, or smaller and centred where the
  /// window is too short, so the editor fits without scrolling. A very short
  /// window scrolls rather than shrink the cover further.
  Widget _fitted(Widget image) => ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: math.max(_minPreviewHeight,
                MediaQuery.sizeOf(context).height - _editorChrome)),
        child: FittedBox(child: image),
      );

  /// The reference's 210 x 300 blank cover, centred at the top.
  Widget _placeholder(BuildContext context) {
    final palette = appPalette(context);
    return Center(
      child: Container(
        width: 210,
        height: 300,
        color: palette.isDark ? const Color(0xff414141) : palette.surfaceDim,
        alignment: Alignment.center,
        child: Icon(
          widget.placeholderIcon,
          size: 96,
          color: palette.isDark
              ? const Color(0xff383838)
              : palette.textMuted.withValues(alpha: .35),
        ),
      ),
    );
  }

  /// A dark 1 px rule 3 px after a button and 4 px before the next. As in
  /// the reference it runs 2 px below the buttons without taking layout
  /// height, so the buttons stay centred on the bar.
  Widget _toolbarDivider(BuildContext context) => SizedBox(
        width: 8,
        height: 30,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(
            left: 3,
            top: 0,
            width: 1,
            height: 32,
            child: ColoredBox(
              color: appPalette(context).isDark
                  ? const Color(0xff010101)
                  : appPalette(context).divider,
            ),
          ),
        ]),
      );

  Future<void> _upload() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Images',
          extensions: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
        ),
      ],
    );
    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    try {
      await validateLibraryImageBytes(bytes);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)
            ?.showSnackBar(SnackBar(content: Text(error.toString())));
      }
      return;
    }
    if (!mounted) return;
    widget.onChanged(LibraryCoverBytes(bytes: bytes));
  }

  Future<void> _findOnline() async {
    final findOnline = widget.findOnline;
    if (findOnline == null) return;
    setState(() => _transforming = true);
    try {
      final candidate = await findOnline(context);
      if (candidate == null || !mounted) return;
      final bytes = await _download(Uri.parse(candidate.url));
      await validateLibraryImageBytes(bytes);
      if (!mounted) return;
      widget.onChanged(
        LibraryCoverBytes(bytes: bytes, description: candidate.description),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text('Could not use this online cover: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _transforming = false);
    }
  }

  Future<void> _openCropEditor() async {
    final source = _source;
    if (source == null || _transforming) return;

    setState(() => _transforming = true);
    try {
      final bytes = switch (source) {
        LibraryCoverBytes image => image.bytes,
        String url => await _download(Uri.parse(url)),
        _ => throw StateError('Unknown cover source.'),
      };
      if (img.decodeImage(bytes) == null) {
        throw const FormatException('The cover image could not be decoded.');
      }
      if (!mounted || source != _source) return;
      setState(() => _cropEditorBytes = bytes);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
              content: Text('Could not load this cover for editing.')),
        );
      }
    } finally {
      if (mounted) setState(() => _transforming = false);
    }
  }

  Future<Uint8List> _download(Uri uri) async {
    if (!(uri.isScheme('http') || uri.isScheme('https'))) {
      throw const FormatException('The cover URL is invalid.');
    }
    final response = await _coverImageClient.getUri<List<int>>(uri);
    final bytes = response.data;
    if (response.statusCode != 200 || bytes == null || bytes.isEmpty) {
      throw StateError('The cover could not be downloaded.');
    }
    return Uint8List.fromList(bytes);
  }

  Future<void> _applyEditedBytes(Uint8List bytes) async {
    widget.onChanged(
      LibraryCoverBytes(bytes: bytes, description: widget.image?.description),
    );
    if (mounted) setState(() => _cropEditorBytes = null);
  }
}
