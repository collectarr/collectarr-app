import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';

enum LibraryEditFormSection { details, artwork, description }

final class LibraryEditFormFieldSpec {
  const LibraryEditFormFieldSpec({
    required this.id,
    required this.section,
    required this.controller,
    required this.label,
    this.required = false,
    this.maxLines = 1,
    this.visible = true,
  });

  /// Opaque stable identity used by the shared renderer for widget keys.
  final Object id;
  final LibraryEditFormSection section;
  final TextEditingController controller;
  final String label;
  final bool required;
  final int maxLines;
  final bool visible;
}

final class LibraryEditFormSchema {
  const LibraryEditFormSchema({
    this.fields = const [],
    this.sectionTitles = const {},
  });

  static const empty = LibraryEditFormSchema();

  final List<LibraryEditFormFieldSpec> fields;
  final Map<LibraryEditFormSection, String> sectionTitles;

  List<LibraryEditFormFieldSpec> fieldsFor(LibraryEditFormSection section) =>
      List<LibraryEditFormFieldSpec>.unmodifiable(fields.where(
        (field) => field.section == section && field.visible,
      ));

  String titleFor(LibraryEditFormSection section) =>
      sectionTitles[section] ?? 'Fields';
}

/// Opaque controller registry shared by the kind edit session and renderer.
///
/// Field identities and controller creation stay with the kind-owned session.
final class LibraryEditFormFields {
  LibraryEditFormFields(this._textControllers);

  final TextControllerGroup _textControllers;
  final Map<Object, TextEditingController> _controllers = {};

  TextEditingController create(Object id, {String initialValue = ''}) {
    if (_controllers.containsKey(id)) {
      throw StateError(
          'An edit field with this identity is already registered.');
    }
    final controller = _textControllers.create(text: initialValue);
    _controllers[id] = controller;
    return controller;
  }

  TextEditingController controller(Object id) {
    final controller = _controllers[id];
    if (controller == null) {
      throw StateError('The requested edit field is not registered.');
    }
    return controller;
  }
}
