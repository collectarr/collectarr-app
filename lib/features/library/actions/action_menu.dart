import 'dart:async';

import 'package:flutter/material.dart';

import 'ui_action.dart';

/// Generic host for a set of actions contributed by one typed context.
///
/// The host owns popup rendering and error forwarding. It only evaluates the
/// structural action contract; it never reads semantic fields from [TContext].
class ActionMenu<TContext> extends StatelessWidget {
  const ActionMenu({
    super.key,
    required this.contextValue,
    required this.actions,
    required this.placement,
    this.tooltip = 'More actions',
    this.icon = Icons.more_horiz,
    this.onActionError,
  });

  final TContext contextValue;
  final List<UiAction<TContext>> actions;
  final UiActionPlacement placement;
  final String tooltip;
  final IconData icon;
  final void Function(
    UiAction<TContext> action,
    Object error,
    StackTrace stackTrace,
  )? onActionError;

  @override
  Widget build(BuildContext context) {
    final availableActions = actions
        .where(
          (action) =>
              action.placement == placement && action.isVisible(contextValue),
        )
        .toList(growable: false);

    return PopupMenuButton<UiAction<TContext>>(
      tooltip: tooltip,
      icon: Icon(icon),
      itemBuilder: (context) => [
        for (final action in availableActions)
          PopupMenuItem<UiAction<TContext>>(
            value: action,
            enabled: action.isEnabled(contextValue),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(action.icon, size: 18),
              title: Text(action.label),
            ),
          ),
      ],
      onSelected: (action) => unawaited(_runAction(action)),
    );
  }

  Future<void> _runAction(UiAction<TContext> action) async {
    try {
      await action.run(contextValue);
    } catch (error, stackTrace) {
      onActionError?.call(action, error, stackTrace);
    }
  }
}
