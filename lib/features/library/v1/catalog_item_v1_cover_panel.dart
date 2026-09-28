import 'dart:convert';
import 'dart:typed_data';

import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_cover_crop_editor.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Catalog Item cover upload, crop/rotate, and removal controls.
final class CatalogItemV1CoverPanel extends ConsumerStatefulWidget {
  const CatalogItemV1CoverPanel({
    required this.reference,
    required this.canEdit,
    this.fallbackUrl,
    super.key,
  });

  final CatalogItemRef reference;
  final bool canEdit;
  final String? fallbackUrl;

  @override
  ConsumerState<CatalogItemV1CoverPanel> createState() =>
      _CatalogItemV1CoverPanelState();
}

final class _CatalogItemV1CoverPanelState
    extends ConsumerState<CatalogItemV1CoverPanel> {
  late Future<List<Map<String, dynamic>>> _images;
  bool _busy = false;

  ApiClient get _api => ref.read(apiClientProvider);

  @override
  void initState() {
    super.initState();
    _images = _loadImages();
  }

  Future<List<Map<String, dynamic>>> _loadImages() async =>
      (await _api.listEntityImages(
        entityType: 'catalog_item',
        entityId: widget.reference.id,
      ))
          .where((image) => image['image_type'] == 'front_cover')
          .toList(growable: false);

  void _refresh() => setState(() => _images = _loadImages());

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<List<Map<String, dynamic>>>(
        future: _images,
        builder: (context, snapshot) {
          final image = snapshot.data?.firstOrNull;
          final url = image?['public_url'] as String? ?? widget.fallbackUrl;
          return SizedBox(
            width: 112,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: AspectRatio(
                    aspectRatio: 0.75,
                    child: url == null || url.isEmpty
                        ? ColoredBox(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Icon(Icons.image_outlined, size: 32),
                          )
                        : Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const ColoredBox(
                              color: Colors.black12,
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                  ),
                ),
                if (widget.canEdit) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 0,
                    children: [
                      IconButton(
                        tooltip: 'Upload catalog cover',
                        visualDensity: VisualDensity.compact,
                        onPressed: _busy ? null : _pickAndEdit,
                        icon: const Icon(Icons.file_upload_outlined, size: 18),
                      ),
                      if (image != null)
                        IconButton(
                          tooltip: 'Crop or rotate cover',
                          visualDensity: VisualDensity.compact,
                          onPressed: _busy ? null : () => _editAsset(image),
                          icon: const Icon(Icons.crop_rotate, size: 18),
                        ),
                      if (image != null)
                        IconButton(
                          tooltip: 'Remove catalog cover',
                          visualDensity: VisualDensity.compact,
                          onPressed: _busy ? null : () => _remove(image),
                          icon: const Icon(Icons.delete_outline, size: 18),
                        ),
                    ],
                  ),
                ],
                if (_busy)
                  const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          );
        },
      );

  Future<void> _pickAndEdit() async {
    try {
      final previous = (await _images).firstOrNull;
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 95,
      );
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      final edited = await _showCropEditor(bytes);
      if (edited != null) await _saveCover(edited, replacing: previous);
    } catch (error) {
      _showError('Could not open or read the selected image: $error');
    }
  }

  Future<void> _editAsset(Map<String, dynamic> image) async {
    setState(() => _busy = true);
    try {
      final key = image['storage_key'];
      if (key is! String || key.isEmpty) {
        throw const FormatException('The cover has no downloadable image key.');
      }
      final encoded = (await _api.batchDownloadImages([key]))[key];
      if (encoded == null) {
        throw const FormatException('Could not download the current cover.');
      }
      if (!mounted) return;
      final edited = await _showCropEditor(base64Decode(encoded));
      if (edited != null) await _saveCover(edited, replacing: image);
    } catch (error) {
      _showError('Could not edit the current cover: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Uint8List?> _showCropEditor(Uint8List bytes) => showDialog<Uint8List>(
        context: context,
        builder: (dialogContext) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: MusicCoverCropEditor(
                title: 'Front Cover',
                imageBytes: bytes,
                onApply: (edited) async =>
                    Navigator.of(dialogContext).pop(edited),
              ),
            ),
          ),
        ),
      );

  Future<void> _saveCover(
    Uint8List bytes, {
    Map<String, dynamic>? replacing,
  }) async {
    setState(() => _busy = true);
    try {
      final uploaded = await _api.addEntityImage(
        entityType: 'catalog_item',
        entityId: widget.reference.id,
        imageType: 'front_cover',
        imageDataBase64: base64Encode(bytes),
        isPrimary: true,
      );
      final previousId = replacing?['id'];
      if (previousId is String && previousId != uploaded['id']) {
        await _api.deleteEntityImage(previousId);
      }
      if (mounted) _refresh();
    } catch (error) {
      _showError('Could not save the catalog cover: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(Map<String, dynamic> image) async {
    final id = image['id'];
    if (id is! String) return;
    setState(() => _busy = true);
    try {
      await _api.deleteEntityImage(id);
      if (mounted) _refresh();
    } catch (error) {
      _showError('Could not remove the catalog cover: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
