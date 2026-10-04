import 'package:flutter/widgets.dart';

/// Owns stable text controllers for schema-rendered fields.
///
/// Renderers provide stable field IDs and initial values. This store keeps raw
/// user input across rebuilds and releases all controllers with the renderer.
final class LibrarySchemaTextControllerStore {
  final Map<String, TextEditingController> _controllers = {};

  TextEditingController controllerFor(String fieldId, String initialValue) =>
      _controllers.putIfAbsent(
        fieldId,
        () => TextEditingController(text: initialValue),
      );

  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }
}

/// Shares schema input controllers across every tab in one Add/Edit dialog.
///
/// The dialog scaffold owns the store and disposes it when the form closes.
/// Standalone renderers can omit this scope and keep their local store.
final class LibrarySchemaTextControllerScope extends InheritedWidget {
  const LibrarySchemaTextControllerScope({
    super.key,
    required this.store,
    required super.child,
  });

  final LibrarySchemaTextControllerStore store;

  static LibrarySchemaTextControllerStore? maybeOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<
              LibrarySchemaTextControllerScope>()
          ?.store;

  @override
  bool updateShouldNotify(LibrarySchemaTextControllerScope oldWidget) =>
      !identical(store, oldWidget.store);
}

/// Provides stable field focus nodes across schema tabs in one dialog.
final class LibrarySchemaFieldFocusScope extends InheritedWidget {
  const LibrarySchemaFieldFocusScope({
    super.key,
    required this.tabId,
    required this.nodes,
    required super.child,
  });

  final String tabId;
  final Map<String, FocusNode> nodes;

  static FocusNode? nodeFor(BuildContext context, String fieldId) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<LibrarySchemaFieldFocusScope>();
    if (scope == null) return null;
    return scope.nodes.putIfAbsent(
      '${scope.tabId}::$fieldId',
      FocusNode.new,
    );
  }

  @override
  bool updateShouldNotify(LibrarySchemaFieldFocusScope oldWidget) =>
      tabId != oldWidget.tabId || !identical(nodes, oldWidget.nodes);
}
