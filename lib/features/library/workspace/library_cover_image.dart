import 'dart:convert';

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
    this.localBase64,
    this.ownedItemId,
    this.borderRadius = 4,
    this.fit = BoxFit.contain,
    super.key,
  });

  final String title;
  final String? itemNumber;
  final String? imageUrl;
  final String? localBase64;
  final String? ownedItemId;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Resolve local image: prefer explicit localBase64, then look up from DB.
    var local = localBase64;
    if (local == null && ownedItemId != null) {
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
      final cacheWidth = constraints.hasBoundedWidth &&
        constraints.maxWidth > 0
          ? (constraints.maxWidth * pixelRatio).ceil()
            : null;

    // Prefer local offline bytes when available
    if (local != null && local.isNotEmpty) {
      try {
        final bytes = base64Decode(local);
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.memory(
            bytes,
            fit: fit,
            cacheWidth: cacheWidth,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => placeholder,
          ),
        );
      } catch (error, stackTrace) {
        logRecoverableError(
          source: 'library_cover_image',
          message:
              'Failed to decode local cover image; falling back to network image.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    final url = _normalizedImageUrl(imageUrl);
    if (url == null) {
      return placeholder;
    }
    if (kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          url,
          key: ValueKey(url),
          fit: fit,
          cacheWidth: cacheWidth,
          filterQuality: FilterQuality.medium,
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
          loadingBuilder: (context, child, loadingProgress) {
            return loadingProgress == null ? child : placeholder;
          },
          errorBuilder: (_, __, ___) => placeholder,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        key: ValueKey(url),
        imageUrl: url,
        fit: fit,
        memCacheWidth: cacheWidth,
        filterQuality: FilterQuality.medium,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
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
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 7,
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
    this.localBase64,
    this.secondaryImageUrl,
    this.secondaryLocalBase64,
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
  final String? localBase64;
  final String? secondaryImageUrl;
  final String? secondaryLocalBase64;
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

  bool get _showSecondaryControl {
    if (!widget.enableSecondaryControl) {
      return false;
    }
    return _hasSecondary || (widget.ownedItemId?.trim().isNotEmpty ?? false);
  }

  bool get _hasSecondary {
    return (widget.secondaryLocalBase64?.trim().isNotEmpty ?? false) ||
        (widget.secondaryImageUrl?.trim().isNotEmpty ?? false);
  }

  String? get _activeImageUrl =>
      _showSecondary ? widget.secondaryImageUrl : widget.imageUrl;

  String? get _activeLocalBase64 =>
      _showSecondary ? widget.secondaryLocalBase64 : widget.localBase64;

  bool get _canPreview {
    return widget.enableFullscreen &&
        ((_activeImageUrl?.trim().isNotEmpty ?? false) ||
            (_activeLocalBase64?.trim().isNotEmpty ?? false) ||
            (widget.ownedItemId?.trim().isNotEmpty ?? false));
  }

  Future<void> _openPreview() async {
    if (!_canPreview) {
      return;
    }
    final size = MediaQuery.sizeOf(context);
    final previewWidth = (size.width * 0.55).clamp(280.0, 720.0);
    final previewHeight = (size.height * 0.88).clamp(280.0, 1200.0);
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
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: size.width * 0.92,
                      maxHeight: size.height * 0.92,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: previewWidth,
                            maxHeight: previewHeight,
                          ),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {},
                            child: InteractiveViewer(
                              minScale: 0.5,
                              maxScale: 5,
                              child: LibraryCoverImage(
                                title: widget.title,
                                itemNumber: widget.itemNumber,
                                imageUrl: _activeImageUrl,
                                localBase64: _activeLocalBase64,
                                ownedItemId: widget.ownedItemId,
                                borderRadius: 0,
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
  }

  Future<void> _handleSecondaryPressed() async {
    if (_hasSecondary) {
      setState(() => _showSecondary = !_showSecondary);
      return;
    }
    if (widget.onMissingSecondaryPressed != null) {
      await widget.onMissingSecondaryPressed!();
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('No back cover is saved for this item yet.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final interactive = _canPreview;
    final hoverCue = widget.enableHoverCue;
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
                        localBase64: _activeLocalBase64,
                        ownedItemId: widget.ownedItemId,
                        borderRadius: widget.borderRadius,
                      ),
                    ),
                  ),
                  if (_showSecondaryControl)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: FilledButton.tonalIcon(
                        onPressed: () {
                          _handleSecondaryPressed();
                        },
                        icon: Icon(
                          _hasSecondary
                              ? (_showSecondary
                                  ? Icons.flip_to_front_outlined
                                  : Icons.flip_to_back_outlined)
                              : Icons.photo_library_outlined,
                          size: 14,
                        ),
                        label: Text(
                          _hasSecondary
                              ? (_showSecondary ? 'View front' : 'View back')
                              : 'Back cover',
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: const Color(0xD0101010),
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: widget.accentColor.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                    ),
                  if (interactive)
                    IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 170),
                        opacity: _hovered ? 1 : 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              widget.borderRadius + 8,
                            ),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x00000000),
                                Color(0x22000000),
                                Color(0xCC030303),
                              ],
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: const Color(0xCC050505),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: widget.accentColor
                                        .withValues(alpha: 0.7),
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
                                              const Text(
                                                'Open cover',
                                                style: TextStyle(
                                                  color: Colors.white,
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

class _CoverFrame extends StatelessWidget {
  const _CoverFrame({
    required this.child,
    required this.borderRadius,
  });

  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius + 2),
        border: Border.all(
          color: const Color(0x90FFFFFF),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xA6000000),
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
