import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_cover_crop_editor.dart';

final Dio _groupCoverImageClient = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    responseType: ResponseType.bytes,
  ),
);

/// Edits the single front cover owned by a Music release group.
final class MusicReleaseGroupCoverEditor extends StatefulWidget {
  const MusicReleaseGroupCoverEditor({
    super.key,
    required this.releaseGroupId,
    required this.coreCoverUrl,
    required this.originalCoreCoverUrl,
    required this.localCoverPath,
    required this.onCoreCoverChanged,
    required this.onLocalCoverPathChanged,
  });

  final String releaseGroupId;
  final String? coreCoverUrl;
  final String? originalCoreCoverUrl;
  final String? localCoverPath;
  final ValueChanged<String> onCoreCoverChanged;
  final ValueChanged<String?> onLocalCoverPathChanged;

  @override
  State<MusicReleaseGroupCoverEditor> createState() =>
      _MusicReleaseGroupCoverEditorState();
}

final class _MusicReleaseGroupCoverEditorState
    extends State<MusicReleaseGroupCoverEditor> {
  Uint8List? _cropEditorBytes;
  bool _transforming = false;

  String? get _sourceKey =>
      _sourceKeyFor(widget.localCoverPath, widget.coreCoverUrl);

  static String? _sourceKeyFor(String? localPath, String? coreCoverUrl) {
    final path = localPath?.trim();
    if (path != null && path.isNotEmpty) return 'local:$path';
    final url = coreCoverUrl?.trim();
    return url == null || url.isEmpty ? null : 'core:$url';
  }

  @override
  void didUpdateWidget(covariant MusicReleaseGroupCoverEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_sourceKeyFor(oldWidget.localCoverPath, oldWidget.coreCoverUrl) !=
        _sourceKey) {
      _cropEditorBytes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sourceKey = _sourceKey;
    final cropEditorBytes = _cropEditorBytes;
    if (cropEditorBytes != null) {
      return MusicCoverCropEditor(
        title: 'Front Cover',
        imageBytes: cropEditorBytes,
        onApply: _saveEditedBytes,
      );
    }
    final colors = Theme.of(context).colorScheme;
    final hasLocalCover = widget.localCoverPath?.trim().isNotEmpty == true;
    final hasCoreCover = widget.coreCoverUrl?.trim().isNotEmpty == true;
    final canEditCover = sourceKey != null && !_transforming;
    final removeActionLabel = hasLocalCover
        ? widget.originalCoreCoverUrl?.trim().isNotEmpty == true
            ? 'Restore Core Cover'
            : 'Remove'
        : hasCoreCover
            ? 'Remove Core Cover'
            : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 7, 10, 5),
            child: Text(
              'Front Cover',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          ColoredBox(
            color: colors.surfaceContainerLowest,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    children: [
                      _toolbarAction(
                        context,
                        icon: Icons.search,
                        label: 'Find Online',
                        onPressed: () => unawaited(
                          launchUrl(
                            Uri.https(
                              'musicbrainz.org',
                              '/release-group/${widget.releaseGroupId}',
                            ),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                      ),
                      _toolbarAction(
                        context,
                        icon: Icons.file_upload_outlined,
                        label: 'Upload',
                        onPressed: _upload,
                      ),
                      if (removeActionLabel != null)
                        _toolbarAction(
                          context,
                          icon: removeActionLabel == 'Restore Core Cover'
                              ? Icons.restore
                              : Icons.delete_outline,
                          label: removeActionLabel,
                          onPressed: _removeOrRestore,
                        ),
                    ],
                  ),
                ),
                _toolbarAction(
                  context,
                  icon: Icons.crop_rotate,
                  label: 'Crop / Rotate',
                  onPressed: canEditCover ? _openCropEditor : null,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: AspectRatio(
                aspectRatio: 1.08,
                child: ColoredBox(
                  color: const Color(0xFFE3E3E1),
                  child: hasLocalCover
                      ? Image.file(
                          File(widget.localCoverPath!.trim()),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const _NoGroupCoverPreview(),
                        )
                      : hasCoreCover
                          ? Image.network(
                              widget.coreCoverUrl!.trim(),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const _NoGroupCoverPreview(),
                            )
                          : const _NoGroupCoverPreview(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolbarAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) =>
      TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          minimumSize: const Size(0, 38),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
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
    final path = file.path.trim();
    if (path.isEmpty) {
      _showError('This platform did not provide a local image path.');
      return;
    }
    widget.onLocalCoverPathChanged(path);
  }

  void _removeOrRestore() {
    if (widget.localCoverPath?.trim().isNotEmpty == true) {
      if (widget.originalCoreCoverUrl?.trim().isNotEmpty == true) {
        widget.onLocalCoverPathChanged(null);
        widget.onCoreCoverChanged(widget.originalCoreCoverUrl!.trim());
      } else {
        widget.onLocalCoverPathChanged(null);
      }
      return;
    }
    widget.onCoreCoverChanged('');
  }

  Future<void> _openCropEditor() async {
    final sourceKey = _sourceKey;
    if (sourceKey == null || _transforming) return;
    setState(() => _transforming = true);
    try {
      final bytes = await _loadSourceBytes();
      if (img.decodeImage(bytes) == null) {
        throw const FormatException('The cover image could not be decoded.');
      }
      if (!mounted || sourceKey != _sourceKey) return;
      setState(() => _cropEditorBytes = Uint8List.fromList(bytes));
    } catch (_) {
      if (mounted) _showError('Could not load this cover for editing.');
    } finally {
      if (mounted) setState(() => _transforming = false);
    }
  }

  Future<Uint8List> _loadSourceBytes() async {
    final localPath = widget.localCoverPath?.trim();
    if (localPath != null && localPath.isNotEmpty) {
      return File(localPath).readAsBytes();
    }
    final coverUrl = widget.coreCoverUrl?.trim();
    final uri = coverUrl == null ? null : Uri.tryParse(coverUrl);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      throw const FormatException('The Core cover URL is invalid.');
    }
    final response = await _groupCoverImageClient.getUri<List<int>>(uri);
    final bytes = response.data;
    if (response.statusCode != 200 || bytes == null || bytes.isEmpty) {
      throw StateError('The Core cover could not be downloaded.');
    }
    return Uint8List.fromList(bytes);
  }

  Future<void> _saveEditedBytes(Uint8List bytes) async {
    final sourceKey = _sourceKey;
    if (sourceKey == null) return;
    try {
      final supportDirectory = await getApplicationSupportDirectory();
      final coverDirectory = Directory(
        path.join(supportDirectory.path, 'music_release_group_covers'),
      );
      await coverDirectory.create(recursive: true);
      final output = File(path.join(
        coverDirectory.path,
        'music-group-cover-${const Uuid().v4()}.png',
      ));
      await output.writeAsBytes(bytes, flush: true);
      if (!mounted || sourceKey != _sourceKey) return;
      widget.onLocalCoverPathChanged(output.path);
      setState(() => _cropEditorBytes = null);
    } catch (_) {
      if (mounted) _showError('Could not save the edited cover image.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

final class _NoGroupCoverPreview extends StatelessWidget {
  const _NoGroupCoverPreview();

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: 38,
              color: Color(0xFF424242),
            ),
            SizedBox(height: 6),
            Text(
              'No cover image',
              style: TextStyle(color: Color(0xFF424242)),
            ),
          ],
        ),
      );
}
