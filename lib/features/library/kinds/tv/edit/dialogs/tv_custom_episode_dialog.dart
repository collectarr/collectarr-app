import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showTvCustomEpisodeDialog(
  BuildContext context, {
  required WidgetRef ref,
  required LibraryTypeConfig type,
  required String itemId,
  CustomEpisode? existingEpisode,
  int seasonNumber = 1,
  int episodeNumber = 1,
  String title = '',
  String? overview,
  String? airDate,
  int? runtimeMinutes,
  String? stillImageUrl,
  String? localImagePath,
  String? thumbnailImageUrl,
}) async {
  final seasonController =
      TextEditingController(text: seasonNumber.toString());
  final episodeController =
      TextEditingController(text: episodeNumber.toString());
  final titleController = TextEditingController(text: title);
  final overviewController = TextEditingController(text: overview ?? '');
  final airDateController = TextEditingController(text: airDate ?? '');
  final runtimeController =
      TextEditingController(text: runtimeMinutes?.toString() ?? '');
  final stillController = TextEditingController(text: stillImageUrl ?? '');
  final localImageController =
      TextEditingController(text: localImagePath ?? '');
  final thumbnailController =
      TextEditingController(text: thumbnailImageUrl ?? '');
  try {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(existingEpisode == null ? 'Add episode' : 'Edit episode'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: seasonController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Season'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: episodeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Episode'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: overviewController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Overview'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: airDateController,
                          decoration:
                              const InputDecoration(labelText: 'Air date'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: runtimeController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Runtime (min)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: stillController,
                    decoration:
                        const InputDecoration(labelText: 'Still image URL'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: thumbnailController,
                    decoration: const InputDecoration(
                      labelText: 'Thumbnail image URL',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: localImageController,
                    decoration:
                        const InputDecoration(labelText: 'Local image path'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (result != true) {
      return;
    }
    final parsedSeason =
        int.tryParse(seasonController.text.trim()) ?? seasonNumber;
    final parsedEpisode =
        int.tryParse(episodeController.text.trim()) ?? episodeNumber;
    final parsedRuntime = int.tryParse(runtimeController.text.trim());
    await ref.read(collectionMutationsProvider).upsertCustomEpisode(
          id: existingEpisode?.id,
          catalogRef: CatalogEntityRef(
            kind: type.workspace.kind.apiValue,
            entityType: CatalogEntityType.work,
            id: itemId,
          ),
          seasonNumber: parsedSeason,
          episodeNumber: parsedEpisode,
          title: titleController.text.trim().isEmpty
              ? 'Untitled'
              : titleController.text.trim(),
          overview: _nullIfBlank(overviewController.text),
          airDate: _nullIfBlank(airDateController.text),
          runtimeMinutes: parsedRuntime,
          stillImageUrl: _nullIfBlank(stillController.text),
          localImagePath: _nullIfBlank(localImageController.text),
          thumbnailImageUrl: _nullIfBlank(thumbnailController.text),
        );
  } finally {
    seasonController.dispose();
    episodeController.dispose();
    titleController.dispose();
    overviewController.dispose();
    airDateController.dispose();
    runtimeController.dispose();
    stillController.dispose();
    localImageController.dispose();
    thumbnailController.dispose();
  }
}

String? _nullIfBlank(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
