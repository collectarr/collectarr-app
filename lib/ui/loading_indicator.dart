import 'package:flutter/material.dart';

/// Centered loading spinner for use in `AsyncValue.when(loading: ...)`.
///
/// Provides a single place to adjust the loading appearance across the app
/// (e.g. swap to skeleton/shimmer later).
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.strokeWidth = 4.0});

  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(strokeWidth: strokeWidth),
    );
  }
}
