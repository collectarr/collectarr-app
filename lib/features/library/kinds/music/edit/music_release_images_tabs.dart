import 'dart:async';
import 'dart:typed_data';

import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_image.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

final class MusicReleaseCoversTab extends StatefulWidget {
  const MusicReleaseCoversTab({
    super.key,
    required this.releaseId,
    required this.draft,
    required this.images,
    required this.accent,
    required this.onImagesChanged,
  });

  final String releaseId;
  final MusicReleaseEditDraft draft;
  final List<MusicReleaseImage> images;
  final Color accent;
  final ValueChanged<List<MusicReleaseImage>> onImagesChanged;

  @override
  State<MusicReleaseCoversTab> createState() => _MusicReleaseCoversTabState();
}

final class _MusicReleaseCoversTabState extends State<MusicReleaseCoversTab> {
  late final TextEditingController _coreCoverUrl;

  @override
  void initState() {
    super.initState();
    _coreCoverUrl = TextEditingController(
      text: widget.draft.coverImageUrl ?? '',
    );
  }

  @override
  void dispose() {
    _coreCoverUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Core artwork',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                key: const ValueKey('musicReleaseCoverImageUrlField'),
                controller: _coreCoverUrl,
                decoration: const InputDecoration(
                  labelText: 'Core cover URL',
                  hintText: 'https://…',
                ),
                keyboardType: TextInputType.url,
                onChanged: (value) =>
                    widget.draft.coverImageUrl = _nullable(value),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    final original = widget.draft.original.coverImageUrl;
                    _coreCoverUrl.text = original ?? '';
                    widget.draft.coverImageUrl = original;
                  }),
                  icon: const Icon(Icons.restore),
                  label: const Text('Restore Core Cover'),
                ),
              ),
            ],
          ),
        ),
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
                coreCoverUrl: widget.draft.coverImageUrl,
                accent: widget.accent,
                onChanged: (value) => _replaceCover('front_cover', value),
              )),
              Expanded(
                  child: _CoverEditor(
                title: 'Back Cover',
                releaseId: widget.releaseId,
                image: back,
                coreCoverUrl: null,
                accent: widget.accent,
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
}

final class _CoverEditor extends StatefulWidget {
  const _CoverEditor({
    required this.title,
    required this.releaseId,
    required this.image,
    required this.coreCoverUrl,
    required this.accent,
    required this.onChanged,
  });

  final String title;
  final String releaseId;
  final MusicReleaseImage? image;
  final String? coreCoverUrl;
  final Color accent;
  final ValueChanged<MusicReleaseImage?> onChanged;

  @override
  State<_CoverEditor> createState() => _CoverEditorState();
}

final class _CoverEditorState extends State<_CoverEditor> {
  Uint8List? _stagedBytes;
  String? _stagedForId;

  @override
  void didUpdateWidget(covariant _CoverEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image?.id != widget.image?.id) {
      _stagedBytes = null;
      _stagedForId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.image;
    final previewBytes = _stagedForId == image?.id ? _stagedBytes : null;
    return EditSection(
      title: widget.title,
      accent: widget.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.45,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
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
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              FilledButton.tonalIcon(
                onPressed: _upload,
                icon: const Icon(Icons.upload_outlined),
                label: const Text('Upload'),
              ),
              TextButton.icon(
                onPressed: () => unawaited(
                  launchUrl(
                    Uri.https(
                      'musicbrainz.org',
                      '/release/${widget.releaseId}',
                    ),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                icon: const Icon(Icons.search),
                label: const Text('Find Online'),
              ),
              TextButton.icon(
                onPressed: image == null ? null : () => widget.onChanged(null),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove'),
              ),
              TextButton.icon(
                onPressed: image == null ? null : _rotate,
                icon: const Icon(Icons.rotate_right),
                label: const Text('Rotate'),
              ),
              TextButton.icon(
                onPressed: image == null ? null : _cropToSquare,
                icon: const Icon(Icons.crop),
                label: const Text('Crop to square'),
              ),
              if (previewBytes != null)
                TextButton(
                  onPressed: () => setState(() {
                    _stagedBytes = null;
                    _stagedForId = null;
                  }),
                  child: const Text('Reset'),
                ),
              if (previewBytes != null)
                FilledButton.icon(
                  onPressed: _apply,
                  icon: const Icon(Icons.check),
                  label: const Text('Apply'),
                ),
            ],
          ),
          if (widget.title == 'Front Cover' &&
              image == null &&
              widget.coreCoverUrl?.trim().isNotEmpty == true)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('Showing the Core cover; upload to use your own.'),
            ),
        ],
      ),
    );
  }

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

  void _rotate() {
    final image = widget.image;
    if (image == null) return;
    final source = _currentBytes(image);
    final decoded = img.decodeImage(source);
    if (decoded == null) return;
    setState(() {
      _stagedForId = image.id;
      _stagedBytes = Uint8List.fromList(
        img.encodePng(img.copyRotate(decoded, angle: 90)),
      );
    });
  }

  void _cropToSquare() {
    final image = widget.image;
    if (image == null) return;
    final decoded = img.decodeImage(_currentBytes(image));
    if (decoded == null) return;
    final side =
        decoded.width < decoded.height ? decoded.width : decoded.height;
    final x = (decoded.width - side) ~/ 2;
    final y = (decoded.height - side) ~/ 2;
    setState(() {
      _stagedForId = image.id;
      _stagedBytes = Uint8List.fromList(
        img.encodePng(
          img.copyCrop(decoded, x: x, y: y, width: side, height: side),
        ),
      );
    });
  }

  Uint8List _currentBytes(MusicReleaseImage image) =>
      _stagedForId == image.id ? _stagedBytes! : image.imageData;

  void _apply() {
    final image = widget.image;
    if (image == null || _stagedForId != image.id || _stagedBytes == null) {
      return;
    }
    widget.onChanged(image.copyWith(imageData: _stagedBytes));
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
            Icon(Icons.image_outlined, size: 38),
            SizedBox(height: 6),
            Text('No cover image'),
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
                    onReorder: _reorder,
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
    final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final next = List<MusicReleaseImage>.of(_images);
    final image = next.removeAt(oldIndex);
    next.insert(index, image);
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
                  CompactSearchDropdownFormField<String>(
                    key: ValueKey(
                        'release-image-type-${widget.image.imageType}'),
                    initialValue: widget.image.imageType,
                    decoration: const InputDecoration(labelText: 'Image type'),
                    items: const [
                      DropdownMenuItem(
                          value: 'booklet', child: Text('Booklet')),
                      DropdownMenuItem(
                          value: 'signature', child: Text('Signature')),
                      DropdownMenuItem(value: 'label', child: Text('Label')),
                      DropdownMenuItem(value: 'disc', child: Text('Disc')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
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
