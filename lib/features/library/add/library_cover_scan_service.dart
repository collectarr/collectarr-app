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

  Future<LibraryCoverReviewedImage?> reviewImage({
    required BuildContext context,
    required LibraryTypeConfig type,
    required XFile file,
  });
}

class LibraryCoverCropBounds {
  const LibraryCoverCropBounds({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  const LibraryCoverCropBounds.fullFrame()
      : left = 0,
        top = 0,
        right = 1,
        bottom = 1;

  final double left;
  final double top;
  final double right;
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;

  bool get isFullFrame =>
      left == 0 && top == 0 && right == 1 && bottom == 1;

  LibraryCoverCropBounds copyWith({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return LibraryCoverCropBounds(
      left: left ?? this.left,
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
    );
  }
}

class LibraryCoverReviewedImage {
  const LibraryCoverReviewedImage({
    required this.sourceFile,
    required this.displayName,
    this.imageBytes,
    this.rotationQuarterTurns = 0,
    this.cropBounds = const LibraryCoverCropBounds.fullFrame(),
  });

  final XFile sourceFile;
  final String displayName;
  final Uint8List? imageBytes;
  final int rotationQuarterTurns;
  final LibraryCoverCropBounds cropBounds;

  factory LibraryCoverReviewedImage.fromFile(
    XFile file, {
    Uint8List? imageBytes,
    String? displayName,
    int rotationQuarterTurns = 0,
    LibraryCoverCropBounds cropBounds = const LibraryCoverCropBounds.fullFrame(),
  }) {
    final resolvedName = displayName?.trim();
    return LibraryCoverReviewedImage(
      sourceFile: file,
      displayName: resolvedName == null || resolvedName.isEmpty
          ? (file.name.trim().isEmpty ? path.basename(file.path) : file.name)
          : resolvedName,
      imageBytes: imageBytes,
      rotationQuarterTurns: rotationQuarterTurns % 4,
      cropBounds: cropBounds,
    );
  }
}

class DialogLibraryCoverImageReview implements LibraryCoverImageReview {
  const DialogLibraryCoverImageReview();

  @override
  Future<LibraryCoverReviewedImage?> reviewImage({
    required BuildContext context,
    required LibraryTypeConfig type,
    required XFile file,
  }) {
    return showDialog<LibraryCoverReviewedImage>(
      context: context,
      builder: (context) => _LibraryCoverScanReviewDialog(file: file),
    );
  }
}

class _LibraryCoverScanReviewDialog extends StatefulWidget {
  const _LibraryCoverScanReviewDialog({required this.file});

  final XFile file;

  @override
  State<_LibraryCoverScanReviewDialog> createState() =>
      _LibraryCoverScanReviewDialogState();
}

class _LibraryCoverScanReviewDialogState
    extends State<_LibraryCoverScanReviewDialog> {
  static const _cropStep = 0.05;
  static const _minCropSpan = 0.35;

  late final TextEditingController _displayNameController;
  late final Future<Uint8List?> _previewBytesFuture;
  int _rotationQuarterTurns = 0;
  LibraryCoverCropBounds _cropBounds = const LibraryCoverCropBounds.fullFrame();

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.file.name.trim().isEmpty
          ? path.basename(widget.file.path)
          : widget.file.name.trim(),
    );
    _previewBytesFuture = _readPreviewBytes(widget.file);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxDialogHeight = MediaQuery.sizeOf(context).height * 0.84;
    return FutureBuilder<Uint8List?>(
      future: _previewBytesFuture,
      builder: (context, snapshot) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560, maxHeight: maxDialogHeight),
          child: SingleChildScrollView(
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
                _LibraryCoverScanReviewPreview(
                  file: widget.file,
                  previewBytes: snapshot.data,
                  isLoading: snapshot.connectionState != ConnectionState.done,
                  rotationQuarterTurns: _rotationQuarterTurns,
                  cropBounds: _cropBounds,
                ),
                const SizedBox(height: 12),
                Text(
                  'Crop the frame locally so later OCR and cleanup only inspect the relevant cover area.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      key: const ValueKey('library-cover-review-trim-left'),
                      onPressed: () => _trimCropEdge(left: _cropStep),
                      icon: const Icon(Icons.keyboard_double_arrow_right),
                      label: const Text('Trim left'),
                    ),
                    OutlinedButton.icon(
                      key: const ValueKey('library-cover-review-trim-right'),
                      onPressed: () => _trimCropEdge(right: -_cropStep),
                      icon: const Icon(Icons.keyboard_double_arrow_left),
                      label: const Text('Trim right'),
                    ),
                    OutlinedButton.icon(
                      key: const ValueKey('library-cover-review-trim-top'),
                      onPressed: () => _trimCropEdge(top: _cropStep),
                      icon: const Icon(Icons.keyboard_double_arrow_down),
                      label: const Text('Trim top'),
                    ),
                    OutlinedButton.icon(
                      key: const ValueKey('library-cover-review-trim-bottom'),
                      onPressed: () => _trimCropEdge(bottom: -_cropStep),
                      icon: const Icon(Icons.keyboard_double_arrow_up),
                      label: const Text('Trim bottom'),
                    ),
                    TextButton.icon(
                      key: const ValueKey('library-cover-review-reset-crop'),
                      onPressed: _cropBounds.isFullFrame
                          ? null
                          : () => setState(
                                () => _cropBounds =
                                    const LibraryCoverCropBounds.fullFrame(),
                              ),
                      icon: const Icon(Icons.crop_free),
                      label: const Text('Reset crop'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Crop: ${(_cropBounds.width * 100).round()}% width x ${(_cropBounds.height * 100).round()}% height',
                  key: const ValueKey('library-cover-review-crop-label'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      key: const ValueKey('library-cover-review-rotate-left'),
                      onPressed: () => setState(
                        () => _rotationQuarterTurns =
                            (_rotationQuarterTurns + 3) % 4,
                      ),
                      icon: const Icon(Icons.rotate_left),
                      label: const Text('Rotate left'),
                    ),
                    OutlinedButton.icon(
                      key: const ValueKey('library-cover-review-rotate-right'),
                      onPressed: () => setState(
                        () => _rotationQuarterTurns =
                            (_rotationQuarterTurns + 1) % 4,
                      ),
                      icon: const Icon(Icons.rotate_right),
                      label: const Text('Rotate right'),
                    ),
                    Padding(
                      key: const ValueKey('library-cover-review-rotation-label'),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Rotation: ${_rotationQuarterTurns * 90}°',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey('library-cover-review-label-field'),
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Local scan label',
                    hintText: 'Edit the title, issue, year, or publisher hints',
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
                      onPressed: () => Navigator.of(context).pop(
                        LibraryCoverReviewedImage.fromFile(
                          widget.file,
                          imageBytes: snapshot.data,
                          displayName: _displayNameController.text,
                          rotationQuarterTurns: _rotationQuarterTurns,
                          cropBounds: _cropBounds,
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Use image'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _trimCropEdge({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    setState(() {
      var next = _cropBounds;
      if (left != 0) {
        final nextLeft = (next.left + left).clamp(0.0, next.right - _minCropSpan);
        next = next.copyWith(left: nextLeft.toDouble());
      }
      if (right != 0) {
        final nextRight = (next.right + right).clamp(next.left + _minCropSpan, 1.0);
        next = next.copyWith(right: nextRight.toDouble());
      }
      if (top != 0) {
        final nextTop = (next.top + top).clamp(0.0, next.bottom - _minCropSpan);
        next = next.copyWith(top: nextTop.toDouble());
      }
      if (bottom != 0) {
        final nextBottom = (next.bottom + bottom).clamp(next.top + _minCropSpan, 1.0);
        next = next.copyWith(bottom: nextBottom.toDouble());
      }
      _cropBounds = next;
    });
  }
}

Future<Uint8List?> _readPreviewBytes(XFile file) async {
  try {
    final bytes = await file.readAsBytes();
    return bytes.isEmpty ? null : bytes;
  } catch (_) {
    return null;
  }
}

class _LibraryCoverScanReviewPreview extends StatelessWidget {
  const _LibraryCoverScanReviewPreview({
    required this.file,
    required this.previewBytes,
    required this.isLoading,
    required this.rotationQuarterTurns,
    required this.cropBounds,
  });

  final XFile file;
  final Uint8List? previewBytes;
  final bool isLoading;
  final int rotationQuarterTurns;
  final LibraryCoverCropBounds cropBounds;

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
          child: RotatedBox(
            quarterTurns: rotationQuarterTurns,
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                fit: StackFit.expand,
                children: [
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (previewBytes == null)
                    const Center(
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
                    )
                  else
                    Image.memory(previewBytes!, fit: BoxFit.contain),
                  IgnorePointer(
                    child: _LibraryCoverCropOverlay(
                      bounds: cropBounds,
                      size: Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LibraryCoverCropOverlay extends StatelessWidget {
  const _LibraryCoverCropOverlay({required this.bounds, required this.size});

  final LibraryCoverCropBounds bounds;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final left = size.width * bounds.left;
    final top = size.height * bounds.top;
    final width = size.width * bounds.width;
    final height = size.height * bounds.height;
    return Stack(
      children: [
        if (top > 0)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: top,
            child: const ColoredBox(color: Color(0x7A000000)),
          ),
        if (bounds.bottom < 1)
          Positioned(
            left: 0,
            right: 0,
            top: top + height,
            height: size.height - (top + height),
            child: const ColoredBox(color: Color(0x7A000000)),
          ),
        if (left > 0)
          Positioned(
            left: 0,
            top: top,
            width: left,
            height: height,
            child: const ColoredBox(color: Color(0x7A000000)),
          ),
        if (bounds.right < 1)
          Positioned(
            left: left + width,
            top: top,
            width: size.width - (left + width),
            height: height,
            child: const ColoredBox(color: Color(0x7A000000)),
          ),
        Positioned(
          left: left,
          top: top,
          width: width,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white70, width: 2),
            ),
          ),
        ),
      ],
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
    this.reviewSummary,
    this.warnings = const <String>[],
  });

  final String? query;
  final String? series;
  final String? issueNumber;
  final String? publisher;
  final int? year;
  final String? confidenceLabel;
  final String? reviewSummary;
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

LibraryCoverScanResult _filenameDerivedResult(LibraryCoverReviewedImage image) {
  final filename = image.displayName.trim();
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
    reviewSummary: _reviewSummary(image),
    warnings: const <String>[
      'Search hints were derived locally from the imported filename. OCR is not enabled yet.',
    ],
  );
}

String? _reviewSummary(LibraryCoverReviewedImage image) {
  final parts = <String>[
    if (image.rotationQuarterTurns != 0)
      'rotated ${image.rotationQuarterTurns * 90}°',
    if (!image.cropBounds.isFullFrame)
      'cropped ${(image.cropBounds.width * 100).round()}% x ${(image.cropBounds.height * 100).round()}%',
  ];
  if (parts.isEmpty) {
    return null;
  }
  return parts.join(', ');
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