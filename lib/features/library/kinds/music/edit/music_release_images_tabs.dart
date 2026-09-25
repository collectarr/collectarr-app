import 'dart:async';
import 'dart:typed_data';

import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_image.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

enum _CoverTransformAction { crop, rotate }

final Dio _coverImageClient = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    responseType: ResponseType.bytes,
  ),
);

final class MusicReleaseCoversTab extends StatefulWidget {
  const MusicReleaseCoversTab({
    super.key,
    required this.releaseId,
    required this.draft,
    required this.images,
    required this.onImagesChanged,
  });

  final String releaseId;
  final MusicReleaseEditDraft draft;
  final List<MusicReleaseImage> images;
  final ValueChanged<List<MusicReleaseImage>> onImagesChanged;

  @override
  State<MusicReleaseCoversTab> createState() => _MusicReleaseCoversTabState();
}

final class _MusicReleaseCoversTabState extends State<MusicReleaseCoversTab> {
  @override
  Widget build(BuildContext context) {
    return EditTabShell(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final front = _cover('front_cover');
            final back = _cover('back_cover');
            final children = [
              Expanded(
                  child: _CoverEditor(
                title: 'Front Cover',
                releaseId: widget.releaseId,
                image: front,
                coreCoverUrl: widget.draft.values.coverImageUrl,
                restoreCoreCoverUrl: widget.draft.original.coverImageUrl,
                onRestoreCoreCover: _restoreCoreCover,
                onRemoveCoreCover: _removeCoreCover,
                onChanged: (value) => _replaceCover('front_cover', value),
              )),
              Expanded(
                  child: _CoverEditor(
                title: 'Back Cover',
                releaseId: widget.releaseId,
                image: back,
                coreCoverUrl: null,
                restoreCoreCoverUrl: null,
                onRestoreCoreCover: _restoreCoreCover,
                onRemoveCoreCover: _removeCoreCover,
                onChanged: (value) => _replaceCover('back_cover', value),
              )),
            ];
            if (constraints.maxWidth >= 680) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [children[0], const SizedBox(width: 12), children[1]],
              );
            }
            return Column(
              children: [children[0], const SizedBox(height: 12), children[1]],
            );
          },
        ),
      ],
    );
  }

  MusicReleaseImage? _cover(String imageType) {
    for (final image in widget.images) {
      if (image.purpose == MusicReleaseImagePurpose.cover &&
          image.imageType == imageType) {
        return image;
      }
    }
    return null;
  }

  void _replaceCover(String imageType, MusicReleaseImage? replacement) {
    final next = [
      for (final image in widget.images)
        if (image.purpose != MusicReleaseImagePurpose.cover ||
            image.imageType != imageType)
          image,
      if (replacement != null) replacement,
    ];
    widget.onImagesChanged(next);
  }

  void _restoreCoreCover() {
    setState(() {
      final original = widget.draft.original.coverImageUrl;
      widget.draft.values.coverImageUrl = original ?? '';
    });
  }

  void _removeCoreCover() {
    setState(() {
      widget.draft.values.coverImageUrl = '';
    });
  }
}

final class _CoverEditor extends StatefulWidget {
  const _CoverEditor({
    required this.title,
    required this.releaseId,
    required this.image,
    required this.coreCoverUrl,
    required this.restoreCoreCoverUrl,
    required this.onRestoreCoreCover,
    required this.onRemoveCoreCover,
    required this.onChanged,
  });

  final String title;
  final String releaseId;
  final MusicReleaseImage? image;
  final String? coreCoverUrl;
  final String? restoreCoreCoverUrl;
  final VoidCallback onRestoreCoreCover;
  final VoidCallback onRemoveCoreCover;
  final ValueChanged<MusicReleaseImage?> onChanged;

  @override
  State<_CoverEditor> createState() => _CoverEditorState();
}

final class _CoverEditorState extends State<_CoverEditor> {
  Uint8List? _stagedBytes;
  String? _stagedForId;
  bool _transforming = false;

  String? get _sourceKey => _sourceKeyFor(widget.image, widget.coreCoverUrl);

  static String? _sourceKeyFor(
    MusicReleaseImage? image,
    String? coreCoverUrl,
  ) {
    if (image != null) return 'local:${image.id}';
    final url = coreCoverUrl?.trim();
    return url == null || url.isEmpty ? null : 'core:$url';
  }

  @override
  void didUpdateWidget(covariant _CoverEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_sourceKeyFor(oldWidget.image, oldWidget.coreCoverUrl) != _sourceKey) {
      _stagedBytes = null;
      _stagedForId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.image;
    final sourceKey = _sourceKey;
    final previewBytes = _stagedForId == sourceKey ? _stagedBytes : null;
    final canEditCover = sourceKey != null && !_transforming;
    final hasCurrentCoreCover = widget.coreCoverUrl?.trim().isNotEmpty == true;
    final canRestoreCoreCover =
        widget.restoreCoreCoverUrl?.trim().isNotEmpty == true;
    final removeActionLabel = image != null
        ? canRestoreCoreCover
            ? 'Restore Core Cover'
            : 'Remove'
        : hasCurrentCoreCover
            ? 'Remove Core Cover'
            : null;
    final colors = Theme.of(context).colorScheme;
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
              widget.title,
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
                              '/release/${widget.releaseId}',
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
                      if (previewBytes != null)
                        _toolbarAction(
                          context,
                          icon: Icons.undo,
                          label: 'Reset',
                          onPressed: () => setState(() {
                            _stagedBytes = null;
                            _stagedForId = null;
                          }),
                        ),
                      if (previewBytes != null)
                        _toolbarAction(
                          context,
                          icon: Icons.check,
                          label: 'Apply',
                          onPressed: _apply,
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<_CoverTransformAction>(
                  padding: EdgeInsets.zero,
                  tooltip: 'Crop or rotate cover',
                  onSelected: (action) => unawaited(_transform(action)),
                  enabled: canEditCover,
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _CoverTransformAction.crop,
                      child: ListTile(
                        leading: Icon(Icons.crop),
                        title: Text('Crop to square'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: _CoverTransformAction.rotate,
                      child: ListTile(
                        leading: Icon(Icons.rotate_right),
                        title: Text('Rotate 90 degrees'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  child: _toolbarActionLabel(
                    context,
                    icon: Icons.edit_outlined,
                    label: 'Crop / Rotate',
                    enabled: canEditCover,
                  ),
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
                  child: previewBytes != null
                      ? Image.memory(previewBytes, fit: BoxFit.contain)
                      : image != null
                          ? Image.memory(image.imageData, fit: BoxFit.contain)
                          : widget.coreCoverUrl?.trim().isNotEmpty == true
                              ? Image.network(
                                  widget.coreCoverUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const _NoCoverPreview(),
                                )
                              : const _NoCoverPreview(),
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

  Widget _toolbarActionLabel(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool enabled,
  }) =>
      SizedBox(
        height: 38,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Opacity(
            opacity: enabled ? 1 : 0.38,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
          ),
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
    final bytes = await file.readAsBytes();
    final current = widget.image;
    widget.onChanged(
      MusicReleaseImage(
        id: current?.id ?? const Uuid().v4(),
        releaseId: widget.releaseId,
        purpose: MusicReleaseImagePurpose.cover,
        imageType: widget.title == 'Front Cover' ? 'front_cover' : 'back_cover',
        imageData: bytes,
        description: null,
        sortOrder: current?.sortOrder ?? 0,
        createdAt: current?.createdAt ?? DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> _transform(_CoverTransformAction action) async {
    final sourceKey = _sourceKey;
    if (sourceKey == null || _transforming) return;

    setState(() => _transforming = true);
    try {
      final decoded = img.decodeImage(await _loadSourceBytes(sourceKey));
      if (decoded == null) {
        throw const FormatException('The cover image could not be decoded.');
      }

      final transformed = switch (action) {
        _CoverTransformAction.rotate => img.copyRotate(decoded, angle: 90),
        _CoverTransformAction.crop => _cropSquare(decoded),
      };
      if (!mounted || sourceKey != _sourceKey) return;
      setState(() {
        _stagedForId = sourceKey;
        _stagedBytes = Uint8List.fromList(img.encodePng(transformed));
      });
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

  img.Image _cropSquare(img.Image decoded) {
    final side =
        decoded.width < decoded.height ? decoded.width : decoded.height;
    final x = (decoded.width - side) ~/ 2;
    final y = (decoded.height - side) ~/ 2;
    return img.copyCrop(decoded, x: x, y: y, width: side, height: side);
  }

  Future<Uint8List> _loadSourceBytes(String sourceKey) async {
    if (_stagedForId == sourceKey && _stagedBytes != null) {
      return _stagedBytes!;
    }
    final image = widget.image;
    if (image != null) return image.imageData;

    final coverUrl = widget.coreCoverUrl?.trim();
    final uri = coverUrl == null ? null : Uri.tryParse(coverUrl);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      throw const FormatException('The Core cover URL is invalid.');
    }
    final response = await _coverImageClient.getUri<List<int>>(uri);
    final bytes = response.data;
    if (response.statusCode != 200 || bytes == null || bytes.isEmpty) {
      throw StateError('The Core cover could not be downloaded.');
    }
    return Uint8List.fromList(bytes);
  }

  void _apply() {
    final image = widget.image;
    final sourceKey = _sourceKey;
    final stagedBytes = _stagedBytes;
    if (sourceKey == null || _stagedForId != sourceKey || stagedBytes == null) {
      return;
    }
    final now = DateTime.now().toUtc();
    widget.onChanged(
      image?.copyWith(imageData: stagedBytes) ??
          MusicReleaseImage(
            id: const Uuid().v4(),
            releaseId: widget.releaseId,
            purpose: MusicReleaseImagePurpose.cover,
            imageType:
                widget.title == 'Front Cover' ? 'front_cover' : 'back_cover',
            imageData: stagedBytes,
            description: null,
            sortOrder: 0,
            createdAt: now,
          ),
    );
    setState(() {
      _stagedBytes = null;
      _stagedForId = null;
    });
  }
}

final class _NoCoverPreview extends StatelessWidget {
  const _NoCoverPreview();

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

final class MusicReleaseMyImagesTab extends StatelessWidget {
  const MusicReleaseMyImagesTab({
    super.key,
    required this.releaseId,
    required this.images,
    required this.accent,
    required this.onImagesChanged,
  });

  final String releaseId;
  final List<MusicReleaseImage> images;
  final Color accent;
  final ValueChanged<List<MusicReleaseImage>> onImagesChanged;

  @override
  Widget build(BuildContext context) => _MusicReleaseMyImagesEditor(
        releaseId: releaseId,
        images: images
            .where(
                (image) => image.purpose == MusicReleaseImagePurpose.personal)
            .toList(growable: false),
        accent: accent,
        onChanged: (personal) => onImagesChanged([
          ...images.where(
            (image) => image.purpose != MusicReleaseImagePurpose.personal,
          ),
          ...personal,
        ]),
      );
}

final class _MusicReleaseMyImagesEditor extends StatefulWidget {
  const _MusicReleaseMyImagesEditor({
    required this.releaseId,
    required this.images,
    required this.accent,
    required this.onChanged,
  });

  final String releaseId;
  final List<MusicReleaseImage> images;
  final Color accent;
  final ValueChanged<List<MusicReleaseImage>> onChanged;

  @override
  State<_MusicReleaseMyImagesEditor> createState() =>
      _MusicReleaseMyImagesEditorState();
}

final class _MusicReleaseMyImagesEditorState
    extends State<_MusicReleaseMyImagesEditor> {
  late List<MusicReleaseImage> _images;

  @override
  void initState() {
    super.initState();
    _images = List.of(widget.images);
  }

  @override
  void didUpdateWidget(covariant _MusicReleaseMyImagesEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.images, widget.images)) {
      _images = List.of(widget.images);
    }
  }

  @override
  Widget build(BuildContext context) => EditTabShell(
        children: [
          EditSection(
            title: 'My Images (${_images.length}/5)',
            accent: widget.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add your own images, set a description and choose an image type.',
                ),
                if (_images.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Center(
                        child: Text('Drop, paste or click to add an image.')),
                  ),
                if (_images.isNotEmpty)
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _images.length,
                    onReorderItem: _reorder,
                    itemBuilder: (context, index) => _PersonalImageRow(
                      key: ValueKey(_images[index].id),
                      image: _images[index],
                      index: index,
                      onChanged: (image) => _replace(index, image),
                      onDelete: () => _remove(index),
                    ),
                  ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _images.length >= 5 ? null : _add,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Add image'),
                ),
              ],
            ),
          ),
        ],
      );

  Future<void> _add() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Images',
          extensions: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
        ),
      ],
    );
    if (file == null || !mounted) return;
    final image = MusicReleaseImage(
      id: const Uuid().v4(),
      releaseId: widget.releaseId,
      purpose: MusicReleaseImagePurpose.personal,
      imageType: 'other',
      imageData: await file.readAsBytes(),
      sortOrder: _images.length,
      createdAt: DateTime.now().toUtc(),
    );
    _commit([..._images, image]);
  }

  void _replace(int index, MusicReleaseImage image) {
    final next = List<MusicReleaseImage>.of(_images)..[index] = image;
    _commit(next);
  }

  void _remove(int index) {
    final next = List<MusicReleaseImage>.of(_images)..removeAt(index);
    _commit(next);
  }

  void _reorder(int oldIndex, int newIndex) {
    final next = List<MusicReleaseImage>.of(_images);
    final image = next.removeAt(oldIndex);
    next.insert(newIndex, image);
    _commit(next);
  }

  void _commit(List<MusicReleaseImage> next) {
    setState(() => _images = [
          for (var index = 0; index < next.length; index++)
            next[index].copyWith(sortOrder: index),
        ]);
    widget.onChanged(_images);
  }
}

final class _PersonalImageRow extends StatefulWidget {
  const _PersonalImageRow({
    super.key,
    required this.image,
    required this.index,
    required this.onChanged,
    required this.onDelete,
  });

  final MusicReleaseImage image;
  final int index;
  final ValueChanged<MusicReleaseImage> onChanged;
  final VoidCallback onDelete;

  @override
  State<_PersonalImageRow> createState() => _PersonalImageRowState();
}

final class _PersonalImageRowState extends State<_PersonalImageRow> {
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    _description = TextEditingController(text: widget.image.description ?? '');
  }

  @override
  void didUpdateWidget(covariant _PersonalImageRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image.id != widget.image.id) {
      _description.text = widget.image.description ?? '';
    }
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        key: ValueKey('release-image-row-${widget.image.id}'),
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 22),
              child: Icon(Icons.drag_indicator),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.memory(
                widget.image.imageData,
                width: 104,
                height: 104,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  LibraryDropdownPickField<String>(
                    label: 'Image type',
                    value: widget.image.imageType,
                    options: const [
                      LibraryFieldOption(value: 'booklet', label: 'Booklet'),
                      LibraryFieldOption(
                          value: 'signature', label: 'Signature'),
                      LibraryFieldOption(value: 'label', label: 'Label'),
                      LibraryFieldOption(value: 'disc', label: 'Disc'),
                      LibraryFieldOption(value: 'other', label: 'Other'),
                    ],
                    openPicker: (
                            {required label,
                            required selectedValue,
                            required options}) =>
                        showPickListSelectDialog(
                      context: context,
                      label: label,
                      options: options,
                      selectedValue: selectedValue,
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        widget
                            .onChanged(widget.image.copyWith(imageType: value));
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    onChanged: (value) => widget.onChanged(
                      widget.image.copyWith(
                        description: _nullable(value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove image',
              onPressed: widget.onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      );
}

String? _nullable(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
