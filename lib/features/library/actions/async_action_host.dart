import 'dart:async';

import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:flutter/material.dart';

import 'async_action_executor.dart';

typedef AsyncActionRun = void Function(
  String label,
  FutureOr<void> Function() action, {
  AsyncActionErrorHandler? onError,
});

/// Shares busy, repeat-submit and error handling across menus and buttons.
class AsyncActionHost extends StatefulWidget {
  const AsyncActionHost({super.key, required this.builder});

  final Widget Function(BuildContext context, bool busy, AsyncActionRun run)
      builder;

  @override
  State<AsyncActionHost> createState() => _AsyncActionHostState();
}

class _AsyncActionHostState extends State<AsyncActionHost> {
  late final _executor = AsyncActionExecutor()..addListener(_changed);

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _executor.dispose();
    super.dispose();
  }

  void _run(String label, FutureOr<void> Function() action,
      {AsyncActionErrorHandler? onError}) {
    if (!mounted) return;
    final actionContext = context;
    unawaited(_executor.run(action, onError: (error, stack) {
      logRecoverableError(
          source: 'actions',
          message: '$label failed',
          error: error,
          stackTrace: stack);
      if (onError != null) {
        onError(error, stack);
      } else if (actionContext.mounted) {
        ScaffoldMessenger.maybeOf(actionContext)?.showSnackBar(
          SnackBar(content: Text('$label failed: $error')),
        );
      }
    }));
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _executor.isRunning, _run);
}
