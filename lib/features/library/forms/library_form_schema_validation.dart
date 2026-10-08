import 'package:collectarr_app/features/library/forms/library_field_spec_control_builder.dart';
import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import 'package:collectarr_app/features/library/forms/library_schema_text_controller_store.dart';

final class LibraryFormValidationProblem {
  const LibraryFormValidationProblem(this.message, {this.fieldId});

  final String message;
  final String? fieldId;
}

/// A validation callback contributed by one stable form tab.
final class LibraryFormValidationTab {
  const LibraryFormValidationTab({
    required this.id,
    required this.index,
    required this.validate,
  });

  final String id;
  final int index;
  final LibraryFormValidationProblem? Function() validate;
}

/// Identifies the first invalid tab in the order supplied by the host.
final class LibraryFormTabValidationFailure {
  const LibraryFormTabValidationFailure({
    required this.tabId,
    required this.tabIndex,
    required this.problem,
  });

  final String tabId;
  final int tabIndex;
  final LibraryFormValidationProblem problem;
}

LibraryFormTabValidationFailure? firstLibraryFormTabValidationFailure(
  Iterable<LibraryFormValidationTab> tabs,
) {
  for (final tab in tabs) {
    final problem = tab.validate();
    if (problem != null) {
      return LibraryFormTabValidationFailure(
        tabId: tab.id,
        tabIndex: tab.index,
        problem: problem,
      );
    }
  }
  return null;
}

LibraryFormValidationProblem? firstLibraryFormValidationProblem<TDraft>({
  required LibraryFormSchema<TDraft> schema,
  required TDraft draft,
  required LibrarySchemaTextControllerStore controllers,
  bool validateSchema = true,
}) {
  if (validateSchema) {
    final message = schema.validate?.call(draft);
    if (message != null) return LibraryFormValidationProblem(message);
  }

  for (final section in schema.sections) {
    if (!section.isVisible(draft)) continue;
    for (final field in section.fields) {
      if (!field.isVisible(draft)) continue;
      final message = field is LibraryNumberFieldSpec<TDraft>
          ? libraryNumberFieldError(
              field,
              controllers
                  .controllerFor(
                    field.id,
                    field.value(draft)?.toString() ?? '',
                  )
                  .text,
              draft,
            )
          : field.validate(draft);
      if (message != null) {
        return LibraryFormValidationProblem(message, fieldId: field.id);
      }
    }
  }
  return null;
}
