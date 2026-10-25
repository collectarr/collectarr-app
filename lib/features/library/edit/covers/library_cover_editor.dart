import 'dart:typed_data';

import 'package:collectarr_app/features/library/edit/covers/library_cover_crop_editor.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_image_intake.dart';
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
    final palette = appPalette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: Opacity(
            opacity: 0.7,
            child: Text(
              widget.title,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, height: 19 / 13),
            ),
          ),
        ),
        // The reference's black toolbar with its top corners rounded.
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          child: Container(
            constraints: const BoxConstraints(minHeight: 38),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            decoration: BoxDecoration(
              color: palette.isDark ? const Color(0xff131313) : palette.toolbar,
              border: Border(
                top: BorderSide(
                    color: palette.isDark
                        ? const Color(0xff252525)
                        : palette.divider),
                bottom: BorderSide(
                    color: palette.isDark
                        ? const Color(0xff010101)
                        : palette.divider),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A narrow panel wraps the left group instead of overflowing.
                Expanded(
                  child: Wrap(children: [
                    for (final (index, action) in [
                      if (widget.findOnline != null)
                        _toolbarAction(
                          context,
                          icon: AppIcons.findOnline,
                          label: 'Find Online',
                          onPressed: _transforming ? null : _findOnline,
                        ),
                      _toolbarAction(
                        context,
                        icon: AppIcons.upload,
                        label: 'Upload',
                        onPressed: _transforming ? null : _upload,
                      ),
                      if (removeActionLabel != null)
                        _toolbarAction(
                          context,
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
                _toolbarAction(
                  context,
                  icon: AppIcons.inlineEdit,
                  label: 'Crop / Rotate',
                  onPressed: canEditCover ? _openCropEditor : null,
                ),
              ],
            ),
          ),
        ),
        // The cover keeps its own proportions across the full width.
        ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: palette.isDark ? const Color(0xff444444) : palette.surface,
              border: Border(
                left: _previewBorder(palette),
                right: _previewBorder(palette),
                bottom: _previewBorder(palette),
              ),
            ),
            child: image != null
                ? Image.memory(image.bytes, fit: BoxFit.fitWidth)
                : widget.coreCoverUrl?.trim().isNotEmpty == true
                    ? Image.network(
                        widget.coreCoverUrl!,
                        fit: BoxFit.fitWidth,
                        errorBuilder: (context, error, stack) =>
                            _placeholder(context),
                      )
                    : _placeholder(context),
          ),
        ),
      ],
    );
  }

  BorderSide _previewBorder(AppThemePalette palette) => BorderSide(
      color: palette.isDark ? const Color(0xff666666) : palette.divider);

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

  /// A 30 px toolbar button: 14 px glyph and label, a #464950 hover and a
  /// quarter-opacity disabled state.
  Widget _toolbarAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final palette = appPalette(context);
    return Opacity(
      opacity: onPressed == null ? 0.25 : 1,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          textStyle: TextStyle(
              fontFamily: appFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 20 / 14),
          foregroundColor: palette.textPrimary,
          disabledForegroundColor: palette.textPrimary,
          overlayColor: palette.isDark ? const Color(0xff464950) : null,
          shape: const RoundedRectangleBorder(),
          minimumSize: const Size(0, 30),
          maximumSize: const Size(double.infinity, 30),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        // The reference's fixed-width glyph sits right against its label.
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14),
          const SizedBox(width: 3),
          Flexible(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }

  /// A dark 1 px rule in the 5 px gap before a button.
  Widget _toolbarDivider(BuildContext context) => Container(
        width: 1,
        height: 32,
        margin: const EdgeInsets.only(right: 4),
        color: appPalette(context).isDark
            ? const Color(0xff010101)
            : appPalette(context).divider,
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
