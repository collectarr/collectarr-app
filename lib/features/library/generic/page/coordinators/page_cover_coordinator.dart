// ignore_for_file: use_build_context_synchronously
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/collection/services/image_download_service.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_coordinator_context.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Handles cover scanning (gallery/camera → API) and bulk cover download.
class LibraryPageCoverCoordinator {
  LibraryPageCoverCoordinator(this._page);

  final LibraryPageCoordinatorContext _page;

  Future<void> downloadAllCoversFlow(ShelfState shelfState) async {
    final db = _page.ref.read(localDatabaseProvider);
    final imagesRepo = ItemImagesCacheRepository(db);
    final service = ImageDownloadService(imagesRepo: imagesRepo);

    final itemsToCover = <String, String?>{};
    for (final entry in shelfState.entries) {
      final ownedId = entry.ownedItem?.id;
      if (ownedId == null) continue;
      itemsToCover[ownedId] = entry.catalogItem?.displayCoverUrl;
    }
    if (itemsToCover.isEmpty) return;

    if (!_page.mounted) return;
    ScaffoldMessenger.of(_page.context).showSnackBar(
      SnackBar(
        content: Text('Downloading covers for ${itemsToCover.length} items...'),
        duration: const Duration(seconds: 2),
      ),
    );

    final results = await service.downloadCoversForItems(itemsToCover);

    if (_page.mounted) {
      ScaffoldMessenger.of(_page.context).showSnackBar(
        SnackBar(
          content: Text('Downloaded ${results.length} covers.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> scanCoverFlow() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );
    if (picked == null || !_page.mounted) return;

    final bytes = await picked.readAsBytes();
    if (!_page.mounted) return;

    _page.rebuild(() => _page.isScanningCover = true);

    try {
      final api = _page.ref.read(apiClientProvider);
      final response = await api.searchByCoverUpload(bytes);
      if (!_page.mounted) return;

      _page.rebuild(() => _page.isScanningCover = false);

      final results =
          (response['results'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      if (results.isEmpty) {
        ScaffoldMessenger.of(_page.context).showSnackBar(
          const SnackBar(content: Text('No matching covers found.')),
        );
        return;
      }

      await _showCoverScanResults(results: results);
    } catch (e) {
      if (_page.mounted) {
        _page.rebuild(() => _page.isScanningCover = false);
        ScaffoldMessenger.of(_page.context).showSnackBar(
          SnackBar(content: Text('Cover scan failed: $e')),
        );
      }
    }
  }

  Future<void> _showCoverScanResults({
    required List<Map<String, dynamic>> results,
  }) async {
    await showDialog<void>(
      context: _page.context,
      builder: (dialogContext) => AccentAlertDialog(
        backgroundColor: appPalette(dialogContext).panel,
        title: const Text('Cover Matches'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: results.length,
            itemBuilder: (context, index) {
              final match = results[index];
              final entityType = match['entity_type'] as String? ?? '';
              final entityId = match['entity_id'] as String? ?? '';
              final distance = match['hamming_distance'] as int? ?? 0;
              final publicUrl = match['public_url'] as String?;
              final confidence = ((64 - distance) / 64 * 100).round();

              return ListTile(
                leading: publicUrl != null && publicUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: publicUrl,
                          width: 40,
                          height: 56,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 40),
                        ),
                      )
                    : const Icon(Icons.image, size: 40),
                title: Text(
                  '$entityType / ${entityId.length > 8 ? '${entityId.substring(0, 8)}…' : entityId}',
                ),
                subtitle: Text('$confidence% match (distance: $distance)'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  if (entityType == 'item') {
                    _page.selectItem(entityId);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
