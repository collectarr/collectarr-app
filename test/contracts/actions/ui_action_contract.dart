import 'dart:async';

import '../contract_test_helpers.dart';

/// Structural contract for a kind-owned action exposed to generic UI hosts.
///
/// The action context is intentionally generic. A production action contract
/// must not grow fields for a particular kind.
void defineUiActionContract<TAction, TContext>({
  required String name,
  required TAction Function() create,
  required String Function(TAction action) id,
  required String Function(TAction action) label,
  required bool Function(TAction action, TContext context) isVisible,
  required bool Function(TAction action, TContext context) isEnabled,
  required FutureOr<void> Function(TAction action, TContext context) run,
  required TContext Function() createContext,
}) {
  defineAsyncTypedContract<TAction>(
    name: '$name UI action contract',
    create: create,
    check: (action) async {
      final actionId = id(action);
      expectNonEmpty(actionId, '$name action ID must not be empty');
      expectNonEmpty(label(action), '$name action label must not be empty');

      final context = createContext();
      final visible = isVisible(action, context);
      final enabled = isEnabled(action, context);
      expectContract(
        visible || !visible,
        '$name action visibility must be evaluable without throwing',
      );
      expectContract(
        enabled || !enabled,
        '$name action enabled state must be evaluable without throwing',
      );

      if (visible && enabled) {
        await run(action, context);
      }
    },
  );
}
