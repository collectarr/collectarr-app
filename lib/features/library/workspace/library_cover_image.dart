import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/features/collection/providers/local_cover_image_provider.dart';
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
    super.key,
  });

  final String title;
  final String? itemNumber;
  final String? imageUrl;
  final String? localBase64;
  final String? ownedItemId;
  final double borderRadius;

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
    // Prefer local offline bytes when available
    if (local != null && local.isNotEmpty) {
      try {
        final bytes = base64Decode(local);
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.memory(
            bytes,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => placeholder,
          ),
        );
      } catch (_) {
        // fall through to network
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
          fit: BoxFit.contain,
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
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
      ),
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

class LibraryInteractiveCover extends StatefulWidget {
  const LibraryInteractiveCover({
    required this.title,
    this.itemNumber,
    this.imageUrl,
    this.localBase64,
    this.ownedItemId,
    this.borderRadius = 4,
    this.accentColor = const Color(0xFF10A8D8),
    this.enableFullscreen = true,
    this.enableHoverCue = true,
    super.key,
  });

  final String title;
  final String? itemNumber;
  final String? imageUrl;
  final String? localBase64;
  final String? ownedItemId;
  final double borderRadius;
  final Color accentColor;
  final bool enableFullscreen;
  final bool enableHoverCue;

  @override
  State<LibraryInteractiveCover> createState() =>
      _LibraryInteractiveCoverState();
}

class _LibraryInteractiveCoverState extends State<LibraryInteractiveCover> {
  bool _hovered = false;

  bool get _canPreview {
    return widget.enableFullscreen &&
        ((widget.imageUrl?.trim().isNotEmpty ?? false) ||
            (widget.localBase64?.trim().isNotEmpty ?? false) ||
            (widget.ownedItemId?.trim().isNotEmpty ?? false));
  }

  Future<void> _openPreview() async {
    if (!_canPreview) {
      return;
    }
    final size = MediaQuery.sizeOf(context);
    final previewWidth = (size.width * 0.55).clamp(280.0, 720.0);
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xE6101010),
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: size.width * 0.92,
            maxHeight: size.height * 0.92,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5,
              child: Center(
                child: SizedBox(
                  width: previewWidth,
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: LibraryCoverImage(
                      title: widget.title,
                      itemNumber: widget.itemNumber,
                      imageUrl: widget.imageUrl,
                      localBase64: widget.localBase64,
                      ownedItemId: widget.ownedItemId,
                      borderRadius: 10,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final interactive = _canPreview;
    final hoverCue = interactive && widget.enableHoverCue;
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
            fit: StackFit.expand,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 170),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
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
                clipBehavior: Clip.antiAlias,
                child: LibraryCoverImage(
                  title: widget.title,
                  itemNumber: widget.itemNumber,
                  imageUrl: widget.imageUrl,
                  localBase64: widget.localBase64,
                  ownedItemId: widget.ownedItemId,
                  borderRadius: widget.borderRadius,
                ),
              ),
              IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 170),
                  opacity: _hovered ? 1 : 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
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
                              color: widget.accentColor.withValues(alpha: 0.7),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
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
            ],
          ),
        ),
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
    return ClipRRect(
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
                            ? const Color(0xFF1D1D1D)
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
  }
}
