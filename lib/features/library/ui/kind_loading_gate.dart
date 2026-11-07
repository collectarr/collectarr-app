import 'package:collectarr_app/ui/app_spinner.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The shelf's loading screen.
class LibraryShelfLoading extends StatelessWidget {
  const LibraryShelfLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return AppLoadingPlaceholder(
      label: 'Loading...',
      color: palette.isDark ? const Color(0xffdddddd) : palette.textSecondary,
      fontWeight: FontWeight.w400,
    );
  }
}

/// Shows the loading screen for one frame whenever [kind] changes, then builds
/// the kind's page: that build is slow enough to otherwise look frozen.
class LibraryKindLoadingGate extends StatefulWidget {
  const LibraryKindLoadingGate({
    super.key,
    required this.kind,
    required this.builder,
  });

  final String kind;
  final WidgetBuilder builder;

  @override
  State<LibraryKindLoadingGate> createState() => _LibraryKindLoadingGateState();
}

class _LibraryKindLoadingGateState extends State<LibraryKindLoadingGate> {
  String? _readyKind;
  String? _pendingKind;

  @override
  Widget build(BuildContext context) {
    final kind = widget.kind;
    if (kind == _readyKind) {
      _pendingKind = null;
      return widget.builder(context);
    }
    if (_pendingKind != kind) {
      _pendingKind = kind;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pendingKind == kind) {
          setState(() => _readyKind = kind);
        }
      });
    }
    return const LibraryShelfLoading();
  }
}
