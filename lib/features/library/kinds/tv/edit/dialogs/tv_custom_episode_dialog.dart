import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_mutation_provider.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showTvCustomEpisodeDialog(
  BuildContext context, {
  required WidgetRef ref,
  required LibraryEntryRef libraryEntryRef,
  TvCustomEpisode? existingEpisode,
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
  final seasonController = TextEditingController(text: seasonNumber.toString());
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
      barrierDismissible: false,
      builder: (dialogContext) {
        return AccentAlertDialog(
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
                        child: LibraryEditTextField(
                          controller: seasonController,
                          keyboardType: TextInputType.number,
                          label: 'Season',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LibraryEditTextField(
                          controller: episodeController,
                          keyboardType: TextInputType.number,
                          label: 'Episode',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LibraryEditTextField(
                    controller: titleController,
                    label: 'Title',
                  ),
                  const SizedBox(height: 12),
                  LibraryEditTextField(
                    controller: overviewController,
                    maxLines: 3,
                    minLines: 3,
                    label: 'Overview',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: LibraryEditTextField(
                          controller: airDateController,
                          label: 'Air date',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LibraryEditTextField(
                          controller: runtimeController,
                          keyboardType: TextInputType.number,
                          label: 'Runtime (min)',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LibraryEditTextField(
                    controller: stillController,
                    label: 'Still image URL',
                  ),
                  const SizedBox(height: 12),
                  LibraryEditTextField(
                    controller: thumbnailController,
                    label: 'Thumbnail image URL',
                  ),
                  const SizedBox(height: 12),
                  LibraryEditTextField(
                    controller: localImageController,
                    label: 'Local image path',
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
    await ref.read(tvCustomEpisodeMutationsProvider).upsertCustomEpisode(
          id: existingEpisode?.id.value,
          libraryEntryRef: libraryEntryRef,
          seasonNumber: parsedSeason,
          episodeNumber: parsedEpisode,
          title: titleController.text.trim().isEmpty
              ? 'Untitled'
              : titleController.text.trim(),
          description: _nullIfBlank(overviewController.text),
          airDate: _parseDate(airDateController.text),
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

DateTime? _parseDate(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : DateTime.tryParse(trimmed);
}
