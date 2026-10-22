import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/edit/covers/library_cover_editor.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const _front = 'front_cover';
const _back = 'back_cover';

/// Reference Covers tab of Game Edit and Manual Add: Front and Back cover
/// panels over the copy's cover images, the front falling back to the Core
/// cover.
final class GameCoversTab extends StatefulWidget {
  const GameCoversTab({
    super.key,
    required this.images,
    required this.coverImageUrl,
    required this.originalCoverImageUrl,
    required this.onCoverImageUrlChanged,
    required this.onEdits,
  });

  /// Existing images of the copy; only front and back covers are used.
  final List<ItemImageContent> images;
  final String coverImageUrl;
  final String originalCoverImageUrl;
  final ValueChanged<String> onCoverImageUrlChanged;

  /// Replacement edits for the covers changed so far.
  final ValueChanged<List<ItemImageEdit>> onEdits;

  @override
  State<GameCoversTab> createState() => _GameCoversTabState();
}

final class _GameCoversTabState extends State<GameCoversTab> {
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
        placeholderIcon: AppIcons.gamepad,
      );

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final front = _panel('Front Cover', _front);
            final back = _panel('Back Cover', _back);
            if (constraints.maxWidth < 680) {
              return Column(
                  children: [front, const SizedBox(height: 12), back]);
            }
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: front),
              const SizedBox(width: 12),
              Expanded(child: back),
            ]);
          },
        ),
      );
}
