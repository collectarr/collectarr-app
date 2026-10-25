import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/edit/covers/library_cover_editor.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const _front = 'front_cover';
const _back = 'back_cover';

/// Shared image-pair mechanics: local edits, removal, Core fallback and upload.
/// Inventory modules supply their own image labels and placeholder.
final class LibraryCoverImagesTab extends StatefulWidget {
  const LibraryCoverImagesTab({
    super.key,
    required this.images,
    required this.coverImageUrl,
    required this.originalCoverImageUrl,
    required this.onCoverImageUrlChanged,
    required this.onEdits,
    required this.frontLabel,
    required this.backLabel,
    required this.placeholderIcon,
    this.findOnline,
  });

  /// Existing images of the copy; only front and back covers are used.
  final List<ItemImageContent> images;
  final String frontLabel;
  final String backLabel;
  final IconData placeholderIcon;

  /// Kind-owned online cover search offered on both panels; hidden when null.
  final Future<LibraryOnlineCover?> Function(BuildContext context)? findOnline;
  final String coverImageUrl;
  final String originalCoverImageUrl;
  final ValueChanged<String> onCoverImageUrlChanged;

  /// Replacement edits for the covers changed so far.
  final ValueChanged<List<ItemImageEdit>> onEdits;

  @override
  State<LibraryCoverImagesTab> createState() => _LibraryCoverImagesTabState();
}

final class _LibraryCoverImagesTabState extends State<LibraryCoverImagesTab> {
  /// Changed covers by image type; a null value removes the cover.
  final Map<String, LibraryCoverBytes?> _changed = {};
  late String _coverImageUrl = widget.coverImageUrl;

  ItemImageContent? _existing(String type) =>
      widget.images.where((image) => image.imageType == type).firstOrNull;

  LibraryCoverBytes? _current(String type) {
    if (_changed.containsKey(type)) return _changed[type];
    final image = _existing(type);
    return image == null
        ? null
        : LibraryCoverBytes(bytes: image.imageData, description: image.caption);
  }

  void _change(String type, LibraryCoverBytes? value) {
    setState(() => _changed[type] = value);
    final now = DateTime.now().toUtc();
    widget.onEdits([
      for (final MapEntry(key: type, value: cover) in _changed.entries)
        if (cover == null)
          if (_existing(type) case final existing?)
            ItemImageEdit(id: existing.id, imageType: type, deleted: true)
          else
            ...[]
        else
          ItemImageEdit(
            id: _existing(type)?.id ?? const Uuid().v4(),
            imageData: cover.bytes,
            caption: cover.description,
            imageType: type,
            createdAt: _existing(type)?.createdAt ?? now,
          ),
    ]);
  }

  void _setCoverImageUrl(String value) {
    setState(() => _coverImageUrl = value);
    widget.onCoverImageUrlChanged(value);
  }

  Widget _panel(String title, String type) => LibraryCoverEditor(
        title: title,
        image: _current(type),
        coreCoverUrl: type == _front ? _coverImageUrl : null,
        restoreCoreCoverUrl:
            type == _front ? widget.originalCoverImageUrl : null,
        onRestoreCoreCover: () =>
            _setCoverImageUrl(widget.originalCoverImageUrl),
        onRemoveCoreCover: () => _setCoverImageUrl(''),
        onChanged: (value) => _change(type, value),
        placeholderIcon: widget.placeholderIcon,
        findOnline: widget.findOnline,
      );

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        // The editor body already pads the tab by 15 px.
        padding: const EdgeInsets.only(bottom: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final front = _panel(widget.frontLabel, _front);
            final back = _panel(widget.backLabel, _back);
            if (constraints.maxWidth < 680) {
              return Column(
                  children: [front, const SizedBox(height: 15), back]);
            }
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: front),
              const SizedBox(width: 14),
              Expanded(child: back),
            ]);
          },
        ),
      );
}
