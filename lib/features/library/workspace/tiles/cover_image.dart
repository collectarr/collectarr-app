import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/features/library/ui/image_load_gate.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/utils/image_url.dart';
import 'package:collectarr_app/features/collection/providers/local_cover_image_provider.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/library_square_close_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_cache.dart';

import 'cover_element_aspect.dart'
    if (dart.library.js_interop) 'cover_element_aspect_web.dart';

/// Lets the owning layout follow a cover's decoded shape.
class LibraryCoverLayoutScope extends InheritedWidget {
  const LibraryCoverLayoutScope({
    required this.fallbackAspectRatio,
    this.onAspectRatio,
    this.onImageMissing,
    this.fitToHeight = false,
    required super.child,
    super.key,
  });
  final double fallbackAspectRatio;
  final ValueChanged<double>? onAspectRatio;
  final VoidCallback? onImageMissing;
  final bool fitToHeight;
  static LibraryCoverLayoutScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LibraryCoverLayoutScope>();
  @override
  bool updateShouldNotify(LibraryCoverLayoutScope oldWidget) =>
      fallbackAspectRatio != oldWidget.fallbackAspectRatio ||
      onAspectRatio != oldWidget.onAspectRatio ||
      onImageMissing != oldWidget.onImageMissing ||
      fitToHeight != oldWidget.fitToHeight;
}

class LibraryCoverImage extends ConsumerWidget {
  const LibraryCoverImage({
    required this.title,
    this.mediaKind,
    this.itemNumber,
    this.imageUrl,
    this.localBytes,
    this.libraryEntryRef,
    this.targetCacheWidth,
    this.fallbackAspectRatio = 2 / 3,
    this.localImageType = 'front_cover',
    this.borderRadius = 4,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.showPlaceholder = true,
    this.allowWebImageElement = true,
    this.onAspectRatio,
    super.key,
  });

  final String title;
  final CatalogMediaKind? mediaKind;
  final String? itemNumber;
  final String? imageUrl;
  final Uint8List? localBytes;
  final LibraryEntryRef? libraryEntryRef;
  final int? targetCacheWidth;
  final double fallbackAspectRatio;
  final String localImageType;
  final double borderRadius;
  final BoxFit fit;
  final Alignment alignment;
  final bool showPlaceholder;

  /// Whether the web app may show a cover that blocks cross-origin reads as
  /// an `<img>` element. Such elements sit outside Flutter's canvas, so a
  /// cover drawn under translucent layers or text must not use one.
  final bool allowWebImageElement;

  /// Hears the width / height of what this shows: the image's own, or
  /// [fallbackAspectRatio] for the placeholder.
  final ValueChanged<double>? onAspectRatio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = LibraryCoverLayoutScope.maybeOf(context);
    if (layout == null) return _buildImage(context, ref, onAspectRatio);
    return LibraryCoverShape(
      imageUrl: imageUrl,
      libraryEntryRef: libraryEntryRef,
      imageType: localImageType,
      fallbackAspectRatio: layout.fallbackAspectRatio,
      builder: (context, aspect, report) {
        final image = _buildImage(context, ref, (ratio) {
          report(ratio);
          layout.onAspectRatio?.call(ratio);
          onAspectRatio?.call(ratio);
        },
            shapeFallback: layout.fallbackAspectRatio,
            onImageMissing: layout.onImageMissing);
        if (layout.fitToHeight) {
          return LayoutBuilder(
              builder: (context, constraints) => SizedBox(
                    width: math.min(
                        constraints.maxWidth, constraints.maxHeight * aspect),
                    height: constraints.maxHeight,
                    child: image,
                  ));
        }
        return AspectRatio(aspectRatio: aspect, child: image);
      },
    );
  }

  Widget _buildImage(
      BuildContext context, WidgetRef ref, ValueChanged<double>? onAspectRatio,
      {double? shapeFallback, VoidCallback? onImageMissing}) {
    final fallbackAspectRatio = shapeFallback ?? this.fallbackAspectRatio;
    final url = normalizeNetworkImageUrl(imageUrl);

    // An entry's chosen local cover takes precedence over catalog artwork.
    var local = localBytes;
    var localLoading = false;
    if (local == null && libraryEntryRef != null) {
      final localAsync = ref.watch(
        localItemImageProvider((
          libraryEntryRef: libraryEntryRef!,
          imageType: localImageType,
        )),
      );
      local = localAsync.value;
      localLoading = !localAsync.hasValue && !localAsync.hasError;
    }

    // A panel waiting for its cover hears when this one is in.
    final loads = LibraryImageLoadGate.maybeOf(context);
    final loadKey = (libraryEntryRef, url, localImageType);
    if (loads != null) {
      if (localLoading || _looksLikeSupportedImage(local) || url != null) {
        loads.expect(loadKey);
      }
    }
    void loaded() => loads?.done(loadKey);
    Widget onFrame(BuildContext _, Widget child, int? frame, bool sync) {
      if (frame != null || sync) loaded();
      return child;
    }

    void showingFallback() {
      loaded();
      if (onImageMissing != null) {
        onImageMissing();
      } else {
        onAspectRatio?.call(fallbackAspectRatio);
      }
    }

    Widget reportingShape(Image image, {String? elementUrl}) {
      final report = onAspectRatio;
      return report == null
          ? image
          : _CoverAspectReporter(
              image: image.image,
              elementUrl: elementUrl,
              onAspectRatio: report,
              child: image,
            );
    }

    final fallbackCover = showPlaceholder
        ? Align(
            alignment: alignment,
            child: LibraryGeneratedCover(
              kind: libraryEntryRef?.kind ??
                  mediaKind ??
                  CatalogMediaKind.unknown,
              itemNumber: itemNumber,
              borderRadius: borderRadius,
              aspectRatio: fallbackAspectRatio,
              fit: fit,
              alignment: alignment,
            ),
          )
        : const SizedBox.expand();

    return LayoutBuilder(
      builder: (context, constraints) {
        final pixelRatio = MediaQuery.devicePixelRatioOf(context);
        final resolvedCacheWidth =
            targetCacheWidth ?? _resolveCacheWidth(constraints, pixelRatio);
        final cacheWidth = kIsWeb || resolvedCacheWidth == null
            ? null
            : libraryCoverDecodeWidth(loadKey, resolvedCacheWidth);

        // Prefer local offline bytes when available
        if (_looksLikeSupportedImage(local)) {
          final safeLocal = local!;
          return ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: reportingShape(Image.memory(
              safeLocal,
              fit: fit,
              alignment: alignment,
              cacheWidth: cacheWidth,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
              frameBuilder: onFrame,
              errorBuilder: (_, __, ___) {
                showingFallback();
                return fallbackCover;
              },
            )),
          );
        }
        if (url == null) {
          if (!localLoading) showingFallback();
          return fallbackCover;
        }
        if (kIsWeb) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: reportingShape(
              Image.network(
                url,
                // An `<img>` element keeps the address it was created with, so
                // another cover needs a new element.
                key: ValueKey(url),
                fit: fit,
                alignment: alignment,
                cacheWidth: null,
                gaplessPlayback: true,
                filterQuality: FilterQuality.medium,
                webHtmlElementStrategy: allowWebImageElement
                    ? WebHtmlElementStrategy.fallback
                    : WebHtmlElementStrategy.never,
                frameBuilder: onFrame,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) {
                    return child;
                  }
                  return _CoverLoadingShell(
                    borderRadius: borderRadius,
                  );
                },
                errorBuilder: (_, __, ___) {
                  showingFallback();
                  return fallbackCover;
                },
              ),
              elementUrl: url,
            ),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: CachedNetworkImage(
            cacheManager: libraryCoverCacheManager,
            imageUrl: url,
            fit: fit,
            alignment: alignment,
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
            placeholderFadeInDuration: Duration.zero,
            memCacheWidth: cacheWidth,
            placeholder: (_, __) => _CoverLoadingShell(
              borderRadius: borderRadius,
            ),
            errorWidget: (_, __, ___) {
              showingFallback();
              return fallbackCover;
            },
            imageBuilder: (_, imageProvider) {
              loaded();
              return reportingShape(Image(
                image: imageProvider,
                fit: fit,
                alignment: alignment,
                gaplessPlayback: true,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) {
                  showingFallback();
                  return fallbackCover;
                },
              ));
            },
          ),
        );
      },
    );
  }

  bool _looksLikeSupportedImage(Uint8List? bytes) {
    if (bytes == null || bytes.length < 12) {
      return false;
    }

    // PNG signature
    final isPng = bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A;
    if (isPng) {
      return true;
    }

    // JPEG SOI
    final isJpeg = bytes[0] == 0xFF && bytes[1] == 0xD8;
    if (isJpeg) {
      return true;
    }

    // GIF87a / GIF89a
    final isGif = bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38 &&
        (bytes[4] == 0x37 || bytes[4] == 0x39) &&
        bytes[5] == 0x61;
    if (isGif) {
      return true;
    }

    // WEBP: RIFF....WEBP
    final isWebp = bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50;
    return isWebp;
  }

  int? _resolveCacheWidth(
    BoxConstraints constraints,
    double pixelRatio,
  ) {
    if (!constraints.hasBoundedWidth || constraints.maxWidth <= 0) {
      return null;
    }
    return (constraints.maxWidth * pixelRatio).ceil();
  }
}

/// Reports the width / height of an image another widget is showing, through
/// the same cached stream, so nothing is fetched or decoded twice.
class _CoverAspectReporter extends StatefulWidget {
  const _CoverAspectReporter({
    required this.image,
    required this.elementUrl,
    required this.onAspectRatio,
    required this.child,
  });

  final ImageProvider image;

  /// The address to measure when the web app shows the image as an `<img>`
  /// element, whose pixels and size Flutter cannot read.
  final String? elementUrl;
  final ValueChanged<double> onAspectRatio;
  final Widget child;

  @override
  State<_CoverAspectReporter> createState() => _CoverAspectReporterState();
}

class _CoverAspectReporterState extends State<_CoverAspectReporter> {
  ImageStream? _stream;
  late final _listener =
      ImageStreamListener(_onImage, onError: (_, __) {/* Image shows it. */});

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant _CoverAspectReporter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) _resolve();
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    super.dispose();
  }

  void _resolve() {
    final stream = widget.image.resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _stream?.removeListener(_listener);
    _stream = stream..addListener(_listener);
  }

  void _onImage(ImageInfo info, bool _) {
    final elementUrl = widget.elementUrl;
    try {
      widget.onAspectRatio(info.image.width / info.image.height);
    } on UnsupportedError {
      if (elementUrl != null) _measureElement(elementUrl);
    }
    info.dispose();
  }

  Future<void> _measureElement(String url) async {
    final stream = _stream;
    final aspectRatio = await coverElementAspectRatio(url);
    if (aspectRatio != null && mounted && identical(stream, _stream)) {
      widget.onAspectRatio(aspectRatio);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Covers already measured, so one that scrolls back into view has its shape
/// from the first frame.
final _knownCoverAspectRatios = <Object, double>{};
const _kKnownCoverAspectRatioLimit = 4096;

/// Follows the shape of a cover, so what surrounds it (a tile's shadow and
/// active frame, a flow card) hugs the image and leaves no gaps beside it. The
/// builder has [fallbackAspectRatio] until the image reports through
/// `onAspectRatio`, which goes to the cover's image widget.
class LibraryCoverShape extends StatefulWidget {
  const LibraryCoverShape({
    required this.imageUrl,
    required this.libraryEntryRef,
    required this.fallbackAspectRatio,
    required this.builder,
    this.followsImage = true,
    this.imageType = 'front_cover',
    super.key,
  });

  final String? imageUrl;
  final LibraryEntryRef? libraryEntryRef;
  final double fallbackAspectRatio;

  /// Off for a cover in an opaque case of a fixed shape, such as a slab.
  final bool followsImage;
  final String imageType;
  final Widget Function(
    BuildContext context,
    double aspectRatio,
    ValueChanged<double> onAspectRatio,
  ) builder;

  @override
  State<LibraryCoverShape> createState() => _LibraryCoverShapeState();
}

class _LibraryCoverShapeState extends State<LibraryCoverShape> {
  double? _aspectRatio;

  Object get _coverKey =>
      (widget.libraryEntryRef, widget.imageUrl, widget.imageType);

  @override
  void initState() {
    super.initState();
    _aspectRatio = _knownCoverAspectRatios[_coverKey];
  }

  @override
  void didUpdateWidget(covariant LibraryCoverShape oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.libraryEntryRef != widget.libraryEntryRef ||
        oldWidget.imageType != widget.imageType) {
      _aspectRatio = _knownCoverAspectRatios[_coverKey];
    }
  }

  void _report(double aspectRatio) {
    if (!aspectRatio.isFinite || aspectRatio <= 0) return;
    final known = _knownCoverAspectRatios;
    known.remove(_coverKey);
    known[_coverKey] = aspectRatio;
    if (known.length > _kKnownCoverAspectRatioLimit) {
      known.remove(known.keys.first);
    }
    if (aspectRatio == _aspectRatio) return;
    void apply() {
      if (mounted) setState(() => _aspectRatio = aspectRatio);
    }

    // A cached image reports while its widget is still being built.
    if (WidgetsBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => apply());
    } else {
      apply();
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        widget.followsImage
            ? _aspectRatio ?? widget.fallbackAspectRatio
            : widget.fallbackAspectRatio,
        _report,
      );
}

class _CoverLoadingShell extends StatelessWidget {
  const _CoverLoadingShell({
    required this.borderRadius,
  });

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final base = palette.surfaceSubtle;
    final accent = Color.alphaBlend(
      palette.accent.withValues(alpha: palette.isDark ? 0.12 : 0.08),
      base,
    );
    final line = Color.alphaBlend(
      palette.divider.withValues(alpha: 0.9),
      base,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final fallbackWidth = constraints.hasBoundedWidth
            ? null
            : math.max(constraints.minWidth, 96.0).toDouble();
        final fallbackHeight = constraints.hasBoundedHeight
            ? null
            : math
                .max(
                  constraints.minHeight,
                  constraints.hasBoundedWidth
                      ? constraints.maxWidth
                      : fallbackWidth ?? 96.0,
                )
                .toDouble();
        return SizedBox(
          width: fallbackWidth,
          height: fallbackHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        base,
                        accent,
                        base,
                      ],
                    ),
                  ),
                ),
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.72,
                    heightFactor: 0.18,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: line,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LibraryInteractiveCover extends StatefulWidget {
  const LibraryInteractiveCover({
    required this.title,
    this.mediaKind,
    this.itemNumber,
    this.imageUrl,
    this.localBytes,
    this.targetCacheWidth,
    this.fallbackAspectRatio = 2 / 3,
    this.secondaryImageUrl,
    this.secondaryLocalBytes,
    this.libraryEntryRef,
    this.borderRadius = 4,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.accentColor = kAppAccent,
    this.enableFullscreen = true,
    this.enableHoverCue = true,
    this.enableSecondaryControl = true,
    this.showFrame = true,
    this.onMissingSecondaryPressed,
    this.onAspectRatio,
    super.key,
  });

  /// Hears the width / height of the front cover; see [LibraryCoverShape].
  final ValueChanged<double>? onAspectRatio;

  final String title;
  final CatalogMediaKind? mediaKind;
  final String? itemNumber;
  final String? imageUrl;
  final Uint8List? localBytes;
  final int? targetCacheWidth;
  final double fallbackAspectRatio;
  final String? secondaryImageUrl;
  final Uint8List? secondaryLocalBytes;
  final LibraryEntryRef? libraryEntryRef;
  final double borderRadius;
  final BoxFit fit;
  final Alignment alignment;
  final Color accentColor;
  final bool enableFullscreen;
  final bool enableHoverCue;
  final bool enableSecondaryControl;

  /// Draws the outlined, shadowed frame; tiles that own their shadow turn it off.
  final bool showFrame;
  final Future<void> Function()? onMissingSecondaryPressed;

  @override
  State<LibraryInteractiveCover> createState() =>
      _LibraryInteractiveCoverState();
}

class _LibraryInteractiveCoverState extends State<LibraryInteractiveCover> {
  bool _hovered = false;
  bool _showSecondary = false;
  bool _previewWarmRequested = false;

  @override
  void didUpdateWidget(covariant LibraryInteractiveCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    final coverChanged = oldWidget.libraryEntryRef != widget.libraryEntryRef ||
        oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.secondaryImageUrl != widget.secondaryImageUrl ||
        oldWidget.localBytes != widget.localBytes ||
        oldWidget.secondaryLocalBytes != widget.secondaryLocalBytes;
    if (coverChanged) {
      // Parent rebuild already redraws this widget; avoid an extra reset frame.
      _showSecondary = false;
      _hovered = false;
      _previewWarmRequested = false;
    }
  }

  bool get _hasSecondary {
    return (widget.secondaryLocalBytes?.isNotEmpty ?? false) ||
        (widget.secondaryImageUrl?.trim().isNotEmpty ?? false);
  }

  bool get _hasFront {
    return (widget.localBytes?.isNotEmpty ?? false) ||
        (widget.imageUrl?.trim().isNotEmpty ?? false) ||
        (widget.libraryEntryRef != null);
  }

  String? get _activeImageUrl =>
      _showSecondary ? widget.secondaryImageUrl : widget.imageUrl;

  Uint8List? get _activeLocalBytes =>
      _showSecondary ? widget.secondaryLocalBytes : widget.localBytes;

  bool get _canPreview {
    return widget.enableFullscreen && (_hasFront || _hasSecondary);
  }

  Future<void> _warmPreviewImage() async {
    // Skip eager precache here: malformed or stale URLs can trigger noisy
    // decode exceptions while the normal image widgets still fall back safely.
    return;
  }

  void _maybeWarmPreviewImage() {
    if (_previewWarmRequested || !_canPreview) {
      return;
    }
    _previewWarmRequested = true;
    unawaited(_warmPreviewImage());
  }

  Future<void> _openPreview() async {
    if (!_canPreview) {
      return;
    }
    _maybeWarmPreviewImage();
    if (!mounted) {
      return;
    }
    final size = MediaQuery.sizeOf(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final renderedAspectRatio =
        renderBox != null && renderBox.hasSize && renderBox.size.height > 0
            ? renderBox.size.width / renderBox.size.height
            : null;
    final coverAspectRatio = renderedAspectRatio != null &&
            renderedAspectRatio.isFinite &&
            renderedAspectRatio > 0
        ? renderedAspectRatio
        : widget.fallbackAspectRatio;
    final maxPreviewWidth = size.width * 0.92;
    final maxPreviewHeight = math.max(0.0,
        math.min(size.height * 0.92, size.height - kAppDialogTopInset - 24));
    final previewWidth = maxPreviewWidth < 420
        ? maxPreviewWidth
        : (size.width * 0.70).clamp(420.0, maxPreviewWidth);
    final previewHeight = maxPreviewHeight < 320
        ? maxPreviewHeight
        : (size.height * 0.70).clamp(320.0, maxPreviewHeight);
    final effectivePreviewWidth = math.max(0.0, previewWidth);
    final effectivePreviewHeight = math.max(0.0, previewHeight);
    var showBackOnly = _showSecondary;
    await showAppDialog<void>(
      context: context,
      barrierLabel: 'Close cover preview',
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 260),
      builder: (context) {
        return SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) {},
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        24, kAppDialogTopInset, 24, 24),
                    child: StatefulBuilder(
                      builder: (context, setDialogState) {
                        final contentWidth = effectivePreviewWidth - 28;
                        final contentHeight = effectivePreviewHeight - 28;
                        final hasExplicitFront =
                            (widget.localBytes?.isNotEmpty ?? false) ||
                                (widget.imageUrl?.trim().isNotEmpty ?? false);
                        final hasExplicitBack =
                            (widget.secondaryLocalBytes?.isNotEmpty ?? false) ||
                                (widget.secondaryImageUrl?.trim().isNotEmpty ??
                                    false);
                        final maxSideBySideCoverWidth = math.min(
                          (contentWidth - 12) / 2,
                          contentHeight * coverAspectRatio,
                        );
                        // Show both covers whenever each can remain readable.
                        const minReadableSideBySideCoverWidth = 150.0;
                        final showSideBySide = hasExplicitFront &&
                            hasExplicitBack &&
                            maxSideBySideCoverWidth >=
                                minReadableSideBySideCoverWidth;
                        final showSwitchBadges =
                            widget.enableSecondaryControl &&
                                hasExplicitFront &&
                                hasExplicitBack &&
                                !showSideBySide;

                        Widget buildCover({
                          required String? imageUrl,
                          required Uint8List? localBytes,
                          LibraryEntryRef? libraryEntryRef,
                        }) {
                          return AspectRatio(
                            aspectRatio: coverAspectRatio,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: LibraryCoverImage(
                                  title: widget.title,
                                  mediaKind: widget.mediaKind,
                                  itemNumber: widget.itemNumber,
                                  imageUrl: imageUrl,
                                  localBytes: localBytes,
                                  libraryEntryRef: libraryEntryRef,
                                  targetCacheWidth: widget.targetCacheWidth,
                                  fallbackAspectRatio:
                                      widget.fallbackAspectRatio,
                                  borderRadius: 0,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        }

                        final singleCover = buildCover(
                          imageUrl: showBackOnly
                              ? widget.secondaryImageUrl
                              : widget.imageUrl,
                          localBytes: showBackOnly
                              ? widget.secondaryLocalBytes
                              : widget.localBytes,
                          libraryEntryRef:
                              showBackOnly ? null : widget.libraryEntryRef,
                        );

                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: size.width * 0.92,
                            maxHeight: size.height * 0.92,
                          ),
                          child: SizedBox(
                            width: effectivePreviewWidth,
                            height: effectivePreviewHeight,
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Stack(
                                children: [
                                  Center(
                                    child: InteractiveViewer(
                                      minScale: 0.5,
                                      maxScale: 5,
                                      child: showSideBySide
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxHeight: contentHeight,
                                                    maxWidth:
                                                        (contentWidth - 12) / 2,
                                                  ),
                                                  child: buildCover(
                                                    imageUrl: widget.imageUrl,
                                                    localBytes:
                                                        widget.localBytes,
                                                    libraryEntryRef:
                                                        widget.libraryEntryRef,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxHeight: contentHeight,
                                                    maxWidth:
                                                        (contentWidth - 12) / 2,
                                                  ),
                                                  child: buildCover(
                                                    imageUrl: widget
                                                        .secondaryImageUrl,
                                                    localBytes: widget
                                                        .secondaryLocalBytes,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxHeight: contentHeight,
                                                maxWidth: math.min(
                                                  contentWidth,
                                                  contentHeight *
                                                      coverAspectRatio,
                                                ),
                                              ),
                                              child: singleCover,
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: LibrarySquareCloseButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ),
                                  if (showSwitchBadges)
                                    Positioned(
                                      left: 8,
                                      right: 8,
                                      bottom: 8,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _PreviewCoverSwitchBadge(
                                            label: 'Front',
                                            selected: !showBackOnly,
                                            accentColor: widget.accentColor,
                                            onPressed: () => setDialogState(
                                              () => showBackOnly = false,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          _PreviewCoverSwitchBadge(
                                            label: 'Back',
                                            selected: showBackOnly,
                                            accentColor: widget.accentColor,
                                            onPressed: () => setDialogState(
                                              () => showBackOnly = true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(curved),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.88, end: 1).animate(curved),
              child: child,
            ),
          ),
        );
      },
    );
    if (!mounted) {
      return;
    }
    setState(() => _showSecondary = showBackOnly);
  }

  Widget _wrapFrame(Widget child) => widget.showFrame
      ? _CoverFrame(borderRadius: widget.borderRadius, child: child)
      : child;

  @override
  Widget build(BuildContext context) {
    final interactive = _canPreview;
    final hoverCue = widget.enableHoverCue;
    final palette = appPalette(context);
    final controlBackground = Color.alphaBlend(
      widget.accentColor.withValues(alpha: 0.16),
      palette.surface.withValues(alpha: 0.94),
    );
    final controlForeground = appContrastingTextColor(controlBackground);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactHoverCue =
            constraints.maxWidth < 180 || constraints.maxHeight < 160;
        final canExpandInBothAxes =
            constraints.hasBoundedWidth && constraints.hasBoundedHeight;
        return MouseRegion(
          cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
          onEnter: hoverCue
              ? (_) {
                  _maybeWarmPreviewImage();
                  setState(() => _hovered = true);
                }
              : null,
          onExit: hoverCue ? (_) => setState(() => _hovered = false) : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: interactive ? _openPreview : null,
            child: Stack(
              fit: canExpandInBothAxes ? StackFit.expand : StackFit.loose,
              children: [
                _wrapFrame(
                  LibraryCoverImage(
                    title: widget.title,
                    mediaKind: widget.mediaKind,
                    itemNumber: widget.itemNumber,
                    imageUrl: _activeImageUrl,
                    localBytes: _activeLocalBytes,
                    libraryEntryRef: widget.libraryEntryRef,
                    targetCacheWidth: widget.targetCacheWidth,
                    fallbackAspectRatio: widget.fallbackAspectRatio,
                    borderRadius: widget.borderRadius,
                    fit: widget.fit,
                    alignment: widget.alignment,
                    onAspectRatio: _showSecondary ? null : widget.onAspectRatio,
                  ),
                ),
                if (interactive && hoverCue)
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: IgnorePointer(
                      ignoring: true,
                      child: Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 140),
                          opacity: _hovered ? 1 : 0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: controlBackground.withValues(alpha: 0.96),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color:
                                    widget.accentColor.withValues(alpha: 0.7),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: compactHoverCue ? 8 : 10,
                                vertical: compactHoverCue ? 4 : 5,
                              ),
                              child: compactHoverCue
                                  ? Icon(
                                      Icons.open_in_full,
                                      size: 14,
                                      color: widget.accentColor,
                                    )
                                  : FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.open_in_full,
                                            size: 14,
                                            color: widget.accentColor,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Fullscreen',
                                            style: TextStyle(
                                              color: controlForeground,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PreviewCoverSwitchBadge extends StatelessWidget {
  const _PreviewCoverSwitchBadge({
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final background = selected
        ? Color.alphaBlend(accentColor.withValues(alpha: 0.34), palette.surface)
        : Color.alphaBlend(accentColor.withValues(alpha: 0.1), palette.surface);
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 30),
        visualDensity: VisualDensity.compact,
        backgroundColor: background,
        foregroundColor: appContrastingTextColor(background),
        side: BorderSide(color: accentColor.withValues(alpha: 0.6)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _CoverFrame extends StatelessWidget {
  const _CoverFrame({
    required this.child,
    required this.borderRadius,
  });

  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius + 2),
        border: Border.all(
          color: palette.divider.withValues(alpha: 0.72),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(
                  alpha: palette.isDark ? 0.65 : 0.22,
                ),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius + 1),
        child: child,
      ),
    );
  }
}

/// The dark tile standing in for a missing cover: the item's kind icon,
/// plus the item number top left, clear of the tick box and status marks
/// along the bottom.
class LibraryGeneratedCover extends StatelessWidget {
  const LibraryGeneratedCover({
    required this.kind,
    this.itemNumber,
    this.borderRadius = 4,
    this.aspectRatio = 2 / 3,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    super.key,
  });

  final CatalogMediaKind kind;
  final String? itemNumber;
  final double borderRadius;
  final double aspectRatio;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final icon = defaultLibraryKindRegistry
            .tryGet(kind)
            ?.identity
            .coverPlaceholderIcon ??
        Icons.image_outlined;
    final palette = appPalette(context);
    final cover = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: ColoredBox(
        color: palette.panelRaised,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Icon(icon,
                  size: 72, color: palette.textMuted.withValues(alpha: .35)),
            ),
            if (itemNumber != null)
              Positioned(
                left: 6,
                top: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    child: Text(
                      '#$itemNumber',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.hasBoundedWidth && constraints.hasBoundedHeight) {
          // Fills the space it is given: loose constraints alone would leave
          // the box at its design size.
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: FittedBox(
              fit: fit,
              alignment: alignment,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: 180,
                height: 180 / aspectRatio,
                child: cover,
              ),
            ),
          );
        }
        if (!constraints.hasBoundedWidth && !constraints.hasBoundedHeight) {
          return SizedBox(
            width: 96,
            height: 96 / aspectRatio,
            child: cover,
          );
        }
        return AspectRatio(
          aspectRatio: aspectRatio,
          child: cover,
        );
      },
    );
  }
}
