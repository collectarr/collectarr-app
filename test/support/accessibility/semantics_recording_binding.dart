import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';

/// Checks serialized updates against the retained tree, rather than only
/// inspecting the final Dart tree after all route animations have settled.
class SemanticsRecordingTestBinding extends AutomatedTestWidgetsFlutterBinding {
  final nodes = <int, List<int>>{};
  final orphans = <int>[];

  @override
  ui.SemanticsUpdateBuilder createSemanticsUpdateBuilder() =>
      _RecordingBuilder(this);

  void check(Set<int> updated) {
    final reachable = <int>{};
    void visit(int id) {
      if (!reachable.add(id)) return;
      for (final child in nodes[id] ?? const <int>[]) {
        visit(child);
      }
    }

    visit(0);
    orphans.addAll(updated.difference(reachable));
    nodes.removeWhere((id, _) => !reachable.contains(id));
  }
}

class _RecordingBuilder implements ui.SemanticsUpdateBuilder {
  _RecordingBuilder(this.binding);
  final SemanticsRecordingTestBinding binding;
  final _delegate = ui.SemanticsUpdateBuilder();
  final _updated = <int>{};

  @override
  dynamic noSuchMethod(Invocation invocation) {
    switch (invocation.memberName) {
      case #updateNode:
        final id = invocation.namedArguments[#id] as int;
        binding.nodes[id] = List<int>.from(
            invocation.namedArguments[#childrenInTraversalOrder] as Iterable);
        _updated.add(id);
        return Function.apply(_delegate.updateNode,
            invocation.positionalArguments, invocation.namedArguments);
      case #updateCustomAction:
        return Function.apply(_delegate.updateCustomAction,
            invocation.positionalArguments, invocation.namedArguments);
      case #build:
        binding.check(_updated);
        return _delegate.build();
      default:
        return super.noSuchMethod(invocation);
    }
  }
}
