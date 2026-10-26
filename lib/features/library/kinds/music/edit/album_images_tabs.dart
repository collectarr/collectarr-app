import 'package:collectarr_app/ui/app_dialog.dart';

import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_image.dart';
import 'package:collectarr_app/features/library/edit/covers/library_cover_editor.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/album_draft.dart';
import 'package:collectarr_app/features/library/edit/covers/library_online_cover_picker_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/online_cover_search.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_managed_vocabulary_field.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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

/// Music cover panel: the shared cover editor over album images, with the
/// Music online cover search.
final class MusicCoverEditor extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final current = image;
    return LibraryCoverEditor(
      title: title,
      image: current == null
          ? null
          : LibraryCoverBytes(
              bytes: current.imageData, description: current.description),
      coreCoverUrl: coreCoverUrl,
      restoreCoreCoverUrl: restoreCoreCoverUrl,
      onRestoreCoreCover: onRestoreCoreCover,
      onRemoveCoreCover: onRemoveCoreCover,
      placeholderIcon: AppIcons.compactDisc,
      findOnline: (context) async {
        final candidate = await showAppDialog<LibraryOnlineCoverCandidate>(
          context: context,
          builder: (_) => LibraryOnlineCoverPickerDialog(
            hint: 'Album title, artist or barcode',
            tokens: [searchArtist, searchTitle, searchBarcode],
            search: (query, terms) async => [
              for (final cover in await MusicOnlineCoverSearch().search(query,
                  barcode: terms.contains(searchBarcode.trim())
                      ? searchBarcode.trim()
                      : null))
                LibraryOnlineCoverCandidate(
                    title: cover.title,
                    subtitle: cover.artist,
                    imageUrl: cover.imageUrl),
            ],
          ),
        );
        return candidate == null
            ? null
            : LibraryOnlineCover(
                url: candidate.imageUrl,
                description: '${candidate.title} — ${candidate.subtitle}',
              );
      },
      onChanged: (value) {
        if (value == null) {
          onChanged(null);
          return;
        }
        onChanged(
          current?.copyWith(
                imageData: value.bytes,
                description: value.description,
              ) ??
              MusicAlbumImage(
                id: const Uuid().v4(),
                albumId: albumId,
                purpose: MusicAlbumImagePurpose.cover,
                imageType: title == 'Back Cover' ? 'back_cover' : 'front_cover',
                imageData: value.bytes,
                description: value.description,
                sortOrder: 0,
                createdAt: DateTime.now().toUtc(),
              ),
        );
      },
    );
  }
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
