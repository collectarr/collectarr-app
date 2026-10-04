import 'package:collectarr_app/features/library/schema/library_field_spec_control_builder.dart';
import 'package:collectarr_app/features/library/schema/library_form_schema.dart';
import 'package:collectarr_app/features/library/schema/library_schema_text_controller_store.dart';

final class LibraryFormValidationIssue {
  const LibraryFormValidationIssue(this.message, {this.fieldId});

  final String message;
  final String? fieldId;
}

LibraryFormValidationIssue? firstLibraryFormValidationIssue<TDraft>({
  required LibraryFormSchema<TDraft> schema,
  required TDraft draft,
  required LibrarySchemaTextControllerStore controllers,
  bool validateSchema = true,
}) {
  if (validateSchema) {
    final message = schema.validate?.call(draft);
    if (message != null) return LibraryFormValidationIssue(message);
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
        return LibraryFormValidationIssue(message, fieldId: field.id);
      }
    }
  }
  return null;
}
