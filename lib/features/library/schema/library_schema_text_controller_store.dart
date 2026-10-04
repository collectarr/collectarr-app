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
