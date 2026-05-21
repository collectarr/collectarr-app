import 'package:collectarr_app/ui/clz_style.dart';
import 'package:flutter/material.dart';

/// A draggable bottom sheet wrapper for the inspector on mobile.
/// Shows the inspector as a slide-up panel that can be swiped away.
class MobileInspectorSheet extends StatelessWidget {
  const MobileInspectorSheet({
    super.key,
    required this.child,
    required this.accent,
  });

  final Widget child;
  final Color accent;

  /// Show the inspector as a modal bottom sheet on mobile.
  static Future<void> show({
    required BuildContext context,
    required Widget inspector,
    required Color accent,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: kClzPanel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (_) => MobileInspectorSheet(
        accent: accent,
        child: inspector,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: kClzTextMuted.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Inspector content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: child,
          ),
        ),
      ],
    );
  }
}

/// A pull-to-refresh wrapper for the library grid on mobile.
class MobilePullToRefresh extends StatelessWidget {
  const MobilePullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    required this.accent,
  });

  final Widget child;
  final Future<void> Function() onRefresh;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: accent,
      backgroundColor: kClzPanel,
      child: child,
    );
  }
}

/// Responsive breakpoint helper.
class ResponsiveLayout {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;
}
