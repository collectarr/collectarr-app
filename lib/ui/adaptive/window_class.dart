import 'package:flutter/material.dart';

/// Standard Material 3 window width size classes.
enum WindowWidthClass {
  /// Phones in portrait, small devices (< 600 dp).
  compact,

  /// Small tablets, foldables, large phones in landscape (600 - 839 dp).
  medium,

  /// Large tablets, foldables unfolded, smaller desktop windows (840 - 1199 dp).
  expanded,

  /// Standard desktop windows, laptops (1200 - 1599 dp).
  large,

  /// Ultra-wide screens and 4K displays (>= 1600 dp).
  extraLarge;

  bool get isCompact => this == WindowWidthClass.compact;
  bool get isMedium => this == WindowWidthClass.medium;
  bool get isExpanded => this == WindowWidthClass.expanded;
  bool get isLarge => this == WindowWidthClass.large;
  bool get isExtraLarge => this == WindowWidthClass.extraLarge;

  bool get isCompactOrMedium => index <= WindowWidthClass.medium.index;
  bool get isExpandedOrGreater => index >= WindowWidthClass.expanded.index;
  bool get isLargeOrGreater => index >= WindowWidthClass.large.index;
}

/// Standard Material 3 window height size classes.
enum WindowHeightClass {
  /// Landscape phones, compact vertical displays (< 480 dp).
  compact,

  /// Typical phone portrait, tablets, laptops (480 - 899 dp).
  medium,

  /// Tall desktop windows, vertical monitors (>= 900 dp).
  expanded;

  bool get isCompact => this == WindowHeightClass.compact;
  bool get isMedium => this == WindowHeightClass.medium;
  bool get isExpanded => this == WindowHeightClass.expanded;
}

/// Representation of the current window configuration for adaptive UI layouts.
@immutable
class AppWindowClass {
  const AppWindowClass({
    required this.widthClass,
    required this.heightClass,
    required this.size,
  });

  /// Window width breakpoint boundaries (in logical pixels / dp).
  static const double compactMaxWidth = 600.0;
  static const double mediumMaxWidth = 840.0;
  static const double expandedMaxWidth = 1200.0;
  static const double largeMaxWidth = 1600.0;

  /// Window height breakpoint boundaries (in logical pixels / dp).
  static const double compactMaxHeight = 480.0;
  static const double mediumMaxHeight = 900.0;

  final WindowWidthClass widthClass;
  final WindowHeightClass heightClass;
  final Size size;

  /// Compute window class from logical screen [size].
  factory AppWindowClass.fromSize(Size size) {
    final width = size.width;
    final height = size.height;

    final WindowWidthClass widthClass;
    if (width < compactMaxWidth) {
      widthClass = WindowWidthClass.compact;
    } else if (width < mediumMaxWidth) {
      widthClass = WindowWidthClass.medium;
    } else if (width < expandedMaxWidth) {
      widthClass = WindowWidthClass.expanded;
    } else if (width < largeMaxWidth) {
      widthClass = WindowWidthClass.large;
    } else {
      widthClass = WindowWidthClass.extraLarge;
    }

    final WindowHeightClass heightClass;
    if (height < compactMaxHeight) {
      heightClass = WindowHeightClass.compact;
    } else if (height < mediumMaxHeight) {
      heightClass = WindowHeightClass.medium;
    } else {
      heightClass = WindowHeightClass.expanded;
    }

    return AppWindowClass(
      widthClass: widthClass,
      heightClass: heightClass,
      size: size,
    );
  }

  /// Compute window class from layout [constraints].
  factory AppWindowClass.fromConstraints(BoxConstraints constraints) {
    return AppWindowClass.fromSize(
      Size(
        constraints.hasBoundedWidth ? constraints.maxWidth : double.infinity,
        constraints.hasBoundedHeight ? constraints.maxHeight : double.infinity,
      ),
    );
  }

  /// Retrieve the [AppWindowClass] from the nearest [MediaQuery] in the widget tree.
  static AppWindowClass of(BuildContext context) {
    return AppWindowClass.fromSize(MediaQuery.sizeOf(context));
  }

  /// Safely retrieve the [AppWindowClass] if [MediaQuery] is available.
  static AppWindowClass? maybeOf(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) {
      return null;
    }
    return AppWindowClass.fromSize(mediaQuery.size);
  }

  // Convenience width getters
  bool get isCompact => widthClass.isCompact;
  bool get isMedium => widthClass.isMedium;
  bool get isExpanded => widthClass.isExpanded;
  bool get isLarge => widthClass.isLarge;
  bool get isExtraLarge => widthClass.isExtraLarge;

  bool get isCompactOrMedium => widthClass.isCompactOrMedium;
  bool get isExpandedOrGreater => widthClass.isExpandedOrGreater;
  bool get isLargeOrGreater => widthClass.isLargeOrGreater;

  // Semantic layout queries
  bool get isMobile => isCompact;
  bool get isTablet => isMedium || isExpanded;
  bool get isDesktop => isExpandedOrGreater;

  /// Whether navigation should be presented as a bottom navigation bar.
  bool get showBottomNav => isCompact;

  /// Whether navigation should be presented as a compact navigation rail.
  bool get showNavRail => isMedium || isExpanded;

  /// Whether navigation should be presented as an expanded navigation drawer/sidebar.
  bool get showNavDrawer => isLargeOrGreater;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppWindowClass &&
          runtimeType == other.runtimeType &&
          widthClass == other.widthClass &&
          heightClass == other.heightClass &&
          size == other.size;

  @override
  int get hashCode => Object.hash(widthClass, heightClass, size);

  @override
  String toString() =>
      'AppWindowClass(widthClass: $widthClass, heightClass: $heightClass, size: $size)';
}

/// A widget that builds its child dynamically based on the ambient [AppWindowClass].
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, AppWindowClass windowClass)
      builder;

  @override
  Widget build(BuildContext context) {
    final windowClass = AppWindowClass.of(context);
    return builder(context, windowClass);
  }
}
