import 'dart:typed_data';

import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

abstract class LibraryCoverScanService {
  const LibraryCoverScanService();

  Future<LibraryCoverScanResult?> scanCover({
    required BuildContext context,
    required LibraryTypeConfig type,
  });
}

class LocalLibraryCoverScanService implements LibraryCoverScanService {
  const LocalLibraryCoverScanService({
    this.sourcePrompt = const BottomSheetLibraryCoverScanSourcePrompt(),
    this.imagePicker = const DeviceLibraryCoverImagePicker(),
    this.imageReview = const DialogLibraryCoverImageReview(),
  });

  final LibraryCoverScanSourcePrompt sourcePrompt;
  final LibraryCoverImagePicker imagePicker;
  final LibraryCoverImageReview imageReview;

  @override
  Future<LibraryCoverScanResult?> scanCover({
    required BuildContext context,
    required LibraryTypeConfig type,
  }) async {
    final action = await sourcePrompt.selectAction(
      context: context,
      type: type,
    );
    if (action != LibraryCoverScanAction.importImage) {
      return null;
    }
    final picked = await imagePicker.pickImage();
    if (picked == null) {
      return null;
    }
    final reviewed = await imageReview.reviewImage(
      context: context,
      type: type,
      file: picked,
    );
    if (reviewed == null) {
      return null;
    }
    return _filenameDerivedResult(reviewed);
  }
}

class NoopLibraryCoverScanService implements LibraryCoverScanService {
  const NoopLibraryCoverScanService();

  @override
  Future<LibraryCoverScanResult?> scanCover({
    required BuildContext context,
    required LibraryTypeConfig type,
  }) async {
    return null;
  }
}

enum LibraryCoverScanAction { importImage }

abstract class LibraryCoverScanSourcePrompt {
  const LibraryCoverScanSourcePrompt();

  Future<LibraryCoverScanAction?> selectAction({
    required BuildContext context,
    required LibraryTypeConfig type,
  });
}

class BottomSheetLibraryCoverScanSourcePrompt
    implements LibraryCoverScanSourcePrompt {
  const BottomSheetLibraryCoverScanSourcePrompt();

  @override
  Future<LibraryCoverScanAction?> selectAction({
    required BuildContext context,
    required LibraryTypeConfig type,
  }) {
    return showModalBottomSheet<LibraryCoverScanAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Scan cover',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Import a local cover photo. OCR and image cleanup can be layered in later without sending the image to the server.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(
                  LibraryCoverScanAction.importImage,
                ),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Import image'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract class LibraryCoverImagePicker {
  const LibraryCoverImagePicker();

  Future<XFile?> pickImage();
}

class DeviceLibraryCoverImagePicker implements LibraryCoverImagePicker {
  const DeviceLibraryCoverImagePicker();

  @override
  Future<XFile?> pickImage() {
    return ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 90,
    );
  }
}

abstract class LibraryCoverImageReview {
  const LibraryCoverImageReview();

  Future<XFile?> reviewImage({
    required BuildContext context,
    required LibraryTypeConfig type,
    required XFile file,
  });
}

class DialogLibraryCoverImageReview implements LibraryCoverImageReview {
  const DialogLibraryCoverImageReview();

  @override
  Future<XFile?> reviewImage({
    required BuildContext context,
    required LibraryTypeConfig type,
    required XFile file,
  }) {
    return showDialog<XFile>(
      context: context,
      builder: (context) => _LibraryCoverScanReviewDialog(file: file),
    );
  }
}

class _LibraryCoverScanReviewDialog extends StatelessWidget {
  const _LibraryCoverScanReviewDialog({required this.file});

  final XFile file;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Review imported cover',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Keep this image local and confirm it before search hints are derived. Crop and OCR hooks can plug into this step later.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              _LibraryCoverScanReviewPreview(file: file),
              const SizedBox(height: 12),
              Text(
                file.name.trim().isEmpty ? path.basename(file.path) : file.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(file),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Use image'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryCoverScanReviewPreview extends StatelessWidget {
  const _LibraryCoverScanReviewPreview({required this.file});

  final XFile file;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          color: Colors.black12,
        ),
        child: AspectRatio(
          aspectRatio: 0.72,
          child: FutureBuilder<Uint8List>(
            future: file.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_outlined, size: 42),
                        SizedBox(height: 8),
                        Text(
                          'Preview unavailable, but the image can still be used for local scan hints.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Image.memory(snapshot.data!, fit: BoxFit.contain);
            },
          ),
        ),
      ),
    );
  }
}

class LibraryCoverScanResult {
  const LibraryCoverScanResult({
    this.query,
    this.series,
    this.issueNumber,
    this.publisher,
    this.year,
    this.confidenceLabel,
    this.warnings = const <String>[],
  });

  final String? query;
  final String? series;
  final String? issueNumber;
  final String? publisher;
  final int? year;
  final String? confidenceLabel;
  final List<String> warnings;

  bool get hasAnyHint {
    return (query?.trim().isNotEmpty ?? false) ||
        (series?.trim().isNotEmpty ?? false) ||
        (issueNumber?.trim().isNotEmpty ?? false) ||
        (publisher?.trim().isNotEmpty ?? false) ||
        year != null;
  }

  bool get showAdvancedFields {
    return (series?.trim().isNotEmpty ?? false) ||
        (issueNumber?.trim().isNotEmpty ?? false) ||
        (publisher?.trim().isNotEmpty ?? false) ||
        year != null;
  }
}

LibraryCoverScanResult _filenameDerivedResult(XFile file) {
  final filename = file.name.trim().isNotEmpty
      ? file.name.trim()
      : path.basename(file.path);
  final stem = path.basenameWithoutExtension(filename).trim();
  final cleaned = stem
      .replaceAll(RegExp(r'[_\-.]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (cleaned.isEmpty || _looksLikeGenericCameraName(cleaned)) {
    return const LibraryCoverScanResult(
      confidenceLabel: 'low',
      warnings: <String>[
        'Imported image successfully, but the filename does not contain usable search hints yet.',
      ],
    );
  }

  final yearMatch = RegExp(r'\b((?:19|20)\d{2})\b').firstMatch(cleaned);
  final year = yearMatch == null ? null : int.tryParse(yearMatch.group(1)!);
  var remainder = cleaned;
  if (yearMatch != null) {
    remainder = remainder.replaceFirst(yearMatch.group(0)!, ' ');
  }

  final issueMatches = RegExp(r'(?:(?<=\s)|^)#?(\d{1,4}[A-Za-z]?)\b')
      .allMatches(remainder)
      .toList(growable: false);
  final issueNumber = issueMatches.isEmpty ? null : issueMatches.last.group(1);
  if (issueMatches.isNotEmpty) {
    remainder = remainder.replaceFirst(issueMatches.last.group(0)!, ' ');
  }

  final publisher = _extractPublisher(remainder);
  if (publisher != null) {
    remainder = remainder.replaceFirst(
      RegExp(r'\b' + RegExp.escape(publisher) + r'\b', caseSensitive: false),
      ' ',
    );
  }

  final query = remainder.replaceAll(RegExp(r'\s+'), ' ').trim();
  return LibraryCoverScanResult(
    query: query.isEmpty ? cleaned : query,
    series: query.isEmpty ? cleaned : query,
    issueNumber: issueNumber,
    publisher: publisher,
    year: year,
    confidenceLabel: 'low',
    warnings: const <String>[
      'Search hints were derived locally from the imported filename. OCR is not enabled yet.',
    ],
  );
}

String? _extractPublisher(String value) {
  const publishers = <String>['DC', 'Marvel', 'Image', 'Dark Horse', 'Boom'];
  for (final publisher in publishers) {
    if (RegExp(r'\b' + RegExp.escape(publisher) + r'\b', caseSensitive: false)
        .hasMatch(value)) {
      return publisher;
    }
  }
  return null;
}

bool _looksLikeGenericCameraName(String value) {
  final normalized = value.trim().toUpperCase();
  return RegExp(r'^(IMG|PXL|DSC|PHOTO|SCREENSHOT)[ _-]?[0-9-]+$')
      .hasMatch(normalized);
}