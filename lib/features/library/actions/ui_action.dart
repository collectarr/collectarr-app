import 'dart:async';

import 'package:flutter/material.dart';

/// Where a typed action is offered by a generic host.
///
/// This enum describes presentation placement only. It deliberately contains
/// no domain-specific action categories.
enum UiActionPlacement {
  toolbar,
  itemMenu,
  bulkMenu,
  secondary,
}

/// Structural contract for actions contributed by a concrete kind.
///
/// Generic UI may inspect presentation state and invoke [run], but it must
/// not inspect the context's semantic fields. The concrete [TContext] and the
/// action implementation belong to the owning kind.
abstract interface class UiAction<TContext> {
  String get id;
  String get label;
  IconData get icon;
  UiActionPlacement get placement;

  bool isVisible(TContext context);

  bool isEnabled(TContext context);

  FutureOr<void> run(TContext context);
}
