import 'dart:typed_data';

import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_image.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_cover_crop_editor.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_online_cover_picker_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_online_cover_search.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_image_intake.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_managed_vocabulary_field.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

final Dio _coverImageClient = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    responseType: ResponseType.bytes,
  ),
);

final class MusicAlbumCoversTab extends StatefulWidget {
  const MusicAlbumCoversTab({
    super.key,
    required this.albumId,
    required this.draft,
    required this.images,
    required this.onImagesChanged,
  });

  final String albumId;
  final MusicAlbumEditDraft draft;
  final List<MusicAlbumImage> images;
  final ValueChanged<List<MusicAlbumImage>> onImagesChanged;

  @override
  State<MusicAlbumCoversTab> createState() => _MusicAlbumCoversTabState();
}

final class _MusicAlbumCoversTabState extends State<MusicAlbumCoversTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final front = _cover('front_cover');
            final back = _cover('back_cover');
            final children = [
              MusicCoverEditor(
                title: 'Front Cover',
                albumId: widget.albumId,
                searchArtist: widget.draft.values.artist,
                searchTitle: widget.draft.values.title,
                searchBarcode: widget.draft.values.barcode,
                image: front,
                coreCoverUrl: widget.draft.values.coverImageUrl,
                restoreCoreCoverUrl: widget.draft.original.coverImageUrl,
                onRestoreCoreCover: () => _restoreCoreCover(false),
                onRemoveCoreCover: () => _removeCoreCover(false),
                onChanged: (value) => _replaceCover('front_cover', value),
              ),
              MusicCoverEditor(
                title: 'Back Cover',
                albumId: widget.albumId,
                searchArtist: widget.draft.values.artist,
                searchTitle: widget.draft.values.title,
                searchBarcode: widget.draft.values.barcode,
                image: back,
                coreCoverUrl: widget.draft.values.backCoverImageUrl,
                restoreCoreCoverUrl: widget.draft.original.backCoverImageUrl,
                onRestoreCoreCover: () => _restoreCoreCover(true),
                onRemoveCoreCover: () => _removeCoreCover(true),
                onChanged: (value) => _replaceCover('back_cover', value),
              ),
            ];
            if (constraints.maxWidth >= 680) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: children[0]),
                  const SizedBox(width: 12),
                  Expanded(child: children[1])
                ],
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

  MusicAlbumImage? _cover(String imageType) {
    for (final image in widget.images) {
      if (image.purpose == MusicAlbumImagePurpose.cover &&
          image.imageType == imageType) {
        return image;
      }
    }
    return null;
  }

  void _replaceCover(String imageType, MusicAlbumImage? replacement) {
    final next = [
      for (final image in widget.images)
        if (image.purpose != MusicAlbumImagePurpose.cover ||
            image.imageType != imageType)
          image,
      if (replacement != null) replacement,
    ];
    widget.onImagesChanged(next);
  }

  void _restoreCoreCover(bool back) {
    setState(() {
      if (back) {
        widget.draft.values.backCoverImageUrl =
            widget.draft.original.backCoverImageUrl ?? '';
      } else {
        widget.draft.values.coverImageUrl =
            widget.draft.original.coverImageUrl ?? '';
      }
    });
  }

  void _removeCoreCover(bool back) {
    setState(() {
      if (back) {
        widget.draft.values.backCoverImageUrl = '';
      } else {
        widget.draft.values.coverImageUrl = '';
      }
    });
  }
}

final class MusicCoverEditor extends StatefulWidget {
  const MusicCoverEditor({
    super.key,
    required this.title,
    required this.albumId,
    this.searchArtist = '',
    this.searchTitle = '',
    this.searchBarcode = '',
    required this.image,
    required this.coreCoverUrl,
    required this.restoreCoreCoverUrl,
    required this.onRestoreCoreCover,
    required this.onRemoveCoreCover,
    required this.onChanged,
  });

  final String title;
  final String albumId;
  final String searchArtist;
  final String searchTitle;
  final String searchBarcode;
  final MusicAlbumImage? image;
  final String? coreCoverUrl;
  final String? restoreCoreCoverUrl;
  final VoidCallback onRestoreCoreCover;
  final VoidCallback onRemoveCoreCover;
  final ValueChanged<MusicAlbumImage?> onChanged;

  @override
  State<MusicCoverEditor> createState() => MusicCoverEditorState();
}

final class MusicCoverEditorState extends State<MusicCoverEditor> {
  Uint8List? _cropEditorBytes;
  bool _transforming = false;

  String? get _sourceKey => _sourceKeyFor(widget.image, widget.coreCoverUrl);

  static String? _sourceKeyFor(
    MusicAlbumImage? image,
    String? coreCoverUrl,
  ) {
    if (image != null) return 'local:${image.id}';
    final url = coreCoverUrl?.trim();
    return url == null || url.isEmpty ? null : 'core:$url';
  }

  @override
  void didUpdateWidget(covariant MusicCoverEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_sourceKeyFor(oldWidget.image, oldWidget.coreCoverUrl) != _sourceKey) {
      _cropEditorBytes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.image;
    final sourceKey = _sourceKey;
    final cropEditorBytes = _cropEditorBytes;
    if (cropEditorBytes != null) {
      return MusicCoverCropEditor(
        title: widget.title,
        imageBytes: cropEditorBytes,
        onApply: _applyEditedBytes,
      );
    }
    final canEditCover = sourceKey != null && !_transforming;
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
    final colors = Theme.of(context).colorScheme;
    return Column(
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
                      icon: Icons.file_upload_outlined,
                      label: 'Upload',
                      onPressed: _transforming ? null : _upload,
                    ),
                    _toolbarAction(
                      context,
                      icon: Icons.image_search_outlined,
                      label: 'Find Online',
                      onPressed: _transforming ? null : _findOnline,
                    ),
                    if (removeActionLabel != null)
                      _toolbarAction(
                        context,
                        icon: removeActionLabel == 'Restore'
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
              aspectRatio: 1,
              child: ColoredBox(
                color: appPalette(context).surface,
                child: image != null
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
    final current = widget.image;
    widget.onChanged(
      MusicAlbumImage(
        id: current?.id ?? const Uuid().v4(),
        albumId: widget.albumId,
        purpose: MusicAlbumImagePurpose.cover,
        imageType: widget.title == 'Front Cover' ? 'front_cover' : 'back_cover',
        imageData: bytes,
        description: null,
        sortOrder: current?.sortOrder ?? 0,
        createdAt: current?.createdAt ?? DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> _findOnline() async {
    setState(() => _transforming = true);
    try {
      final candidate = await showDialog<MusicOnlineCoverCandidate>(
        context: context,
        builder: (_) => MusicOnlineCoverPickerDialog(
          artist: widget.searchArtist,
          title: widget.searchTitle,
          barcode: widget.searchBarcode,
        ),
      );
      if (candidate == null || !mounted) return;

      final response = await _coverImageClient.get<List<int>>(
        candidate.imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final responseBytes = response.data;
      if (responseBytes == null || responseBytes.isEmpty) {
        throw StateError('The selected cover image could not be downloaded.');
      }
      final bytes = Uint8List.fromList(responseBytes);
      await validateLibraryImageBytes(bytes);
      if (!mounted) return;
      final current = widget.image;
      widget.onChanged(
        MusicAlbumImage(
          id: current?.id ?? const Uuid().v4(),
          albumId: widget.albumId,
          purpose: MusicAlbumImagePurpose.cover,
          imageType:
              widget.title == 'Back Cover' ? 'back_cover' : 'front_cover',
          imageData: bytes,
          description: '${candidate.title} — ${candidate.artist}',
          sortOrder: current?.sortOrder ?? 0,
          createdAt: current?.createdAt ?? DateTime.now().toUtc(),
        ),
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
    final sourceKey = _sourceKey;
    if (sourceKey == null || _transforming) return;

    setState(() => _transforming = true);
    try {
      final bytes = await _loadSourceBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw const FormatException('The cover image could not be decoded.');
      }
      if (!mounted || sourceKey != _sourceKey) return;
      setState(() => _cropEditorBytes = Uint8List.fromList(bytes));
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

  Future<Uint8List> _loadSourceBytes() async {
    final image = widget.image;
    if (image != null) return image.imageData;

    final coverUrl = widget.coreCoverUrl?.trim();
    final uri = coverUrl == null ? null : Uri.tryParse(coverUrl);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
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
    final image = widget.image;
    final sourceKey = _sourceKey;
    if (sourceKey == null) return;
    final now = DateTime.now().toUtc();
    widget.onChanged(
      image?.copyWith(imageData: bytes) ??
          MusicAlbumImage(
            id: const Uuid().v4(),
            albumId: widget.albumId,
            purpose: MusicAlbumImagePurpose.cover,
            imageType:
                widget.title == 'Front Cover' ? 'front_cover' : 'back_cover',
            imageData: bytes,
            description: null,
            sortOrder: 0,
            createdAt: now,
          ),
    );
    if (mounted) setState(() => _cropEditorBytes = null);
  }
}

final class _NoCoverPreview extends StatelessWidget {
  const _NoCoverPreview();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: 38,
              color: appPalette(context).textMuted,
            ),
            SizedBox(height: 6),
            Text(
              'No cover image',
              style: TextStyle(color: appPalette(context).textMuted),
            ),
          ],
        ),
      );
}

final class MusicAlbumMyImagesTab extends StatelessWidget {
  const MusicAlbumMyImagesTab({
    super.key,
    required this.albumId,
    required this.images,
    required this.accent,
    required this.onImagesChanged,
  });

  final String albumId;
  final List<MusicAlbumImage> images;
  final Color accent;
  final ValueChanged<List<MusicAlbumImage>> onImagesChanged;

  @override
  Widget build(BuildContext context) => ItemImagesEditSection(
        images: images
            .where((image) => image.purpose == MusicAlbumImagePurpose.personal)
            .toList(growable: false),
        accent: accent,
        helperText:
            'Add your own images (max. 5), set a description and an image type (Signature, Booklet, etc.).',
        maximumImages: 5,
        defaultImageType: 'other',
        uniqueImageTypes: const {},
        imageTypeFieldBuilder: (context,
                {required value, required onChanged}) =>
            LibraryManagedVocabularyField(
          label: 'Image Type',
          listName: MusicVocabularyIds.imageType.value,
          mediaKind: 'music',
          value: value,
          builtIns: MusicVocabularies.imageType.builtIns,
          optionLabel: MusicVocabularies.imageType.optionLabel,
          onChanged: (selected) {
            if (selected != null) onChanged(selected);
          },
        ),
        onChanged: (edits) {
          final originalById = {
            for (final image in images)
              if (image.purpose == MusicAlbumImagePurpose.personal)
                image.id: image,
          };
          final personal = <MusicAlbumImage>[];
          for (final edit in edits) {
            if (edit.deleted) continue;
            final original = originalById[edit.id];
            final imageData = edit.imageData ?? original?.imageData;
            if (imageData == null) {
              throw StateError('A new Music image must include its bytes.');
            }
            personal.add(
              MusicAlbumImage(
                id: edit.id,
                albumId: albumId,
                purpose: MusicAlbumImagePurpose.personal,
                imageType: edit.imageType,
                imageData: imageData,
                description: edit.caption,
                sortOrder: edit.sortOrder,
                createdAt: edit.createdAt ??
                    original?.createdAt ??
                    DateTime.now().toUtc(),
              ),
            );
          }
          onImagesChanged([
            ...images.where(
              (image) => image.purpose != MusicAlbumImagePurpose.personal,
            ),
            ...personal,
          ]);
        },
      );
}
