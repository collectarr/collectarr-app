import 'dart:math' as math;

import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/ui/theme/theme_palette.dart';
import 'package:flutter/material.dart';

/// Values shared by Add widgets; platform selection stays at this boundary.
class LibraryAddPresentationTokens {
  const LibraryAddPresentationTokens._({
    required this.gridMinimumWidth,
    required this.captionLines,
    required this.borderedCover,
    required this.badgeFillsRow,
    required this.confirmHeaderHeight,
    required this.confirmInset,
    required this.confirmCloseButton,
    required this.toolbarVerticalPadding,
    required this.toolbarHeight,
    required this.tintedToolbar,
    required this.searchOnCanvas,
  });

  static const desktop = LibraryAddPresentationTokens._(
    gridMinimumWidth: 173,
    captionLines: 1,
    borderedCover: false,
    badgeFillsRow: false,
    confirmHeaderHeight: 38,
    confirmInset: 10,
    confirmCloseButton: false,
    toolbarVerticalPadding: 0,
    toolbarHeight: 38,
    tintedToolbar: false,
    searchOnCanvas: false,
  );

  static const mobile = LibraryAddPresentationTokens._(
    gridMinimumWidth: 125,
    captionLines: 2,
    borderedCover: true,
    badgeFillsRow: true,
    confirmHeaderHeight: 48,
    confirmInset: 0,
    confirmCloseButton: true,
    toolbarVerticalPadding: 4,
    toolbarHeight: null,
    tintedToolbar: true,
    searchOnCanvas: true,
  );

  static LibraryAddPresentationTokens get current =>
      appPresentationPlatform.isNativeMobile ? mobile : desktop;

  final double gridMinimumWidth;
  final int captionLines;
  final bool borderedCover;
  final bool badgeFillsRow;
  final double confirmHeaderHeight;
  final double confirmInset;
  final bool confirmCloseButton;
  final double toolbarVerticalPadding;
  final double? toolbarHeight;
  final bool tintedToolbar;
  final bool searchOnCanvas;

  Color? toolbarColor(AppThemePalette palette) =>
      tintedToolbar ? mobileGroupHeaderColor(palette) : null;

  Color mobileGroupHeaderColor(AppThemePalette palette) =>
      palette.isDark ? const Color(0xff29464f) : const Color(0xffd4e8ef);

  Color searchBackground(AppThemePalette palette) => searchOnCanvas
      ? palette.canvas
      : palette.isDark
          ? const Color(0xff595e67)
          : palette.panel;

  double confirmHorizontalInset(BoxConstraints constraints, Size? fixed) {
    if (confirmInset == 0 || fixed == null) return confirmInset;
    return math.max(confirmInset, (constraints.maxWidth - fixed.width) / 2);
  }
}
