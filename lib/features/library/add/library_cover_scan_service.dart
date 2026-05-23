import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'
  as mlkit;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

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
    this.imagePreprocessor = const LocalLibraryCoverImagePreprocessor(),
    this.textRecognizer = const CompositeLibraryCoverTextRecognizer(),
  });

  final LibraryCoverScanSourcePrompt sourcePrompt;
  final LibraryCoverImagePicker imagePicker;
  final LibraryCoverImageReview imageReview;
  final LibraryCoverImagePreprocessor imagePreprocessor;
  final LibraryCoverTextRecognizer textRecognizer;

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
    final prepared = await imagePreprocessor.prepareImage(
      type: type,
      image: reviewed,
    );
    final recognizedText = await textRecognizer.recognizeText(
      type: type,
      image: prepared,
    );
    return _analysisDerivedResult(
      reviewed,
      recognizedText: recognizedText,
    );
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

class LibraryCoverPreparedImage {
  const LibraryCoverPreparedImage({
    required this.reviewedImage,
    this.preparedBytes,
    this.transformsApplied = false,
  });

  final LibraryCoverReviewedImage reviewedImage;
  final Uint8List? preparedBytes;
  final bool transformsApplied;
}

abstract class LibraryCoverImagePreprocessor {
  const LibraryCoverImagePreprocessor();

  Future<LibraryCoverPreparedImage> prepareImage({
    required LibraryTypeConfig type,
    required LibraryCoverReviewedImage image,
  });
}

class LocalLibraryCoverImagePreprocessor
    implements LibraryCoverImagePreprocessor {
  const LocalLibraryCoverImagePreprocessor();

  @override
  Future<LibraryCoverPreparedImage> prepareImage({
    required LibraryTypeConfig type,
    required LibraryCoverReviewedImage image,
  }) async {
    if (!_needsImageTransform(image)) {
      return LibraryCoverPreparedImage(
        reviewedImage: image,
        preparedBytes: image.imageBytes,
      );
    }
    final sourceBytes = image.imageBytes ?? await _readPreviewBytes(image.sourceFile);
    if (sourceBytes == null) {
      return LibraryCoverPreparedImage(
        reviewedImage: image,
        preparedBytes: null,
      );
    }
    final transformedBytes = await _transformPreparedBytes(sourceBytes, image);
    return LibraryCoverPreparedImage(
      reviewedImage: image,
      preparedBytes: transformedBytes ?? sourceBytes,
      transformsApplied: transformedBytes != null,
    );
  }
}

bool _needsImageTransform(LibraryCoverReviewedImage image) {
  return image.rotationQuarterTurns != 0 || !image.cropBounds.isFullFrame;
}

Future<Uint8List?> _transformPreparedBytes(
  Uint8List sourceBytes,
  LibraryCoverReviewedImage image,
) async {
  ui.Codec? codec;
  ui.Image? frameImage;
  ui.Image? rotatedImage;
  ui.Image? croppedImage;
  try {
    codec = await ui.instantiateImageCodec(sourceBytes);
    final frame = await codec.getNextFrame();
    frameImage = frame.image;

    final rotatedSize = _rotatedImageSize(
      frameImage.width,
      frameImage.height,
      image.rotationQuarterTurns,
    );
    rotatedImage = await _renderRotatedImage(
      frameImage,
      image.rotationQuarterTurns,
      rotatedSize,
    );

    final cropRect = _cropRectForBounds(rotatedSize, image.cropBounds);
    croppedImage = await _renderCroppedImage(rotatedImage, cropRect);
    final byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  } catch (_) {
    return null;
  } finally {
    codec?.dispose();
    frameImage?.dispose();
    rotatedImage?.dispose();
    croppedImage?.dispose();
  }
}

Size _rotatedImageSize(int width, int height, int quarterTurns) {
  return quarterTurns.isOdd
      ? Size(height.toDouble(), width.toDouble())
      : Size(width.toDouble(), height.toDouble());
}

Future<ui.Image> _renderRotatedImage(
  ui.Image source,
  int quarterTurns,
  Size outputSize,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final normalizedTurns = quarterTurns % 4;
  if (normalizedTurns == 1) {
    canvas.translate(outputSize.width, 0);
    canvas.rotate(math.pi / 2);
  } else if (normalizedTurns == 2) {
    canvas.translate(outputSize.width, outputSize.height);
    canvas.rotate(math.pi);
  } else if (normalizedTurns == 3) {
    canvas.translate(0, outputSize.height);
    canvas.rotate(-math.pi / 2);
  }
  canvas.drawImage(source, Offset.zero, Paint());
  return recorder
      .endRecording()
      .toImage(outputSize.width.round(), outputSize.height.round());
}

Rect _cropRectForBounds(Size size, LibraryCoverCropBounds bounds) {
  final left = size.width * bounds.left;
  final top = size.height * bounds.top;
  final width = math.max(1, (size.width * bounds.width).round()).toDouble();
  final height = math.max(1, (size.height * bounds.height).round()).toDouble();
    final clampedLeft =
      left.clamp(0.0, math.max(0.0, size.width - width)).toDouble();
    final clampedTop =
      top.clamp(0.0, math.max(0.0, size.height - height)).toDouble();
  return Rect.fromLTWH(
    clampedLeft,
    clampedTop,
    math.min(width, size.width),
    math.min(height, size.height),
  );
}

Future<ui.Image> _renderCroppedImage(ui.Image source, Rect cropRect) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final outputWidth = cropRect.width.round();
  final outputHeight = cropRect.height.round();
  canvas.drawImageRect(
    source,
    cropRect,
    Rect.fromLTWH(0, 0, outputWidth.toDouble(), outputHeight.toDouble()),
    Paint(),
  );
  return recorder.endRecording().toImage(outputWidth, outputHeight);
}

abstract class LibraryCoverTextRecognizer {
  const LibraryCoverTextRecognizer();

  Future<String?> recognizeText({
    required LibraryTypeConfig type,
    required LibraryCoverPreparedImage image,
  });
}

class ReviewSeedLibraryCoverTextRecognizer
    implements LibraryCoverTextRecognizer {
  const ReviewSeedLibraryCoverTextRecognizer();

  @override
  Future<String?> recognizeText({
    required LibraryTypeConfig type,
    required LibraryCoverPreparedImage image,
  }) async {
    final extracted = image.reviewedImage.extractedText?.trim();
    return extracted == null || extracted.isEmpty ? null : extracted;
  }
}

bool localCoverTextRecognitionSupported({
  bool isWeb = kIsWeb,
  TargetPlatform? platform,
}) {
  if (isWeb) {
    return false;
  }
  return switch (platform ?? defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    TargetPlatform.fuchsia ||
    TargetPlatform.linux ||
    TargetPlatform.macOS ||
    TargetPlatform.windows =>
      false,
  };
}

class CompositeLibraryCoverTextRecognizer implements LibraryCoverTextRecognizer {
  const CompositeLibraryCoverTextRecognizer({
    this.nativeRecognizer = const GoogleMlKitLibraryCoverTextRecognizer(),
    this.fallbackRecognizer = const ReviewSeedLibraryCoverTextRecognizer(),
  });

  final LibraryCoverTextRecognizer nativeRecognizer;
  final LibraryCoverTextRecognizer fallbackRecognizer;

  @override
  Future<String?> recognizeText({
    required LibraryTypeConfig type,
    required LibraryCoverPreparedImage image,
  }) async {
    final nativeText = await nativeRecognizer.recognizeText(
      type: type,
      image: image,
    );
    if (nativeText?.trim().isNotEmpty == true) {
      return nativeText!.trim();
    }
    return fallbackRecognizer.recognizeText(type: type, image: image);
  }
}

class GoogleMlKitLibraryCoverTextRecognizer
    implements LibraryCoverTextRecognizer {
  const GoogleMlKitLibraryCoverTextRecognizer();

  @override
  Future<String?> recognizeText({
    required LibraryTypeConfig type,
    required LibraryCoverPreparedImage image,
  }) async {
    if (!localCoverTextRecognitionSupported()) {
      return null;
    }
    final inputImage = await _buildMlKitInputImage(image);
    if (inputImage == null) {
      return null;
    }
    final recognizer = mlkit.TextRecognizer(
      script: mlkit.TextRecognitionScript.latin,
    );
    try {
      final result = await recognizer.processImage(inputImage);
      final text = result.text.trim();
      return text.isEmpty ? null : text;
    } catch (_) {
      return null;
    } finally {
      await recognizer.close();
    }
  }
}

Future<mlkit.InputImage?> _buildMlKitInputImage(
  LibraryCoverPreparedImage image,
) async {
  final preparedBytes = image.preparedBytes;
  if (preparedBytes != null && image.transformsApplied) {
    final tempDir = await getTemporaryDirectory();
    final tempPath = path.join(
      tempDir.path,
      'cover-scan-${DateTime.now().microsecondsSinceEpoch}.png',
    );
    await XFile.fromData(
      preparedBytes,
      mimeType: 'image/png',
      name: path.basename(tempPath),
    ).saveTo(tempPath);
    return mlkit.InputImage.fromFilePath(tempPath);
  }
  final sourcePath = image.reviewedImage.sourceFile.path.trim();
  if (sourcePath.isEmpty) {
    return null;
  }
  return mlkit.InputImage.fromFilePath(sourcePath);
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
    this.extractedText,
  });

  final XFile sourceFile;
  final String displayName;
  final Uint8List? imageBytes;
  final int rotationQuarterTurns;
  final LibraryCoverCropBounds cropBounds;
  final String? extractedText;

  factory LibraryCoverReviewedImage.fromFile(
    XFile file, {
    Uint8List? imageBytes,
    String? displayName,
    int rotationQuarterTurns = 0,
    LibraryCoverCropBounds cropBounds = const LibraryCoverCropBounds.fullFrame(),
    String? extractedText,
  }) {
    final resolvedName = displayName?.trim();
    final resolvedText = extractedText?.trim();
    return LibraryCoverReviewedImage(
      sourceFile: file,
      displayName: resolvedName == null || resolvedName.isEmpty
          ? (file.name.trim().isEmpty ? path.basename(file.path) : file.name)
          : resolvedName,
      imageBytes: imageBytes,
      rotationQuarterTurns: rotationQuarterTurns % 4,
      cropBounds: cropBounds,
      extractedText:
          resolvedText == null || resolvedText.isEmpty ? null : resolvedText,
    );
  }
}

class DialogLibraryCoverImageReview implements LibraryCoverImageReview {
  const DialogLibraryCoverImageReview({
    this.imagePreprocessor = const LocalLibraryCoverImagePreprocessor(),
    this.textRecognizer = const CompositeLibraryCoverTextRecognizer(),
  });

  final LibraryCoverImagePreprocessor imagePreprocessor;
  final LibraryCoverTextRecognizer textRecognizer;

  @override
  Future<LibraryCoverReviewedImage?> reviewImage({
    required BuildContext context,
    required LibraryTypeConfig type,
    required XFile file,
  }) {
    return showDialog<LibraryCoverReviewedImage>(
      context: context,
      builder: (context) => _LibraryCoverScanReviewDialog(
        file: file,
        type: type,
        imagePreprocessor: imagePreprocessor,
        textRecognizer: textRecognizer,
      ),
    );
  }
}

class _LibraryCoverScanReviewDialog extends StatefulWidget {
  const _LibraryCoverScanReviewDialog({
    required this.file,
    required this.type,
    required this.imagePreprocessor,
    required this.textRecognizer,
  });

  final XFile file;
  final LibraryTypeConfig type;
  final LibraryCoverImagePreprocessor imagePreprocessor;
  final LibraryCoverTextRecognizer textRecognizer;

  @override
  State<_LibraryCoverScanReviewDialog> createState() =>
      _LibraryCoverScanReviewDialogState();
}

class _LibraryCoverScanReviewDialogState
    extends State<_LibraryCoverScanReviewDialog> {
  static const _cropStep = 0.05;
  static const _minCropSpan = 0.35;

  late final TextEditingController _displayNameController;
  late final TextEditingController _extractedTextController;
  late final Future<Uint8List?> _previewBytesFuture;
  int _rotationQuarterTurns = 0;
  LibraryCoverCropBounds _cropBounds = const LibraryCoverCropBounds.fullFrame();
  bool _isAutofillingExtractedText = false;
  String? _autofillStatus;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.file.name.trim().isEmpty
          ? path.basename(widget.file.path)
          : widget.file.name.trim(),
    );
    _extractedTextController = TextEditingController();
    _previewBytesFuture = _readPreviewBytes(widget.file);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autofillExtractedText();
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _extractedTextController.dispose();
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
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey('library-cover-review-text-field'),
                  controller: _extractedTextController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Auto extracted text',
                    hintText:
                        'Review or correct locally extracted title, issue, year, or publisher text',
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TextButton.icon(
                      key: const ValueKey('library-cover-review-refresh-text'),
                      onPressed: _isAutofillingExtractedText
                          ? null
                          : () => _autofillExtractedText(forceReplace: true),
                      icon: const Icon(Icons.auto_awesome_outlined),
                      label: const Text('Refresh auto text'),
                    ),
                    if (_isAutofillingExtractedText)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (_autofillStatus != null)
                      Text(
                        _autofillStatus!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                  ],
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
                          extractedText: _extractedTextController.text,
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

  Future<void> _autofillExtractedText({bool forceReplace = false}) async {
    if (_isAutofillingExtractedText) {
      return;
    }
    setState(() {
      _isAutofillingExtractedText = true;
      _autofillStatus = 'Extracting local text...';
    });
    try {
      final reviewed = LibraryCoverReviewedImage.fromFile(
        widget.file,
        imageBytes: await _previewBytesFuture,
        displayName: _displayNameController.text,
        rotationQuarterTurns: _rotationQuarterTurns,
        cropBounds: _cropBounds,
      );
      final prepared = await widget.imagePreprocessor.prepareImage(
        type: widget.type,
        image: reviewed,
      );
      final recognized = await widget.textRecognizer.recognizeText(
        type: widget.type,
        image: prepared,
      );
      final fallback = _normalizedAnalysisText(_displayNameController.text);
      final nextText = (recognized?.trim().isNotEmpty == true
              ? recognized!.trim()
              : fallback)
          ?.trim();
      if (!mounted) {
        return;
      }
      if ((forceReplace || _extractedTextController.text.trim().isEmpty) &&
          nextText != null &&
          nextText.isNotEmpty) {
        _extractedTextController.text = nextText;
      }
      setState(() {
        _autofillStatus = nextText == null || nextText.isEmpty
            ? 'No local text detected yet.'
            : localCoverTextRecognitionSupported()
                ? 'Local OCR preview ready.'
                : 'Heuristic text preview ready.';
      });
    } finally {
      if (mounted) {
        setState(() => _isAutofillingExtractedText = false);
      }
    }
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

LibraryCoverScanResult _analysisDerivedResult(
  LibraryCoverReviewedImage image, {
  String? recognizedText,
}) {
  final primaryText = _normalizedAnalysisText(recognizedText);
  final fallbackText = _normalizedAnalysisText(image.displayName);

  final drafts = <_CoverHintDraft>[
    if (primaryText != null) _draftFromText(primaryText),
    if (fallbackText != null && fallbackText.toLowerCase() != primaryText?.toLowerCase())
      _draftFromText(fallbackText),
  ];

  if (drafts.isEmpty || !drafts.any((draft) => draft.hasAnyHint)) {
    return const LibraryCoverScanResult(
      confidenceLabel: 'low',
      warnings: <String>[
        'Imported image successfully, but the filename and review text do not contain usable search hints yet.',
      ],
    );
  }

  final merged = _mergeDrafts(drafts);
  final primaryHasReviewText = primaryText != null;

  return LibraryCoverScanResult(
    query: merged.query,
    series: merged.series,
    issueNumber: merged.issueNumber,
    publisher: merged.publisher,
    year: merged.year,
    confidenceLabel: primaryHasReviewText ? 'medium' : 'low',
    reviewSummary: _reviewSummary(image),
    warnings: <String>[
      primaryHasReviewText
          ? 'Search hints were derived locally from the imported filename and review text. OCR is not enabled yet.'
          : 'Search hints were derived locally from the imported filename. OCR is not enabled yet.',
    ],
  );
}

String? _reviewSummary(LibraryCoverReviewedImage image) {
  final parts = <String>[
    if (image.rotationQuarterTurns != 0)
      'rotated ${image.rotationQuarterTurns * 90}°',
    if (!image.cropBounds.isFullFrame)
      'cropped ${(image.cropBounds.width * 100).round()}% x ${(image.cropBounds.height * 100).round()}%',
    if (image.extractedText?.trim().isNotEmpty ?? false) 'review text added',
  ];
  if (parts.isEmpty) {
    return null;
  }
  return parts.join(', ');
}

String? _normalizedAnalysisText(String? raw) {
  final trimmed = raw?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  final stem = path.basenameWithoutExtension(trimmed).trim();
  final cleaned = stem
      .replaceAll(RegExp(r'[_\-.]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (cleaned.isEmpty || _looksLikeGenericCameraName(cleaned)) {
    return null;
  }
  return cleaned;
}

class _CoverHintDraft {
  const _CoverHintDraft({
    this.query,
    this.series,
    this.issueNumber,
    this.publisher,
    this.year,
  });

  final String? query;
  final String? series;
  final String? issueNumber;
  final String? publisher;
  final int? year;

  bool get hasAnyHint {
    return (query?.isNotEmpty ?? false) ||
        (series?.isNotEmpty ?? false) ||
        (issueNumber?.isNotEmpty ?? false) ||
        (publisher?.isNotEmpty ?? false) ||
        year != null;
  }
}

_CoverHintDraft _draftFromText(String cleaned) {
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
  final resolvedQuery = query.isEmpty ? cleaned : query;
  return _CoverHintDraft(
    query: resolvedQuery,
    series: resolvedQuery,
    issueNumber: issueNumber,
    publisher: publisher,
    year: year,
  );
}

_CoverHintDraft _mergeDrafts(List<_CoverHintDraft> drafts) {
  var query = '';
  var series = '';
  String? issueNumber;
  String? publisher;
  int? year;
  for (final draft in drafts) {
    if (query.isEmpty && draft.query?.trim().isNotEmpty == true) {
      query = draft.query!.trim();
    }
    if (series.isEmpty && draft.series?.trim().isNotEmpty == true) {
      series = draft.series!.trim();
    }
    issueNumber ??= draft.issueNumber?.trim().isEmpty == true
        ? null
        : draft.issueNumber?.trim();
    publisher ??= draft.publisher?.trim().isEmpty == true
        ? null
        : draft.publisher?.trim();
    year ??= draft.year;
  }
  return _CoverHintDraft(
    query: query.isEmpty ? null : query,
    series: series.isEmpty ? null : series,
    issueNumber: issueNumber,
    publisher: publisher,
    year: year,
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