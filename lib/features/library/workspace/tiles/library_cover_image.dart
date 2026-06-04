import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/features/collection/providers/local_cover_image_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryCoverImage extends ConsumerWidget {
  const LibraryCoverImage({
    required this.title,
    this.itemNumber,
    this.imageUrl,
    this.localBytes,
    this.ownedItemId,
    this.borderRadius = 4,
    this.fit = BoxFit.contain,
    super.key,
  });

  final String title;
  final String? itemNumber;
  final String? imageUrl;
  final Uint8List? localBytes;
  final String? ownedItemId;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = _normalizedImageUrl(imageUrl);

    // Resolve local image: prefer explicit local bytes; query DB only when
    // there is no usable remote URL to avoid first-load source swapping.
    var local = localBytes;
    if (local == null && ownedItemId != null && url == null) {
      local = ref.watch(localCoverImageProvider(ownedItemId!)).value;
    }

    final placeholder = LibraryGeneratedCover(
      title: title,
      itemNumber: itemNumber,
      borderRadius: borderRadius,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final pixelRatio = MediaQuery.devicePixelRatioOf(context);
        // Quantize to 32-pixel steps to keep sharper cover caches while
        // still avoiding excessive re-decodes during layout resizing.
        final resolvedCacheWidth =
            constraints.hasBoundedWidth && constraints.maxWidth > 0
                ? (((constraints.maxWidth * pixelRatio) / 32).ceil() * 32)
                : null;
        final cacheWidth = kIsWeb ? null : resolvedCacheWidth;

        // Prefer local offline bytes when available
        if (_looksLikeSupportedImage(local)) {
          final safeLocal = local!;
          return ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Image.memory(
              safeLocal,
              fit: fit,
              cacheWidth: cacheWidth,
              gaplessPlayback: true,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => placeholder,
            ),
          );
        }
        if (url == null) {
          return placeholder;
        }
        if (kIsWeb) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Image.network(
              url,
              fit: fit,
              // Keep a stable decoded image across layout switches.
              cacheWidth: null,
              gaplessPlayback: true,
              filterQuality: FilterQuality.high,
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              errorBuilder: (_, __, ___) => placeholder,
            ),
          );
        }
        final provider = CachedNetworkImageProvider(url);
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image(
            image: provider,
            fit: fit,
            gaplessPlayback: true,
            filterQuality: FilterQuality.high,
            frameBuilder: (context, child, _, __) => child,
            errorBuilder: (_, __, ___) => placeholder,
          ),
        );
      },
    );
  }

  String? _normalizedImageUrl(String? value) {
    final url = value?.trim();
    if (url == null || url.isEmpty) {
      return null;
    }
    final parsed = Uri.tryParse(url);
    if (parsed == null || !parsed.hasScheme) {
      return null;
    }
    if (parsed.scheme != 'http' && parsed.scheme != 'https') {
      return null;
    }
    return url;
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
}

/// Wraps a cover image in a slab-style frame for graded comics (CGC/CBCS).
class SlabFrameOverlay extends StatelessWidget {
  const SlabFrameOverlay({
    required this.child,
    required this.gradingCompany,
    required this.grade,
    this.labelType,
    super.key,
  });

  static Widget maybeWrap({
    required String? rawOrSlabbed,
    required String? gradingCompany,
    required String? grade,
    required String? labelType,
    required Widget child,
  }) {
    if (rawOrSlabbed?.toLowerCase() != 'slabbed') return child;
    if (gradingCompany == null || grade == null) return child;
    return SlabFrameOverlay(
      gradingCompany: gradingCompany,
      grade: grade,
      labelType: labelType,
      child: child,
    );
  }

  final Widget child;
  final String gradingCompany;
  final String grade;
  final String? labelType;

  /// Returns the label color for the grading company.
  Color get _labelColor {
    final company = gradingCompany.toUpperCase();
    if (company.contains('CGC')) return const Color(0xFF1565C0);
    if (company.contains('CBCS')) return const Color(0xFF2E7D32);
    if (company.contains('PGX')) return const Color(0xFF6A1B9A);
    return const Color(0xFF37474F);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 60;
        final labelHeight = isCompact ? 14.0 : 20.0;
        final gradeSize = isCompact ? 8.0 : 11.0;
        final companySize = isCompact ? 7.0 : 9.0;
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            border: Border.all(
              color: _labelColor.withValues(alpha: 0.8),
              width: isCompact ? 1.5 : 2.5,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Column(
            children: [
              // Slab label header
              Container(
                width: double.infinity,
                height: labelHeight,
                decoration: BoxDecoration(
                  color: _labelColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(1.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        gradingCompany.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: companySize,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(width: isCompact ? 3 : 6),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 2 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        grade,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: gradeSize,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Cover image
              Expanded(child: child),
              // Bottom bar with label type
              if (labelType != null && !isCompact)
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _labelColor.withValues(alpha: 0.7),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(1.5),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labelType!.toUpperCase(),
                    style: TextStyle(
                      color:
                          ThemeData.estimateBrightnessForColor(_labelColor) ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class LibraryInteractiveCover extends StatefulWidget {
  const LibraryInteractiveCover({
    required this.title,
    this.itemNumber,
    this.imageUrl,
    this.localBytes,
    this.secondaryImageUrl,
    this.secondaryLocalBytes,
    this.ownedItemId,
    this.borderRadius = 4,
    this.accentColor = kAppAccent,
    this.enableFullscreen = true,
    this.enableHoverCue = true,
    this.enableSecondaryControl = true,
    this.onMissingSecondaryPressed,
    super.key,
  });

  final String title;
  final String? itemNumber;
  final String? imageUrl;
  final Uint8List? localBytes;
  final String? secondaryImageUrl;
  final Uint8List? secondaryLocalBytes;
  final String? ownedItemId;
  final double borderRadius;
  final Color accentColor;
  final bool enableFullscreen;
  final bool enableHoverCue;
  final bool enableSecondaryControl;
  final Future<void> Function()? onMissingSecondaryPressed;

  @override
  State<LibraryInteractiveCover> createState() =>
      _LibraryInteractiveCoverState();
}

class _LibraryInteractiveCoverState extends State<LibraryInteractiveCover> {
  bool _hovered = false;
  bool _showSecondary = false;

  @override
  void didUpdateWidget(covariant LibraryInteractiveCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    final coverChanged = oldWidget.ownedItemId != widget.ownedItemId ||
        oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.secondaryImageUrl != widget.secondaryImageUrl ||
        oldWidget.localBytes != widget.localBytes ||
        oldWidget.secondaryLocalBytes != widget.secondaryLocalBytes;
    if (coverChanged) {
      // Parent rebuild already redraws this widget; avoid an extra reset frame.
      _showSecondary = false;
      _hovered = false;
    }
  }

  bool get _hasSecondary {
    return (widget.secondaryLocalBytes?.isNotEmpty ?? false) ||
        (widget.secondaryImageUrl?.trim().isNotEmpty ?? false);
  }

  bool get _hasFront {
    return (widget.localBytes?.isNotEmpty ?? false) ||
        (widget.imageUrl?.trim().isNotEmpty ?? false) ||
        (widget.ownedItemId?.trim().isNotEmpty ?? false);
  }

  String? get _activeImageUrl =>
      _showSecondary ? widget.secondaryImageUrl : widget.imageUrl;

  Uint8List? get _activeLocalBytes =>
      _showSecondary ? widget.secondaryLocalBytes : widget.localBytes;

  bool get _canPreview {
    return widget.enableFullscreen && (_hasFront || _hasSecondary);
  }

  Future<void> _warmPreviewImage() async {
    if (!mounted) {
      return;
    }
    for (final imageUrl in [
      widget.imageUrl?.trim(),
      widget.secondaryImageUrl?.trim()
    ]) {
      if (imageUrl == null || imageUrl.isEmpty) {
        continue;
      }
      try {
        await precacheImage(NetworkImage(imageUrl), context);
      } catch (error, stackTrace) {
        logRecoverableError(
          source: 'library_cover_image',
          message: 'Failed to precache cover preview image.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  Future<void> _openPreview() async {
    if (!_canPreview) {
      return;
    }
    await _warmPreviewImage();
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
        : (2 / 3);
    final maxPreviewWidth = size.width * 0.92;
    final maxPreviewHeight = size.height * 0.92;
    final previewWidth = maxPreviewWidth < 420
        ? maxPreviewWidth
        : (size.width * 0.70).clamp(420.0, maxPreviewWidth);
    final previewHeight = maxPreviewHeight < 320
        ? maxPreviewHeight
        : (size.height * 0.70).clamp(320.0, maxPreviewHeight);
    final effectivePreviewWidth = math.max(0.0, previewWidth);
    final effectivePreviewHeight = math.max(0.0, previewHeight);
    var showBackOnly = _showSecondary;
    await showGeneralDialog<void>(
      context: context,
      barrierLabel: 'Close cover preview',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) => Navigator.of(context).pop(),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
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
                          String? ownedItemId,
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
                                  itemNumber: widget.itemNumber,
                                  imageUrl: imageUrl,
                                  localBytes: localBytes,
                                  ownedItemId: ownedItemId,
                                  borderRadius: 0,
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
                          ownedItemId: showBackOnly ? null : widget.ownedItemId,
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
                                                    ownedItemId:
                                                        widget.ownedItemId,
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

  @override
  Widget build(BuildContext context) {
    final interactive = _canPreview;
    final hoverCue = widget.enableHoverCue;
    final palette = appPalette(context);
    final controlBackground = Color.alphaBlend(
      widget.accentColor.withValues(alpha: 0.16),
      palette.surface.withValues(alpha: 0.94),
    );
    final controlForeground =
        ThemeData.estimateBrightnessForColor(controlBackground) ==
                Brightness.dark
            ? Colors.white
            : palette.textPrimary;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactHoverCue =
            constraints.maxWidth < 180 || constraints.maxHeight < 160;
        return MouseRegion(
          cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
          onEnter: hoverCue ? (_) => setState(() => _hovered = true) : null,
          onExit: hoverCue ? (_) => setState(() => _hovered = false) : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: interactive ? _openPreview : null,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 170),
              curve: Curves.easeOutCubic,
              scale: _hovered ? 1.02 : 1,
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 170),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        widget.borderRadius + 8,
                      ),
                      boxShadow: [
                        if (_hovered)
                          BoxShadow(
                            color: widget.accentColor.withValues(alpha: 0.28),
                            blurRadius: 18,
                            spreadRadius: 1.5,
                            offset: const Offset(0, 6),
                          ),
                      ],
                    ),
                    child: _CoverFrame(
                      borderRadius: widget.borderRadius,
                      child: LibraryCoverImage(
                        title: widget.title,
                        itemNumber: widget.itemNumber,
                        imageUrl: _activeImageUrl,
                        localBytes: _activeLocalBytes,
                        ownedItemId: widget.ownedItemId,
                        borderRadius: widget.borderRadius,
                      ),
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
                                color:
                                    controlBackground.withValues(alpha: 0.96),
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
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
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
        foregroundColor: selected ? Colors.white : palette.textPrimary,
        side: BorderSide(color: accentColor.withValues(alpha: 0.6)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
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

class LibraryGeneratedCover extends StatelessWidget {
  const LibraryGeneratedCover({
    required this.title,
    this.itemNumber,
    this.borderRadius = 4,
    super.key,
  });

  final String title;
  final String? itemNumber;
  final double borderRadius;

  static const _palettes = [
    (Color(0xFF145DA0), Color(0xFFB1D4E0), Color(0xFFFFFFFF)),
    (Color(0xFFB22222), Color(0xFFFFD166), Color(0xFFFFFFFF)),
    (Color(0xFF2D6A4F), Color(0xFF95D5B2), Color(0xFFFFFFFF)),
    (Color(0xFF3D348B), Color(0xFFF7B801), Color(0xFFFFFFFF)),
    (Color(0xFF22223B), Color(0xFFC9ADA7), Color(0xFFFFFFFF)),
    (Color(0xFF7F5539), Color(0xFFE6CCB2), Color(0xFF201A16)),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = _palettes[title.hashCode.abs() % _palettes.length];
    final displayTitle = title.replaceAll(', Vol.', '\nVol.');
    final cover = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(color: palette.$1),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(height: 18, color: palette.$2),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(height: 28, color: const Color(0x33000000)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 34),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 86,
                  child: Text(
                    displayTitle,
                    maxLines: 4,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.$3,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 0.95,
                    ),
                  ),
                ),
              ),
            ),
            if (itemNumber != null)
              Positioned(
                right: 6,
                bottom: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.$2,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    child: Text(
                      '#$itemNumber',
                      style: TextStyle(
                        color: palette.$3 == const Color(0xFFFFFFFF)
                            ? kAppPanel
                            : palette.$3,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
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
        if (constraints.hasBoundedHeight) {
          return cover;
        }
        return AspectRatio(
          aspectRatio: 2 / 3,
          child: cover,
        );
      },
    );
  }
}
